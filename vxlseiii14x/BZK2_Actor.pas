unit BZK2_Actor;

interface

const
   C_BZKACTOR_OBJECT = 0;
   C_BZKACTOR_LIGHT = 1;

type
   TBZK2Actor = class
      private
         Name : string;
         Location : integer;
         MyClass : string;
         Angle : real;
         ActorType : byte;
         Light : integer;
         Mesh : string;
         // I/O
         procedure WriteName (var MyFile : System.Text);
         procedure WriteLocation (var MyFile : System.Text);
         procedure WriteClass (var MyFile : System.Text);
         procedure WriteAngle (var MyFile : System.Text);
         procedure WriteLight (var MyFile : System.Text);
         procedure WriteMesh (var MyFile : System.Text);
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;
         // I/O
         procedure WriteToFile (var MyFile : System.Text);
         // Gets
         function GetName : string;
         function GetLocation : integer;
         function GetClass : string;
         function GetAngle : real;
         function GetLight: integer;
         function GetMesh: string;
         function GetType : byte;
         // Sets
         procedure SetName ( value : string);
         procedure SetLocation ( value : integer);
         procedure SetClass ( value : string);
         procedure SetAngle ( value : real);
         procedure SetLight( value : integer);
         procedure SetMesh( value : string);
         procedure SetType ( value : byte);
         // Assign
         procedure Assign(const Actor : TBZK2Actor);
   end;


implementation

// Constructors and Destructors
constructor TBZK2Actor.Create;
begin
   Name := '';
   Location := 1;
   MyClass := 'DefaultClass';
   Angle := 0;
   ActorType := C_BZKACTOR_OBJECT;
end;

destructor TBZK2Actor.Destroy;
begin
   Name := '';
   MyClass := '';
   inherited Destroy;
end;

// Gets
function TBZK2Actor.GetName : string;
begin
   Result := Name;
end;

function TBZK2Actor.GetLocation : integer;
begin
   Result := Location;
end;

function TBZK2Actor.GetClass : string;
begin
   Result := MyClass;
end;

function TBZK2Actor.GetAngle : real;
begin
   Result := Angle;
end;

function TBZK2Actor.GetLight : integer;
begin
   Result := Light;
end;

function TBZK2Actor.GetMesh : string;
begin
   Result := Mesh;
end;

function TBZK2Actor.GetType : byte;
begin
   Result := ActorType;
end;

// Sets
procedure TBZK2Actor.SetName ( Value : string);
begin
   Name := Value;
end;

procedure TBZK2Actor.SetLocation ( Value : integer);
begin
   Location := Value;
end;

procedure TBZK2Actor.SetClass ( Value : string);
begin
   MyClass := value;
end;

procedure TBZK2Actor.SetAngle ( Value : real);
begin
   Angle := value;
end;

procedure TBZK2Actor.SetLight ( Value : integer);
begin
   Light := value;
end;

procedure TBZK2Actor.SetMesh ( Value : string);
begin
   Mesh := value;
end;

procedure TBZK2Actor.SetType ( Value : byte);
begin
   ActorType := value;
end;

// I/O
procedure TBZK2Actor.WriteToFile (var MyFile : System.Text);
begin
   WriteLn(MyFile,'<Actor>');
   WriteName(MyFile);
   if ActorType = C_BZKACTOR_OBJECT then
   begin
      WriteLocation(MyFile);
      WriteMesh(MyFile);
      WriteAngle(MyFile);
      WriteClass(MyFile);
   end
   else if ActorType = C_BZKACTOR_LIGHT then
   begin
      WriteLight(MyFile);
      WriteLocation(MyFile);
      WriteMesh(MyFile);
   end;
   WriteLn(MyFile,'</Actor>');
end;

procedure TBZK2Actor.WriteName (var MyFile : System.Text);
begin
   WriteLn(MyFile,'<Name>');
   WriteLn(MyFile,Name);
   WriteLn(MyFile,'</Name>');
end;

procedure TBZK2Actor.WriteLocation (var MyFile : System.Text);
begin
   WriteLn(MyFile,'<Location>');
   WriteLn(MyFile,Location);
   WriteLn(MyFile,'</Location>');
end;

procedure TBZK2Actor.WriteClass (var MyFile : System.Text);
begin
   WriteLn(MyFile,'<Class>');
   WriteLn(MyFile,MyClass);
   WriteLn(MyFile,'</Class>');
end;

procedure TBZK2Actor.WriteAngle (var MyFile : System.Text);
begin
   WriteLn(MyFile,'<Angle>');
   WriteLn(MyFile,Angle);
   WriteLn(MyFile,'</Angle>');
end;

procedure TBZK2Actor.WriteLight (var MyFile : System.Text);
begin
   WriteLn(MyFile,'<Light>');
   WriteLn(MyFile,Light);
   WriteLn(MyFile,'</Light>');
end;

procedure TBZK2Actor.WriteMesh (var MyFile : System.Text);
begin
   if Length(Mesh) > 0 then
   begin
      WriteLn(MyFile,'<Mesh>');
      WriteLn(MyFile,Mesh);
      WriteLn(MyFile,'</Mesh>');
   end;
end;

procedure TBZK2Actor.Assign(const Actor : TBZK2Actor);
begin
   SetName(Actor.GetName);
   SetType(Actor.ActorType);
   SetLocation(Actor.GetLocation);
   SetClass(Actor.GetClass);
   SetLight(Actor.Light);
   SetAngle(Actor.Angle);
   SetMesh(Actor.Mesh);
end;


end.
