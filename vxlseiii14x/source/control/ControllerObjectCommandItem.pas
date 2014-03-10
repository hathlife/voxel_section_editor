unit ControllerObjectCommandItem;

interface

uses ControllerDataTypes;

type
   TControllerObjectCommandItem = class
      public
         Command: longint;
         Params: TCommandParams;

         // Constructors and Destructors
         constructor Create; overload;
         constructor Create(_Command: longint; var _Params: TCommandParams); overload;
         destructor Destroy; override;
   end;

implementation

constructor TControllerObjectCommandItem.Create;
begin
   Params := nil;
   Command := 0;
end;

constructor TControllerObjectCommandItem.Create(_Command: longint; var _Params: TCommandParams);
begin
   Params := _Params;
   Command := _Command;
end;

destructor TControllerObjectCommandItem.Destroy;
begin
   if Params <> nil then
   begin
      Params.Free;
   end;
   inherited Destroy;
end;

end.
