{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit basscode;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, {$IFDEF MSWINDOWS}Windows,{$ENDIF} WinVersion, Graphics, Classes, basslight, SysUtils;

var
 BASSFFTType:DWORD;
 BASSFFTNoWin:DWORD;
 BASSFFTRemDC:DWORD;
 BASSAmpMin:real;
 BASSNetUseProxy:boolean;
 BASSNetAgent,BASSNetProxy:string;
 BASSInitialized:boolean = False; //True => BASS_Init was called successfully
 BASSPaused:boolean;       //pause flag, used by SwitchPause
 BASSDevice:integer;
 MusicHandle:DWORD = 0;  //handle to stream or module,
                           //0 => no music loaded
 MusicIsStream:boolean;    //True => Music is stream, otherwise module

 {
 Next procedures and functions checks some flags and handles
 and if all OK calls BASS functions. During calling
 some errors can be ocurred, all of them are translated
 into DELPHI's exceptions with error messages
 }

 procedure InitBASS(device: Integer; freq, flags: DWORD; win: HWND);
                         //calls BASS_Init if BASS was not initialized

 procedure PlayBASS(FileName:PChar;Stream:boolean;StartTime,TimeLenMs:integer);
                         //Tries start playing file: Stream = True - as stream,
                         //                          Stream = False - as module.
                         //If successed then set sync for end of music by
                         //WM_PLAYNEXTITEM message
 procedure FreeAndUnloadBASS;
 function GetLengthBASS:QWORD;
                         //returns max position for using with
                         //BASS_ChannelGetPosition.

 procedure SetSync;    //Set SYNC_END and POS message
 procedure SetMetaSync;//Set SYNC_META message
 procedure RemoveSync; //Remove SYNC_END, POS and META message

 //procedure SetVolumeBASS(v:single); //if BASS loaded set global volume

 procedure GetNetConfig;
 procedure StartBASS;
 procedure PlayFreeBASS;     //if PlayBASS was OK, stops playing and removes sync

 function BASS_StreamCreateFile2(f: Pointer; flags: DWORD): HSTREAM;

 procedure SwitchPause;  //during playing pauses/resumes playback

 procedure BASSVisualisation;
 procedure BASS_SetLoop;

implementation

uses
  MainWin, Players, Mixer, FileTypes, settings;

var
 CallbackWindow:HWND;
 hsEND:HSYNC = 0; //sync handler, used for end of music message (WM_PLAYNEXTITEM)
                  //if <> 0 then sync is set
 hsPOS:HSYNC = 0;
 hsMETA:HSYNC = 0;
 SyncTime,SyncRestart:QWORD;
 {$IFDEF UseBassForEmu}
 StreamIsUser:boolean;    //True => Stream is user filled, otherwise file-stream
 {$ENDIF UseBassForEmu}

// BASSVolume:single = 1; //global volume 0..1

procedure FreeBASS;
begin
if BASSInitialized then
 begin
  BASSInitialized := False;
  BASS_Free;
 end;
end;

procedure InitBASS(device: Integer; freq, flags: DWORD; win: HWND);
begin
if BASSInitialized and (BASSDevice = device) then exit;
FreeBASS;
BASSDevice := device;
CallbackWindow := win;
BASSInitialized := BASS_Init(device,freq,flags,{$IFDEF MSWINDOWS}win{$ELSE}nil{$ENDIF},nil);
if not BASSInitialized then RaiseLastBASSError;
end;

procedure FreeAndUnloadBASS;
begin
FreeBASS;
UnloadBASS;
end;

procedure SyncEndProc(handle: HSYNC; channel, data: DWORD; user: Pointer); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
begin
if (SyncTime = QWORD(-1)) or not Do_Loop or not BASS_ChannelSetPosition(MusicHandle,SyncRestart,BASS_POS_BYTE) then
 PostMessage(CallbackWindow,WM_PLAYNEXTITEM,0,0);
end;

procedure SyncMetaProc(handle: HSYNC; channel, data: DWORD; user: Pointer); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
begin
PostMessage(CallbackWindow,WM_BASSMETADATA,0,0);
end;

{$IFDEF UseBassForEmu}
function StreamProcEmu(handle: HSTREAM; buffer: Pointer; length: DWORD; user: Pointer): DWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
var
 bl:integer;
begin
Result := 0;
if handle = MusicHandle then
 begin
  bl := BufferLength;
  BufferLength := DivMul(length,8,Int64(NumberOfChannels) * Int64(SampleBit));
  MakeBuffer(buffer);
  BufferLength := bl;
  Result := BuffLen * NumberOfChannels * SampleBit div 8;
  if Real_End_All then
   Result := Result or BASS_STREAMPROC_END;
 end;
end;
{$ENDIF UseBassForEmu}

procedure PlayBASS(FileName:PChar;Stream:boolean;StartTime,TimeLenMs:integer);
var
 fl:DWORD;
 Restart:boolean;
begin
if MusicHandle <> 0 then exit;
MusicIsStream := Stream;
{$IFDEF UseBassForEmu}
StreamIsUser := FileName = '';
{$ENDIF UseBassForEmu}
fl := 0; if Do_Loop then fl := BASS_SAMPLE_LOOP;
if Stream then
 begin
 //too slow
{  if Mpeg and ((Length(FileName) <= 2) or (FileName[1] <> '\') or
   (FileName[2] <> '\')) then //exclude prescan if network path
   f := f or BASS_STREAM_PRESCAN;}
  {$IFDEF UseBassForEmu}
  if FileName <> nil then
  {$ENDIF UseBassForEmu}
   MusicHandle := BASS_StreamCreateFile2(FileName,fl)
  {$IFDEF UseBassForEmu}
  else
   begin
    if SampleBit = 8 then
     fl := BASS_SAMPLE_8BITS
    else
     fl := 0;
    MusicHandle := BASS_StreamCreate(SampleRate,NumberOfChannels,fl,@StreamProcEmu,nil);
   end
  {$ENDIF UseBassForEmu}
   ;
 end
else
 MusicHandle := BASS_MusicLoad(False,FileName,0,0,
  BASS_MUSIC_STOPBACK or BASS_MUSIC_PRESCAN {or BASS_MUSIC_POSRESETEX} or fl,0);
if MusicHandle = 0 then RaiseLastBASSError;
BASSPaused := False;
Restart := True;
SyncTime := QWORD(-1);
if StartTime >= 0 then
 begin
  SyncRestart := BASS_ChannelSeconds2Bytes(MusicHandle,StartTime / 1000);
  if not BASS_ChannelSetPosition(MusicHandle,SyncRestart,BASS_POS_BYTE) then
   RaiseLastBASSError
  else
   begin
    Restart := False;
    SyncTime := BASS_ChannelSeconds2Bytes(MusicHandle,(StartTime + TimeLenMs) / 1000);
    SetSync;
   end;
 end;
if Restart and not Do_Loop then SetSync;
if Stream
  {$IFDEF UseBassForEmu}and not StreamIsUser{$ENDIF UseBassForEmu}
 then
  SetMetaSync;
//BASS_ChannelSetAttribute(MusicHandle,BASS_ATTRIB_VOL,BASSVolume);
if not BASS_ChannelPlay(MusicHandle,Restart) then RaiseLastBASSError;
end;

procedure SetSync;
begin
hsEND := BASS_ChannelSetSync(MusicHandle,BASS_SYNC_END,0,@SyncEndProc,nil);
if SyncTime <> QWORD(-1) then
 hsPOS := BASS_ChannelSetSync(MusicHandle,BASS_SYNC_POS,SyncTime,@SyncEndProc,nil);
end;

procedure SetMetaSync;
begin
hsMETA := BASS_ChannelSetSync(MusicHandle,BASS_SYNC_META,0,@SyncMetaProc,nil);
end;

procedure RemoveSync;
begin
 if hsEND <> 0 then
  begin
   if not BASS_ChannelRemoveSync(MusicHandle,hsEND) then RaiseLastBASSError;
   hsEND := 0;
  end;
 if hsPOS <> 0 then
  begin
   if not BASS_ChannelRemoveSync(MusicHandle,hsPOS) then RaiseLastBASSError;
   hsPOS := 0;
  end;
 if hsMETA <> 0 then
  begin
   if not BASS_ChannelRemoveSync(MusicHandle,hsMETA) then RaiseLastBASSError;
   hsMETA := 0;
  end;
end;

function GetLengthBASS:QWORD;
begin
Result := 0;
if MusicHandle = 0 then exit;
Result := BASS_ChannelGetLength(MusicHandle,BASS_POS_BYTE);
if int64(Result) = - 1 then RaiseLastBASSError;
end;

{procedure SetVolumeBASS(v:single);
begin
BASSVolume := v;
if MusicHandle = 0 then exit;
BASS_ChannelSetAttribute(MusicHandle,BASS_ATTRIB_VOL,v);
end;}

procedure PlayFreeBASS;
begin
if MusicHandle = 0 then exit;
try
 RemoveSync;
 BASS_ChannelStop(MusicHandle);
finally
 if MusicIsStream then
  BASS_StreamFree(MusicHandle)
 else
  BASS_MusicFree(MusicHandle);
 MusicHandle := 0;
end;
end;

(*var
 aFile:THandle=0;

procedure MyDownloadProc(buffer:pointer;length:DWORD;user:pointer);{$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
const
 CrLf = #13#10;
begin
if aFile = 0 then aFile := FileCreate(ParamStr(0)+'.download.mp3',fmOpenWrite);
if buffer = nil then
 begin
  FileClose(aFile);
  aFile := 0;
 end
else
 if length <> 0 then
  FileWrite(aFile,buffer^,length)
 else
  begin
   FileWrite(aFile,PChar(buffer)^,StrLen(PChar(buffer)));
   FileWrite(aFile,CrLf,2);
  end;
end;*)

function BASS_StreamCreateFile2(f: Pointer; flags: DWORD): HSTREAM;
var
 IsUrl:boolean;
begin
IsUrl := FileIsURL(PChar(f));
{$IFDEF Windows}
flags := flags or BASS_UNICODE;
f := PWideChar(UTF8Decode(PChar(f)));
{$ENDIF Windows}
if IsUrl then
 begin
  BASS_SetConfigPtr(BASS_CONFIG_NET_AGENT,PChar(BASSNetAgent));
  if not BASSNetUseProxy then
   BASS_SetConfigPtr(BASS_CONFIG_NET_PROXY,nil)
  else
   BASS_SetConfigPtr(BASS_CONFIG_NET_PROXY,PChar(BASSNetProxy));
  Result := BASS_StreamCreateURL(f,0,flags(* or $800000{BASS_STREAM_STATUS}*),nil{@MyDownloadProc},nil);
 end
else
 Result := BASS_StreamCreateFile(False,f,0,0,flags);
end;

procedure SwitchPause;
begin
if MusicHandle = 0 then exit;
if not BASSPaused then
 begin
  BASSPaused := BASS_ChannelPause(MusicHandle);
  if not BASSPaused then RaiseLastBASSError;
 end
else
 begin
  BASSPaused := not BASS_ChannelPlay(MusicHandle,False);
  if BASSPaused then RaiseLastBASSError;
 end
end;

procedure BASSVisualisation;
var
 i,l,r,k:DWORD;
 q:QWORD;
 fft:array of single;
 spa:array[0..spa_num-1] of single;
 k1,l1:real;
 sr:integer;
 srf:single;
begin
if (MusicHandle = 0) or Paused then exit;
  q := BASS_ChannelGetPosition(MusicHandle,BASS_POS_BYTE); if q = QWORD(-1) then exit;
  {$IFDEF UseBassForEmu}
  if StreamIsUser then
   AYVisualisation(DivMul(q,8,Int64(NumberOfChannels) * Int64(SampleBit)))
  else
  {$ENDIF UseBassForEmu}
   begin
    k1 := BASS_ChannelBytes2Seconds(MusicHandle,q); if k1 < 0 then exit;
    CurrTime_Rasch := trunc(k1 * 1000);
    if IsStreamFileType(CurFileType) and (StreamPlayFrom > 0) then
     Dec(CurrTime_Rasch,StreamPlayFrom);
    VProgrPos := CurrTime_Rasch;
    if IndicatorChecked then
     begin
      l := BASS_ChannelGetLevel(MusicHandle);
      if l <> $FFFFFFFF then
       begin
        r := l shr 16;
        if r <= BASSAmpMin * 128 then
         r := 0
        else
         r := trunc(32768/ln(1/BASSAmpMin)*ln(r/BASSAmpMin/32768)+0.5);
        l := l and $FFFF;
        if l <= BASSAmpMin * 128 then
         l := 0
        else
         l := trunc(32768/ln(1/BASSAmpMin)*ln(l/BASSAmpMin/32768)+0.5);
        RedrawVisChannels(l,0,r,32768)
       end
     end;
    if SpectrumChecked then
     begin
      case BASSFFTType of
      BASS_DATA_FFT256: k := 256;
      BASS_DATA_FFT512: k := 512;
      BASS_DATA_FFT1024: k := 1024;
      BASS_DATA_FFT2048: k := 2048;
      BASS_DATA_FFT4096: k := 4096;
      BASS_DATA_FFT8192: k := 8192;
      BASS_DATA_FFT16384: k := 16384;
      else k := 32768;
      end;
      SetLength(fft,k div 2);
      k1 := spa_num/ln(20000/20);
      l := BASS_ChannelGetData(MusicHandle,@fft[0],BASSFFTType or BASSFFTNoWin or BASSFFTRemDC); if l = $FFFFFFFF then exit;
      BMP_Vis.Canvas.CopyMode:=cmSrcCopy;
      BMP_Vis.Canvas.CopyRect(Rect(0,0,spa_width,spa_height),BMP_Sources.Canvas,Bounds(spa_src,0,spa_width,spa_height));
      if BASS_ChannelGetAttribute(MusicHandle,BASS_ATTRIB_FREQ,srf) then
       sr := trunc(srf)
      else
       sr := SampleRate;
      FillChar(spa,spa_num*sizeof(single),0);
      for i := 1 to k div 2 - 1 do
         begin
          r := trunc(k1 * ln(i/k/20*sr)+0.5);
          if r < spa_num then
           spa[r] := spa[r] + fft[i]*fft[i];
         end;
      fft := nil;

      for r := 0 to spa_num-1 do
       begin
        l1 := sqrt(spa[r]);
        if l1 > BASSAmpMin then
         begin
          l1 := spa_height - spa_height/ln(1/BASSAmpMin)*ln(l1/BASSAmpMin);
          if l1 >= 0 then
           begin
            BMP_Vis.Canvas.MoveTo(r,spa_height);
            BMP_Vis.Canvas.LineTo(r,trunc(l1+0.5) + 1);
           end;
         end
       end;

      //todo передавать Canvas через параметры
      FrmMain.Canvas.CopyMode:=cmSrcCopy;
      FrmMain.Canvas.CopyRect(Bounds(spa_x,spa_y,spa_width,spa_height),BMP_Vis.Canvas,Rect(0,0,spa_width,spa_height));
     end;
    ShowProgress(VProgrPos);
   end;
end;

procedure GetNetConfig;
var
 p:pointer;
begin
if BASSNetAgent = '' then
 begin
  BASSNetAgent := PChar(BASS_GetConfigPtr(BASS_CONFIG_NET_AGENT));
  //todo не использовать FrmMixer, через параметры?
  FrmMixer.NetAgentCB.Text := BASSNetAgent;
  p := BASS_GetConfigPtr(BASS_CONFIG_NET_PROXY);
  BASSNetUseProxy := p <> nil;
  FrmMixer.ProxyE.Enabled := BASSNetUseProxy;
  FrmMixer.ProxyChk.Checked := BASSNetUseProxy;
  if BASSNetUseProxy then
   begin
    BASSNetProxy := PChar(p);
    FrmMixer.ProxyE.Text := BASSNetProxy;
   end;
 end;
end;

procedure StartBASS;
begin
 if IsPlaying then exit;
 PlayFreeBASS;
 LoadBASS;
 GetNetConfig;
                                                                 //todo передавать Handle через параметры
 InitBASS({BASS_FIRSTSOUNDDEVICE}BASS_DEFAULTDEVICE,SampleRate,0,FrmMain.Handle);

 IsPlaying := True;
 Paused := False;
 {$IFDEF UseBassForEmu}

 if CurFileType in [BASSFileMin..BASSFileMax] then
  begin
 {$ENDIF UseBassForEmu}
   PlayBASS(PChar(CurItem.FileName),IsStreamFileType(CurFileType),StreamPlayFrom,Time_ms);
   if FileIsURL(CurItem.FileName) then PostMessage(FrmMain.Handle,WM_BASSMETADATA,0,0);
 {$IFDEF UseBassForEmu}
  end
 else if CurFileType in [MinAYChipFile..MaxAYChipFile] then
  PlayBASS(nil,True,DLL,-1,Time_ms);
 {$ENDIF Windows}
end;

procedure BASS_SetLoop;
var
 info:BASS_CHANNELINFO;
begin
if MusicHandle = 0 then exit;
if IsStreamFileType(CurFileType) and (StreamPlayFrom >= 0) then exit;
BASS_ChannelGetInfo(MusicHandle,info);
if Do_Loop then
 begin
  RemoveSync;
  info.flags := info.flags or BASS_SAMPLE_LOOP
 end
else
 begin
  if (Time_ms >= 0) and (CurrTime_Rasch >= Time_ms) then
   begin        //todo передавать Handle через параметры или сделать в инит WndHandleforBASS := Handle
    PostMessage(FrmMain.Handle,WM_PLAYNEXTITEM,0,0);
    exit
   end;
  SetSync;
  info.flags := info.flags and (BASS_SAMPLE_LOOP xor DWORD(-1));
 end;
BASS_ChannelFlags(MusicHandle,info.flags,info.flags);
end;

end.
