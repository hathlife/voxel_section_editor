unit AbstractDataSet;

interface

type
   TAbstractDataSet = class
      private
         FData : array of pointer;
      protected
         // Gets
         function GetData(_pos: integer): pointer; virtual;
         function GetDataLength: integer; virtual;
         function GetLength: integer; virtual;
         function GetLast: integer; virtual;
         // Sets
         procedure SetData(_pos: integer; _data: pointer); virtual;
         procedure SetLength(_size: integer); virtual;
      public
         // constructors and destructors
         constructor Create; overload;
         constructor Create(const _Source: TAbstractDataSet); overload;
         destructor Destroy; override;
         // copies
         procedure Assign(const _Source: TAbstractDataSet); virtual;
         // properties
         property Length: integer read GetLength write SetLength;
         property Last: integer read GetLast;
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

function TAbstractDataSet.GetLast: integer;
begin
   Result := High(FData);
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
      SetData(i,_Source.GetData(i));
   end;
end;

end.
