unit ControllerObjectItem;

interface

uses ControllerObjectCommandList, ControllerDataTypes;

type
   TControllerObjectItem = class
      public
         ObjectID: Pointer;
         BaseObjectID: Pointer;
         CommandList: TControllerObjectCommandList;

         // constructors and destructors
         constructor Create(_Object: Pointer);
         destructor Destroy; override;
   end;

implementation

constructor TControllerObjectItem.Create(_Object: Pointer);
begin
   ObjectID := _Object;
   BaseObjectID := nil;
   CommandList := TControllerObjectCommandList.Create;
end;

destructor TControllerObjectItem.Destroy;
begin
   CommandList.Free;
   inherited Destroy;
end;

end.
