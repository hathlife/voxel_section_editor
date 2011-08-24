unit SingleDataSet;

interface

uses AbstractDataSet;

type
   TSingleDataSet = class (TAbstractDataSet)
      private
         // Gets
         function GetData(_pos: integer): single;
         // Sets
         procedure SetData(_pos: integer; _data: single);
      protected
         FData : array of single;
         // Gets
         function GetDataLength: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // copies
         procedure Assign(const _Source: TAbstractDataSet); override;
         // properties
         property Data[_pos: integer]:single read GetData write SetData;
   end;

implementation

// Gets
function TSingleDataSet.GetData(_pos: integer): single;
begin
   Result := FData[_pos];
end;

function TSingleDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;


// Sets
procedure TSingleDataSet.SetData(_pos: integer; _data: single);
begin
   FData[_pos] := _data;
end;

procedure TSingleDataSet.SetLength(_size: Integer);
begin
   System.SetLength(FData,_size);
end;

// copies
procedure TSingleDataSet.Assign(const _Source: TAbstractDataSet);
var
   maxData,i: integer;
begin
   Length := _Source.Length;
   maxData := GetDataLength() - 1;
   for i := 0 to maxData do
   begin
      Data[i] := (_Source as TSingleDataSet).Data[i];
   end;
end;

end.
