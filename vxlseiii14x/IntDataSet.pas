unit IntDataSet;

interface

uses AbstractDataSet;

type
   TIntDataSet = class (TAbstractDataSet)
      private
         FData : array of longword;
         // Gets
         function GetData(_pos: integer): longword;
         // Sets
         procedure SetData(_pos: integer; _data: longword);
      protected
         function GetDataLength: integer; override;
      public
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

end.
