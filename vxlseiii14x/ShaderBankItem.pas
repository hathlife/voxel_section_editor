unit ShaderBankItem;

interface

uses BasicFunctions, BasicDataTypes, dglOpenGL, SysUtils, Classes;

type
   TShaderBankItem = class
      private
         Counter: longword;
         IsAuthorized,IsVertexCompiled,IsFragmentCompiled,IsLinked, IsRunning : boolean;
         ProgramID, VertexID, FragmentID : GLUInt;
      public
         // Constructor and Destructor
         constructor Create(const _VertexFilename, _FragmentFilename: string); overload;
         destructor Destroy; override;
         // Gets
         function GetID : GLInt;
         function IsProgramLinked: boolean;
         function IsVertexShaderCompiled: boolean;
         function IsFragmentShaderCompiled: boolean;
         // Sets
         procedure SetAuthorization(_value: boolean);
         // Uses
         procedure UseProgram;
         procedure DeactivateProgram;
         // Counter
         function GetCount : integer;
         procedure IncCounter;
         procedure DecCounter;
   end;
   PShaderBankItem = ^TShaderBankItem;

implementation

// Constructors and Destructors
constructor TShaderBankItem.Create(const _VertexFilename, _FragmentFilename: string);
var
   Stream : TStream;
   PPCharData : PPGLChar;
   PCharData,Log : PAnsiChar;
   CharData : array of ansichar;
   Size : GLInt;
   Compiled : PGLInt;
   Filename: string;
begin
   Counter := 1;
   IsVertexCompiled := false;
   IsFragmentCompiled := false;
   IsLinked := false;
   IsRunning := false;
   IsAuthorized := false;
   VertexID := 0;
   FragmentID := 0;
   ProgramID := 0;
   // Let's load the vertex shader first.
   if FileExists(_VertexFilename) then
   begin
      Stream := TFileStream.Create(_VertexFilename,fmOpenRead);
      Size := Stream.Size;
      SetLength(CharData,Size+1);
      PCharData := Addr(CharData[0]);
      PPCharData := Addr(PCharData);
      Stream.Read(CharData[0],Size);
      CharData[High(CharData)] := #0;
      Stream.Free;
      VertexID := glCreateShader(GL_VERTEX_SHADER);
      glShaderSource(VertexID,1,PPCharData,nil);
      SetLength(CharData,0);
      glCompileShader(VertexID);
      GetMem(Compiled,4);
      glGetShaderiv(VertexID,GL_COMPILE_STATUS,Compiled);
      IsVertexCompiled := Compiled^ <> 0;
      FreeMem(Compiled);
      if not IsVertexCompiled then
      begin
         // If compile fails, generate the log.
         // Note: Here compiled will be the size of the error log
         GetMem(Compiled,4);
         glGetShaderiv(VertexID,GL_INFO_LOG_LENGTH,Compiled);
         if Compiled^ > 0 then
         begin
            Filename := copy(_VertexFilename,1,Length(_VertexFilename)-4) + '_error.log';
            Stream := TFileStream.Create(Filename,fmCreate);
            GetMem(Log,Compiled^);
            glGetShaderInfoLog(VertexID,Compiled^,Size,Log);
            Stream.Write(Log^,Size);
            FreeMem(Log);
            Stream.Free;
         end;
         FreeMem(Compiled);
      end;
   end;
   // Let's load the fragment shader.
   if FileExists(_FragmentFilename) then
   begin
      Stream := TFileStream.Create(_FragmentFilename,fmOpenRead);
      Size := Stream.Size;
      SetLength(CharData,Size+1);
      PCharData := Addr(CharData[0]);
      PPCharData := Addr(PCharData);
      Stream.Read(CharData[0],Size);
      CharData[High(CharData)] := #0;
      Stream.Free;
      FragmentID := glCreateShader(GL_FRAGMENT_SHADER);
      glShaderSource(FragmentID,1,PPCharData,nil);
      SetLength(CharData,0);
      glCompileShader(FragmentID);
      GetMem(Compiled,4);
      glGetShaderiv(FragmentID,GL_COMPILE_STATUS,Compiled);
      IsFragmentCompiled := Compiled^ <> 0;
      FreeMem(Compiled);
      if not IsFragmentCompiled then
      begin
         // If compile fails, generate the log.
         // Note: Here compiled will be the size of the error log
         GetMem(Compiled,4);
         glGetShaderiv(FragmentID,GL_INFO_LOG_LENGTH,Compiled);
         if Compiled^ > 0 then
         begin
            Filename := copy(_FragmentFilename,1,Length(_FragmentFilename)-4) + '_error.log';
            Stream := TFileStream.Create(Filename,fmCreate);
            GetMem(Log,Compiled^);
            glGetShaderInfoLog(FragmentID,Compiled^,Size,Log);
            Stream.Write(Log^,Size);
            FreeMem(Log);
            Stream.Free;
         end;
         FreeMem(Compiled);
      end;
   end;
   // Time to create and link the program.
   if IsFragmentCompiled or isVertexCompiled then
   begin
      ProgramID := glCreateProgram();
      if isVertexCompiled then
         glAttachShader(ProgramID,VertexID);
      if isFragmentCompiled then
         glAttachShader(ProgramID,FragmentID);
      glLinkProgram(ProgramID);
      GetMem(Compiled,4);
      glGetProgramiv(ProgramID,GL_LINK_STATUS,Compiled);
      IsLinked := Compiled^ <> 0;
      IsAuthorized := IsLinked;
      FreeMem(Compiled);
      if not IsLinked then
      begin
         // If compile fails, generate the log.
         // Note: Here compiled will be the size of the error log
         GetMem(Compiled,4);
         glGetProgramiv(ProgramID,GL_INFO_LOG_LENGTH,Compiled);
         if Compiled^ > 0 then
         begin
            if IsFragmentCompiled then
               Filename := IncludeTrailingPathDelimiter(ExtractFileDir(_FragmentFilename)) + 'link_error.log'
            else if IsVertexCompiled then
               Filename := IncludeTrailingPathDelimiter(ExtractFileDir(_VertexFilename)) + 'link_error.log';
            Stream := TFileStream.Create(Filename,fmCreate);
            GetMem(Log,Compiled^);
            glGetProgramInfoLog(ProgramID,Compiled^,Size,Log);
            Stream.Write(Log^,Size);
            FreeMem(Log);
            Stream.Free;
         end;
         FreeMem(Compiled);
      end;
   end;
