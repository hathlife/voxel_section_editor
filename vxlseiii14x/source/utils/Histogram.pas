unit Histogram;

interface

uses AbstractDataSet,SingleDataSet,IntDataSet,SysUtils;

type
   THistogram = class
      protected
         FElements: TAbstractDataSet;
         FCounter: TAbstractDataSet;
         FTotalCount: integer;
         // Constructor
         procedure Initialize;
         // Gets
         function GetElement(_ID: integer): single;
         function GetElementUnsafe(_ID: integer): single;
         function GetCounter(_ID: integer): integer;
         function GetCounterUnsafe(_ID: integer): integer;
         function GetSize: integer;
         function GetLast: integer;
         function GetAverageCounter: single;
         function GetTotalCount: integer;
         // ReOrder
         procedure QuickSortElementsAscendent(_min, _max : integer);
         procedure QuickSortElementsDescendent(_min, _max : integer);
         procedure QuickSortCounterAscendent(_min, _max : integer);
         procedure QuickSortCounterDescendent(_min, _max : integer);
      public
         // Constructors and destructors
         constructor Create;
         destructor Destroy; override;
         procedure Clear;
         // I/O
         procedure SaveAsCSV(const _Filename,_ElementsLabel,_QuantityLabel,_PercentageLabel,_AverageLabel: string); overload;
         procedure SaveAsCSV(const _Filename: string); overload;
         // Adds
         procedure AddToHistogram(_Element: single);
         // ReOrder
         procedure ReOrderByElementsAscendently;
         procedure ReOrderByElementsDescendently;
         procedure ReOrderByCounterAscendently;
         procedure ReOrderByCounterDescendently;
         // Properties
         property Size:integer read GetSize;
         property Last:integer read GetLast;
         property TotalCount:integer read GetTotalCount;
         property Elements[_ID: integer]: single read GetElementUnsafe;
         property ElementsSafe[_ID: integer]: single read GetElement;
         property Counters[_ID: integer]: integer read GetCounterUnsafe;
         property CountersSafe[_ID: integer]: integer read GetCounter;
   end;

implementation

// Constructors and destructors
constructor THistogram.Create;
begin
   Initialize;
end;

destructor THistogram.Destroy;
begin
   FElements.Free;
   FCounter.Free;
   inherited Destroy;
end;

procedure THistogram.Clear;
begin
   FElements.Length := 0;
   FCounter.Length := 0;
   FTotalCount := 0;
end;

procedure THistogram.Initialize;
begin
   FElements := TSingleDataSet.Create;
   FCounter := TIntDataSet.Create;
   Clear;
end;

// I/O
procedure THistogram.SaveAsCSV(const _Filename,_ElementsLabel,_QuantityLabel,_PercentageLabel,_AverageLabel: string);
var
   CSVFile: System.Text;
   i,config : integer;
   ElementsLabel : string;
begin
   config := 0;
   if Length(_ElementsLabel) > 0 then
   begin
      ElementsLabel := copy(_ElementsLabel,1,Length(_ElementsLabel));
   end
   else
   begin
      ElementsLabel := 'Elements';
   end;
   if Length(_QuantityLabel) > 0 then
   begin
      config := config or 1;
   end;
   if Length(_PercentageLabel) > 0 then
   begin
      config := config or 2;
   end;
   DecimalSeparator := ',';
   AssignFile(CSVFIle,_Filename);
   Rewrite(CSVFile);
   case config of
      0:
      begin
         WriteLn(CSVFile,'"' + ElementsLabel + '"');
         for i := 0 to FElements.Last do
         begin
            WriteLn(CSVFile,FloatToStr(GetElement(i)));
         end;
      end;
      1:
      begin
         WriteLn(CSVFile,'"' + ElementsLabel + '";"' + _QuantityLabel + '"');
         for i := 0 to FElements.Last do
         begin
            WriteLn(CSVFile,FloatToStr(GetElement(i)) + ';' + IntToStr(GetCounter(i)));
         end;
      end;
      2:
      begin
         WriteLn(CSVFile,'"' + ElementsLabel + '";"' + _PercentageLabel + '"');
         for i := 0 to FElements.Last do
         begin
            WriteLn(CSVFile,FloatToStr(GetElement(i)) + ';' + FloatToStr(GetCounter(i) / FTotalCount));
         end;
      end;
      3:
      begin
         WriteLn(CSVFile,'"' + ElementsLabel + '";"' + _QuantityLabel + '";"' + _PercentageLabel + '"');
         for i := 0 to FElements.Last do
         begin
            WriteLn(CSVFile,FloatToStr(GetElement(i)) + ';' + IntToStr(GetCounter(i)) + ';' + FloatToStr(GetCounter(i) / FTotalCount));
         end;
      end;
   end;
   if Length(_AverageLabel) > 0 then
   begin
      WriteLn(CSVFile,'');
      WriteLn(CSVFile,'"' + _AverageLabel + '";' + FloatToStr(GetAverageCounter()));
   end;
   CloseFile(CSVFIle);
