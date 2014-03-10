unit VH_SurfaceGen;

interface

uses Voxel, BasicMathsTypes, BasicDataTypes, BasicVXLSETypes, math3d, Voxel_Engine,
   math, Dialogs,Sysutils;

type
   TArrayVector3i = array of TVector3i;


function Hermite(p1, p2: TVector3i; t1, t2:TVector3f; var P:TArrayVector3i): boolean;
procedure Surface(var _Voxel : TVoxelSection; const P1, P2, P3: TVector3i; const T1, T2, T3, T4: TVector3f);


implementation


function Hermite(p1, p2: TVector3i; t1, t2:TVector3f;var P: TArrayVector3i): boolean;
var
	s:real;
	h1:real;
	h2:real;
	h3:real;
	h4:real;
   t : integer;
	passos:integer;
begin
   // Pega a quantidade de passos.
	passos := abs(p2.x-p1.x);
	SetLength(P,passos);
   // Se não houver passos, sai fora.
   if passos = 0 then
   begin
      Result := false;
      exit;
   end;

   // Inicializa o pontos variáveis.
	P[0].x := p1.y;
	P[0].y := p1.x;
	for t:= 1 to passos do
	begin
		s:= t/passos;
		h1:= power(2*s,3) - power(3*s,2) + 1;
		h2:= -power(2*s,3) + power(3*s,2);
		h3:= power(s,3) - power(2*s,2) + s;
		h4:= power(s,3) -  power(s,2);
		P[t].x:=Round((h1*p1.x)+(h2*p2.x)+(h3*t1.x)+(h4*t2.x));
		P[t].y:=Round((h1*p1.y)+(h2*p2.y)+(h3*t1.y)+(h4*t2.y));
	end;
   Result := true;
end;

procedure Surface(var _Voxel : TVoxelSection; const P1, P2, P3: TVector3i; const T1, T2, T3, T4: TVector3f);
var
	p: array[0..1] of TVector3i;
	t: array[0..1] of TVector3f;
	x, y, z :integer;
	H1: TArrayVector3i;
	H2: TArrayVector3i;
   v : TVoxelUnpacked;
   temp1:integer;
   temp2:integer;
begin
	p[0].x:=P1.x;
	p[0].y:=P1.z;
	p[1].x:=P2.x;
	p[1].y:=P2.z;
	t[0].x:=T1.x;
	t[0].y:=T1.z;
	t[1].x:=T2.x;
	t[1].y:=T2.z;

	if not Hermite(p[0],p[1],t[0],t[1],H1) then
      exit;

	p[0].x:=P1.y;
	p[0].y:=P1.z;
	p[1].x:=P3.y;
	p[1].y:=P3.z;
	t[0].x:=T3.y;
	t[0].y:=T3.z;
	t[1].x:=T4.y;
	t[1].y:=T4.z;

	if not Hermite(p[0],p[1],t[0],t[1],H2) then
      exit;

	for x:= min(P1.X,P2.X) to max(P1.X,P2.X) do
		for y:= min(P1.Y,P3.Y) to max(P1.Y,P3.Y) do
      begin
         v.Colour := 16;
         v.Normal := 1;
         v.Used := true;
         if ((x < _Voxel.Tailer.XSize)) and ((y < _Voxel.Tailer.YSize)) then
         begin
            try
              begin
                 temp1:=y-min(P1.Y,P3.Y);
                 temp2:=x-min(P1.X,P2.X);
                 if (temp1<0) then temp1:=0;
                 if (temp2<0) then temp2:=0;
                 if (temp1 > High(H1)) then temp1 := High(H1);
                 if (temp2 > High(H2)) then temp2 := High(H2);
                z := H1[temp1].Y + H2[temp2].Y;
               // ShowMessage('h1,h2: (' + IntToStr(H1[temp1].y) + ', ' + IntToStr(H2[temp2].y) + ')');
              end;
            except
              z := 0;
           //   ShowMessage('dropei!');
            end;
           // ShowMessage(InttoStr(z));
            if (z >0)  and (z < _Voxel.Tailer.ZSize) then
              begin
              //  ShowMessage('Ponto: (' + IntToStr(x) + ', ' + IntToStr(y) +', ' + IntToStr(z) + ')');
                 _Voxel.SetVoxel(x,y,z,v);
               end;
         end;
      end;
end;

end.
