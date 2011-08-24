unit IntDataSet;

interface

uses AbstractDataSet;

type
   TIntDataSet = class (TAbstractDataSet)
      private
         // Gets
         function GetData(_pos: integer): longword;
         // Sets
         procedure SetData(_pos: integer; _data: longword);
      protected
         FData : array of longword;
         // Gets
         function GetDataLength: integer; override;
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
function TIntDataSet.GetData(_pos: integer): longword;
begin
   Result := FData[_pos];
end;

function TIntDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

// Sets
procedure TIntDataSet.SetData(_pos: integer; _data: longword);
begin
   FData[_pos] := _data;
end;

procedure TIntDataSet.SetLength(_size: Integer);
begin
   System.SetLength(FData,_size);
end;

// copies
procedure TIntDataSet.Assign(const _Source: TAbstractDataSet);
var
   maxData,i: integer;
begin
   Length := _Source.Length;
   maxData := GetDataLength() - 1;
   for i := 0 to maxData do
   begin
      Data[i] := (_Source as TIntDataSet).Data[i];
   end;
end;

end.