end;

destructor TShaderBankItem.Destroy;
begin
   DeactivateProgram;
   if IsLinked then
   begin
      if IsVertexCompiled then
      begin
         glDetachShader(ProgramID,VertexID);
      end;
      if IsFragmentCompiled then
      begin
         glDetachShader(ProgramID,FragmentID);
      end;
      glDeleteProgram(ProgramID);
   end;
   if IsVertexCompiled then
   begin
      glDeleteShader(VertexID);
   end;
   if IsFragmentCompiled then
   begin
      glDeleteShader(FragmentID);
   end;

   inherited Destroy;
end;

// Gets
function TShaderBankItem.GetID : GLInt;
begin
   Result := ProgramID;
end;

function TShaderBankItem.IsProgramLinked: boolean;
begin
   Result := IsLinked;
end;

function TShaderBankItem.IsVertexShaderCompiled: boolean;
begin
   Result := IsVertexCompiled;
end;

function TShaderBankItem.IsFragmentShaderCompiled: boolean;
begin
   Result := IsFragmentCompiled;
end;

// Sets
procedure TShaderBankItem.SetAuthorization(_value: boolean);
begin
   isAuthorized := _value;
end;

// Uses
procedure TShaderBankItem.UseProgram;
begin
   if IsLinked and (not IsRunning) and (isAuthorized) then
   begin
      glUseProgram(ProgramID);
      IsRunning := true;
   end;
end;

procedure TShaderBankItem.DeactivateProgram;
begin
   if IsRunning then
   begin
      glUseProgram(0);
      IsRunning := false;
   end;
end;

// Counter
function TShaderBankItem.GetCount : integer;
begin
   Result := Counter;
end;

procedure TShaderBankItem.IncCounter;
begin
   inc(Counter);
end;

procedure TShaderBankItem.DecCounter;
begin
   Dec(Counter);
end;

end.
