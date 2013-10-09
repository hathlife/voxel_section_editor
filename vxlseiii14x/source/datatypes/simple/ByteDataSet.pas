unit ByteDataSet;

interface

uses AbstractDataSet;

type
   TByteDataSet = class (TAbstractDataSet)
      private
         // Gets
         function GetData(_pos: integer): byte;
         // Sets
         procedure SetData(_pos: integer; _data: byte);
      protected
         FData : packed array of byte;
         // Gets
         function GetDataLength: integer; override;
         function GetLast: integer; override;
         // Sets
         procedure SetLength(_size: integer); override;
      public
         // copies
         procedure Assign(const _Source: TAbstractDataSet); override;
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

function TByteDataSet.GetLast: integer;
begin
   Result := High(FData);
end;

// Sets
procedure TByteDataSet.SetData(_pos: integer; _data: byte);
begin
   FData[_pos] := _data;
end;

procedure TByteDataSet.SetLength(_size: Integer);
begin
   System.SetLength(FData,_size);
end;

// copies
procedure TByteDataSet.Assign(const _Source: TAbstractDataSet);
var
   maxData,i: integer;
begin
   Length := _Source.Length;
   maxData := GetDataLength() - 1;
   for i := 0 to maxData do
   begin
      Data[i] := (_Source as TByteDataSet).Data[i];
   end;
end;

end.
