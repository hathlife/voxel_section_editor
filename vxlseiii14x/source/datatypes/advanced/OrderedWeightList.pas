unit OrderedWeightList;

// Muniz Binary Tree v1.0
// Created by Banshee

// A somewhat ballanced binary tree. It is an ion cannon made to kill an ant, basically.
// It codifies an ordered list that allows you to browse it as a linked list and a
// binary tree at the same time. You can also browse the whole binary tree starting
// from a leaf.

// Operations such as Add, Find and Delete happens on O(log(n)) in most of the
// situations.

// Feel free to use it in your program, as long as I'm credited.

interface

uses BasicDataTypes;

type
   TCompareValueFunction = function (_Value1, _Value2 : single): boolean of object;
   TAddValueMethod = procedure (_Value: integer) of object;
   TDeleteValueMethod = procedure of object;
   COrderedWeightList = class
      private
         Root,First,Last,NumElements,NextID: integer;
         IsHigher: TCompareValueFunction;

         // These vectors are what make this structure be expensive.
         FLeft, FRight, FFather, FPrevious, FNext: aint32;
         FWeight: afloat;

         // Comparisons
         function IsHigherAscendent(_Value1, _Value2: single): boolean;
         function IsHigherDescendent(_Value1, _Value2: single): boolean;

         // Gets
         function GetLeft(_value: integer): integer;
         function GetRight(_value: integer): integer;
         function GetFather(_value: integer): integer;
         function GetWeight(_value: integer): single;
         function GetNext(_value: integer): integer;
         function GetPrevious(_value: integer): integer;
      public
         // Constructors and Destructors
         constructor Create;
         destructor Destroy; override;

         // Add
         function Add (_Value : single): integer;
         procedure Delete(_ID: integer);
         // Delete
         procedure Reset;
         procedure Clear;
         procedure ClearBuffers;
         // Sets
         procedure SetRAMSize(_Value: integer);
         procedure SetAscendentOrder;
         procedure SetDecendentOrder;
         // Gets
         function GetValue (var _Weight : single): integer;
         // Misc
         function GetFirstElement: integer;
         function GetLastElement: integer;

         // Data should be browsable by public.
         property Left[_Value: integer]: integer read GetLeft;
         property Right[_Value: integer]: integer read GetRight;
         property Father[_Value: integer]: integer read GetFather;
         property Weight[_Value: integer]: single read GetWeight;
         property Next[_Value: integer]: integer read GetNext;
         property Previous[_Value: integer]: integer read GetPrevious;
   end;

implementation

constructor COrderedWeightList.Create;
begin
   Clear;
   SetAscendentOrder;
end;

destructor COrderedWeightList.Destroy;
begin
   Clear;
   inherited Destroy;
end;

procedure COrderedWeightList.Reset;
begin
   Root := -1;
   First := -1;
   Last := -1;
   NumElements := 0;
   NextID := 0;
end;

// Add
function COrderedWeightList.Add (_Value : single): integer;
var
   i,Daddy,Grandpa,GrandGrandPa: integer;
   goLeft: boolean;
