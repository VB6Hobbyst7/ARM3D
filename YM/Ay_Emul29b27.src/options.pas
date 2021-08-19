{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit Options;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF Windows}Windows,{$ENDIF Windows}
  WinVersion, Classes, SysUtils, LazFileUtils, Forms, lazutf8;

function OptionsInit(PrepareToWrite:boolean):boolean;
procedure OptionsDone;
function OptionsRead(const OptionName:string;var OptionValue:string):boolean;
procedure OptionsWrite(const OptionName,OptionValue:string);
procedure SaveDefaultDir3;
procedure SaveDefaultDir2;
procedure DeleteOptions;

implementation

uses
 MainWin;

const
 fn = 'Ay_Emul.cfg';

var
  OPath:string='';
  OpArr:array of record
   Name,Value:string;
  end;

procedure AddOption(const Name,Value:string);
var
 i,n:integer;
begin
n := Length(OpArr);
if Name <> '' then
  for i := 0 to n-1 do
   if OpArr[i].Name = Name then
    begin
     OpArr[i].Value:=Value;
     exit;
    end;
SetLength(OpArr,n+1);
OpArr[n].Name:=Name;
OpArr[n].Value:=Value;
end;

function OptionsInit(PrepareToWrite:boolean):boolean;
var
 f:TextFile;

 procedure LoadOptions;
 var
  s,s1:string;
  i:integer;
 begin
  System.Reset(f);
  try
   while not eof(f) do
    begin
     Readln(f,s1);
     s := Trim(s1); if s = '' then
      begin
       AddOption('','');
       continue;
      end;
     if s[1] in [';','#'] then
      begin
       AddOption('',s1);
       continue;
      end;
     i := Pos('=',s1); if i in [0,1] then continue;
     AddOption(Copy(s1,1,i-1),Copy(s1,i+1,Length(s1)-i));
    end;
  finally
   CloseFile(f);
  end;
 end;

  function CheckAndRead(const path:string):boolean;
  var
   fname:string;
  begin
  Result := False;
  fname := path+fn;
  if FileExists(fname) then
   begin
    AssignFile(f,fname);
    try
     LoadOptions;
    except
     exit;
    end;
    OPath := path;
    Result := True;
   end;
  end;

 function CheckWriteAccess(const path:string):boolean;
 var
  fname:string;
  h:THandle;
 begin
 Result := False;
 fname := path+fn;
 if not FileExists(fname) then
  if not ForceDirectories(path) then exit;
 h := FileCreate(fname); if integer(h) = -1 then exit;
 FileClose(h);
 OPath := path;
 Result := True;
 end;

begin
Result := False;
if OPath = '' then
 begin
  Application.Title := 'Ay_Emul'; //avoid undesired behavior of GetAppConfigDirUTF8
  if not CheckAndRead(ExtractFilePath(GetProcessFileName)) then
   if not CheckAndRead(GetAppConfigDirUTF8(False)) then
    if not PrepareToWrite then exit;
 end
else
 if not CheckAndRead(OPath) then
  if not PrepareToWrite then exit;
if PrepareToWrite then
 begin
  if OPath = '' then
   begin
    if not CheckWriteAccess(GetAppConfigDirUTF8(False)) then
     if not CheckWriteAccess(ExtractFilePath(GetProcessFileName)) then
      begin
       OpArr := nil;
       exit;
      end;
   end
  else if not CheckWriteAccess(OPath) then
   begin
    OpArr := nil;
    exit;
   end;
 end;
Result := True;
end;

procedure OptionsDone;
var
 i,n:integer;
 f:TextFile;
 fname:string;
begin
n := Length(OpArr); if n = 0 then exit;
fname := OPath+fn;
AssignFile(f,fname);
try
 Rewrite(f);
 try
  for i := 0 to n-1 do
   if OpArr[i].Name <> '' then
    Writeln(f,OpArr[i].Name,'=',OpArr[i].Value)
   else
    Writeln(f,OpArr[i].Value);
 finally
  CloseFile(f);
 end;
except
end;
OpArr := nil;
end;

function OptionsRead(const OptionName:string;var OptionValue:string):boolean;
var
 i,n:integer;
begin
Result := False;
n := Length(OpArr); if n = 0 then exit;
for i := 0 to n-1 do
 if OpArr[i].Name = OptionName then
  begin
   OptionValue := OpArr[i].Value;
   Result := True;
   exit;
  end;
end;

procedure OptionsWrite(const OptionName,OptionValue:string);
begin
AddOption(OptionName,OptionValue);
end;

procedure SaveDefaultDir2;
{$IFDEF Windows}
var
 DefDir:string;
{$ENDIF Windows}
begin
if FrmMain.DefaultDirectory = '' then exit;
{$IFDEF Windows}
DefDir := ExtractFileDrive(FrmMain.DefaultDirectory);
if not ((DefDir <> '') and (DefDir[1] in ['a'..'z','A'..'Z']) and
        (GetDriveType(PChar(DefDir + '\')) = DRIVE_FIXED)) then exit;
{$ENDIF Windows}
OptionsWrite('DefaultDirectory',FrmMain.DefaultDirectory);
end;

procedure DeleteOptions;
begin
if FileExists(FIDO_Descriptor_FileName) then
 DeleteFile(FIDO_Descriptor_FileName);
if OPath = '' then exit;
if FileExists(OPath+fn) then
 DeleteFile(OPath+fn);
end;

procedure SaveDefaultDir3;
begin
OptionsInit(True);
try
 SaveDefaultDir2;
finally
 OptionsDone;
end;
end;

end.

