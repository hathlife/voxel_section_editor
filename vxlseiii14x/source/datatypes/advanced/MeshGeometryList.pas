unit MeshGeometryList;

interface

uses BasicDataTypes, BasicConstants, MeshGeometryBase;

type
   CMeshGeometryList = class
      private
         Start,Last,Active : PMeshGeometryBase;
         FCount: integer;
         procedure Reset;
         function GetActive: PMeshGeometryBase;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure LoadState(_State: PMeshGeometryBase);
         function SaveState:PMeshGeometryBase;
         // Add
         procedure Add; overload;
         procedure Add(_type: integer); overload;
         procedure Delete;
         // Delete
         procedure Clear;
         // Misc
         procedure GoToFirstElement;
         procedure GoToNextElement;
         // Properties
         property Count: integer read FCount;
         property Current: PMeshGeometryBase read GetActive;
   end;

implementation

uses MeshBRepGeometry;

constructor CMeshGeometryList.Create;
begin
   Reset;
end;

destructor CMeshGeometryList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure CMeshGeometryList.Reset;
begin
   Start := nil;
   Last := nil;
   Active := nil;
   FCount := 0;
end;

// I/O
procedure CMeshGeometryList.LoadState(_State: PMeshGeometryBase);
begin
   Active := _State;
end;

function CMeshGeometryList.SaveState:PMeshGeometryBase;
begin
   Result := Active;
end;


// Add
procedure CMeshGeometryList.Add;
var
   NewPosition : PMeshGeometryBase;
begin
   New(NewPosition);
   inc(FCount);
   if Start <> nil then
   begin
      Last^.Next := NewPosition;
   end
   else
   begin
      Start := NewPosition;
      Active := Start;
   end;
   Last := NewPosition;
end;

procedure CMeshGeometryList.Add(_type: integer);
var
   NewPosition : PMeshGeometryBase;
begin
   New(NewPosition);
   Case(_Type) of
      C_GEO_BREP:
      begin
         NewPosition^ := TMeshBRepGeometry.Create();
      end; 
      C_GEO_BREP3:
      begin
         NewPosition^ := TMeshBRepGeometry.Create(3);
      end;
      C_GEO_BREP4:
      begin
         NewPosition^ := TMeshBRepGeometry.Create(4);
      end;
   end;
   NewPosition^.Next := nil;
   inc(FCount);
   if Start <> nil then
   begin
      Last^.Next := NewPosition;
   end
   else
   begin
      Start := NewPosition;
      Active := Start;
   end;
   Last := NewPosition;
end;

// Delete
procedure CMeshGeometryList.Delete;
var
   Previous : PMeshGeometryBase;
begin
   if Active <> nil then
   begin
      Previous := Start;
      if Active = Start then
      begin
         Start := Start^.Next;
      end
      else
      begin
         while Previous^.Next <> Active do
         begin
            Previous := Previous^.Next;
         end;
         Previous^.Next := Active^.Next;
         if Active = Last then
         begin
            Last := Previous;
         end;
      end;
      Dispose(Active);
      dec(FCount);
   end;
end;

procedure CMeshGeometryList.Clear;
var
   Garbage : PMeshGeometryBase;
begin
   Active := Start;
   while Active <> nil do
   begin
      Garbage := Active;
      Active := Active^.Next;
      dispose(Garbage);
   end;
   Reset;
end;

// Gets
function CMeshGeometryList.GetActive: PMeshGeometryBase;
begin
   Result := Active;
end;

// Misc
procedure CMeshGeometryList.GoToNextElement;
begin
   if Active <> nil then
   begin
      Active := Active^.Next;
   end
end;

procedure CMeshGeometryList.GoToFirstElement;
begin
   Active := Start;
end;

end.
