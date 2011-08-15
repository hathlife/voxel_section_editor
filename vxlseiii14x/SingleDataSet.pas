unit SingleDataSet;

interface

uses AbstractDataSet;

type
   TSingleDataSet = class (TAbstractDataSet)
      private
         FData : array of single;
         // Gets
         function GetData(_pos: integer): single;
         // Sets
         procedure SetData(_pos: integer; _data: single);
      protected
         function GetDataLength: integer; override;
      public
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

end.
