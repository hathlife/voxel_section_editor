unit Metric;

interface

uses Math;

type
   TMetric = class
   private
      FData: array of Single;
      FDimension: Cardinal;
      FSize: Cardinal;
      FOrthogonal: boolean;
   protected
      // Gets
      function GetDimension: Cardinal;
      function GetData(_x,_y: Cardinal): single;
      function QuickGetData(_x,_y: Cardinal): single;
      function GetMaxElement: Cardinal;
      function GetMaxX: Cardinal;
      // Sets
      procedure SetDimension(_Dimension: cardinal);
      procedure SetData(_x,_y: Cardinal; _Value: single);
      procedure QuickSetData(_x,_y: Cardinal; _Value: single);
   public
      // Constructors and Destructors
      constructor Create; overload;
      constructor Create(_Dimension: integer); overload;
      constructor Create(_Source: TMetric); overload;
      destructor Destroy; override;
      // Gets
//      function IsOrthogonal: boolean;
      // Clone/Copy/Assign
      procedure Assign(_Source: TMetric);
      // Properties
      property Dimension: cardinal read GetDimension write SetDimension;
      property MaxX: cardinal read GetMaxX;
      property MaxY: cardinal read GetMaxX;
      property Data[_x,_y:Cardinal]:single read GetData write SetData;
      property UnsafeData[_x,_y:Cardinal]:single read QuickGetData write QuickSetData;
      property Orthogonal:boolean read FOrthogonal write FOrthogonal;
   end;

implementation

// Constructors and Destructors
constructor TMetric.Create;
begin
   FDimension := 0;
   Dimension := 4; // SetDimension(4);
end;

constructor TMetric.Create(_Dimension: Integer);
begin
   FDimension := 0;
   Dimension := _Dimension; // SetDimension(_Dimension);
end;

constructor TMetric.Create(_Source: TMetric);
begin
   FDimension := 0;
   Assign(_Source);
end;

destructor TMetric.Destroy;
begin
   SetLength(FData,0);
   inherited Destroy;
end;

// Gets
function TMetric.GetDimension: cardinal;
begin
   Result := FDimension;
end;

function TMetric.GetMaxElement: cardinal;
begin
   Result := FSize - 1;
end;

function TMetric.GetMaxX: cardinal;
begin
   Result := FDimension - 1;
end;

function TMetric.GetData(_x,_y: Cardinal): single;
begin
   if (_x < FDimension) and (_y < FDimension) then
   begin
      Result := FData[_x+(FDimension * _y)];
   end
   else
   begin
      Result := 0;
   end;
end;

function TMetric.QuickGetData(_x,_y: Cardinal): single;
begin
   Result := FData[_x+(FDimension * _y)];
end;

{
// What the hell is that?
function TMetric.IsOrthogonal: boolean;
var
   counter,i,j : cardinal;
begin
   Result := true;
   for i := 0 to GetMaxX do
   begin
      counter := 0;
      for j := 0 to GetMaxX do
      begin
         if QuickGetData(i,j) <> 0 then
         begin
            inc(counter);
            if counter > 1 then
               exit;
         end;
      end;
   end;
   Result := false;
end;
}

// Sets
procedure TMetric.SetDimension(_Dimension: cardinal);
var
   BackupData: array of Single;
   NewSize,i,j : cardinal;
begin
   if _Dimension <> FDimension then
   begin
      if FDimension > 0 then
      begin
         NewSize := _Dimension * _Dimension;
         SetLength(BackupData,FSize);
         for i := Low(FData) to High(FData) do
         begin
            BackupData[i] := FData[i];
         end;
         SetLength(FData,NewSize);
         for i := 0 to Min(FDimension,_Dimension) - 1 do
            for j := 0 to Min(FDimension,_Dimension) - 1 do
            begin
               FData[i+(_Dimension * j)] := BackupData[i+(FDimension*j)];
            end;
         SetLength(BackupData,0);
         FDimension := _Dimension;
         FSize := NewSize;
      end
      else
      begin
         FDimension := _Dimension;
         FSize := _Dimension * _Dimension;
         SetLength(FData,FSize);
         for i := 0 to FSize - 1 do
         begin
            FData[i] := 0;
         end;
         for i := 0 to FDimension - 1 do
         begin
            FData[i + (i*FDimension)] := 1;
         end;
      end;
   end;
end;

procedure TMetric.SetData(_x,_y: Cardinal; _Value: single);
begin
   if (_x < FDimension) and (_y < FDimension) then
   begin
      FData[_x+(FDimension * _y)] := _Value;
   end;
end;

procedure TMetric.QuickSetData(_x,_y: Cardinal; _Value: single);
begin
   FData[_x+(FDimension * _y)] := _Value;
end;

// Clone/Copy/Assign
procedure TMetric.Assign(_Source: TMetric);
var
   x,y : cardinal;
begin
   Dimension := _Source.Dimension;
   for x := 0 to FDimension - 1 do
      for y := 0 to FDimension - 1 do
      begin
         QuickSetData(x,y,_Source.QuickGetData(x,y));
      end;
end;

end.
