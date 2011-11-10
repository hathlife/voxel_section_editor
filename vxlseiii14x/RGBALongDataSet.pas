unit RGBALongDataSet;

interface

uses LongDataSet;

type
   TRGBALongDataSet = class (TLongDataSet)
      private
         FLength : integer;
         // Gets
         function GetData(_pos: integer): longword; reintroduce;
         function GetRed(_pos: integer): longword;
         function GetGreen(_pos: integer): longword;
         function GetBlue(_pos: integer): longword;
         function GetAlpha(_pos: integer): longword;
         // Sets
         procedure SetData(_pos: integer; _data: longword); reintroduce;
         procedure SetRed(_pos: integer; _data: longword);
         procedure SetGreen(_pos: integer; _data: longword);
         procedure SetBlue(_pos: integer; _data: longword);
         procedure SetAlpha(_pos: integer; _data: longword);
      protected
         // Gets
         function GetDataLength: integer; override;
         function GetLength: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // properties
         property Data[_pos: integer]:longword read GetData write SetData;
         property Red[_pos: integer]:longword read GetRed write SetRed;
         property Green[_pos: integer]:longword read GetGreen write SetGreen;
         property Blue[_pos: integer]:longword read GetBlue write SetBlue;
         property Alpha[_pos: integer]:longword read GetAlpha write SetAlpha;
   end;

implementation

// Gets
function TRGBALongDataSet.GetData(_pos: integer): longword;
begin
   Result := FData[_pos];
end;

function TRGBALongDataSet.GetRed(_pos: integer): longword;
begin
   Result := FData[4*_pos];
end;

function TRGBALongDataSet.GetGreen(_pos: integer): longword;
begin
   Result := FData[(4*_pos)+1];
end;

function TRGBALongDataSet.GetBlue(_pos: integer): longword;
begin
   Result := FData[(4*_pos)+2];
end;

function TRGBALongDataSet.GetAlpha(_pos: integer): longword;
begin
   Result := FData[(4*_pos)+3];
end;

function TRGBALongDataSet.GetLength: integer;
begin
   Result := FLength;
end;

function TRGBALongDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;


// Sets
procedure TRGBALongDataSet.SetData(_pos: integer; _data: longword);
begin
   FData[_pos] := _data;
end;

procedure TRGBALongDataSet.SetRed(_pos: integer; _data: longword);
begin
   FData[4*_pos] := _data;
end;

procedure TRGBALongDataSet.SetGreen(_pos: integer; _data: longword);
begin
   FData[(4*_pos)+1] := _data;
end;

procedure TRGBALongDataSet.SetBlue(_pos: integer; _data: longword);
begin
   FData[(4*_pos)+2] := _data;
end;

procedure TRGBALongDataSet.SetAlpha(_pos: integer; _data: longword);
begin
   FData[(4*_pos)+3] := _data;
end;

procedure TRGBALongDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*4);
end;

end.
