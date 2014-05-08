unit MultiVector;

interface

uses BasicDataTypes, Math, GAConstants, GABasicFunctions, Debug, SysUtils;

type
   TMultiVector = class
   private
      FData: array of Single;
      FDimension: Cardinal;
      FSize: Cardinal;
   protected
      // Gets
      function GetDimension: Cardinal;
      function GetData(_x: Cardinal): single;
      function QuickGetData(_x: Cardinal): single;
      function GetMaxElement: Cardinal; overload;
      // Sets
      procedure SetDimension(_Dimension: cardinal);
      procedure SetData(_x: Cardinal; _Value: single);
      procedure QuickSetData(_x: Cardinal; _Value: single);
   public
      // Constructors and Destructors
      constructor Create(_Dimension: integer); overload;
      constructor Create(const _Source: TMultiVector); overload;
      destructor Destroy; override;
      procedure ClearValues;
      // Gets
      function GetTheFirstNonZeroBitmap: cardinal;
      function GetTheNextNonZeroBitmap(_Current: cardinal): cardinal;
      function GetMaxElementForGrade(_MaxGrade: cardinal): Cardinal; overload;
      // Clone/Copy/Assign
      procedure Assign(const _Source: TMultiVector);
      // Debug
      procedure Debug(var _DebugFile: TDebugFile); overload;
      procedure Debug(var _DebugFile: TDebugFile; const _VectorName: string); overload;
      // Properties
      property Dimension: cardinal read GetDimension write SetDimension;
      property MaxElement: cardinal read GetMaxElement;
      property Data[_x:Cardinal]:single read GetData write SetData;
      property UnsafeData[_x:Cardinal]:single read QuickGetData write QuickSetData;
   end;

implementation

// Constructors and Destructors
constructor TMultiVector.Create(_Dimension: Integer);
begin
   FDimension := 0;
   Dimension := _Dimension; // SetDimension(_Dimension);
end;

constructor TMultiVector.Create(const _Source: TMultiVector);
begin
   FDimension := 0;
   Assign(_Source);
end;

destructor TMultiVector.Destroy;
begin
   SetLength(FData,0);
   inherited Destroy;
end;

procedure TMultiVector.ClearValues;
var
   i: integer;
begin
   for i := 0 to High(FData) do
   begin
      FData[i] := 0;
   end;   
end;

// Gets
function TMultiVector.GetDimension: cardinal;
begin
   Result := FDimension;
end;

function TMultiVector.GetMaxElement: cardinal;
begin
   Result := FSize - 1;
end;

function TMultiVector.GetMaxElementForGrade(_MaxGrade: cardinal): Cardinal;
begin
   if _MaxGrade < FDimension then
   begin
      Result := (1 shl _MaxGrade) - 1;
   end
   else
   begin
      Result := FSize - 1;
   end;
end;


function TMultiVector.GetData(_x: Cardinal): single;
begin
   if (_x < FSize) then
   begin
      Result := FData[_x];
   end
   else
   begin
      Result := 0;
   end;
end;

function TMultiVector.QuickGetData(_x: Cardinal): single;
begin
   Result := FData[_x];
end;

function TMultiVector.GetTheFirstNonZeroBitmap: cardinal;
begin
   Result := 0;
   while (Result < FSize) do
   begin
      if (UnsafeData[Result] <> 0) then
      begin
         exit;
      end;
      inc(Result);
   end;
   Result := C_INFINITY;
end;

function TMultiVector.GetTheNextNonZeroBitmap(_Current: Cardinal): cardinal;
begin
   Result := _Current + 1;
   while (Result < FSize) do
   begin
      if (UnsafeData[Result] <> 0) then
      begin
         exit;
      end;
      inc(Result);
   end;
   Result := C_INFINITY;
end;


// Sets
procedure TMultiVector.SetDimension(_Dimension: cardinal);
var
   NewSize,i : cardinal;
begin
   if FDimension > 0 then
   begin
      NewSize := 1 shl _Dimension;
      SetLength(FData,NewSize);
      for i := Min(FSize,NewSize) to High(FData) do
      begin
         FData[i] := 0;
      end;
      FDimension := _Dimension;
      FSize := NewSize;
   end
   else
   begin
      FDimension := _Dimension;
      FSize := 1 shl _Dimension;
      SetLength(FData,FSize);
      for i := 0 to FSize - 1 do
      begin
         FData[i] := 0;
      end;
   end;
end;

procedure TMultiVector.SetData(_x: Cardinal; _Value: single);
begin
   if (_x < FSize) then
   begin
      FData[_x] := _Value;
   end;
end;

procedure TMultiVector.QuickSetData(_x: Cardinal; _Value: single);
begin
   FData[_x] := _Value;
end;

// Clone/Copy/Assign
procedure TMultiVector.Assign(const _Source: TMultiVector);
var
   i : cardinal;
begin
   Dimension := _Source.Dimension;
   for i := 0 to FSize - 1 do
   begin
      QuickSetData(i,_Source.QuickGetData(i));
   end;
end;

// Debug
procedure TMultiVector.Debug(var _DebugFile: TDebugFile);
begin
   Debug(_DebugFile,'MultiVector');
end;

procedure TMultiVector.Debug(var _DebugFile: TDebugFile; const _VectorName: string);
var
   i,countElem,countBitmap,bitmap,numBase : cardinal;
   temp: string;
begin
   temp := _VectorName + ' contents: ';
   countElem := 0;
   for i := 0 to MaxElement do
   begin
      if UnsafeData[i] <> 0 then
      begin
         if countElem <> 0 then
         begin
            temp := temp + ' + ';
         end;
         // Write value.
         temp := temp + FloatToStr(UnsafeData[i]);
         // Write bases.
         countBitmap := 0;
         numBase := 1;
         bitmap := 1;
         while i >= bitmap do
         begin
            if (i and bitmap) <> 0 then
            begin
               if countBitmap = 0 then
               begin
                  temp := temp + ' e' + IntToStr(NumBase);
               end
               else
               begin
                  temp := temp + '^e' + IntToStr(NumBase);
               end;
               inc(countBitmap);
            end;
            bitmap := bitmap shl 1;
            inc(numBase);
         end;
          inc(countElem);
      end;
   end;
   if countElem = 0 then
   begin
      temp := temp + '0';
   end;
   _DebugFile.Add(temp);
end;

end.
