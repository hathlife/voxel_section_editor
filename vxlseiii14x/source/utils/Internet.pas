unit Internet;

interface

uses Windows, Forms, WinInet, SysUtils, Classes, BasicFunctions;

type
   TWebFileDownloader = class(TThread)
      private
         FFileURL: string;
         FFileName: string;
         procedure ForceProcessMessages;
      protected
         procedure Execute; override;
         function GetWebFile (const _FileURL, _FileName: String): boolean;
      public
         constructor Create(const _FileURL, _FileName: String);
         destructor Destroy; override;
   end;

function GetWebContent (const _FileURL: String): string;

implementation

constructor TWebFileDownloader.Create(const _FileURL, _FileName: String);
begin
   inherited Create(true);
   Priority := TpLowest;
   FFileURL := CopyString(_FileURL);
   FFileName := CopyString(_FileName);
   ReturnValue := 0;
   Resume;
end;

procedure TWebFileDownloader.Execute;
begin
   if GetWebFile(FFileURL,FFileName) then
      ReturnValue := 1;
   inherited;
end;

destructor TWebFileDownloader.Destroy;
begin
   FFileURL := '';
   FFilename := '';

   inherited Destroy;
end;

function TWebFileDownloader.GetWebFile (const _FileURL, _FileName: String): boolean;
const
   BufferSize = 1024;
var
   hSession, hURL: HInternet;
   Buffer: array[1..BufferSize] of Byte;
   BufferLen: DWORD;
   f: File;
   sAppName: string;
begin
   result := false;
   sAppName := ExtractFileName(Application.ExeName) ;
   hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0) ;
   try
      hURL := InternetOpenURL(hSession, PChar(_FileURL), nil, 0, 0, 0) ;
      try
         AssignFile(f, _FileName) ;
         Rewrite(f,1) ;
         repeat
            InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen) ;
            BlockWrite(f, Buffer, BufferLen);
            synchronize(ForceProcessMessages);
         until BufferLen = 0;
         CloseFile(f);
      finally
         InternetCloseHandle(hURL);
         result := True;
      end
   finally
      InternetCloseHandle(hSession)
   end
end;

procedure TWebFileDownloader.ForceProcessMessages;
begin
   Application.ProcessMessages;
end;


function GetWebContent (const _FileURL: String): string;
const
   BufferSize = 1024;
var
   hSession, hURL: HInternet;
   Buffer: array[1..BufferSize] of Byte;
   BufferLen,i: DWORD;
   sAppName: string;
begin
   Result := '';
   sAppName := ExtractFileName(Application.ExeName) ;
   hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0) ;
   try
      hURL := InternetOpenURL(hSession, PChar(_FileURL), nil, 0, 0, 0) ;
      try
         repeat
            InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen) ;
            for i := 1 to Bufferlen do
            begin
               Result := Result + Char(Buffer[i]);
            end;
         until BufferLen = 0;
      finally
         InternetCloseHandle(hURL)
      end
   finally
      InternetCloseHandle(hSession)
   end
end;


end.
