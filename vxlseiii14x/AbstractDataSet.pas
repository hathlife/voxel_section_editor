unit AbstractDataSet;

interface

type
   TAbstractDataSet = class
      private
         FData : array of pointer;
         // Gets
         function GetData(_pos: integer): pointer;
         // Sets
         procedure SetData(_pos: integer; _data: pointer);
      protected
         // Gets
         function GetDataLength: integer; virtual;
         function GetLength: integer; virtual;
         // Sets
         procedure SetLength(_size: integer); virtual;
      public
         // constructors and destructors
         constructor Create; overload;
         constructor Create(const _Source: TAbstractDataSet); overload;
         destructor Destroy; override;
         // copies
         procedure Assign(const _Source: TAbstractDataSet); virtual;
         // properties
         property Data[_pos: integer]:pointer read GetData write SetData;
         property Length: integer read GetLength write SetLength;
   end;

implementation

// Constructors and Destructors
constructor TAbstractDataSet.Create;
begin
   Length := 0;
end;

constructor TAbstractDataSet.Create(const _Source: TAbstractDataSet);
begin
   Assign(_Source);
end;

destructor TAbstractDataSet.Destroy;
begin
   Length := 0;
   inherited Destroy;
end;

// Gets
function TAbstractDataSet.GetData(_pos: integer): pointer;
begin
   Result := FData[_pos];
end;

function TAbstractDataSet.GetLength: integer;
begin
   Result := GetDataLength;
end;

function TAbstractDataSet.GetDataLength: integer;
begin
   Result := High(FData) + 1;
end;

// Sets
procedure TAbstractDataSet.SetData(_pos: integer; _data: pointer);
begin
   FData[_pos] := _data;
end;

procedure TAbstractDataSet.SetLength(_size: Integer);
begin
   System.SetLength(FData,_size);
end;

// copies
procedure TAbstractDataSet.Assign(const _Source: TAbstractDataSet);
var
   maxData,i: integer;
begin
   Length := _Source.Length;
   maxData := GetDataLength() - 1;
   for i := 0 to maxData do
   begin
      Data[i] := _Source.Data[i];
   end;
end;

end.
