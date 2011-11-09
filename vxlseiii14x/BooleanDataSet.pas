unit BooleanDataSet;

interface

uses AbstractDataSet;

type
   TBooleanDataSet = class (TAbstractDataSet)
      private
         // Gets
         function GetData(_pos: integer): boolean; reintroduce;
         // Sets
         procedure SetData(_pos: integer; _data: boolean); reintroduce;
      protected
         FData : packed array of boolean;
         // Gets
         function GetDataLength: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // copies
         procedure Assign(const _Source: TAbstractDataSet); override;
         // properties
         property Data[_pos: integer]:boolean read GetData write SetData;
   end;

implementation

// Gets
function TBooleanDataSet.GetData(_pos: integer): boolean;
begin
   Result := FData[_pos];
end;

function TBooleanDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

// Sets
procedure TBooleanDataSet.SetData(_pos: integer; _data: boolean);
begin
   FData[_pos] := _data;
end;

procedure TBooleanDataSet.SetLength(_size: Integer);
begin
   System.SetLength(FData,_size);
end;

// copies
procedure TBooleanDataSet.Assign(const _Source: TAbstractDataSet);
var
   maxData,i: integer;
begin
   Length := _Source.Length;
   maxData := GetDataLength() - 1;
   for i := 0 to maxData do
   begin
      Data[i] := (_Source as TBooleanDataSet).Data[i];
   end;
end;

end.
