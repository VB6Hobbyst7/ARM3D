{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit WinVersion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, LCLIntf, LCLType, lazutf8,
  {$IFDEF Windows}
  Windows,
  {$ENDIF Windows}
  Types, simpleipc, process;

const
//Version related constants
 VersionString = '2.9';
 VersionMajor = 2;
 VersionMinor = 9;
 CompilYs = '2021';
 CompilY = 2021;
 CompilM = 05;
 CompilD = 1;
 {$ifdef beta}
 BetaNumber = 'beta 27';
 {$endif beta}
 IPCServerName = 'Ay_Emul 2.9'{$ifdef beta}+' '+BetaNumber{$endif beta} + ' IPC';
 {$IFDEF Windows}
 DdeServiceName = 'Ay_Emul 2.9'{$ifdef beta}+' '+BetaNumber{$endif beta} + ' DDE';
 {$ENDIF Windows}

var
  IPCServer:TSimpleIPCServer;

  function GetCommandLine:string;
  function FileIsURL(FileName:string):boolean;
  function IPCSendParams:boolean;
  procedure StartIPC;
  procedure StopIPC;
  {$IFDEF Windows}
  procedure StartDDE;
  procedure StopDDE;
  procedure OpenInEditor;
  {$ENDIF Windows}
  procedure RemoveTaskbarButton;
  procedure AddTaskbarButton;
  procedure CheckStringFitting(handle:THandle;var s:string;w:integer);
  function GetProcessFileName:string;
  {$IFNDEF Windows}
  procedure NonWin;
  {$ENDIF Windows}
  procedure CmdExecute(const cmd:string;const pars:array of string);

implementation

uses
{$IFDEF Windows}
 MainWin, PlayList;
{$ELSE Windows}
 Languages;
{$ENDIF Windows}

function IPCSendParams:boolean;
var
 s:string;
begin
Result := False;
with TSimpleIPCClient.Create(nil) do
  try
    ServerID:=IPCServerName;
    if ServerRunning then
     begin
       Active:=True;
       Result := True;
       s := '"' + GetCurrentDir + '" ' + GetCommandLine;
       if ParamCount = 0 then s := s + ' -vshow';
       SendStringMessage(s);
       Active:=False;
     end;
  finally
    Free;
  end;
end;

type
 TMessageHook = class(TThread)
   procedure ApplyMessage;
 protected
   procedure Execute; override;
 end;

var
  MessageHook:TMessageHook;

procedure TMessageHook.ApplyMessage;
begin
  IPCServer.PeekMessage(0, True)
end;

procedure TMessageHook.Execute;
begin
  while not Terminated do
   begin
    if IPCServer.Active then
      Synchronize(@ApplyMessage);
    Sleep(3);
   end;
end;

procedure StartIPC;
begin
IPCServer:=TSimpleIPCServer.Create(Nil);
IPCServer.ServerID:=IPCServerName;
IPCServer.Global:=True;
IPCServer.StartServer;
MessageHook := TMessageHook.Create(False);
end;

procedure StopIPC;
begin
  MessageHook.Terminate;
  MessageHook.WaitFor;
  MessageHook.Free;
  IPCServer.Free;
end;

{$IFDEF Windows}
var
 DdeInst: Integer;

 function hsz2Str(Ahsz: HSZ): String;
 var
  L: Integer;
 begin
  Result := '';
  if Ahsz = 0 then exit;
  L := DdeQueryString(DdeInst, Ahsz, nil, 0, CP_WINANSI);
  if L <= 0 then exit;
  SetLength(Result, L);
  DdeQueryString(DdeInst, Ahsz, PChar(Result), L + 1, CP_WINANSI);
 end;

 function hDdeData2Str(AData: HDDEData): String;
 var
  L: Integer;
 begin
  Result := '';
  if AData = 0 then exit;
  L := DdeGetData(AData, nil, 0, 0);
  if L <= 0 then exit;
  SetLength(Result, L);
  DdeGetData(AData, PByte(PChar(Result)), L, 0);
  Result := UTF8Encode(WideString(PWideChar(Result)));
 end;

 function DdeFunc(CallType, Fmt: UINT; Conv: HConv; hsz1, hsz2: HSZ;
  Data: HDDEData; Data1, Data2: DWORD): HDDEData stdcall;
 const
  SZDDESYS_TOPIC = 'System';
 begin
  Result := 0;
  case CallType of
    XTYP_CONNECT: begin
      if SameText(hsz2Str(hsz1), SZDDESYS_TOPIC)
      and SameText(hsz2Str(hsz2), DdeServiceName) then
        begin
         Result := 1;
        end;
    end;
    XTYP_EXECUTE: begin
      if SameText(hsz2Str(hsz1), SZDDESYS_TOPIC) then begin
        SetCommandLine('"' + GetCurrentDir + '" Ay_Emul.exe ' + hDdeData2Str(Data));
        Result := DDE_FACK;
      end;
    end;
  end;
 end;

procedure StartDDE;
const
 CBF_SKIP_ALLNOTIFICATIONS = $003c0000;
begin
DdeInitializeW(@DdeInst, @DdeFunc, APPCLASS_STANDARD or CBF_SKIP_ALLNOTIFICATIONS, 0);
DdeNameService(DdeInst, DdeCreateStringHandle(DdeInst, DdeServiceName, CP_WINANSI), 0, DNS_REGISTER);
end;

procedure StopDDE;
begin
DdeUninitialize(DdeInst);
end;

{$ENDIF Windows}

function FileIsURL(FileName:string):boolean;
const
 nprotos=2;
 protos:array[0..nprotos]of string=
   ('http://','https://','ftp://');
var
 i:integer;
begin
FileName := LowerCase(FileName);
Result := True;
for i := 0 to nprotos do
 if (Pos(protos[i],FileName) = 1) then exit;
Result := False;
end;

function GetCommandLine:string;
{$IFDEF Windows}
begin
Result := UTF8Encode(WideString(GetCommandLineW))
{$ELSE Windows}
var
 i:integer;
begin
Result := '"' + ParamStr(0) + '"';
for i := 1 to ParamCount do
 Result := Result + ' "' + ParamStr(i) + '"';
{$ENDIF Windows}
end;

procedure CmdExecute(const cmd:string;const pars:array of string);
var
 i:integer;
begin
with TProcess.Create(nil) do
 try
  Executable := cmd;
  for i := 0 to Length(pars)-1 do
   Parameters.Add(pars[i]);
  Options := [poWaitonexit];
  Execute;
 finally
  Free;
 end;
end;

{$IFDEF Windows}

procedure OpenInEditor;
var
 SI:STARTUPINFOW;
 PI:PROCESS_INFORMATION;
 FN:array of string;
 s:string;
 i,n:integer;
begin
n := 0; s := '';
for i := 0 to Length(PlaylistItems) - 1 do
 if PlayListItems[i]^.Selected then
  begin
   inc(n);
   SetLength(FN,n);
   FN[n - 1] := FrmPLst.SaveFile(i,True);
   s := s + ' "' + FN[n - 1] + '"';
  end;
if n = 0 then exit;
FillChar(SI,sizeof(SI),0);
SI.cb := sizeof(SI);
if not CreateProcessW(PWideChar(UTF8Decode(VTPath)),PWideChar(UTF8Decode(VTPath + s)),
        nil,nil,False,0,nil,PWideChar(UTF8Decode(ExtractFileDir(VTPath))),SI,PI) then
 begin //todo: удалять временные файлы по завершению процесса?
  try
   RaiseLastOSError;
  finally
   for i := n - 1 downto 0 do
    SysUtils.DeleteFile(FN[i]);
  end;
 end;
end;

{$ENDIF Windows}

procedure CheckStringFitting(handle:THandle;var s:string;w:integer);
var
 sz:TSize;
 len,nch:integer;
begin
len := Length(s); //в байтах - вроде фича LCL, а не баг
if not LCLIntf.GetTextExtentExPoint(handle,PChar(s),len,w,@nch,nil,Sz) then exit;
len := UTF8Length(s);
if nch < len then s := UTF8Copy(s,1,nch-3)+'...';
end;

function GetProcessFileName:string;
begin
Result := ParamStr{UTF8}(0);
end;

{$IFDEF Windows}
procedure Set_WS_EXSTYLE(h:THandle;WS:DWORD);
begin
ShowWindow(h,SW_HIDE);
SetWindowLong(h, GWL_EXSTYLE, WS);
ShowWindow(h,SW_SHOWNA);
end;
{$ENDIF Windows}

procedure RemoveTaskbarButton;
{$IFDEF Windows}
var
 h:THandle;
{$ENDIF Windows}
begin
{$IFDEF Windows}
h := GetParent(FrmMain.Handle);
Set_WS_EXSTYLE(h,GetWindowLong(h, GWL_EXSTYLE) and not WS_EX_APPWINDOW or WS_EX_TOOLWINDOW);
{$ENDIF Windows}
//todo in GTK2
end;

procedure AddTaskbarButton;
{$IFDEF Windows}
var
 h:THandle;
{$ENDIF Windows}
begin
{$IFDEF Windows}
h := GetParent(FrmMain.Handle);
Set_WS_EXSTYLE(h,GetWindowLong(h, GWL_EXSTYLE) and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW);
{$ENDIF Windows}
//todo in GTK2
end;

{$IFNDEF Windows}
procedure NonWin;
begin
MessageDlg(Mes_WinVersion,mtInformation,[mbOk],0);
end;
{$ENDIF Windows}

end.

