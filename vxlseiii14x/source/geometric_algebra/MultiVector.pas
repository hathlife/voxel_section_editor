unit MultiVector;

interface

uses BasicDataTypes, Math, GAConstants, GABasicFunctions;

type
   TMultiVector = class
   private
      FData: PSingle;
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
      // Gets
      function GetTheFirstNonZeroBitmap: cardinal;
      function GetTheNextNonZeroBitmap(_Current: cardinal): cardinal;
      function GetMaxElementForGrade(_MaxGrade: cardinal): Cardinal; overload;
      // Clone/Copy/Assign
      procedure Assign(const _Source: TMultiVector);
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
   FData := nil;
   FDimension := 0;
   Dimension := _Dimension; // SetDimension(_Dimension);
end;

constructor TMultiVector.Create(const _Source: TMultiVector);
begin
   FData := nil;
   FDimension := 0;
   Assign(_Source);
end;

destructor TMultiVector.Destroy;
begin
   FreeMem(FData);
   inherited Destroy;
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
      Result := PSingle(Cardinal(FData)+_x)^;
   end
   else
   begin
      Result := 0;
   end;
end;

function TMultiVector.QuickGetData(_x: Cardinal): single;
begin
   Result := PSingle(Cardinal(FData)+_x)^;
end;

function TMultiVector.GetTheFirstNonZeroBitmap: cardinal;
begin
   Result := 0;
   while (Result < FSize) do
   begin
      if (PSingle(Cardinal(FData)+Result)^ <> 0) then
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
      if (PSingle(Cardinal(FData)+Result)^ <> 0) then
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
   NewData: PSingle;
   NewSize,i : cardinal;
begin
   if FDimension > 0 then
   begin
      NewSize := PowerBase2(_Dimension);
      GetMem(NewData,NewSize);
      for i := 0 to Min(FSize,NewSize) - 1 do
      begin
         PSingle(Cardinal(NewData)+i)^ := PSingle(Cardinal(FData)+i)^;
      end;
      FreeMem(FData);
      FDimension := _Dimension;
      FSize := NewSize;
      FData := NewData;
   end
   else
   begin
      FDimension := _Dimension;
      FSize := PowerBase2(_Dimension);
      GetMem(FData,FSize);
      for i := 0 to FSize - 1 do
      begin
         PSingle(Cardinal(FData)+i)^ := 0;
      end;
   end;
end;

procedure TMultiVector.SetData(_x: Cardinal; _Value: single);
begin
   if (_x < FSize) then
   begin
      PSingle(Cardinal(FData)+_x)^ := _Value;
   end;
end;

procedure TMultiVector.QuickSetData(_x: Cardinal; _Value: single);
begin
   PSingle(Cardinal(FData)+_x)^ := _Value;
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

end.