end;

procedure THistogram.SaveAsCSV(const _Filename: string);
begin
   SaveAsCSV(_Filename,'Elements','Quantity','%:','Average:');
end;


// Gets
function THistogram.GetElement(_ID: integer): single;
begin
   Result := -1;
   if (_ID >= 0) and (_ID <= FElements.Last) then
   begin
      Result := (FElements as TSingleDataSet).Data[_ID];
   end;
end;

function THistogram.GetElementUnsafe(_ID: integer): single;
begin
   Result := (FElements as TSingleDataSet).Data[_ID];
end;

function THistogram.GetCounter(_ID: integer): integer;
begin
   Result := -1;
   if (_ID >= 0) and (_ID <= FElements.Last) then
   begin
      Result := (FCounter as TIntDataSet).Data[_ID];
   end;
end;

function THistogram.GetCounterUnsafe(_ID: integer): integer;
begin
   Result := (FCounter as TIntDataSet).Data[_ID];
end;

function THistogram.GetSize: integer;
begin
   Result := FElements.Length;
end;

function THistogram.GetLast: integer;
begin
   Result := FElements.Last;
end;

function THistogram.GetAverageCounter: single;
var
   i : integer;
begin
   Result := 0;
   for i := 0 to FElements.Last do
   begin
      Result := Result + ((FElements as TSingleDataSet).Data[i] * (FCounter as TIntDataSet).Data[i]);
   end;
   Result := Result / FTotalCount;
end;

function THistogram.GetTotalCount: integer;
begin
   Result := FTotalCount;
end;

// Adds
procedure THistogram.AddToHistogram(_Element: single);
var
   i : integer;
begin
   inc(FTotalCount);
   i := 0;
   while i <= FElements.Last do
   begin
      if _Element = (FElements as TSingleDataSet).Data[i] then
      begin
         (FCounter as TIntDataSet).Data[i] := (FCounter as TIntDataSet).Data[i] + 1;
         exit;
      end;
      inc(i);
   end;
   // element not found. Add a new element.
   FElements.Length := FElements.Length + 1;
   FCounter.Length := FCounter.Length + 1;
   (FElements as TSingleDataSet).Data[FElements.Last] := _Element;
   (FCounter as TIntDataSet).Data[FCounter.Last] := 1;
end;

// ReOrder
procedure THistogram.ReOrderByElementsAscendently;
begin
   QuickSortElementsAscendent(0,FElements.Last);
end;

procedure THistogram.ReOrderByElementsDescendently;
begin
   QuickSortElementsDescendent(0,FElements.Last);
end;

procedure THistogram.ReOrderByCounterAscendently;
begin
   QuickSortCounterAscendent(0,FElements.Last);
end;

procedure THistogram.ReOrderByCounterDescendently;
begin
   QuickSortCounterDescendent(0,FElements.Last);
end;

procedure THistogram.QuickSortElementsAscendent(_min, _max : integer);
var
   Lo, Hi, Mid, T: Integer;
   A : real;
begin
   Lo := _min;
   Hi := _max;
   Mid := (Lo + Hi) div 2;
   repeat
      while ((FElements as TSingleDataSet).Data[Lo] - (FElements as TSingleDataSet).Data[Mid]) < 0 do Inc(Lo);
      while ((FElements as TSingleDataSet).Data[Hi] - (FElements as TSingleDataSet).Data[Mid]) > 0 do Dec(Hi);
      if Lo <= Hi then
      begin
         A := (FElements as TSingleDataSet).Data[Lo];
         (FElements as TSingleDataSet).Data[Lo] := (FElements as TSingleDataSet).Data[Hi];
         (FElements as TSingleDataSet).Data[Hi] := A;
         T := (FCounter as TIntDataSet).Data[Lo];
         (FCounter as TIntDataSet).Data[Lo] := (FCounter as TIntDataSet).Data[Hi];
         (FCounter as TIntDataSet).Data[Hi] := T;
         if (Lo = Mid) and (Hi <> Mid) then
            Mid := Hi
         else if (Hi = Mid) and (Lo <> Mid) then
            Mid := Lo;
         Inc(Lo);
         Dec(Hi);
      end;
   until Lo > Hi;
   if Hi > _min then
      QuickSortElementsAscendent(_min, Hi);
   if Lo < _max then
      QuickSortElementsAscendent(Lo, _max);
