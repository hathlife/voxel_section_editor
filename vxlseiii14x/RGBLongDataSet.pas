unit RGBLongDataSet;

interface

uses LongDataSet;

type
   TRGBLongDataSet = class (TLongDataSet)
      private
         FLength : integer;
         // Gets
         function GetData(_pos: integer): longword; reintroduce;
         function GetRed(_pos: integer): longword;
         function GetGreen(_pos: integer): longword;
         function GetBlue(_pos: integer): longword;
         // Sets
         procedure SetData(_pos: integer; _data: longword); reintroduce;
         procedure SetRed(_pos: integer; _data: longword);
         procedure SetGreen(_pos: integer; _data: longword);
         procedure SetBlue(_pos: integer; _data: longword);
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
   end;

implementation

// Gets
function TRGBLongDataSet.GetData(_pos: integer): longword;
begin
   Result := FData[_pos];
end;

function TRGBLongDataSet.GetRed(_pos: integer): longword;
begin
   Result := FData[3*_pos];
end;

function TRGBLongDataSet.GetGreen(_pos: integer): longword;
begin
   Result := FData[(3*_pos)+1];
end;

function TRGBLongDataSet.GetBlue(_pos: integer): longword;
begin
   Result := FData[(3*_pos)+2];
end;

function TRGBLongDataSet.GetLength: integer;
begin
   Result := FLength;
end;

function TRGBLongDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;


// Sets
procedure TRGBLongDataSet.SetData(_pos: integer; _data: longword);
begin
   FData[_pos] := _data;
end;

procedure TRGBLongDataSet.SetRed(_pos: integer; _data: longword);
begin
   FData[3*_pos] := _data;
end;

procedure TRGBLongDataSet.SetGreen(_pos: integer; _data: longword);
begin
   FData[(3*_pos)+1] := _data;
end;

procedure TRGBLongDataSet.SetBlue(_pos: integer; _data: longword);
begin
   FData[(3*_pos)+2] := _data;
end;

procedure TRGBLongDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*3);
end;

end.