begin
   // Find out next writable element.
   Result := -1;
   i := 0;
   // Find out a potential destination for this new element.
   if NextID <= High(FLeft) then
   begin
      // Quickly assign a destination.
      Result := NextID;
   end
   else
   begin
      // Try to find as destination a previously deleted element.
      while (i <= High(FLeft)) and (Result = -1) do
      begin
         if (FLeft[i] = -1) and (FRight[i] = -1) and (FFather[i] = -1) and (FWeight[i] = -1) then
         begin
            Result := i;
         end;
         inc(i);
      end;
   end;
   // Can we add this element?
   if Result <> -1 then
   begin
      // Let's add it then.
      inc(NumElements);
      FLeft[Result] := -1;
      FRight[Result] := -1;
      FWeight[Result] := _Value;
      i := Root;
      // Is it the first element?
      if i <> -1 then
      begin
         // This is not the first element. Let's search its position there.
         while i <> -1 do
         begin
            Daddy := i;
            if isHigher(FWeight[i],_Value) then
            begin
               i := FLeft[i];
               goLeft := true;
            end
            else
            begin
               i := FRight[i];
               goLeft := false;
            end;
         end;
         // Now we have an idea of the location of this element in the binary tree.
         // First, let's try to make it look more ballanced.
         if Daddy <> Root then
         begin
            Grandpa := FFather[Daddy];
            if Grandpa <> -1 then
            begin
               GrandGrandPa := FFather[GrandPa];
               if goLeft then
               begin
                  if FRight[Daddy] = -1 then
                  begin
                     if FRight[Grandpa] = -1 then
                     begin
                        if GrandGrandPa <> -1 then
                        begin
                           if FLeft[GrandGrandPa] = GrandPa then
                              FLeft[GrandGrandPa] := Daddy
                           else
                              FRight[GrandGrandPa] := Daddy;
                        end
                        else
                        begin
                           Root := Daddy
                        end;
                        FRight[Daddy] := GrandPa;
                        FLeft[Daddy] := Result;
                        FNext[Result] := Daddy;
                        FPrevious[Result] := FPrevious[Daddy];
                        FPrevious[Daddy] := Result;
                        FLeft[GrandPa] := -1;
                        FFather[Daddy] := GrandGrandPa;
                        FFather[GrandPa] := Daddy;
                        FFather[Result] := Daddy;
                     end
                     else if FLeft[Grandpa] = -1 then
                     begin
                        if GrandGrandPa <> -1 then
                        begin
                           if FLeft[GrandGrandPa] = GrandPa then
                              FLeft[GrandGrandPa] := Result
                           else
                              FRight[GrandGrandPa] := Result;
                        end
                        else
                        begin
                           Root := Result;
                        end;
                        FRight[Daddy] := -1;
                        FLeft[Daddy] := -1;
                        FLeft[GrandPa] := -1;
                        FRight[GrandPa] := -1;
                        FLeft[Result] := GrandPa;
                        FRight[Result] := Daddy;
                        FNext[Result] := Daddy;
                        FPrevious[Result] := FPrevious[Daddy];
                        FPrevious[Daddy] := Result;
                        FFather[Result] := GrandGrandPa;
                        FFather[Daddy] := Result;
                        FFather[GrandPa] := Result;
                     end
                     else
                     begin
                        FLeft[Daddy] := Result;
                        FFather[Result] := Daddy;
                        FNext[Result] := Daddy;
                        FPrevious[Result] := FPrevious[Daddy];
                        FPrevious[Daddy] := Result;
                     end;
                  end
                  else
                  begin
                     FLeft[Daddy] := Result;
                     FFather[Result] := Daddy;
                     FNext[Result] := Daddy;
                     FPrevious[Result] := FPrevious[Daddy];
                     FPrevious[Daddy] := Result;
                  end;
               end
               else  // goRight
               begin
                  if FLeft[Daddy] = -1 then
                  begin
                     if FRight[Grandpa] = -1 then
                     begin
                        if GrandGrandPa <> -1 then
                        begin
                           if FLeft[GrandGrandPa] = GrandPa then
                              FLeft[GrandGrandPa] := Result
                           else
                              FRight[GrandGrandPa] := Result;
                        end
                        else
                        begin
                           Root := Result;
                        end;
                        FRight[Daddy] := -1;
                        FLeft[Daddy] := -1;
                        FLeft[GrandPa] := -1;
                        FRight[GrandPa] := -1;
                        FLeft[Result] := Daddy;
                        FRight[Result] := GrandPa;
                        FNext[Result] := GrandPa;
                        FPrevious[Result] := FPrevious[GrandPa];
                        FPrevious[GrandPa] := Result;
                        FFather[Result] := GrandGrandPa;
                        FFather[GrandPa] := Result;
                        FFather[Daddy] := Result;
                     end
                     else if FLeft[Grandpa] = -1 then
                     begin
                        if GrandGrandPa <> -1 then
                        begin
                           if FLeft[GrandGrandPa] = GrandPa then
                              FLeft[GrandGrandPa] := Daddy
                           else
                              FRight[GrandGrandPa] := Daddy;
                        end
                        else
                        begin
                           Root := Daddy;
                        end;
                        FRight[Daddy] := Result;
                        FPrevious[Result] := Daddy;
                        FNext[Result] := FNext[Daddy];
                        FNext[Daddy] := Result;
                        FLeft[Daddy] := GrandPa;
                        FRight[GrandPa] := -1;
                        FFather[Daddy] := GrandGrandPa;
                        FFather[Result] := Daddy;
                        FFather[GrandPa] := Daddy;
                     end
                     else
                     begin
                        FRight[Daddy] := Result;
                        FFather[Result] := Daddy;
                        FPrevious[Result] := Daddy;
                        FNext[Result] := FNext[Daddy];
                        FNext[Daddy] := Result;
                     end;
                  end
                  else
                  begin
                     FRight[Daddy] := Result;
                     FFather[Result] := Daddy;
                     FPrevious[Result] := Daddy;
                     FNext[Result] := FNext[Daddy];
                     FNext[Daddy] := Result;
                  end;
               end;
            end
            else
            begin
               if goLeft then
               begin
                  FLeft[Daddy] := Result;
                  FNext[Result] := Daddy;
                  FPrevious[Result] := FPrevious[Daddy];
                  FPrevious[Daddy] := Result;
               end
               else
               begin
                  FRight[Daddy] := Result;
                  FPrevious[Result] := Daddy;
                  FNext[Result] := FNext[Daddy];
                  FNext[Daddy] := Result;
               end;
               FFather[Result] := Daddy;
            end;
         end
         else
         begin
            if goLeft then
            begin
               FLeft[Daddy] := Result;
               FNext[Result] := Daddy;
               FPrevious[Result] := FPrevious[Daddy];
               FPrevious[Daddy] := Result;
            end
            else
            begin
               FRight[Daddy] := Result;
               FPrevious[Result] := Daddy;
               FNext[Result] := FNext[Daddy];
               FNext[Daddy] := Result;
            end;
            FFather[Result] := Daddy;
         end;
      end
      else // this is the first element.
      begin
         Root := Result;
         First := Result;
         Last := Result;
         FFather[Result] := -1;
         FNext[Result] := -1;
         FPrevious[Result] := -1;
      end;
      if goLeft then
      begin
         if not IsHigher(FWeight[First],FWeight[Result]) then
         begin
            First := Result;
         end;
      end
      else
      begin
         if IsHigher(FWeight[Last],FWeight[Result]) then
         begin
            Last := Result;
         end;
      end;

   end;
   // else, the element cannot be added and it will return -1.
