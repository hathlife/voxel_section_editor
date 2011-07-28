unit ImageIOUtils;

interface

uses Graphics, Jpeg, PCXCtrl, SysUtils, PNGImage, TARGA, Dialogs;

function GetBMPFromImageFile(filename: string): TBitmap; overload;
function GetBMPFromJPGImageFile(filename: string): TBitmap;
function GetBMPFromPCXImageFile(filename: string): TBitmap;
function GetBMPFromPNGImageFile(filename: string): TBitmap;
function GetBMPFromTGAImageFile(filename: string): TBitmap;
procedure SaveImage(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsJPGImageFile(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsPCXImageFile(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsPNGImageFile(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsTGAImageFile(const _FileName: string; const _Bitmap:TBitmap);

implementation

function GetBMPFromTGAImageFile(filename: string): TBitmap;
var
   Bitmap: TBitmap;
begin
   Bitmap := TBitmap.Create;
   Result := TBitmap.Create;

   LoadFromFileX(Filename, Bitmap);

   Result.Assign(Bitmap);
   Bitmap.Free;
end;

function GetBMPFromPNGImageFile(filename: string): TBitmap;
var
   PNGImage: TPNGObject;
   Bitmap:   TBitmap;
begin
   Bitmap   := TBitmap.Create;
   PNGImage := TPNGObject.Create;

   PNGImage.LoadFromFile(Filename);
   Bitmap.Assign(PNGImage);

   PNGImage.Free;
   Result := Bitmap;
end;

function GetBMPFromJPGImageFile(filename: string): TBitmap;
var
   JPEGImage: TJPEGImage;
   Bitmap:    TBitmap;
begin
   Bitmap    := TBitmap.Create;
   JPEGImage := TJPEGImage.Create;

   JPEGImage.LoadFromFile(Filename);
   Bitmap.Assign(JPEGImage);

   JPEGImage.Free;
   Result := Bitmap;
end;

function GetBMPFromPCXImageFile(filename: string): TBitmap;
var
   PCXBitmap: TPCXBitmap;
   Bitmap:    TBitmap;
begin
   Bitmap    := TBitmap.Create;
   PCXBitmap := TPCXBitmap.Create;

   try
      try
         PCXBitmap.LoadFromFile(Filename);
         Bitmap.Assign(TBitmap(PCXBitmap));
      except
         ShowMessage(
            'Aten��o: O suporte para arquivos PCX neste programa � limitado e, por algum motivo, esse arquivo n�o pode ser lido. Escolha outro arquivo.');
      end;
   finally
      PCXBitmap.Free;
   end;
   Result := Bitmap;
end;

function GetBMPFromImageFile(filename: string): TBitmap; overload;
var
   Bmp: TBitmap;
   Ext: string;
begin
   Bmp := TBitmap.Create;

   Ext := ansilowercase(extractfileext(filename));

   if Ext = '.bmp' then
      Bmp.LoadFromFile(Filename);

   if (Ext = '.jpg') or (Ext = '.jpeg') then
      bmp := GetBMPFromJPGImageFile(Filename);

   if (Ext = '.pcx') then
      bmp := GetBMPFromPCXImageFile(Filename);

   if (Ext = '.png') then
      bmp := GetBMPFromPNGImageFile(Filename);

   if (Ext = '.tga') then
      bmp := GetBMPFromTGAImageFile(Filename);

   Result := bmp;
end;

procedure SaveImage(const _FileName: string; const _Bitmap:TBitmap);
var
   Ext: string;
begin
   Ext := ansilowercase(extractfileext(_FileName));
   if Ext = '.bmp' then
   begin
      _Bitmap.SaveToFile(_FileName);
   end
   else if (Ext = '.jpg') or (Ext = '.jpeg') then
   begin
      SaveBMPAsJPGImageFile(_FileName,_Bitmap);
   end
   else if (Ext = '.pcx') then
   begin
      SaveBMPAsPCXImageFile(_FileName,_Bitmap);
   end
   else if (Ext = '.png') then
   begin
      SaveBMPAsPNGImageFile(_FileName,_Bitmap);
   end
   else if (Ext = '.tga') then
   begin
      SaveBMPAsTGAImageFile(_FileName,_Bitmap);
   end;
end;

procedure SaveBMPAsJPGImageFile(const _FileName: string; const _Bitmap:TBitmap);
var
   JPEGImage: TJPEGImage;
begin
   JPEGImage := TJPEGImage.Create;
   JPEGImage.Assign(_Bitmap);
   JPEGImage.SaveToFile(_Filename);
   JPEGImage.Free;
end;

procedure SaveBMPAsPCXImageFile(const _FileName: string; const _Bitmap:TBitmap);
var
   PCXImage: TPCXBitmap;
begin
   PCXImage := TPCXBitmap.Create;
   PCXImage.Assign(_Bitmap);
   PCXImage.SaveToFile(_Filename);
   PCXImage.Free;
end;

procedure SaveBMPAsPNGImageFile(const _FileName: string; const _Bitmap:TBitmap);
var
   PNGImage: TPNGObject;
begin
   PNGImage := TPNGObject.Create;
   PNGImage.Assign(_Bitmap);
   PNGImage.SaveToFile(_FileName);
   PNGImage.Free;
end;

procedure SaveBMPAsTGAImageFile(const _FileName: string; const _Bitmap:TBitmap);
begin
   SaveToFileX(_Filename,_Bitmap,2);
end;


end.
