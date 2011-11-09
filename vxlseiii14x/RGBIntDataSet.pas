unit RGBIntDataSet;

interface

uses IntDataSet;

type
   TRGBIntDataSet = class (TIntDataSet)
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
function TRGBIntDataSet.GetData(_pos: integer): longword;
begin
   Result := FData[_pos];
end;

function TRGBIntDataSet.GetRed(_pos: integer): longword;
begin
   Result := FData[3*_pos];
end;

function TRGBIntDataSet.GetGreen(_pos: integer): longword;
begin
   Result := FData[(3*_pos)+1];
end;

function TRGBIntDataSet.GetBlue(_pos: integer): longword;
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


// Sets
procedure TRGBIntDataSet.SetData(_pos: integer; _data: longword);
begin
   FData[_pos] := _data;
end;

procedure TRGBIntDataSet.SetRed(_pos: integer; _data: longword);
begin
   FData[3*_pos] := _data;
end;

procedure TRGBIntDataSet.SetGreen(_pos: integer; _data: longword);
begin
   FData[(3*_pos)+1] := _data;
end;

procedure TRGBIntDataSet.SetBlue(_pos: integer; _data: longword);
begin
   FData[(3*_pos)+2] := _data;
end;

procedure TRGBIntDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*3);
end;


end.
