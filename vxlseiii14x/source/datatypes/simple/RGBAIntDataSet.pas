unit RGBAIntDataSet;

interface

uses IntDataSet;

type
   TRGBAIntDataSet = class (TIntDataSet)
      private
         FLength : integer;
         // Gets
         function GetData(_pos: integer): integer; reintroduce;
         function GetRed(_pos: integer): integer;
         function GetGreen(_pos: integer): integer;
         function GetBlue(_pos: integer): integer;
         function GetAlpha(_pos: integer): integer;
         // Sets
         procedure SetData(_pos: integer; _data: integer); reintroduce;
         procedure SetRed(_pos: integer; _data: integer);
         procedure SetGreen(_pos: integer; _data: integer);
         procedure SetBlue(_pos: integer; _data: integer);
         procedure SetAlpha(_pos: integer; _data: integer);
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
         property Alpha[_pos: integer]:integer read GetAlpha write SetAlpha;
   end;

implementation

// Gets
function TRGBAIntDataSet.GetData(_pos: integer): integer;
begin
   Result := FData[_pos];
end;

function TRGBAIntDataSet.GetRed(_pos: integer): integer;
begin
   Result := FData[4*_pos];
end;

function TRGBAIntDataSet.GetGreen(_pos: integer): integer;
begin
   Result := FData[(4*_pos)+1];
end;

function TRGBAIntDataSet.GetBlue(_pos: integer): integer;
begin
   Result := FData[(4*_pos)+2];
end;

function TRGBAIntDataSet.GetAlpha(_pos: integer): integer;
begin
   Result := FData[(4*_pos)+3];
end;

function TRGBAIntDataSet.GetLength: integer;
begin
   Result := FLength;
end;

function TRGBAIntDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

function TRGBAIntDataSet.GetLast: integer;
begin
   Result := FLength - 1;
end;

// Sets
procedure TRGBAIntDataSet.SetData(_pos: integer; _data: integer);
begin
   FData[_pos] := _data;
end;

procedure TRGBAIntDataSet.SetRed(_pos: integer; _data: integer);
begin
   FData[4*_pos] := _data;
end;

procedure TRGBAIntDataSet.SetGreen(_pos: integer; _data: integer);
begin
   FData[(4*_pos)+1] := _data;
end;

procedure TRGBAIntDataSet.SetBlue(_pos: integer; _data: integer);
begin
   FData[(4*_pos)+2] := _data;
end;

procedure TRGBAIntDataSet.SetAlpha(_pos: integer; _data: integer);
begin
   FData[(4*_pos)+3] := _data;
end;

procedure TRGBAIntDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*4);
end;

end.
