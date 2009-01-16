unit BmpToDIB;

interface

uses
   Windows;

   function WIDTHBYTES(bits : DWORD) : DWORD;
   function DIBNumColors( lpbi : PBITMAPINFOHEADER ) : WORD;
   function PaletteSize( lpbi : PBITMAPINFOHEADER ) : WORD;
   function BitmapToDIB(hBitmap : HBITMAP; hPal : HPALETTE) : THandle;

implementation

   function WIDTHBYTES(bits : DWORD) : DWORD;
   begin
      WIDTHBYTES := ((((bits) + 31) div 32) * 4);
   end;

   function DIBNumColors( lpbi : PBITMAPINFOHEADER ) : WORD;
   var
      wBitCount : WORD;
      dwClrUsed : DWORD;
   begin
      dwClrUsed := lpbi^.biClrUsed;

      if (dwClrUsed <> 0) then
      begin
         DIBNumColors := dwClrUsed;
         exit;
      end;

      wBitCount := lpbi^.biBitCount;

      case wBitCount of
         1: DIBNumColors := 2;
         4: DIBNumColors := 16;
         8: DIBNumColors := 256;
      else
         DIBNumColors := 0;
      end;
   end;

   function PaletteSize( lpbi : PBITMAPINFOHEADER ) : WORD;
   begin
      PaletteSize := ( DIBNumColors( lpbi ) * SizeOf( RGBQUAD ) );
   end;

   function BitmapToDIB(hBitmap : HBITMAP; hPal : HPALETTE) : THandle;
   var
      bm : BITMAP; // bitmap structure
      bi : BITMAPINFOHEADER; // bitmap header
      lpbi : PBITMAPINFOHEADER; // pointer to BITMAPINFOHEADER
      dwLen : DWORD; // size of memory block
      hDIB, h : THandle; // handle to DIB, temp handle
      hDC : Windows.HDC; // handle to DC
      biBits : WORD; // bits per pixel
   begin

      // check if bitmap handle is valid

      if (hBitmap = 0) then
      begin
         BitmapToDIB := 0;
         exit;
      end;

      // fill in BITMAP structure, return NULL if it didn't work

      if (GetObject(hBitmap, SizeOf(bm), @bm) = 0) then
      begin
         BitmapToDIB := 0;
         exit;
      end;

      // if no palette is specified, use default palette

      if (hPal = 0) then
         hPal := GetStockObject(DEFAULT_PALETTE);

      // calculate bits per pixel

      biBits := bm.bmPlanes * bm.bmBitsPixel;

      // make sure bits per pixel is valid

      if (biBits <= 1) then
         biBits := 1
      else if (biBits <= 4) then
         biBits := 4
      else if (biBits <= 8) then
         biBits := 8
      else // if greater than 8-bit, force to 24-bit
         biBits := 24;

      // initialize BITMAPINFOHEADER

      bi.biSize := SizeOf(BITMAPINFOHEADER);
      bi.biWidth := bm.bmWidth;
      bi.biHeight := bm.bmHeight;
      bi.biPlanes := 1;
      bi.biBitCount := biBits;
      bi.biCompression := BI_RGB;
      bi.biSizeImage := 0;
      bi.biXPelsPerMeter := 0;
      bi.biYPelsPerMeter := 0;
      bi.biClrUsed := 0;
      bi.biClrImportant := 0;

      // calculate size of memory block required to store BITMAPINFO

      dwLen := bi.biSize + PaletteSize(@bi);

      // get a DC

      hDC := GetDC(0);

      // select and realize our palette

      hPal := SelectPalette(hDC, hPal, FALSE);
      RealizePalette(hDC);

      // alloc memory block to store our bitmap

      hDIB := GlobalAlloc(GHND, dwLen);

      // if we couldn't get memory block

      if (hDIB = 0) then
      begin
      // clean up and return NULL

         SelectPalette(hDC, hPal, TRUE);
         RealizePalette(hDC);
         ReleaseDC(0, hDC);
         BitmapToDIB := 0;
         exit;
      end;

      // lock memory and get pointer to it

      lpbi := GlobalLock(hDIB);

      /// use our bitmap info. to fill BITMAPINFOHEADER

      lpbi^ := bi;

      // call GetDIBits with a NULL lpBits param, so it will calculate the
      // biSizeImage field for us

      GetDIBits(hDC, hBitmap, 0, bi.biHeight, NIL, PBITMAPINFO(lpbi)^, DIB_RGB_COLORS);

      // get the info. returned by GetDIBits and unlock memory block

      bi := lpbi^;
      GlobalUnlock(hDIB);

      // if the driver did not fill in the biSizeImage field, make one up
      if (bi.biSizeImage = 0) then
         bi.biSizeImage := WIDTHBYTES(bm.bmWidth * biBits) * bm.bmHeight;

      // realloc the buffer big enough to hold all the bits

      dwLen := bi.biSize + PaletteSize(@bi) + bi.biSizeImage;

      h := GlobalReAlloc(hDIB, dwLen, 0);
      if (h <> 0) then
         hDIB := h
      else
      begin
      // clean up and return NULL

         GlobalFree(hDIB);
         hDIB := 0;
         SelectPalette(hDC, hPal, TRUE);
         RealizePalette(hDC);
         ReleaseDC(0, hDC);
         BitmapToDIB := 0;
         exit;
      end;
      // lock memory block and get pointer to it */

      lpbi := GlobalLock(hDIB);

      // call GetDIBits with a NON-NULL lpBits param, and actualy get the
      // bits this time

      if (GetDIBits(hDC, hBitmap, 0, bi.biHeight, (PCHAR(lpbi) + lpbi^.biSize + PaletteSize(lpbi)), PBITMAPINFO(lpbi)^, DIB_RGB_COLORS) = 0) then
      begin
      // clean up and return NULL

         GlobalUnlock(hDIB);
         hDIB := 0;
         SelectPalette(hDC, hPal, TRUE);
         RealizePalette(hDC);
         ReleaseDC(0, hDC);
         BitmapToDIB := 0;
         exit;
      end;

      bi := lpbi^;

      // clean up
      GlobalUnlock(hDIB);
      SelectPalette(hDC, hPal, TRUE);
      RealizePalette(hDC);
      ReleaseDC(0, hDC);

      // return handle to the DIB
      BitmapToDIB := hDIB;
   end;
end.

