unit Debug;

interface

uses
   Dialogs, SysUtils, SyncObjs; // VK for EInOutError & MessageDlg

type
   TDebugFile = class
        FileName : string;
      private
         FLock : TCriticalSection;
      public
         constructor Create(const _FileName: String);
         destructor Destroy; override;
         procedure Add(const _Content:string);
   end;



implementation

uses Windows;

   constructor TDebugFile.Create(const _FileName: String);
   var
      MyFile : System.Text;
   begin
      FLock := TCriticalSection.Create;
      Filename := _Filename;
      try
         AssignFile(MyFile,Filename);
         FileMode := fmOpenWrite;
         Rewrite(MyFile);
         CloseFile(MyFile);
      except on E : EInOutError do // VK 1.36 U
         MessageDlg('Error: ' + E.Message + Char($0A) + Filename, mtError, [mbOK], 0);
      end;
   end;

   destructor TDebugFile.Destroy;
   begin
      FLock.Free;
      FileName := '';
      inherited Destroy;
   end;

   procedure TDebugFile.Add(const _Content:string);
   var
      MyFile : System.Text;
   begin
      try
         FLock.Acquire;
         AssignFile(MyFile,Filename);
         FileMode := fmOpenWrite;
         Append(MyFile);
         Writeln(MyFile,_Content);
         CloseFile(MyFile);
         FLock.Release;
      except on E : EInOutError do // VK 1.36 U
         MessageDlg('Error: ' + E.Message + Char($0A) + Filename, mtError, [mbOK], 0);
      end;
   end;

end.
