unit FloatSpinEdit;

interface

uses Classes, QComCtrls, Qt, SysUtils, QConsts, QForms;

procedure CheckRange(AMin, AMax: Real);

type
   TFloatSpinEdit = class(TCustomSpinEdit)
      private
         FMin: Real;
         FMax: Real;
         FValue: Real;
         FOnChanged: TSEChangedEvent;
         function GetIncrement: Real;
         function GetMax: Real;
         function GetMin: Real;
         function GetValue: Real;
         procedure SetIncrement(AValue: Real);
         procedure SetMax(AValue: Real);
         procedure SetMin(AValue: Real);
         procedure SetValue(const AValue: Real);
         procedure SetRange(const AMin, AMax: Real);
         procedure ValueChangedHook(AValue: Real); cdecl;
      protected
         procedure Change(AValue: Real); dynamic;
         procedure HookEvents; override;
         property Max: Real read GetMax write SetMax;
         property Min: Real read GetMin write SetMin;
         property Increment: Real read GetIncrement write SetIncrement;
         property Value: Real read GetValue write SetValue;
         property OnChanged: TSEChangedEvent read FOnChanged write FOnChanged;
      public
   end;

implementation

procedure CheckRange(AMin, AMax: Real);
begin
  if (AMax < AMin) or (AMin > AMax) then
    raise ERangeException.Create(Format(SInvalidRangeError,[AMin, AMax]));
end;

function TFloatSpinEdit.GetIncrement: Real;
begin
  Result := QSpinBox_lineStep(Handle);
end;

function TFloatSpinEdit.GetMax: Real;
begin
  Result := QSpinBox_maxValue(Handle);
end;

function TFloatSpinEdit.GetMin: Real;
begin
  Result := QSpinBox_minValue(Handle);
end;

procedure TFloatSpinEdit.SetMin(AValue: Real);
begin
  if (csLoading in ComponentState) then
    SetRange(AValue, FMax)
  else
    SetRange(AValue, Max);
end;

procedure TFloatSpinEdit.SetMax(AValue: Real);
begin
  if (csLoading in ComponentState) then
    SetRange(FMin, AValue)
  else
    SetRange(Min, AValue);
end;

procedure TFloatSpinEdit.SetIncrement(AValue: Real);
begin
  QSpinBox_setLineStep(Handle, Round(AValue));
end;

procedure TFloatSpinEdit.SetRange(const AMin, AMax: Real);
begin
  FMin := AMin;
  FMax := AMax;

  if not HandleAllocated or (csLoading in ComponentState) then
    Exit;

  try
    CheckRange(AMin, AMax);
  except
    FMin := Min;
    FMax := Max;
    raise;
  end;

  QRangeControl_setRange(RangeControl, Round(FMin), Round(FMax));

  if Value < Min then
    Value := Min
  else if Value > Max then Value := Max;
end;

procedure TFloatSpinEdit.ValueChangedHook(AValue: Real);
begin
  try
    Change(AValue);
  except
    Application.HandleException(Self);
  end;
end;

function TFloatSpinEdit.GetValue: Real;
begin
  Result := StrToFloatDef(CleanText, Min);
end;

procedure TFloatSpinEdit.SetValue(const AValue: Real);
var
  TempV: WideString;
begin
  if AValue <> FValue then
  begin
    FValue := AValue;
    if FValue < FMin then
      FValue := FMin;
    if FValue > FMax then
      FValue := FMax;
    if not (csLoading in ComponentState) then
      QSpinBox_setValue(Handle, Round(FValue));
  end;
  if not (csLoading in ComponentState) then
  begin
    TempV := Prefix + FloatToStr(FValue) + Suffix;
    if (SpecialText <> '') and (FValue = FMin) then
      TempV := SpecialText;
    QLineEdit_setText(QClxSpinBox_editor(Handle), PWideString(@TempV));
  end;
end;

procedure TFloatSpinEdit.Change(AValue: Real);
begin
  FValue := AValue;
  if Assigned(FOnChanged) then
    FOnChanged(Self, Round(AValue));
end;

procedure TFloatSpinEdit.HookEvents;
var
  Method: TMethod;
begin
  inherited HookEvents;
  QSpinBox_valueChanged_Event(Method) := Round(ValueChangedHook);
  QSpinBox_hook_hook_valueChanged(QSpinBox_hookH(Hooks), Method);
end;

end.
