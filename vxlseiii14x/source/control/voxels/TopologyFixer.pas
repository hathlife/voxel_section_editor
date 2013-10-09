unit TopologyFixer;

interface

uses Voxel, VoxelMap, Palette;

type
   CTopologyFixer = class
      private
         FInputMap,FInputColor,FInputNormal,FMap,FColor,FNormal: TVoxelMap;
         Section : TVoxelSection;
         Palette: TPalette;
         procedure AddVertex(_xNew,_yNew,_zNew,_xOld,_yOld,_zOld,_config: integer);
      public
         constructor Create(const _Section: TVoxelSection; const _Palette: TPalette);
         destructor Destroy; override;
         procedure IncreaseVolumetricResolution();
   end;

implementation

uses Windows,BasicConstants, BasicDataTypes, Normals, Math3D;

constructor CTopologyFixer.Create(const _Section: TVoxelSection; const _Palette: TPalette);
var
   Values : array of single;
begin
   Section := _Section;
   Palette := _Palette;
   FInputMap := TVoxelMap.CreateQuick(Section,1);
   FInputMap.GenerateSurfaceMap;
   FInputMap.Bias := 0;
   FInputColor := TVoxelMap.Create(Section,0,C_MODE_COLOUR,0);
   FInputNormal := TVoxelMap.Create(Section,0,C_MODE_NORMAL,0);
   Section.Resize((Section.Tailer.XSize*2)+1,(Section.Tailer.YSize*2)+1,(Section.Tailer.ZSize*2)+1);
   FMap := TVoxelMap.Create(Section,0,C_MODE_NONE,C_OUTSIDE_VOLUME);
   FColor := TVoxelMap.Create(Section,0,C_MODE_NONE,0);
   FNormal := TVoxelMap.Create(Section,0,C_MODE_NONE,0);
   IncreaseVolumetricResolution();
   FMap.SynchronizeWithSection(C_MODE_USED,C_SURFACE);
   FColor.SynchronizeWithSection(C_MODE_COLOUR,0);
   FNormal.SynchronizeWithSection(C_MODE_NORMAL,0);
   FMap.Free;
   FMap := TVoxelMap.CreateQuick(Section,1);
   FMap.GenerateSurfaceMap;
   SetLength(Values,6);
   Values[0] := 0;
   Values[1] := 0;
   Values[2] := 0;
   Values[3] := 0;
   Values[4] := C_SURFACE;
   Values[5] := 0;
   FMap.ConvertValues(Values);
   FMap.SynchronizeWithSection(C_MODE_USED,C_SURFACE);
end;

destructor CTopologyFixer.Destroy;
begin
   FInputMap.Free;
   FInputColor.Free;
   FInputNormal.Free;
   FMap.Free;
   FColor.Free;
   FNormal.Free;
   inherited Destroy;
end;

procedure CTopologyFixer.IncreaseVolumetricResolution();
const
   ConnectivityVertexConfigStart: array[0..26] of byte = (0,0,1,2,3,4,7,10,13,16,16,17,17,18,18,19,19,20,20,21,22,23,24,27,30,33,36);
   ConnectivityVertexConfigData: array[0..35] of longword = (2049,32769,8193,513,32776,8196,16385,2056,8194,4097,32784,516,65537,2064,514,1025,2560,10240,40960,33280,133120,163840,139264,131584,1081344,532480,147456,1050624,270336,135168,2129920,524800,196608,2099200,262656,132096);
   RegionBitNeighbours: array[0..25] of longword = (1,2049,32769,8193,513,57357,14347,98949,3603,512,2560,2048,10240,8192,40960,32768,33280,131072,133120,163840,139264,131584,1761280,1456128,2851328,2493952);
   ConnectivityBitNeighbours: array[0..25] of longword = (30,2369,32929,8289,897,16396,4106,65556,1042,2163728,33557248,267266,8398912,1069064,4235296,606212,16810624,3932160,42076160,21135360,12722176,50463232,1589248,1314816,2686976,2360320);
var
   Cube : TNormals;
   xOld,yOld,zOld,xNew,yNew,zNew,i,j,maxi: integer;
   CurrentNormal : TVector3f;
   RegionBitConfig,ConnectivityConfig,current: longword;
