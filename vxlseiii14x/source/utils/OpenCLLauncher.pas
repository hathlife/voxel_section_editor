unit OpenCLLauncher;

interface

uses Windows, SysUtils, dglOpenGL, CL, cl_platform, oclUtils, BasicDataTypes, Debug;

type
   TOpenCLLauncher = class
      private
         FCurrent_indevice: Integer;
         FContext: PCL_context;
         FSource: PAnsiChar;
         FProgram_: PCL_program;
         FCommandQueue: PCL_command_queue;
         FIsLoaded: boolean;
         FKernel: array of PCL_kernel;
         FCurrentKernel: integer;
         FDebugFile: TDebugFile;
         FHasDebugFile: boolean;
         FProgramName: string;
         FKernelName: AString;
         FMem: array of PCL_mem;
         FFlags: array of boolean;
         // Constructors and Destructors
         procedure InitializeClass;
         procedure InitializeContext;
         function GetDriver: AnsiString;
         procedure ClearContext;
         // I/O
         procedure ClearProgram;
         // Sets
         procedure SetCurrentKernel(_value: integer);
         // Execute
         function VerifyKernelParameters(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; var _OutputData: APointer; const _OutputSize,_OutputUnitSize: AUint32; const _OutputSource: aint32; _NumDimensions: TCL_int; const _GlobalWorkSize,_LocalWorkSize: Auint32): boolean;
         // Misc
         procedure WriteDebug(const _Text: string);
      public
         // Constructors and Destructors
         constructor Create; overload;
         constructor Create(const _FileName, _KernelName: string); overload;
         destructor Destroy; override;
         // I/O
         procedure LoadProgram(const _FileName, _KernelName: string); overload;
         procedure LoadProgram(const _FileName: string; const _KernelNames: AString); overload;
         procedure LoadDataIntoGPU(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; var _OutputData: APointer; const _OutputSource: aint32);
         procedure SaveDataFromGPU(const _InputData: APointer; const _InputSize: Auint32; var _OutputData: APointer; const _OutputSize,_OutputUnitSize: AUint32; const _OutputSource: aint32);
         // Execute
         procedure RunKernel(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; var _OutputData: APointer; const _OutputSize,_OutputUnitSize: AUint32; const _OutputSource: aint32; _NumDimensions: TCL_int; const _GlobalWorkSize,_LocalWorkSize: Auint32); overload;
         procedure RunKernel(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; const _OutputSource: aint32; _NumDimensions: TCL_int; const _GlobalWorkSize,_LocalWorkSize: Auint32); overload;
         procedure RunKernelSafe(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; var _OutputData: APointer; const _OutputSize,_OutputUnitSize: AUint32; const _OutputSource: aint32; _NumDimensions: TCL_int; const _GlobalWorkSize,_LocalWorkSize: Auint32);
         // Properties
         property CurrentKernel: integer read FCurrentKernel write SetCurrentKernel;
   end;

implementation

function TOpenCLLauncher.GetDriver: AnsiString;
const
   nvd: AnsiString = 'NVIDIA Corporation';
   ati_amdd: AnsiString = 'ATI Technologies Inc.';

   NV_DRIVER = 'OpenCL.dll';
   ATI_AMD_DRIVER = 'atiocl.dll';//'OpenCL.dll'
var
   SysDir: array [0..(MAX_PATH - 1)] of AnsiChar;
   l: Cardinal;
