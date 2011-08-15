unit RGBSingleDataSet;

interface

uses SingleDataSet;

type
   TRGBSingleDataSet = class (TSingleDataSet)
      private
         FData : array of single;
         FLength : integer;
         // Gets
         function GetData(_pos: integer): single;
         function GetRed(_pos: integer): single;
         function GetGreen(_pos: integer): single;
         function GetBlue(_pos: integer): single;
         // Sets
         procedure SetData(_pos: integer; _data: single);
         procedure SetRed(_pos: integer; _data: single);
         procedure SetGreen(_pos: integer; _data: single);
         procedure SetBlue(_pos: integer; _data: single);
      protected
         // Gets
         function GetDataLength: integer; override;
         function GetLength: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // properties
         property Data[_pos: integer]:single read GetData write SetData;
         property Red[_pos: integer]:single read GetRed write SetRed;
         property Green[_pos: integer]:single read GetGreen write SetGreen;
         property Blue[_pos: integer]:single read GetBlue write SetBlue;
   end;

implementation

// Gets
function TRGBSingleDataSet.GetData(_pos: integer): single;
begin
   Result := FData[_pos];
end;

function TRGBSingleDataSet.GetRed(_pos: integer): single;
begin
   Result := FData[3*_pos];
end;

function TRGBSingleDataSet.GetGreen(_pos: integer): single;
begin
   Result := FData[(3*_pos)+1];
end;

function TRGBSingleDataSet.GetBlue(_pos: integer): single;
begin
   Result := FData[(3*_pos)+2];
end;

function TRGBSingleDataSet.GetLength: integer;
begin
   Result := FLength;
end;

function TRGBSingleDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;


// Sets
procedure TRGBSingleDataSet.SetData(_pos: integer; _data: single);
begin
   FData[_pos] := _data;
end;

procedure TRGBSingleDataSet.SetRed(_pos: integer; _data: single);
begin
   FData[3*_pos] := _data;
end;

procedure TRGBSingleDataSet.SetGreen(_pos: integer; _data: single);
begin
   FData[(3*_pos)+1] := _data;
end;

procedure TRGBSingleDataSet.SetBlue(_pos: integer; _data: single);
begin
   FData[(3*_pos)+2] := _data;
end;

procedure TRGBSingleDataSet.SetLength(_size: Integer);
begin
   FLength := _size;
   System.SetLength(FData,_size*3);
end;
end.
