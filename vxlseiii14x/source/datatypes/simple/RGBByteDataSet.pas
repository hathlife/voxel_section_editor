unit RGBByteDataSet;

interface

uses ByteDataSet;

type
   TRGBByteDataSet = class (TByteDataSet)
      private
         FLength : integer;
         // Gets
         function GetData(_pos: integer): byte; reintroduce; overload;
         function GetRed(_pos: integer): byte;
         function GetGreen(_pos: integer): byte;
         function GetBlue(_pos: integer): byte;
         // Sets
         procedure SetData(_pos: integer; _data: byte); reintroduce; overload;
         procedure SetRed(_pos: integer; _data: byte);
         procedure SetGreen(_pos: integer; _data: byte);
         procedure SetBlue(_pos: integer; _data: byte);
      protected
         // Gets
         function GetDataLength: integer; override;
         function GetLength: integer; override;
         function GetLast: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // properties
         property Data[_pos: integer]:byte read GetData write SetData;
         property Red[_pos: integer]:byte read GetRed write SetRed;
         property Green[_pos: integer]:byte read GetGreen write SetGreen;
         property Blue[_pos: integer]:byte read GetBlue write SetBlue;
   end;

implementation

// Gets
function TRGBByteDataSet.GetData(_pos: integer): byte;
begin
   Result := FData[_pos];
end;

function TRGBByteDataSet.GetRed(_pos: integer): byte;
begin
   Result := FData[3*_pos];
end;

function TRGBByteDataSet.GetGreen(_pos: integer): byte;
begin
   Result := FData[(3*_pos)+1];
end;

function TRGBByteDataSet.GetBlue(_pos: integer): byte;
begin
   Result := FData[(3*_pos)+2];
end;

function TRGBByteDataSet.GetLength: integer;
begin
   Result := FLength;
end;

function TRGBByteDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

function TRGBByteDataSet.GetLast: integer;
begin
   Result := FLength - 1;
end;

// Sets
procedure TRGBByteDataSet.SetData(_pos: integer; _data: byte);
begin
   FData[_pos] := _data;
end;

procedure TRGBByteDataSet.SetRed(_pos: integer; _data: byte);
begin
   FData[3*_pos] := _data;
end;

procedure TRGBByteDataSet.SetGreen(_pos: integer; _data: byte);
begin
   FData[(3*_pos)+1] := _data;
end;

procedure TRGBByteDataSet.SetBlue(_pos: integer; _data: byte);
begin
   FData[(3*_pos)+2] := _data;
end;

procedure TRGBByteDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*3);
end;

end.
