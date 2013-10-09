unit LongDataSet;

interface

uses AbstractDataSet;

type
   TLongDataSet = class (TAbstractDataSet)
      private
         // Gets
         function GetData(_pos: integer): longword; reintroduce;
         // Sets
         procedure SetData(_pos: integer; _data: longword); reintroduce;
      protected
         FData : packed array of longword;
         // Gets
         function GetDataLength: integer; override;
         function GetLast: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // copies
         procedure Assign(const _Source: TAbstractDataSet); override;
         // properties
         property Data[_pos: integer]:longword read GetData write SetData;
   end;

implementation

// Gets
function TLongDataSet.GetData(_pos: integer): longword;
begin
   Result := FData[_pos];
end;

function TLongDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

function TLongDataSet.GetLast: integer;
begin
   Result := High(FData);
end;

// Sets
procedure TLongDataSet.SetData(_pos: integer; _data: longword);
begin
   FData[_pos] := _data;
end;

procedure TLongDataSet.SetLength(_size: Integer);
begin
   System.SetLength(FData,_size);
end;

// copies
procedure TLongDataSet.Assign(const _Source: TAbstractDataSet);
var
   maxData,i: integer;
begin
   Length := _Source.Length;
   maxData := GetDataLength() - 1;
   for i := 0 to maxData do
   begin
      Data[i] := (_Source as TLongDataSet).Data[i];
   end;
end;

end.
