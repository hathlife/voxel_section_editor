unit RGBAByteDataSet;

interface

uses ByteDataSet;

type
   TRGBAByteDataSet = class (TByteDataSet)
      private
         FLength : integer;
         // Gets
         function GetData(_pos: integer): byte;
         function GetRed(_pos: integer): byte;
         function GetGreen(_pos: integer): byte;
         function GetBlue(_pos: integer): byte;
         function GetAlpha(_pos: integer): byte;
         // Sets
         procedure SetData(_pos: integer; _data: byte);
         procedure SetRed(_pos: integer; _data: byte);
         procedure SetGreen(_pos: integer; _data: byte);
         procedure SetBlue(_pos: integer; _data: byte);
         procedure SetAlpha(_pos: integer; _data: byte);
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
         property Alpha[_pos: integer]:byte read GetAlpha write SetAlpha;
   end;

implementation

// Gets
function TRGBAByteDataSet.GetData(_pos: integer): byte;
begin
   Result := FData[_pos];
end;

function TRGBAByteDataSet.GetRed(_pos: integer): byte;
begin
   Result := FData[4*_pos];
end;

function TRGBAByteDataSet.GetGreen(_pos: integer): byte;
begin
   Result := FData[(4*_pos)+1];
end;

function TRGBAByteDataSet.GetBlue(_pos: integer): byte;
begin
   Result := FData[(4*_pos)+2];
end;

function TRGBAByteDataSet.GetAlpha(_pos: integer): byte;
begin
   Result := FData[(4*_pos)+3];
end;

function TRGBAByteDataSet.GetLength: integer;
begin
   Result := FLength;
end;

function TRGBAByteDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

function TRGBAByteDataSet.GetLast: integer;
begin
   Result := FLength - 1;
end;

// Sets
procedure TRGBAByteDataSet.SetData(_pos: integer; _data: byte);
begin
   FData[_pos] := _data;
end;

procedure TRGBAByteDataSet.SetRed(_pos: integer; _data: byte);
begin
   FData[4*_pos] := _data;
end;

procedure TRGBAByteDataSet.SetGreen(_pos: integer; _data: byte);
begin
   FData[(4*_pos)+1] := _data;
end;

procedure TRGBAByteDataSet.SetBlue(_pos: integer; _data: byte);
begin
   FData[(4*_pos)+2] := _data;
end;

procedure TRGBAByteDataSet.SetAlpha(_pos: integer; _data: byte);
begin
   FData[(4*_pos)+3] := _data;
end;

procedure TRGBAByteDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*4);
end;

end.