begin
   Cube := TNormals.Create(6);
   maxi := Cube.GetLastID;
   if (maxi > 0) then
   begin
      xNew := 1;
      for xOld := 0 to FInputMap.GetMaxX do
      begin
         yNew := 1;
         for yOld := 0 to FInputMap.GetMaxY do
         begin
            zNew := 1;
            for zOld := 0 to FInputMap.GetMaxZ do
            begin
               if FInputMap.Map[xOld,yOld,zOld] = C_SURFACE then
               begin
                  // 1) We will fill the region config first.
                  i := 0;
                  current := 1;
                  RegionBitConfig := 0;
                  while i <= maxi do
                  begin
                     CurrentNormal := Cube[i];
                     if FInputMap.MapSafe[xOld + Round(CurrentNormal.X),yOld + Round(CurrentNormal.Y),zOld + Round(CurrentNormal.Z)] >= C_SURFACE then
                     begin
                        RegionBitConfig := RegionBitConfig or current;
                     end;
                     inc(i);
                     current := current shl 1;
                  end;
                  // 2) Find the connectivity graph.
                  i := 0;
                  ConnectivityConfig := 0;
                  current := 1;
                  while i <= maxi do
                  begin
                     if (RegionBitConfig and current) = 0 then
                     begin
                        // if one of the next configurations match, the vertex i is
                        // in the config
                        j := ConnectivityVertexConfigStart[i];
                        while j < ConnectivityVertexConfigStart[i+1] do
                        begin
                           if (RegionBitConfig and ConnectivityVertexConfigData[j]) = ConnectivityVertexConfigData[j] then
                           begin
                              ConnectivityConfig := ConnectivityConfig or current;
                              j := ConnectivityVertexConfigStart[i+1]; // go to next i
                           end
                           else
                           begin
                              inc(j);
                           end;
                        end;
                     end
                     else
                     begin
                        ConnectivityConfig := ConnectivityConfig or current;
                     end;
                     inc(i);
                     current := current shl 1;
                  end;

                  // 3) Find the final vertexes.
                  i := 0;
                  current := 1;
                  while i <= maxi do
                  begin
                     // If the vertex is in the connectivity graph, then we add
                     // it (even if it gets eliminated in the end of the technique.
                     if (ConnectivityConfig and current) = current then
                     begin
                        // Add vertex
                        CurrentNormal := Cube[i];
                        AddVertex(xNew + Round(CurrentNormal.X),yNew + Round(CurrentNormal.Y),zNew + Round(CurrentNormal.Z),xOld,yOld,zOld,i);
                     end
                     else // It's not in the connectivity graph.
                     begin
                        // If current is in the RegionBitConfig and one of the
                        // neighbours from the RegionBitNeighbours[i] is in
                        // RegionBitConfig then...
                        if ((RegionBitConfig and current) = current) and ((RegionBitConfig and RegionBitNeighbours[i]) <> 0) then
                        begin
                           // Add Vertex
                           CurrentNormal := Cube[i];
                           AddVertex(xNew + Round(CurrentNormal.X),yNew + Round(CurrentNormal.Y),zNew + Round(CurrentNormal.Z),xOld,yOld,zOld,i);
                        end
                        else // It's not in the connectivity graph from neighbour voxels.
                        begin
                           // Check if one of the neighbours of i in the
                           // ConnectivityConfig exists that it also adds a vertex
                           if (ConnectivityConfig and ConnectivityBitNeighbours[i]) <> 0 then
                           begin
                              // Add Vertex
                              CurrentNormal := Cube[i];
                              AddVertex(xNew + Round(CurrentNormal.X),yNew + Round(CurrentNormal.Y),zNew + Round(CurrentNormal.Z),xOld,yOld,zOld,i);
                           end;
                        end;
                     end;
                     inc(i);
                     current := current shl 1;
                  end;
                  // Add the fixed vertexes
                  // center
                  AddVertex(xNew,yNew,zNew,xOld,yOld,zOld,100); //100 is > 25, so it makes sense in AddVertex
                  // Mid-edges
                  AddVertex(xNew-1,yNew,zNew,xOld,yOld,zOld,0);
                  AddVertex(xNew+1,yNew,zNew,xOld,yOld,zOld,17);
                  AddVertex(xNew,yNew-1,zNew,xOld,yOld,zOld,9);
                  AddVertex(xNew,yNew+1,zNew,xOld,yOld,zOld,13);
                  AddVertex(xNew,yNew,zNew-1,xOld,yOld,zOld,15);
                  AddVertex(xNew,yNew,zNew+1,xOld,yOld,zOld,11);
               end;
               // Ok, go to next voxel.
               inc(zNew,2);
            end;
            inc(yNew,2);
         end;
         inc(xNew,2);
      end;
   end;
   Cube.Free;
end;

