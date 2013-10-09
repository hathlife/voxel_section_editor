unit RGBIntDataSet;

interface

uses IntDataSet;

type
   TRGBIntDataSet = class (TIntDataSet)
      private
         FLength : integer;
         // Gets
         function GetData(_pos: integer): integer; reintroduce;
         function GetRed(_pos: integer): integer;
         function GetGreen(_pos: integer): integer;
         function GetBlue(_pos: integer): integer;
         // Sets
         procedure SetData(_pos: integer; _data: integer); reintroduce;
         procedure SetRed(_pos: integer; _data: integer);
         procedure SetGreen(_pos: integer; _data: integer);
         procedure SetBlue(_pos: integer; _data: integer);
      protected
         // Gets
         function GetDataLength: integer; override;
         function GetLength: integer; override;
         function GetLast: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // properties
         property Data[_pos: integer]:integer read GetData write SetData;
         property Red[_pos: integer]:integer read GetRed write SetRed;
         property Green[_pos: integer]:integer read GetGreen write SetGreen;
         property Blue[_pos: integer]:integer read GetBlue write SetBlue;
   end;

implementation

// Gets
function TRGBIntDataSet.GetData(_pos: integer): integer;
begin
   Result := FData[_pos];
end;

function TRGBIntDataSet.GetRed(_pos: integer): integer;
begin
   Result := FData[3*_pos];
end;

function TRGBIntDataSet.GetGreen(_pos: integer): integer;
begin
   Result := FData[(3*_pos)+1];
end;

function TRGBIntDataSet.GetBlue(_pos: integer): integer;
begin
   Result := FData[(3*_pos)+2];
end;

function TRGBIntDataSet.GetLength: integer;
begin
   Result := FLength;
end;

function TRGBIntDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

function TRGBIntDataSet.GetLast: integer;
begin
   Result := FLength - 1;
end;

// Sets
procedure TRGBIntDataSet.SetData(_pos: integer; _data: integer);
begin
   FData[_pos] := _data;
end;

procedure TRGBIntDataSet.SetRed(_pos: integer; _data: integer);
begin
   FData[3*_pos] := _data;
end;

procedure TRGBIntDataSet.SetGreen(_pos: integer; _data: integer);
begin
   FData[(3*_pos)+1] := _data;
end;

procedure TRGBIntDataSet.SetBlue(_pos: integer; _data: integer);
begin
   FData[(3*_pos)+2] := _data;
end;

procedure TRGBIntDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*3);
end;


end.