begin
   Result := '';
   l := MAX_PATH;
   GetSystemDirectoryA(@SysDir[0], l);

   if FileExists(String(String(SysDir) + '\' + ATI_AMD_DRIVER)) then
      Result := ATI_AMD_DRIVER
   else
      Result := NV_DRIVER;
end;

constructor TOpenCLLauncher.Create;
begin
   InitializeClass;
end;

constructor TOpenCLLauncher.Create(const _FileName, _KernelName: string);
begin
   InitializeClass;
   LoadProgram(_FileName, _KernelName);
end;

destructor TOpenCLLauncher.Destroy;
begin
   ClearContext();
   inherited Destroy;
end;

procedure TOpenCLLauncher.InitializeClass;
begin
   FIsLoaded := false;
   FHasDebugFile := false;
   InitializeContext;
end;

procedure TOpenCLLauncher.InitializeContext;
var
   CPS: array [0..2] of PCL_context_properties;
   Status: TCL_int;
   Current_device: PPCL_device_id;
   Platform_: PCL_platform_id;
   Dev_num: TCL_int;
begin
   CPS[0] :=  pcl_context_properties(cl_context_platform);
   CPS[1] := nil;
   CPS[2] := nil;
   if not InitOpenCL(GetDriver) then Exit;

   Status := clGetPlatformIDs(1, @Platform_, nil);
   if Status <> CL_SUCCESS then 
   begin
      WriteDebug('clGetPlatformIDs: ' + GetString(Status));
      Exit;
   end;

   CPS[1] := pcl_context_properties(Platform_);
   FContext := clCreateContextFromType(@CPS, CL_DEVICE_TYPE_GPU, nil, nil, @Status);
   if Status <> CL_SUCCESS then
   begin
      WriteDebug('clCreateContextFromType: ' + GetString(Status));
      Exit;
   end;

   Status := clGetContextInfo(FContext, CL_CONTEXT_DEVICES, 0, nil, @Dev_num);
   if Status <> CL_SUCCESS then
   begin
      WriteDebug('clGetContextInfo: ' + GetString(Status));
      Exit;
   end;

   if Dev_num <= 0 then
   begin
      WriteDebug('Invalid Dev_num obtained from clGetContextInfo.');
      Exit;
   end;

   Current_device := oclGetDev(FContext, 0);
   FCurrent_indevice := Integer(current_device^);
//  Status := clGetDeviceInfo(PCL_device_id(Current_indevice), CL_DEVICE_NAME, SizeOf(FBuf), @FBuf, nil);
//   if Status <> CL_SUCCESS then
//   begin
//      WriteDebug(GetString(Status));
//      Exit;
//   end;

   FCommandQueue := clCreateCommandQueue(FContext, PCL_device_id(FCurrent_indevice), 0, @Status);
   if Status <> CL_SUCCESS then
   begin
      WriteDebug('clCreateCommandQueue: ' + GetString(Status));
      Exit;
   end;
end;

procedure TOpenCLLauncher.ClearContext;
begin
   if FisLoaded then
   begin
      ClearProgram();
   end;
   clReleaseCommandQueue(FCommandQueue);
   clReleaseContext(FContext);
end;

// I/O
procedure TOpenCLLauncher.LoadProgram(const _FileName, _KernelName: string);
var
   program_length: TSize_t;
   Status: TCL_int;
   Log: AnsiString;
   LogSize: Integer;
begin
   if FIsLoaded then
   begin
      ClearProgram();
   end;

   FProgramName := copy(_Filename,1,Length(_Filename));
   FSource := oclLoadProgSource(_Filename, '', @program_length);

   FProgram_ := clCreateProgramWithSource(FContext, 1, @FSource, @program_length, @Status);
   if Status <> CL_SUCCESS then
   begin
      WriteDebug('clCreateProgramWithSource[' + _Filename + ']: ' + GetString(Status));
      Exit;
   end;

   Status := clBuildProgram(FProgram_, 0, nil, nil, nil, nil);
   if Status <> CL_SUCCESS then
   begin
      WriteDebug(GetString(Status));
      Status := clGetProgramBuildInfo(FProgram_, PCL_device_id(FCurrent_indevice), CL_PROGRAM_BUILD_LOG, 0, nil, @LogSize);
      if Status <> CL_SUCCESS then
      begin
         WriteDebug('clBuildProgram[' + _Filename + ']: ' + GetString(Status));
         Exit;
      end;

      SetLength(Log, LogSize);
      Status := clGetProgramBuildInfo(FProgram_, PCL_device_id(FCurrent_indevice), CL_PROGRAM_BUILD_LOG, LogSize, PAnsiChar(Log), nil);
      if Status <> CL_SUCCESS then
      begin
         WriteDebug('clGetProgramBuildInfo[' + _Filename + ']: ' + GetString(Status));
         Exit;
      end;
      WriteDebug(Log);
   end;

   SetLength(FKernel, 1);
   SetLength(FKernelName, 1);
   FKernelName[0] := copy(_KernelName,1,Length(_KernelName));
   FKernel[0] := clCreateKernel(FProgram_, PAnsiChar(_KernelName), @Status);
   if Status <> CL_SUCCESS then
   begin
      SetLength(FKernel, 0);
      FKernelName[0] := '';
      SetLength(FKernelName, 0);
      clReleaseProgram(FProgram_);
      WriteDebug('clCreateKernel[' + _Filename + '::' + _KernelName + ']: ' + GetString(Status));
      Exit;
   end;
   FCurrentKernel := 0;
   FIsLoaded := true;
end;

procedure TOpenCLLauncher.LoadProgram(const _FileName: string; const _KernelNames: AString);
var
   program_length: TSize_t;
   Status: TCL_int;
   Log: AnsiString;
   i, j, LogSize: Integer;
begin
   if FIsLoaded then
   begin
      ClearProgram();
   end;

   FProgramName := copy(_Filename,1,Length(_Filename));
   FSource := oclLoadProgSource(_Filename, '', @program_length);

   FProgram_ := clCreateProgramWithSource(FContext, 1, @FSource, @program_length, @Status);
   if Status <> CL_SUCCESS then
   begin
      WriteDebug('clCreateProgramWithSource[' + _Filename + ']: ' + GetString(Status));
      Exit;
   end;

   Status := clBuildProgram(FProgram_, 0, nil, nil, nil, nil);
   if Status <> CL_SUCCESS then
   begin
      WriteDebug(GetString(Status));
      Status := clGetProgramBuildInfo(FProgram_, PCL_device_id(FCurrent_indevice), CL_PROGRAM_BUILD_LOG, 0, nil, @LogSize);
      if Status <> CL_SUCCESS then
      begin
         WriteDebug('clBuildProgram[' + _Filename + ']: ' + GetString(Status));
         Exit;
      end;

      SetLength(Log, LogSize);
      Status := clGetProgramBuildInfo(FProgram_, PCL_device_id(FCurrent_indevice), CL_PROGRAM_BUILD_LOG, LogSize, PAnsiChar(Log), nil);
      if Status <> CL_SUCCESS then
      begin
         WriteDebug('clGetProgramBuildInfo[' + _Filename + ']: ' + GetString(Status));
         Exit;
      end;
      WriteDebug(Log);
   end;

   SetLength(FKernel, High(_KernelNames) + 1);
   SetLength(FKernelName, High(_KernelNames) + 1);
   for i := Low(FKernel) to High(FKernel) do
   begin
      FKernelName[i] := copy(_KernelNames[i],1,Length(_KernelNames[i]));
      FKernel[i] := clCreateKernel(FProgram_, PAnsiChar(_KernelNames[i]), @Status);
      if Status <> CL_SUCCESS then
      begin
         j := i - 1;
         while j >= 0 do
         begin
            clReleaseKernel(FKernel[j]);
            FKernelName[j] := '';
            dec(j);
         end;
         FKernelName[i] := '';
         SetLength(FKernel, 0);
         SetLength(FKernelName, 0);
         clReleaseProgram(FProgram_);
         WriteDebug('clCreateKernel[' + _Filename + '::' + _KernelNames[i] + ']: ' + GetString(Status));
         Exit;
      end;
   end;
   FCurrentKernel := 0;
   FIsLoaded := true;
end;

procedure TOpenCLLauncher.ClearProgram;
var
   i: integer;
begin
   for i := Low(FKernel) to High(FKernel) do
   begin
      clReleaseKernel(FKernel[i]);
      FKernelName[i] := '';
   end;
   SetLength(FKernel, 0);
   SetLength(FKernelName, 0);
   clReleaseProgram(FProgram_);
   FisLoaded := false;
end;

procedure TOpenCLLauncher.SetCurrentKernel(_value: integer);
begin
   if (_Value >= Low(FKernel)) and (_Value <= High(FKernel)) then
   begin
      FCurrentKernel := _Value;
   end;
end;

procedure TOpenCLLauncher.LoadDataIntoGPU(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; var _OutputData: APointer; const _OutputSource: aint32);
var
   Status: TCL_int;
   i : integer;
begin
   if not FIsLoaded then exit;

   SetLength(FMem,High(_InputData)+1);
   SetLength(FFlags,High(_InputData)+1);
   // Determine if the flags used for each variable
   for i := Low(FFlags) to High(FFlags) do
   begin
      FFlags[i] := false; // default to mem_copy_host_ptr.
   end;
   for i := Low(_OutputData) to High(_OutputData) do
   begin
      if _OutputSource[i] <> -1 then
      begin
         FFlags[_OutputSource[i]] := true;
      end;
   end;

   // Now, write parameters to GPU memory.
   for i := Low(_InputData) to High(_InputData) do
   begin
      if (_InputSize[i] > 1) or (FFlags[i]) then
      begin
         if FFlags[i] then
         begin
            FMem[i] := clCreateBuffer(FContext, CL_MEM_READ_WRITE or CL_MEM_COPY_HOST_PTR, _InputSize[i] * _InputUnitSize[i], _InputData[i], @Status);
         end
         else
         begin
            FMem[i] := clCreateBuffer(FContext, CL_MEM_COPY_HOST_PTR, _InputSize[i] * _InputUnitSize[i], _InputData[i], @Status);
         end;
         if Status <> CL_SUCCESS then
            WriteDebug('clCreateBuffer[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
         Status := clSetKernelArg(FKernel[FCurrentKernel], i, SizeOf(pcl_mem), @FMem[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clSetKernelArg[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end
      else
      begin
         Status := clSetKernelArg(FKernel[FCurrentKernel], i, _InputUnitSize[i], _InputData[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clSetKernelArg[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
end;

procedure TOpenCLLauncher.SaveDataFromGPU(const _InputData: APointer; const _InputSize: Auint32; var _OutputData: APointer; const _OutputSize,_OutputUnitSize: AUint32; const _OutputSource: aint32);
var
   Status: TCL_int;
   i : integer;
begin
   if not FIsLoaded then exit;

   for i := Low(_OutputData) to High(_OutputData) do
   begin
      if _OutputSource[i] <> -1 then
      begin
         Status := clEnqueueReadBuffer(FCommandQueue, FMem[_OutputSource[i]], CL_TRUE, 0, _OutputSize[i] * _OutputUnitSize[i], _OutputData[i], 0, nil, nil);
         if Status <> CL_SUCCESS then
            WriteDebug('clEnqueueReadBuffer (' + IntToStr(i) + ')[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
   for i := Low(_InputData) to High(_InputData) do
   begin
      if (_InputSize[i] > 1) or (FFlags[i]) then
      begin
         Status := clReleaseMemObject(FMem[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clReleaseMemObject (' + IntToStr(i) + ')[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
end;


// Execute
procedure TOpenCLLauncher.RunKernel(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; var _OutputData: APointer; const _OutputSize,_OutputUnitSize: AUint32; const _OutputSource: aint32; _NumDimensions: TCL_int; const _GlobalWorkSize,_LocalWorkSize: Auint32);
var
   Status: TCL_int;
   i : integer;
begin
   if not FIsLoaded then exit;

   SetLength(FMem,High(_InputData)+1);
   SetLength(FFlags,High(_InputData)+1);
   // Determine if the flags used for each variable
   for i := Low(FFlags) to High(FFlags) do
   begin
      FFlags[i] := false; // default to mem_copy_host_ptr.
   end;
   for i := Low(_OutputData) to High(_OutputData) do
   begin
      if _OutputSource[i] <> -1 then
      begin
         FFlags[_OutputSource[i]] := true;
      end;
   end;

   // Now, write parameters to GPU memory.
   for i := Low(_InputData) to High(_InputData) do
   begin
      if (_InputSize[i] > 1) or (FFlags[i]) then
      begin
         if FFlags[i] then
         begin
            FMem[i] := clCreateBuffer(FContext, CL_MEM_READ_WRITE or CL_MEM_COPY_HOST_PTR, _InputSize[i] * _InputUnitSize[i], _InputData[i], @Status);
         end
         else
         begin
            FMem[i] := clCreateBuffer(FContext, CL_MEM_COPY_HOST_PTR, _InputSize[i] * _InputUnitSize[i], _InputData[i], @Status);
         end;
         if Status <> CL_SUCCESS then
            WriteDebug('clCreateBuffer[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
         Status := clSetKernelArg(FKernel[FCurrentKernel], i, SizeOf(pcl_mem), @FMem[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clSetKernelArg[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end
      else
      begin
         Status := clSetKernelArg(FKernel[FCurrentKernel], i, _InputUnitSize[i], _InputData[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clSetKernelArg[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
   if (_GlobalWorkSize <> nil) and (_LocalWorkSize <> nil) then
   begin
      Status := clEnqueueNDRangeKernel(FCommandQueue, FKernel[FCurrentKernel], _NumDimensions, nil, @(_GlobalWorkSize[0]), @_LocalWorkSize, 0, nil, nil);
      if Status <> CL_SUCCESS then
         WriteDebug('clEnqueueNDRangeKernel[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
   end
   else if (_GlobalWorkSize <> nil) then
   begin
      Status := clEnqueueNDRangeKernel(FCommandQueue, FKernel[FCurrentKernel], _NumDimensions, nil, @(_GlobalWorkSize[0]), nil, 0, nil, nil);
      if Status <> CL_SUCCESS then
         WriteDebug('clEnqueueNDRangeKernel[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
   end;
   Status:= clFinish(FCommandQueue);
   if Status <> CL_SUCCESS then
      WriteDebug('clFinish[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
   for i := Low(_OutputData) to High(_OutputData) do
   begin
      if _OutputSource[i] <> -1 then
      begin
         Status := clEnqueueReadBuffer(FCommandQueue, FMem[_OutputSource[i]], CL_TRUE, 0, _OutputSize[i] * _OutputUnitSize[i], _OutputData[i], 0, nil, nil);
         if Status <> CL_SUCCESS then
            WriteDebug('clEnqueueReadBuffer (' + IntToStr(i) + ')[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
   for i := Low(_InputData) to High(_InputData) do
   begin
      if (_InputSize[i] > 1) or (FFlags[i]) then
      begin
         Status := clReleaseMemObject(FMem[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clReleaseMemObject (' + IntToStr(i) + ')[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
end;

procedure TOpenCLLauncher.RunKernel(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; const _OutputSource: aint32; _NumDimensions: TCL_int; const _GlobalWorkSize,_LocalWorkSize: Auint32);
var
   Status: TCL_int;
   i : integer;
begin
   if not FIsLoaded then exit;

   SetLength(FMem,High(_InputData)+1);
   SetLength(FFlags,High(_InputData)+1);
   // Determine if the flags used for each variable
   for i := Low(FFlags) to High(FFlags) do
   begin
      FFlags[i] := false; // default to mem_copy_host_ptr.
   end;
   for i := Low(_OutputSource) to High(_OutputSource) do
   begin
      if _OutputSource[i] <> -1 then
      begin
         FFlags[_OutputSource[i]] := true;
      end;
   end;

   // Now, write parameters to GPU memory.
   for i := Low(_InputData) to High(_InputData) do
   begin
      if (_InputSize[i] > 1) or (FFlags[i]) then
      begin
         if FFlags[i] then
         begin
            FMem[i] := clCreateBuffer(FContext, CL_MEM_READ_WRITE or CL_MEM_COPY_HOST_PTR, _InputSize[i] * _InputUnitSize[i], _InputData[i], @Status);
         end
         else
         begin
            FMem[i] := clCreateBuffer(FContext, CL_MEM_COPY_HOST_PTR, _InputSize[i] * _InputUnitSize[i], _InputData[i], @Status);
         end;
         if Status <> CL_SUCCESS then
            WriteDebug('clCreateBuffer[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
         Status := clSetKernelArg(FKernel[FCurrentKernel], i, SizeOf(pcl_mem), @FMem[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clSetKernelArg[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end
      else
      begin
         Status := clSetKernelArg(FKernel[FCurrentKernel], i, _InputUnitSize[i], _InputData[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clSetKernelArg[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
   if (_GlobalWorkSize <> nil) and (_LocalWorkSize <> nil) then
   begin
      Status := clEnqueueNDRangeKernel(FCommandQueue, FKernel[FCurrentKernel], _NumDimensions, nil, @(_GlobalWorkSize[0]), @_LocalWorkSize, 0, nil, nil);
      if Status <> CL_SUCCESS then
         WriteDebug('clEnqueueNDRangeKernel[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
   end
   else if (_GlobalWorkSize <> nil) then
   begin
      Status := clEnqueueNDRangeKernel(FCommandQueue, FKernel[FCurrentKernel], _NumDimensions, nil, @(_GlobalWorkSize[0]), nil, 0, nil, nil);
      if Status <> CL_SUCCESS then
         WriteDebug('clEnqueueNDRangeKernel[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
   end;
   Status:= clFinish(FCommandQueue);
   if Status <> CL_SUCCESS then
      WriteDebug('clFinish[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
   for i := Low(_OutputSource) to High(_OutputSource) do
   begin
      if _OutputSource[i] <> -1 then
      begin
         Status := clEnqueueReadBuffer(FCommandQueue, FMem[_OutputSource[i]], CL_TRUE, 0, _InputSize[_OutputSource[i]] * _InputUnitSize[_OutputSource[i]], _InputData[_OutputSource[i]], 0, nil, nil);
         if Status <> CL_SUCCESS then
            WriteDebug('clEnqueueReadBuffer (' + IntToStr(i) + ')[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
   for i := Low(_InputData) to High(_InputData) do
   begin
      if (_InputSize[i] > 1) or (FFlags[i]) then
      begin
         Status := clReleaseMemObject(FMem[i]);
         if Status <> CL_SUCCESS then
            WriteDebug('clReleaseMemObject (' + IntToStr(i) + ')[' + FProgramName + '::' + FKernelName[FCurrentKernel] + ']: ' + GetString(Status));
      end;
   end;
end;

function TOpenCLLauncher.VerifyKernelParameters(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; var _OutputData: APointer; const _OutputSize,_OutputUnitSize: AUint32; const _OutputSource: aint32; _NumDimensions: TCL_int; const _GlobalWorkSize,_LocalWorkSize: Auint32): boolean;
var
   maxDimension: integer;
begin
   Result := false;
   if FIsLoaded then
   begin
      if (_InputData <> nil) and (_InputSize <> nil) and (_InputUnitSize <> nil) then
      begin
         if (High(_InputData) > -1) then
         begin
            if ((High(_InputData) = High(_InputSize)) and (High(_InputData) = High(_InputUnitSize))) then
            begin
               if (_InputData <> nil) and (_InputSize <> nil) and (_InputUnitSize <> nil) and (_OutputSource <> nil) then
               begin
                  if ((High(_OutputData) = High(_OutputSize)) and (High(_OutputData) = High(_OutputUnitSize)) and (High(_OutputData) = High(_OutputSource))) then
                  begin
                     if _NumDimensions > 0 then
                     begin
                        maxDimension := _NumDimensions - 1;
                        if (maxDimension = High(_GlobalWorkSize)) then
                        begin
                           if _LocalWorkSize <> nil then
                           begin
                              if (maxDimension = High(_LocalWorkSize)) then
                              begin
                                 Result := true;
                              end;
                           end
                           else
                           begin
                              Result := true;
                           end;
                        end;
                     end;
                  end;
               end;
            end;
         end;
      end;
   end;
end;

procedure TOpenCLLauncher.RunKernelSafe(const _InputData: APointer; const _InputSize,_InputUnitSize: Auint32; var _OutputData: APointer; const _OutputSize,_OutputUnitSize: AUint32; const _OutputSource: aint32; _NumDimensions: TCL_int; const _GlobalWorkSize,_LocalWorkSize: Auint32);
begin
   if VerifyKernelParameters(_InputData,_InputSize,_InputUnitSize,_OutputData,_OutputSize,_OutputUnitSize,_OutputSource,_NumDimensions,_GlobalWorkSize,_LocalWorkSize) then
   begin
      RunKernel(_InputData,_InputSize,_InputUnitSize,_OutputData,_OutputSize,_OutputUnitSize,_OutputSource,_NumDimensions,_GlobalWorkSize,_LocalWorkSize);
   end;
end;

// Misc
procedure TOpenCLLauncher.WriteDebug(const _Text: string);
begin
   if not FHasDebugFile then
   begin
      FHasDebugFile := true;
      FDebugFile := TDebugFile.Create(ExtractFilePath(ParamStr(0)) + 'ocldebug.txt');
   end;
   FDebugFile.Add(_Text);
end;

end.