procedure CTopologyFixer.AddVertex(_xNew,_yNew,_zNew,_xOld,_yOld,_zOld, _config: integer);
const
   CubeConfigStart: array[0..33] of byte = (0,1,4,7,10,13,20,27,34,41,42,45,46,49,50,53,54,57,58,61,64,67,70,77,84,91,98,115,132,149,166,183,200,226);
   CubeConfigData: array[0..225] of byte = (0,0,1,11,0,2,15,0,3,13,0,4,9,0,2,3,5,13,14,15,0,1,3,6,11,12,13,0,2,4,7,9,15,16,0,1,4,8,9,10,11,9,9,10,11,11,11,12,13,13,13,14,15,15,9,15,16,17,11,17,18,15,17,19,13,17,20,9,17,21,13,14,15,17,19,20,22,11,12,13,17,18,20,23,9,15,16,17,19,21,24,9,10,11,17,18,21,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,4,7,8,9,10,11,15,16,17,18,19,21,24,25,0,1,2,3,5,6,11,12,13,14,15,17,18,19,20,22,23,0,2,3,4,5,7,9,13,14,15,16,17,19,20,21,22,24,0,1,3,4,6,8,9,10,11,12,13,17,18,20,21,23,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25);
var
   Cube : TNormals;
   i,maxi,x,y,z : integer;
   r,g,b: single;
   Normal : TVector3f;
   numColours: integer;
   color: byte;
   UsesRemap: boolean;
   CurrentNormal : TVector3f;
begin
   if FMap[_xNew,_yNew,_zNew] = C_OUTSIDE_VOLUME then
   begin
      // Make it solid.
      FMap[_xNew,_yNew,_zNew] := C_INSIDE_VOLUME;
      // If it's the center voxel.
      if _config > 25 then
      begin
         FColor[_xNew,_yNew,_zNew] := FInputColor[_xOld,_yOld,_zOld];
         FNormal[_xNew,_yNew,_zNew] := FInputNormal[_xOld,_yOld,_zOld];
      end
      else // we'll generate a colour and normal.
      begin
         UsesRemap := (Round(FInputColor.Map[_xOld,_yOld,_zOld]) >= 16) and (Round(FInputColor.Map[_xOld,_yOld,_zOld]) <= 31);
         r := GetRValue(Palette[Round(FInputColor.Map[_xOld,_yOld,_zOld])]);
         g := GetGValue(Palette[Round(FInputColor.Map[_xOld,_yOld,_zOld])]);
         b := GetBValue(Palette[Round(FInputColor.Map[_xOld,_yOld,_zOld])]);
         Normal.X := Section.Normals[Round(FInputNormal.Map[_xOld,_yOld,_zOld])].X;
         Normal.Y := Section.Normals[Round(FInputNormal.Map[_xOld,_yOld,_zOld])].Y;
         Normal.Z := Section.Normals[Round(FInputNormal.Map[_xOld,_yOld,_zOld])].Z;
         Cube := TNormals.Create(6);
         maxi := Cube.GetLastID;
         NumColours := 1;
         // visit all cubed neighbours
         i := CubeConfigStart[_config];
         while i < CubeConfigStart[_config+1] do
         begin
            // add this colour.
            CurrentNormal := Cube[CubeConfigData[i]];
            x := Round(_xOld + CurrentNormal.X);
            y := Round(_yOld + CurrentNormal.Y);
            z := Round(_zOld + CurrentNormal.Z);
            if FInputMap.MapSafe[x,y,z] >= C_SURFACE then
            begin
               UsesRemap := UsesRemap or ((Round(FInputColor.Map[x,y,z]) >= 16) and (Round(FInputColor.Map[x,y,z]) <= 31));
               r := r + GetRValue(Palette[Round(FInputColor.Map[x,y,z])]);
               g := g + GetGValue(Palette[Round(FInputColor.Map[x,y,z])]);
               b := b + GetBValue(Palette[Round(FInputColor.Map[x,y,z])]);
               inc(numColours);
               Normal.X := Normal.X + Section.Normals[Round(FInputNormal.Map[x,y,z])].X;
               Normal.Y := Normal.Y + Section.Normals[Round(FInputNormal.Map[x,y,z])].Y;
               Normal.Z := Normal.Z + Section.Normals[Round(FInputNormal.Map[x,y,z])].Z;
            end;
            inc(i);
         end;
         r := r / numColours;
         g := g / numColours;
         b := b / numColours;
         Normalize(Normal);
         color := Palette.GetColourFromPalette(RGB(Round(r),Round(g),Round(b)));
         if UsesRemap then
         begin
            case color of
               200: color := 16;
               201: color := 19;
               202: color := 22;
               203: color := 25;
            end;
         end
         else
         begin
            case color of
               16: color := 200;
               17: color := 200;
               18: color := 201;
               19: color := 201;
               20: color := 201;
               21: color := 202;
               22: color := 202;
               23: color := 202;
               24: color := 203;
               25: color := 203;
               26: color := 203;
               27: color := 203;
               28: color := 203;
               29: color := 203;
               30: color := 203;
               31: color := 203;
            end;
         end;
         FColor[_xNew,_yNew,_zNew] := color;
         FNormal[_xNew,_yNew,_zNew] := Section.Normals.GetIDFromNormal(Normal);
      end;
   end;
end;

end.
