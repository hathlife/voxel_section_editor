unit GenericThread;

interface

uses Classes;

type
   TGenericFunction = function (const _args: pointer): integer;
   PGenericFunction = ^TGenericFunction;

   TGenericMethod = function (const _args: pointer): integer of object;
   PGenericMethod = ^TGenericMethod;

   TGenericThread = class (TThread)
      private
         MyFunction: TGenericFunction;
         MyMethod: TGenericMethod;
         Arguments: pointer;
      protected
         procedure Execute; override;
      public
         constructor Create(const _Function: TGenericFunction; const _args: pointer); overload;
         constructor Create(const _Method: TGenericMethod; const _args: pointer); overload;
         destructor Destroy; override;
   end;

implementation

// Constructors and Destructors;


constructor TGenericThread.Create(const _Function: TGenericFunction; const _args: Pointer);
begin
   inherited Create(true);
   MyFunction := _Function;
   MyMethod := nil;
   Arguments := _args;
   ReturnValue := 0;
   Resume;
end;

constructor TGenericThread.Create(const _Method: TGenericMethod; const _args: Pointer);
begin
   inherited Create(true);
   MyFunction := nil;
   MyMethod := _Method;
   Arguments := _args;
   ReturnValue := 0;
   Resume;
end;


destructor TGenericThread.Destroy;
begin
   MyFunction := nil;
   MyMethod := nil;
   Arguments := nil;
   inherited Destroy;
end;

// Executes;
procedure TGenericThread.Execute;
begin
   if Addr(MyFunction) <> nil then
   begin
      ReturnValue := MyFunction(Arguments);
   end
   else if Addr(MyMethod) <> nil then
   begin
      ReturnValue := MyMethod(Arguments);
   end;
   inherited;
end;



end.
