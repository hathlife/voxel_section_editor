unit RGBASingleDataSet;

interface

uses SingleDataSet;

type
   TRGBASingleDataSet = class (TSingleDataSet)
      private
         FLength : integer;
         // Gets
         function GetData(_pos: integer): single; reintroduce; overload;
         function GetRed(_pos: integer): single;
         function GetGreen(_pos: integer): single;
         function GetBlue(_pos: integer): single;
         function GetAlpha(_pos: integer): single;
         // Sets
         procedure SetData(_pos: integer; _data: single); reintroduce; overload;
         procedure SetRed(_pos: integer; _data: single);
         procedure SetGreen(_pos: integer; _data: single);
         procedure SetBlue(_pos: integer; _data: single);
         procedure SetAlpha(_pos: integer; _data: single);
      protected
         // Gets
         function GetDataLength: integer; override;
         function GetLength: integer; override;
         function GetLast: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // properties
         property Data[_pos: integer]:single read GetData write SetData;
         property Red[_pos: integer]:single read GetRed write SetRed;
         property Green[_pos: integer]:single read GetGreen write SetGreen;
         property Blue[_pos: integer]:single read GetBlue write SetBlue;
         property Alpha[_pos: integer]:single read GetAlpha write SetAlpha;
   end;

implementation

// Gets
function TRGBASingleDataSet.GetData(_pos: integer): single;
begin
   Result := FData[_pos];
end;

function TRGBASingleDataSet.GetRed(_pos: integer): single;
begin
   Result := FData[4*_pos];
end;

function TRGBASingleDataSet.GetGreen(_pos: integer): single;
begin
   Result := FData[(4*_pos)+1];
end;

function TRGBASingleDataSet.GetBlue(_pos: integer): single;
begin
   Result := FData[(4*_pos)+2];
end;

function TRGBASingleDataSet.GetAlpha(_pos: integer): single;
begin
   Result := FData[(4*_pos)+3];
end;

function TRGBASingleDataSet.GetLength: integer;
begin
   Result := FLength;
end;

function TRGBASingleDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

function TRGBASingleDataSet.GetLast: integer;
begin
   Result := FLength - 1;
end;


// Sets
procedure TRGBASingleDataSet.SetData(_pos: integer; _data: single);
begin
   FData[_pos] := _data;
end;

procedure TRGBASingleDataSet.SetRed(_pos: integer; _data: single);
begin
   FData[4*_pos] := _data;
end;

procedure TRGBASingleDataSet.SetGreen(_pos: integer; _data: single);
begin
   FData[(4*_pos)+1] := _data;
end;

procedure TRGBASingleDataSet.SetBlue(_pos: integer; _data: single);
begin
   FData[(4*_pos)+2] := _data;
end;

procedure TRGBASingleDataSet.SetAlpha(_pos: integer; _data: single);
begin
   FData[(4*_pos)+3] := _data;
end;

procedure TRGBASingleDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*4);
end;

end.
