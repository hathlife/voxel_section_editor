unit ModelUndoEngine;

interface

uses Model, BasicDataTypes, BasicFunctions;

type
   TModelUndoRedo = class
      private
         FMaxStackSize: cardinal;
         FIsStackLimited: boolean;
         FModels: array of array of TModel;
         FLabels: array of array of string;
         FIDs: array of integer;
         // Constructors and Destructors;
         procedure Clear;
         // Gets
         function GetSize(_ModelID: integer): integer;
         function GetLabel(_ModelID, _LabelID: integer): string;
         function GetPosition(var _ModelID: integer): boolean;
      public
         // Constructors and Destructors;
         constructor Create;
         destructor Destroy; override;
         // Add and remove
         procedure Add(var _Model: TModel; const _Label: string);
         procedure Remove(_ModelID: integer);
         function Restore(_ModelID, _NumMoves: integer): TModel;
         // Properties
         property MaxStackSize: cardinal read FMaxStackSize;
         property Size[_ModelID: integer]: integer read GetSize;
         property Labels[_ModelID, _LabelID: integer]: string read GetLabel;
   end;


implementation

// Constructors and Destructors
constructor TModelUndoRedo.Create;
begin
   SetLength(FModels, 0);
   SetLength(FLabels, 0);
   SetLength(FIDs, 0);
   FIsStackLimited := false;
   FMaxStackSize := 10;
end;

destructor TModelUndoRedo.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure TModelUndoRedo.Clear;
var
   i,j: integer;
begin
   i := 0;
   while i <= High(FModels) do
   begin
      j := Low(FModels[i]);
      while j <= High(FModels[i]) do
      begin
         FModels[i, j].Free;
         FLabels[i, j] := '';
      end;
      SetLength(FModels[i], 0);
      SetLength(FLabels[i], 0);
      inc(i);
   end;
   SetLength(FModels, 0);
   SetLength(FLabels, 0);
   SetLength(FIDs, 0);
end;

// Add and remove.
procedure TModelUndoRedo.Add(var _Model: TModel; const _Label: string);
var
   i, j: integer;
begin
   // locate i first.
   i := _Model.ID;
   if not GetPosition(i) then
   begin
      SetLength(FIDs, High(FIDs) + 2);
      i := High(FIDs);
      FIDs[High(FIDs)] := _Model.ID;
      SetLength(FModels, High(FModels) + 2);
      SetLength(FLabels, High(FLabels) + 2);
      SetLength(FModels[i], 0);
      SetLength(FLabels[i], 0);
   end;
   // Now we check for potential restrictions and alocate memory for it, if needed.
   if FIsStackLimited then
   begin
      if High(FModels[i]) >= FMaxStackSize then
      begin
         // remove first element.
         FModels[i, 0].Free;
         j := 0;
         while j < High(FModels[i]) do
         begin
            FModels[i, j] := FModels[i, j+1];
            FLabels[i, j] := CopyString(FLabels[i, j+1]);
            inc(j);
         end;
      end
      else
      begin
         SetLength(FModels[i], High(FModels[i])+2);
         SetLength(FLabels[i], High(FModels[i])+1);
      end;
   end
   else
   begin
      SetLength(FModels[i], High(FModels[i])+2);
      SetLength(FLabels[i], High(FModels[i])+1);
   end;
   // Now we add the model.
   FModels[i, High(FModels[i])] := TModel.Create(_Model);
   FModels[i, High(FModels[i])].ID := _Model.ID;
   FLabels[i, High(FLabels[i])] := CopyString(_Label);
end;

procedure TModelUndoRedo.Remove(_ModelID: integer);
var
   j: integer;
   Position: integer;
begin
   Position := _ModelID;
   if GetPosition(Position) then
   begin
      // clear memory
      j := Low(FModels[Position]);
      while j <= High(FModels[Position]) do
      begin
         FModels[Position, j].Free;
         FLabels[Position, j] := '';
         inc(j);
      end;
      SetLength(FModels[Position], 0);
      SetLength(FLabels[Position], 0);
      // swap the other models
      j := Position;
      while j < High(FModels) do
      begin
         FIDs[j] := FIDs[j + 1];
         FModels[j] := FModels[j + 1];
         FLabels[j] := FLabels[j + 1];
         inc(j);
      end;
      // remove last element.
      SetLength(FModels, High(FModels));
      SetLength(FLabels, High(FLabels));
      SetLength(FIDs, High(FIDs));
   end;
end;

function TModelUndoRedo.Restore(_ModelID, _NumMoves: Integer): TModel;
var
   i: integer;
   Position: integer;
begin
   Position := _ModelID;
   Result := nil;
   if GetPosition(Position) then
   begin
      if _NumMoves > (High(FModels[Position])+1) then
      begin
         Result := nil;
         Clear;
      end
      else
      begin
         i := 0;
         while i < _NumMoves do
         begin
            FModels[Position, High(FModels)-i].Free;
            inc(i);
         end;
         Result := FModels[Position, High(FModels[Position])-i];
         SetLength(FModels[Position], High(FModels[Position])-i);
      end;
   end;
end;

// Gets
function TModelUndoRedo.GetSize(_ModelID: integer): integer;
var
   Position: integer;
begin
   Position := _ModelID;
   if GetPosition(Position) then
   begin
      Result := High(FModels[Position])+1;
   end
   else
   begin
      Result := 0;
   end;
end;

function TModelUndoRedo.GetLabel(_ModelID, _LabelID: integer): string;
var
   Position: integer;
begin
   Position := _ModelID;
   if GetPosition(Position) then
   begin
      if (_LabelID >= 0) and (_LabelID <= High(FLabels[Position])) then
      begin
         Result := FLabels[Position, _LabelID];
      end
      else
      begin
         Result := '';
      end;
   end
   else
   begin
      Result := '';
   end;
end;

function TModelUndoRedo.GetPosition(var _ModelID: integer): boolean;
var
   i: integer;
begin
   // locate i first.
   i := 0;
   Result := false;
   while (i <= High(FIDs)) and (not Result) do
   begin
      if FIDs[i] = _ModelID then
      begin
         _ModelID := i;
         Result := true;
      end
      else
      begin
         inc(i);
      end;
   end;
end;

end.
