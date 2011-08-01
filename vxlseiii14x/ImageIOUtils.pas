unit ImageIOUtils;

interface

uses Graphics, Jpeg, PCXCtrl, SysUtils, PNGImage, TARGA, TextureBankItem, Dialogs;

function GetBMPFromImageFile(_filename: string): TBitmap; overload;
function GetBMPFromJPGImageFile(_filename: string): TBitmap;
function GetBMPFromPCXImageFile(_filename: string): TBitmap;
function GetBMPFromPNGImageFile(_filename: string): TBitmap;
function GetBMPFromTGAImageFile(_filename: string): TBitmap;
function GetBMPFromDDSImageFile(_filename: string): TBitmap;
procedure SaveImage(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsJPGImageFile(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsPCXImageFile(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsPNGImageFile(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsTGAImageFile(const _FileName: string; const _Bitmap:TBitmap);
procedure SaveBMPAsDDSImageFile(const _FileName: string; const _Bitmap:TBitmap);

implementation

function GetBMPFromTGAImageFile(_filename: string): TBitmap;
var
   Bitmap: TBitmap;
begin
   Bitmap := TBitmap.Create;
   Result := TBitmap.Create;

   LoadFromFileX(_Filename, Bitmap);

   Result.Assign(Bitmap);
   Bitmap.Free;
end;

function GetBMPFromPNGImageFile(_filename: string): TBitmap;
var
   PNGImage: TPNGObject;
   Bitmap:   TBitmap;
begin
   Bitmap   := TBitmap.Create;
   PNGImage := TPNGObject.Create;

   PNGImage.LoadFromFile(_Filename);
   Bitmap.Assign(PNGImage);

   PNGImage.Free;
   Result := Bitmap;
end;

function GetBMPFromJPGImageFile(_filename: string): TBitmap;
var
   JPEGImage: TJPEGImage;
   Bitmap:    TBitmap;
begin
   Bitmap    := TBitmap.Create;
   JPEGImage := TJPEGImage.Create;

   JPEGImage.LoadFromFile(_Filename);
   Bitmap.Assign(JPEGImage);

   JPEGImage.Free;
   Result := Bitmap;
end;

function GetBMPFromPCXImageFile(_filename: string): TBitmap;
var
   PCXBitmap: TPCXBitmap;
   Bitmap:    TBitmap;
begin
   Bitmap    := TBitmap.Create;
   PCXBitmap := TPCXBitmap.Create;

   try
      try
         PCXBitmap.LoadFromFile(_Filename);
         Bitmap.Assign(TBitmap(PCXBitmap));
      except
         ShowMessage(
            'Atenção: O suporte para arquivos PCX neste programa é limitado e, por algum motivo, esse arquivo não pode ser lido. Escolha outro arquivo.');
      end;
   finally
      PCXBitmap.Free;
   end;
   Result := Bitmap;
end;

function GetBMPFromDDSImageFile(_filename: string): TBitmap;
var
   Texture: TTextureBankItem;
begin
   Texture := TTextureBankItem.Create(_Filename);
   Result := Texture.DownloadTexture(0);
   Texture.Free;
end;


function GetBMPFromImageFile(_filename: string): TBitmap; overload;
var
   Bmp: TBitmap;
   Ext: string;
begin
   Bmp := TBitmap.Create;

   Ext := ansilowercase(extractfileext(_filename));

   if Ext = '.bmp' then
   begin
      Bmp.LoadFromFile(_Filename);
   end
   else if (Ext = '.jpg') or (Ext = '.jpeg') then
   begin
      bmp := GetBMPFromJPGImageFile(_Filename);
   end
   else if (Ext = '.pcx') then
   begin
      bmp := GetBMPFromPCXImageFile(_Filename);
   end
   else if (Ext = '.png') then
   begin
      bmp := GetBMPFromPNGImageFile(_Filename);
   end
   else if (Ext = '.tga') then
   begin
      bmp := GetBMPFromTGAImageFile(_Filename);
   end
   else if (Ext = '.dds') then
   begin
      bmp := GetBMPFromDDSImageFile(_Filename);
   end;
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
   end
   else if (Ext = '.dds') then
   begin
      SaveBMPAsDDSImageFile(_FileName,_Bitmap);
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

procedure SaveBMPAsDDSImageFile(const _FileName: string; const _Bitmap:TBitmap);
var
   Texture: TTextureBankItem;
begin
   Texture := TTextureBankItem.Create(_Bitmap);
   Texture.SaveTexture(_Filename);
   Texture.Free;
end;


end.