end;

// Delete
procedure COrderedWeightList.Delete(_ID : integer);
var
   Brother,Daddy,NewDaddy,GrandPa,GrandGrandPa : integer;
   IsLeftSon: boolean;
begin
   if (_ID >= 0) and (_ID <= High(FLeft)) then
   begin
      // If it is a leaf, it's just a quick deletion.
      Daddy := FFather[_ID];
      if (FLeft[_ID] = -1) and (FRight[_ID] = -1) then
      begin
         if Daddy <> -1 then
         begin
            // disconnect it from the binary tree.
            if FLeft[Daddy] = _ID then
            begin
               FLeft[Daddy] := -1;
               IsLeftSon := true;
               if First = _ID then
                  First := Daddy;
               Brother := FRight[Daddy];
            end
            else
            begin
               FRight[Daddy] := -1;
               IsLeftSon := false;
               if Last = _ID then
                  Last := Daddy;
               Brother := FLeft[Daddy];
            end;
            // Reballance the binary tree if possible.
            if Brother <> -1 then
            begin
               GrandPa := FFather[Daddy];
               if GrandPa <> -1 then
               begin
                  GrandGrandPa := FFather[GrandPa];
                  if FLeft[GrandPa] <> -1 then
                  begin
                     if FRight[GrandPa] = -1 then
                     begin
                        if IsLeftSon then
                        begin
                           if GrandGrandPa <> -1 then
                           begin
                              if FLeft[GrandGrandPa] = GrandPa then
                              begin
                                 FLeft[GrandGrandPa] := Brother;
                              end
                              else
                              begin
                                 FRight[GrandGrandPa] := Brother;
                              end;
                              FFather[Brother] := GrandGrandPa;
                           end
                           else
                           begin
                              Root := Brother;
                              FFather[Brother] := -1;
                           end;
                           FRight[Daddy] := FLeft[Brother];
                           FLeft[GrandPa] := FRight[Brother];
                           FLeft[Brother] := Daddy;
                           FRight[Brother] := GrandPa;
                           FFather[Daddy] := Brother;
                           FFather[GrandPa] := Brother;
                           if First = _ID then
                              First := Daddy;
                        end
                        else
                        begin
                           if GrandGrandPa <> -1 then
                           begin
                              if FLeft[GrandGrandPa] = GrandPa then
                              begin
                                 FLeft[GrandGrandPa] := Daddy;
                              end
                              else
                              begin
                                 FRight[GrandGrandPa] := Daddy;
                              end;
                              FFather[Daddy] := GrandGrandPa;
                           end
                           else
                           begin
                              Root := Daddy;
                              FFather[Daddy] := -1;
                           end;
                           FRight[Daddy] := GrandPa;
                           FFather[GrandPa] := Daddy;
                           FLeft[GrandPa] := -1;
                           FRight[GrandPa] := -1;
                        end;
                     end;
                  end
                  else if FRight[GrandPa] <> -1 then
                  begin
                     if IsLeftSon then
                     begin
                        if GrandGrandPa <> -1 then
                        begin
                           if FLeft[GrandGrandPa] = GrandPa then
                           begin
                              FLeft[GrandGrandPa] := Daddy;
                           end
                           else
                           begin
                              FRight[GrandGrandPa] := Daddy;
                           end;
                           FFather[Daddy] := GrandGrandPa;
                        end
                        else
                        begin
                           Root := Daddy;
                           FFather[Daddy] := -1;
                        end;
                        FLeft[Daddy] := GrandPa;
                        FFather[GrandPa] := Daddy;
                        FLeft[GrandPa] := -1;
                        FRight[GrandPa] := -1;
                     end
                     else
                     begin
                        if GrandGrandPa <> -1 then
                        begin
                           if FLeft[GrandGrandPa] = GrandPa then
                           begin
                              FLeft[GrandGrandPa] := Brother;
                           end
                           else
                           begin
                              FRight[GrandGrandPa] := Brother;
                           end;
                           FFather[Brother] := GrandGrandPa;
                        end
                        else
                        begin
                           Root := Brother;
                           FFather[Brother] := -1;
                        end;
                        FLeft[Daddy] := FRight[Brother];
                        FRight[GrandPa] := FLeft[Brother];
                        FLeft[Brother] := GrandPa;
                        FRight[Brother] := Daddy;
                        FFather[GrandPa] := Brother;
                        FFather[Daddy] := Brother;
                        if Last = _ID then
                           Last := Daddy;
                     end;
                  end;
               end;
            end;
         end
         else // this was the only element of the binary tree.
         begin
            Root := -1;
            First := -1;
            Last := -1;
         end;

      end
      else // this is not a leaf.
      begin
         if (FLeft[_ID] <> -1) and (FRight[_ID] = -1) then
         begin
            if Daddy <> -1 then
            begin
               if FLeft[Daddy] = _ID then
               begin
                  FLeft[Daddy] := FLeft[_ID];
               end
               else
               begin
                  FRight[Daddy] := FLeft[_ID];
               end;
               FFather[FLeft[_ID]] := Daddy;
            end
            else
            begin
               Root := FLeft[_ID];
            end;
            if Last = _ID then
            begin
               Last := FLeft[_ID];
            end;
         end
         else if (FRight[_ID] <> -1) and (FLeft[_ID] = -1) then
         begin
            if Daddy <> -1 then
            begin
               if FLeft[Daddy] = _ID then
               begin
                  FLeft[Daddy] := FRight[_ID];
               end
               else
               begin
                  FRight[Daddy] := FRight[_ID];
               end;
               FFather[FRight[_ID]] := Daddy;
            end
            else
            begin
               Root := FLeft[_ID];
            end;
            if First = _ID then
            begin
               First := FRight[_ID];
            end;
         end
         else
         begin
            if Daddy <> -1 then
            begin
               NewDaddy := FNext[_ID];
               if FLeft[Daddy] = _ID then
               begin
                  FLeft[Daddy] := NewDaddy;
               end
               else
               begin
                  FRight[Daddy] := NewDaddy;
               end;
               if FLeft[FFather[NewDaddy]] = NewDaddy then
               begin
                  FLeft[FFather[NewDaddy]] := -1;
               end
               else
               begin
                  FRight[FFather[NewDaddy]] := -1;
               end;
               FFather[NewDaddy] := Daddy;
               if FLeft[_ID] <> NewDaddy then
               begin
                  FLeft[NewDaddy] := FLeft[_ID];
                  FFather[FLeft[_ID]] := NewDaddy;
               end
               else
               begin
                  FLeft[NewDaddy] := -1;
               end;
               if FRight[_ID] <> NewDaddy then
               begin
                  FRight[NewDaddy] := FRight[_ID];
                  FFather[FRight[_ID]] := NewDaddy;
               end
               else
               begin
                  FRight[NewDaddy] := -1;
               end;
            end
            else
            begin
               Root := FNext[_ID];
               if FLeft[FFather[Root]] = Root then
               begin
                  FLeft[FFather[Root]] := -1;
               end
               else
               begin
                  FRight[FFather[Root]] := -1;
               end;
               FFather[Root] := -1;
               if FLeft[_ID] <> Root then
               begin
                  FLeft[Root] := FLeft[_ID];
                  FFather[FLeft[_ID]] := Root;
               end
               else
               begin
                  FLeft[Root] := -1;
               end;
               if FRight[_ID] <> Root then
               begin
                  FRight[Root] := FRight[_ID];
                  FFather[FRight[_ID]] := Root;
               end
               else
               begin
                  FRight[Root] := -1;
               end;
            end;
         end;
      end;

      FLeft[_ID] := -1;
      FRight[_ID] := -1;
      FFather[_ID] := -1;
      FWeight[_ID] := -1;
      if FPrevious[_ID] <> -1 then
         FNext[FPrevious[_ID]] := FNext[_ID];
      if FNext[_ID] <> -1 then
         FPrevious[FNext[_ID]] := FPrevious[_ID];
      FPrevious[_ID] := -1;
      FNext[_ID] := -1;
      dec(NumElements);
   end;
