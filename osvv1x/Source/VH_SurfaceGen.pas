unit VH_SurfaceGen;

interface

uses Voxel, math3d, VH_Global, math, Dialogs,Sysutils, VH_Voxel;

type
   TArrayVector3i = array of TVector3i;

procedure Hermite( p1, p2: TVector3i; t1, t2:TVector3f; var P:TArrayVector3i);
procedure Surface( const P1, P2, P3: TVector3i; const T1, T2, T3, T4: TVector3f);


implementation

procedure Hermite(p1, p2: TVector3i; t1, t2:TVector3f;var P: TArrayVector3i);
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
      exit;

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
end;

procedure Surface( const P1, P2, P3: TVector3i; const T1, T2, T3, T4: TVector3f);
var
	p: array[0..1] of TVector3i;
	t: array[0..1] of TVector3f;
	x, y, z :integer;
	H1: TArrayVector3i;
	H2: TArrayVector3i;
   Voxel : TVoxelSection;
   v : TVoxelUnpacked;
begin
	p[0].x:=P1.x;
	p[0].y:=P1.z;
	p[1].x:=P2.x;
	p[1].y:=P2.z;
	t[0].x:=T1.x;
	t[0].y:=T1.z;
	t[1].x:=T2.x;
	t[1].y:=T2.z;

	Hermite(p[0],p[1],t[0],t[1],H1);

	p[0].x:=P1.y;
	p[0].y:=P1.z;
	p[1].x:=P3.y;
	p[1].y:=P3.z;
	t[0].x:=T3.y;
	t[0].y:=T3.z;
	t[1].x:=T4.y;
	t[1].y:=T4.z;

	Hermite(p[0],p[1],t[0],t[1],H2);

   Voxel := VoxelFile.Section[0];
	for x:= min(P1.X,P2.X) to max(P1.X,P2.X) do
		for y:= min(P1.Y,P3.Y) to max(P1.Y,P3.Y) do
      begin
         v.Colour := 16;
         v.Normal := 1;
         v.Used := true;
         if ((x < Voxel.Tailer.XSize)and(x >0) ) and ((y < Voxel.Tailer.YSize)and(y>0)) then
         begin
            try
              z := H1[y - min(P1.Y,P3.Y)].Y + H2[x - min(P1.X,P2.X)].Y;
            except
              z := 0;
            end;
            ShowMessage(InttoStr(z));
            if (z >0)  and (z < Voxel.Tailer.ZSize) then
              begin
                //ShowMessage('Ponto: (' + IntToStr(x) + ', ' + IntToStr(y) +', ' + IntToStr(z) + ')');
                 VoxelFile.Section[0].SetVoxel(x,y,z,v);
               end;
         end;
      end;
      RebuildLists := true;
      UpdateVoxelList;
end;

end.