end;

procedure THistogram.QuickSortElementsDescendent(_min, _max : integer);
var
   Lo, Hi, Mid, T: Integer;
   A : real;
begin
   Lo := _min;
   Hi := _max;
   Mid := (Lo + Hi) div 2;
   repeat
      while ((FElements as TSingleDataSet).Data[Lo] - (FElements as TSingleDataSet).Data[Mid]) > 0 do Inc(Lo);
      while ((FElements as TSingleDataSet).Data[Hi] - (FElements as TSingleDataSet).Data[Mid]) < 0 do Dec(Hi);
      if Lo <= Hi then
      begin
         A := (FElements as TSingleDataSet).Data[Lo];
         (FElements as TSingleDataSet).Data[Lo] := (FElements as TSingleDataSet).Data[Hi];
         (FElements as TSingleDataSet).Data[Hi] := A;
         T := (FCounter as TIntDataSet).Data[Lo];
         (FCounter as TIntDataSet).Data[Lo] := (FCounter as TIntDataSet).Data[Hi];
         (FCounter as TIntDataSet).Data[Hi] := T;
         if (Lo = Mid) and (Hi <> Mid) then
            Mid := Hi
         else if (Hi = Mid) and (Lo <> Mid) then
            Mid := Lo;
         Inc(Lo);
         Dec(Hi);
      end;
   until Lo > Hi;
   if Hi > _min then
      QuickSortElementsDescendent(_min, Hi);
   if Lo < _max then
      QuickSortElementsDescendent(Lo, _max);
end;

procedure THistogram.QuickSortCounterAscendent(_min, _max : integer);
var
   Lo, Hi, Mid, T: Integer;
   A : real;
begin
   Lo := _min;
   Hi := _max;
   Mid := (Lo + Hi) div 2;
   repeat
      while ((FCounter as TIntDataSet).Data[Lo] - (FCounter as TIntDataSet).Data[Mid]) < 0 do Inc(Lo);
      while ((FCounter as TIntDataSet).Data[Hi] - (FCounter as TIntDataSet).Data[Mid]) > 0 do Dec(Hi);
      if Lo <= Hi then
      begin
         A := (FElements as TSingleDataSet).Data[Lo];
         (FElements as TSingleDataSet).Data[Lo] := (FElements as TSingleDataSet).Data[Hi];
         (FElements as TSingleDataSet).Data[Hi] := A;
         T := (FCounter as TIntDataSet).Data[Lo];
         (FCounter as TIntDataSet).Data[Lo] := (FCounter as TIntDataSet).Data[Hi];
         (FCounter as TIntDataSet).Data[Hi] := T;
         if (Lo = Mid) and (Hi <> Mid) then
            Mid := Hi
         else if (Hi = Mid) and (Lo <> Mid) then
            Mid := Lo;
         Inc(Lo);
         Dec(Hi);
      end;
   until Lo > Hi;
   if Hi > _min then
      QuickSortCounterAscendent(_min, Hi);
   if Lo < _max then
      QuickSortCounterAscendent(Lo, _max);
end;

procedure THistogram.QuickSortCounterDescendent(_min, _max : integer);
var
   Lo, Hi, Mid, T: Integer;
   A : real;
begin
   Lo := _min;
   Hi := _max;
   Mid := (Lo + Hi) div 2;
   repeat
      while ((FCounter as TIntDataSet).Data[Lo] - (FCounter as TIntDataSet).Data[Mid]) > 0 do Inc(Lo);
      while ((FCounter as TIntDataSet).Data[Hi] - (FCounter as TIntDataSet).Data[Mid]) < 0 do Dec(Hi);
      if Lo <= Hi then
      begin
         A := (FElements as TSingleDataSet).Data[Lo];
         (FElements as TSingleDataSet).Data[Lo] := (FElements as TSingleDataSet).Data[Hi];
         (FElements as TSingleDataSet).Data[Hi] := A;
         T := (FCounter as TIntDataSet).Data[Lo];
         (FCounter as TIntDataSet).Data[Lo] := (FCounter as TIntDataSet).Data[Hi];
         (FCounter as TIntDataSet).Data[Hi] := T;
         if (Lo = Mid) and (Hi <> Mid) then
            Mid := Hi
         else if (Hi = Mid) and (Lo <> Mid) then
            Mid := Lo;
         Inc(Lo);
         Dec(Hi);
      end;
   until Lo > Hi;
   if Hi > _min then
      QuickSortCounterDescendent(_min, Hi);
   if Lo < _max then
      QuickSortCounterDescendent(Lo, _max);
end;


end.
