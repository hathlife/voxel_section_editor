unit Debug;

interface

type
   TDebugFile = class
        FileName : string;
      private
      public
         constructor Create(const _FileName: String);
         procedure Add(const _Content:string);
   end;



implementation

   constructor TDebugFile.Create(const _FileName: String);
   var
      MyFile : System.Text;
   begin
      Filename := _Filename;
      AssignFile(MyFile,Filename);
      Rewrite(MyFile);
      CloseFile(MyFile);
   end;

   procedure TDebugFile.Add(const _Content:string);
   var
      MyFile : System.Text;
   begin
      AssignFile(MyFile,Filename);
      Append(MyFile);
      Writeln(MyFile,_Content);
      CloseFile(MyFile);
   end;

end.
