unit IsoSurfaceFile;

interface

uses Voxel;

type
   CIsosurfaceFile = class
      public
         // I/O
         procedure SaveToFile(const _Filename: string; const _Voxel: TVoxelSection);
   end;

implementation

uses VoxelMap, BasicConstants, SysUtils, Dialogs, BasicDataTypes;

// http://www.matmidia.mat.puc-rio.br/tomlew/publication_page.php?pubkey=marching_cubes_jgt

// It saves .iso files used by Thomas Lewiner's marching cubes program. I need
// to test it with VXLSE III's entries. -- Banshee
procedure CIsosurfaceFile.SaveToFile(const _Filename: string; const _Voxel: TVoxelSection);
var
   F: File;
   x,y,z,maxx,maxy,maxz: integer;
   NegValue,PosValue : single;
   Value : longword;
   Map: TVoxelMap;
begin
   try
      AssignFile(F,_Filename);
      FileMode := fmOpenWrite; // we save file, so write mode [VK]
      Rewrite(F,1); // file of byte
      Value := _Voxel.Tailer.XSize + 2;
      BlockWrite(F,Value, sizeof(longword));
      Value := _Voxel.Tailer.ZSize + 2;
      BlockWrite(F,Value, sizeof(longword));
      Value := _Voxel.Tailer.YSize + 2;
      BlockWrite(F,Value, sizeof(longword));
      NegValue := -1.0;
      PosValue := 1.0;
      BlockWrite(F,NegValue, sizeof(single));
      BlockWrite(F,PosValue, sizeof(single));
      BlockWrite(F,NegValue, sizeof(single));
      BlockWrite(F,PosValue, sizeof(single));
      BlockWrite(F,NegValue, sizeof(single));
      BlockWrite(F,PosValue, sizeof(single));
      Map := TVoxelMap.CreateQuick(_Voxel,1);
      Map.GenerateVolumeMap;
      maxx := High(_Voxel.Data) +2;
      maxy := High(_Voxel.Data[0]) + 2;
      maxz := High(_Voxel.Data[0,0]) + 2;
      for x := 0 to maxx do
         for z := 0 to maxz do
            for y := 0 to maxy do
            begin
               if Map.MapSafe[x,y,z] = C_INSIDE_VOLUME then
                  BlockWrite(F,NegValue, sizeof(single))
               else
                  BlockWrite(F,PosValue, sizeof(single));
            end;
      CloseFile(F);
   except on E : EInOutError do // VK 1.36 U
		MessageDlg('Error: ' + E.Message + Char($0A) + _Filename, mtError, [mbOK], 0);
   end;

end;

end.
