unit FTGifAnimate;
(******************************************************************************
Unit to make an animated GIF.
Author: Finn Tolderlund
        Denmark
Date: 14.07.2003

homepage:
http://home20.inet.tele.dk/tolderlund/
http://finn.mobilixnet.dk/
e-mail:
finn@mail.tdcadsl.dk
finn.tolderlund@mobilixnet.dk

This unit requires the GIFImage.pas unit from Anders Melander.
The GIFImage.pas unit can be obtained from my homepage above.

This unit can freely be used and distributed.

Disclaimer:
Use of this unit is on your own responsibility.
I will not under any circumstance be held responsible for anything
which may or may not happen as a result of using this unit.
******************************************************************************
History:
19.07.2003  Added GifAnimateEndGif function.
24.07.2003  Added link to an example Delphi project at Earl F. Glynn's website.
02.09.2003  Renamed function GifAnimateEnd to GifAnimateEndPicture.
            Added overloaded function GifAnimateAddImage where you can specify
            a specific TransparentColor.
******************************************************************************)
(******************************************************************************
Example of use:

procedure TFormSphereMovie.MakeGifButtonClick(Sender: TObject);
// BitMapArray is an array of TBitmap.
var
  FrameIndex: Integer;
  Picture: TPicture;
begin
  Screen.Cursor := crHourGlass;
  try
    GifAnimateBegin;
    {Step through each frame in in-memory list}
    for FrameIndex := Low(BitMapArray) to High(BitMapArray) do
    begin
      // add frame to animated gif
      GifAnimateAddImage(BitMapArray[FrameIndex], False, MillisecondsPerFrame);
    end;
    // We are using a TPicture but we could have used a TGIFImage instead.
    // By not using TGIFImage directly we do not have to add GIFImage to the uses clause.
    // By using TPicture we only need to add GifAnimate to the uses clause.
    Picture := GifAnimateEndPicture;
    Picture.SaveToFile(ExtractFilePath(ParamStr(0)) + 'sphere.gif');  // save gif
    ImageMovieFrame.Picture.Assign(Picture);  // display gif
    Picture.Free;
  finally
    Screen.Cursor := crDefault;
  end;
end;
******************************************************************************)
(******************************************************************************
For a complete Delphi project with source, goto one of these pages:
http://homepages.borland.com/efg2lab/Graphics/SphereInCubeMovie.htm
http://www.efg2.com/Lab/Graphics/SphereInCubeMovie.htm
******************************************************************************)

interface

uses
  Windows, Graphics, GIFImage;

procedure GifAnimateBegin;

function GifAnimateEndPicture: TPicture;

function GifAnimateEndGif: TGIFImage;

function GifAnimateAddImage(Source: TGraphic; Transparent: Boolean; DelayMS: Word): Integer; overload;
// Transparent=True uses lower left pixel as transparent color

function GifAnimateAddImage(Source: TGraphic; TransparentColor: TColor; DelayMS: Word): Integer; overload;
// TransparentColor<>-1 uses that color as the transparent.
// Note: There is no guaranteee that the color will actually be in the GIF's color palette.

implementation

var
  GIF: TGIFImage;

function TransparentIndex(GIF: TGIFSubImage): byte;
begin
  // Use the lower left pixel as the transparent color
  Result := GIF.Pixels[0, GIF.Height-1];
end;

function GifAnimateAddImage(Source: TGraphic; Transparent: Boolean; DelayMS: Word): Integer;
var
  Ext		 : TGIFGraphicControlExtension;
  LoopExt: TGIFAppExtNSLoop;
begin
  // Add the source image to the animation
  Result := GIF.Add(Source);
  // Netscape Loop extension must be the first extension in the first frame!
  if (Result = 0) then
  begin
    LoopExt := TGIFAppExtNSLoop.Create(GIF.Images[Result]);
    LoopExt.Loops := 0; // Number of loops (0 = forever)
    GIF.Images[Result].Extensions.Add(LoopExt);
  end;
  // Add Graphic Control Extension
  Ext := TGIFGraphicControlExtension.Create(GIF.Images[Result]);
  Ext.Delay := DelayMS div 10;  // 30; // Animation delay (30 = 300 mS)
//  if (Result > 0) then
  if (Transparent) then
  begin
    Ext.Transparent := True;
    Ext.TransparentColorIndex := TransparentIndex(GIF.Images[Result]);
  end;
  GIF.Images[Result].Extensions.Add(Ext);
end;

function GetColorIndex(GIF: TGIFSubImage; Color: TColor): Integer;
var
  idx, x, y: Integer;
begin
  // Find index for color in the colormap.
  // The same color can be in the colormap more than once.
  // Not all color indexes may be in use, so check if this index is being used.
  // Return only an index which is actually being used in the image.
  // If the index is not being used in the image,
  // try to find the next index for the color in the colormap.
  for idx := 0 to GIF.ColorMap.Count - 1 do
    if GIF.ColorMap.Colors[idx] = Color then
    begin
      // Found an index, is it being used in the image?
      for y := 0 to GIF.Height-1 do
        for x := 0 to GIF.Width-1 do
          if GIF.Pixels[x, y] = idx then
          begin
            Result := idx;  // Index is used in image.
            Exit;
          end;
      // Index not used in the image, try next index.
    end;
  Result := -1;  // didn't find index for the color
end;

function GifAnimateAddImage(Source: TGraphic; TransparentColor: TColor; DelayMS: Word): Integer;
var
  Ext		 : TGIFGraphicControlExtension;
  LoopExt: TGIFAppExtNSLoop;
  idx: Integer;
begin
  // Add the source image to the animation
  Result := GIF.Add(Source);
  // Netscape Loop extension must be the first extension in the first frame!
  if (Result = 0) then
  begin
    LoopExt := TGIFAppExtNSLoop.Create(GIF.Images[Result]);
    LoopExt.Loops := 0; // Number of loops (0 = forever)
    GIF.Images[Result].Extensions.Add(LoopExt);
  end;
  // Add Graphic Control Extension
  Ext := TGIFGraphicControlExtension.Create(GIF.Images[Result]);
  Ext.Delay := DelayMS div 10;  // 30; // Animation delay (30 = 300 mS)
  if TransparentColor <> -1 then
  begin
    idx := GetColorIndex(GIF.Images[Result], TransparentColor);
    if idx in [0..255] then
    begin
      Ext.Transparent := True;
      Ext.TransparentColorIndex := idx;
    end;
  end;
  GIF.Images[Result].Extensions.Add(Ext);
end;

procedure GifAnimateBegin;
begin
  GIF.Free;
  GIF := TGIFImage.Create;
  GIF.ColorReduction := rmQuantizeWindows;
  //  GIF.DitherMode := dmNearest;  // no dither, use nearest color in palette
  GIF.DitherMode := dmFloydSteinberg;
  GIF.Compression := gcLZW;
end;

function GifAnimateEndPicture: TPicture;
begin
  Result := TPicture.Create;
  Result.Assign(GIF);
  GIF.Free;
  GIF := nil;
end;

function GifAnimateEndGif: TGIFImage;
begin
  Result := TGIFImage.Create;
  Result.Assign(GIF);
  GIF.Free;
  GIF := nil;
end;

initialization
  GIF := nil;
finalization
  GIF.Free;
end.