end;

procedure COrderedWeightList.Clear;
begin
   SetRAMSize(0);
   Reset;
end;

procedure COrderedWeightList.ClearBuffers;
var
   i: integer;
begin
   for i := Low(FLeft) to High(FLeft) do
   begin
      FLeft[i] := -1;
      FRight[i] := -1;
      FFather[i] := -1;
   end;
end;

// Sets
procedure COrderedWeightList.SetRAMSize(_Value: integer);
begin
   if (_Value >= 0) then
   begin
      SetLength(FLeft, _Value);
      SetLength(FRight, _Value);
      SetLength(FFather, _Value);
      SetLength(FWeight, _Value);
      ClearBuffers;
   end;
end;

procedure COrderedWeightList.SetAscendentOrder;
begin
   IsHigher := IsHigherAscendent;
end;

procedure COrderedWeightList.SetDecendentOrder;
begin
   IsHigher := IsHigherDescendent;
end;

// Gets
function COrderedWeightList.GetValue (var _Weight : single): integer;
begin
   Result := Root;
   while Result <> -1 do
   begin
      if FWeight[Result] = _Weight then
      begin
         exit;
      end;
      if isHigher(FWeight[Result],_Weight) then
      begin
         Result := FLeft[Result];
      end
      else
      begin
         Result := FRight[Result];
      end;
   end;
end;

function COrderedWeightList.GetLeft(_value: integer): integer;
begin
   Result := FLeft[_Value];
end;

function COrderedWeightList.GetRight(_value: integer): integer;
begin
   Result := FRight[_Value];
end;

function COrderedWeightList.GetFather(_value: integer): integer;
begin
   Result := FFather[_Value];
end;

function COrderedWeightList.GetWeight(_value: integer): single;
begin
   Result := FWeight[_Value];
end;

function COrderedWeightList.GetNext(_value: integer): integer;
begin
   Result := FNext[_Value];
end;

function COrderedWeightList.GetPrevious(_value: integer): integer;
begin
   Result := FPrevious[_Value];
end;


// Comparisons
function COrderedWeightList.IsHigherAscendent(_value1, _value2: single): boolean;
begin
   Result := _Value2 >= _Value1;
end;

function COrderedWeightList.IsHigherDescendent(_value1, _value2: single): boolean;
begin
   Result := _Value1 >= _Value2;
end;

// Misc
function COrderedWeightList.GetFirstElement: integer;
begin
   Result := First;
end;

function COrderedWeightList.GetLastElement: integer;
begin
   Result := Last;
end;

end.
