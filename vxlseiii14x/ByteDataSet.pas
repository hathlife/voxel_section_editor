unit ByteDataSet;

interface

uses AbstractDataSet;

type
   TByteDataSet = class (TAbstractDataSet)
      private
         FData : array of byte;
         // Gets
         function GetData(_pos: integer): byte;
         // Sets
         procedure SetData(_pos: integer; _data: byte);
      protected
         function GetDataLength: integer; override;
      public
         // properties
         property Data[_pos: integer]:byte read GetData write SetData;
   end;

implementation

// Gets
function TByteDataSet.GetData(_pos: integer): byte;
begin
   Result := FData[_pos];
end;

function TByteDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

// Sets
procedure TByteDataSet.SetData(_pos: integer; _data: byte);
begin
   FData[_pos] := _data;
end;

end.
