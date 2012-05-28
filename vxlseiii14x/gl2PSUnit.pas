unit gl2PSUnit;

interface

uses OpenGl, classes;

Const
  GL2PS_PS  = 0;
  GL2PS_EPS = 1;
  GL2PS_TEX = 2;
  GL2PS_PDF = 3;
  GL2PS_SVG = 4;
  GL2PS_PGF = 5;

// Sorting algorithms

  GL2PS_NO_SORT     = 1;
  GL2PS_SIMPLE_SORT = 2;
  GL2PS_BSP_SORT    = 3;

// Message levels and error codes

  GL2PS_SUCCESS       = 0;
  GL2PS_INFO          = 1;
  GL2PS_WARNING       = 2;
  GL2PS_ERROR         = 3;
  GL2PS_NO_FEEDBACK   = 4;
  GL2PS_OVERFLOW      = 5;
  GL2PS_UNINITIALIZED = 6;

// Options for gl2psBeginPage

  GL2PS_NONE                 = 0;
  GL2PS_DRAW_BACKGROUND      = (1 shl 0);
  GL2PS_SIMPLE_LINE_OFFSET   = (1 shl 1);
  GL2PS_SILENT               = (1 shl 2);
  GL2PS_BEST_ROOT            = (1 shl 3);
  GL2PS_OCCLUSION_CULL       = (1 shl 4);
  GL2PS_NO_TEXT              = (1 shl 5);
  GL2PS_LANDSCAPE            = (1 shl 6);
  GL2PS_NO_PS3_SHADING       = (1 shl 7);
  GL2PS_NO_PIXMAP            = (1 shl 8);
  GL2PS_USE_CURRENT_VIEWPORT = (1 shl 9);
  GL2PS_COMPRESS             = (1 shl 10);
  GL2PS_NO_BLENDING          = (1 shl 11);
  GL2PS_TIGHT_BOUNDING_BOX   = (1 shl 12);

// Arguments for gl2psEnable/gl2psDisable

  GL2PS_POLYGON_OFFSET_FILL = 1;
  GL2PS_POLYGON_BOUNDARY    = 2;
  GL2PS_LINE_STIPPLE        = 3;
  GL2PS_BLEND               = 4;

// Text alignment (o=raster position; default mode is BL):
//   +---+ +---+ +---+ +---+ +---+ +---+ +-o-+ o---+ +---o
//   | o | o   | |   o |   | |   | |   | |   | |   | |   |
//   +---+ +---+ +---+ +-o-+ o---+ +---o +---+ +---+ +---+
//    C     CL    CR    B     BL    BR    T     TL    TR */

  GL2PS_TEXT_C  = 1;
  GL2PS_TEXT_CL = 2;
  GL2PS_TEXT_CR = 3;
  GL2PS_TEXT_B  = 4;
  GL2PS_TEXT_BL = 5;
  GL2PS_TEXT_BR = 6;
  GL2PS_TEXT_T  = 7;
  GL2PS_TEXT_TL = 8;
  GL2PS_TEXT_TR = 9;

type
  GL2PSrgba = array[0..3] of GLfloat;
  GLVWarray = array[0..3] of GLInt;

  PGL2PSrgba = ^GL2PSrgba;
  PGLVWarray = ^GLVWArray;


procedure gl2psCreateStream(filename: AnsiString); cdecl; external 'gl2ps.dll';
procedure gl2psDestroyStream(); cdecl; external 'gl2ps.dll';

function gl2psBeginPage(title: AnsiString; producer: AnsiString;
                        viewport: PGLVWarray;
                        format,sort,options,colormode,colorsize: GLInt;
                        colormap: PGL2PSrgba;
                        nr, ng, nb, buffersize: GLInt;
                        filename: AnsiString): GLInt;
                        cdecl; external 'gl2ps.dll';

function gl2psEndPage(): GLInt; cdecl; external 'gl2ps.dll';
function gl2psSetOptions(options: GLInt): GLInt; cdecl; external 'gl2ps.dll';

//function gl2psGetOptions(GLint *options): GLInt; stdcall; external 'gl2ps.dll';

function gl2psBeginViewport(viewport: PGLVWarray): GLInt; stdcall; external 'gl2ps.dll';
function gl2psEndViewport(): GLInt; cdecl; external 'gl2ps.dll';

function gl2psText(const str: AnsiString; const fontname: AnsiString;
                   fontsize: GLshort): GLInt; cdecl; external 'gl2ps.dll';

function gl2psTextOpt(const str: AnsiString; const fontname: AnsiString;
                      fontsize: GLshort; align: GLint; angle: GLfloat): GLInt;
                      cdecl; external 'gl2ps.dll';

function gl2psSpecial(format: GLint; const str: AnsiString): GLInt;
                      cdecl; external 'gl2ps.dll';

//function gl2psDrawPixels(width, height: GLsizei; xorig, yorig: GLint;
//                         format, Atype: GLenum; const void *pixels): GLInt;
//                         stdcall; external 'gl2ps.dll';

function gl2psEnable(mode: GLInt): GLInt; cdecl; external 'gl2ps.dll';
function gl2psDisable(mode: GLInt): GLInt; cdecl; external 'gl2ps.dll';
function gl2psPointSize(value: GLFloat): GLInt; cdecl; external 'gl2ps.dll';
function gl2psLineWidth(value: GLFloat): GLInt; cdecl; external 'gl2ps.dll';

function gl2psBlendFunc(sfactor, dfactor: GLenum): GLInt;
                         cdecl; external 'gl2ps.dll';

implementation

end.
