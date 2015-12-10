unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Registry, ShellApi, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True;
   ListOfStrings.DelimitedText   := Str;
end;

function getRegistryKey(Key: string; StringName: string):string;
var R: TRegistry;
begin
  R := TRegistry.Create(KEY_WRITE);
  try
    R.RootKey := HKEY_CLASSES_ROOT;
    if not R.OpenKeyReadOnly(Key) then
      result := '';
    result := R.ReadString(StringName);
  finally R.Free;
  end;
end;

function addRegistryKey(Key: string; StringName: string; StringValue: string):boolean;
var R: TRegistry;
begin
  R := TRegistry.Create(KEY_WRITE);
  try
    R.RootKey := HKEY_CLASSES_ROOT;
    if not R.OpenKey(Key, True) then
      result := false
    else
      result := true;
    R.WriteString(StringName, StringValue);
  finally R.Free;
  end;
end;

function delRegistryKey(Key: string):boolean;
var R: TRegistry;
begin
  R := TRegistry.Create(KEY_WRITE);
  try
    R.RootKey := HKEY_CLASSES_ROOT;
    R.Access := KEY_ALL_ACCESS;
    R.DeleteKey(Key);
  finally R.Free;
  end;
  result := true;
end;

function existsRegistryKey(Key: string):boolean;
var R: TRegistry;
begin
  R := TRegistry.Create(KEY_READ);
  try
    R.RootKey := HKEY_CLASSES_ROOT;
    if not R.OpenKey(Key, False) then
      result := false
    else
      result := true;
  finally R.Free;
  end;
end;

function addEntry(tvpath: string):boolean;
var k1,k2,k3,k4,k5,k6,k7:boolean;
begin
  k1 := addRegistryKey('teamviewer','','URL:Teamviewer URI Protocol');
  k2 := addRegistryKey('teamviewer','teamviewer',tvpath);
  k3 := addRegistryKey('teamviewer','URL Protocol','');
  k4 := addRegistryKey('teamviewer\DefaultIcon','',ExtractFileName(Application.ExeName) + ',1');
  k5 := addRegistryKey('teamviewer\shell','','');
  k6 := addRegistryKey('teamviewer\shell\open','','');
  k7 := addRegistryKey('teamviewer\shell\open\command','','"' + Application.ExeName + '" "%1"');
  if( k1=true and k2=true and k3=true and k4=true and k5=true and k6=true and k7=true) then
    begin
      showmessage('TeamViewer erfolgreich hinterlegt!');
      application.terminate;
      result := true;
    end else begin
      showmessage('TeamViewer konnte nicht hinterlegt werden. Hast du Adminrechte?');
      result := false;
    end;
end;

function executeTeamviewer(data: string):boolean;
var
   list1,list2: TStringList;
   tvid: integer;
   tvpass: string;
begin
   list1 := TStringList.Create;
   list2 := TStringList.Create;
   tvid := 0;
   tvpass := '';
   try
     Split('/', data, list1);
     if(list1[2] <> '') then
     begin
       Split(':', list1[2], list2);
       if(list2[0] <> '') then
       begin
         tvid := StrToInt(list2[0]);
         if(list2[1] <> '') then
           tvpass := list2[1];
         ShellExecute(0,'open',pchar(getRegistryKey('teamviewer','teamviewer')),pchar('-i ' + IntToStr(tvid) + ' --Password ' + tvpass),nil,SW_SHOWNORMAL);
         result := true;
         application.terminate;
       end else
         result := false;
     end else
       result := false;
   finally
     list1.Free;
     list2.Free;
   end;
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
   begin
     addEntry(OpenDialog1.Filename);
   end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     delRegistryKey('teamviewer\shell\open\command');
     delRegistryKey('teamviewer\shell\open');
     delRegistryKey('teamviewer\shell');
     delRegistryKey('teamviewer\DefaultIcon');
     delRegistryKey('teamviewer');
     if (existsRegistryKey('futuratv') = false) then
       Button2.Enabled := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if(ParamStr(1) <> '') then
    executeTeamviewer(ParamStr(1));
  if (existsRegistryKey('teamviewer') = false) then
    begin
       Button2.Enabled := false;
       if OpenDialog1.Execute then
       begin
         addEntry(OpenDialog1.Filename);
       end;
    end
  else
      Button2.Enabled := true;
end;

end.

