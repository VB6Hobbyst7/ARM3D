{
basslight
---------
(c)2003,2021 S.V.Bulba
http://bulba.untergrund.net/
svbulba@gmail.com

Description:
------------
Dinamycally loads/unloads BASS.DLL (BASSWMA.DLL, BASS_APE.DLL, BASSFLAC.DLL,
BASSWV.DLL, BASS_AC3.DLL, etc)
Uses minimal set of constants, types and declarations from
original BASS.PAS, BASSWMA.PAS, BASS_APE.PAS, BASSFLAC.PAS, BASSWV.PAS,
BASS_AC3.PAS, etc

Linux version is supported too

Written for using with BASS version 2.4
}

unit basslight;

{$mode objfpc}{$H+}

interface

uses
 LCLIntf,LCLType{$IFDEF MSWINDOWS},Windows{$ELSE},dl{$ENDIF}
 {$IFDEF dbgmode},Dialogs{$ENDIF},SysUtils;

type
 EBASSError = class(Exception);

 HMUSIC = DWORD;
 HSAMPLE = DWORD;
 HSTREAM = DWORD;
 HSYNC = DWORD;
// BOOL = LongBool;
// QWORD = int64;
 HPLUGIN = DWORD;

 STREAMPROC = function(handle: HSTREAM; buffer: Pointer; length: DWORD; user: Pointer): DWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 DOWNLOADPROC = procedure(buffer: Pointer; length: DWORD; user: Pointer); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 SYNCPROC = procedure(handle: HSYNC; channel, data: DWORD; user: Pointer); {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

  BASS_CHANNELINFO = record
    freq: DWORD;        // default playback rate
    chans: DWORD;       // channels
    flags: DWORD;       // BASS_SAMPLE/STREAM/MUSIC/SPEAKER flags
    ctype: DWORD;       // type of channel
    origres: DWORD;     // original resolution
    plugin: HPLUGIN;    // plugin
    sample: HSAMPLE;    // sample
    {$IFDEF CPUX64}
    padding: DWORD;
    {$ENDIF}
    filename: PChar;    // filename
  end;

procedure RaiseLastBASSError;

procedure LoadBASS; //if BASS is not loaded then loads BASS and plug-ins
                        //checks version and gets some procs addresses

procedure UnloadBASS;   //Unload BASS if it was loaded

const
 BASS_DEFAULTDEVICE = -1;
 BASS_NOSOUNDDEVICE = 0;
 BASS_FIRSTSOUNDDEVICE = 1;

//Some consts from BASS*.PAS
 BASS_CONFIG_NET_AGENT     = 16;
 BASS_CONFIG_NET_PROXY     = 17;

 BASS_TAG_ID3   = 0;
 BASS_TAG_ID3V2 = 1;
 BASS_TAG_OGG   = 2;
 BASS_TAG_HTTP  = 3;
 BASS_TAG_ICY   = 4;
 BASS_TAG_META  = 5;
 BASS_TAG_APE   = 6;
 BASS_TAG_WMA   = 8;

 BASS_TAG_RIFF_INFO  = $100;
 BASS_TAG_MUSIC_NAME = $10000;
 BASS_TAG_MUSIC_MESSAGE = $10001;
 BASS_TAG_MUSIC_INST = $10100;
 BASS_TAG_MUSIC_SAMPLE = $10300;

 BASS_STREAM_PRESCAN     = $20000;
 BASS_STREAM_DECODE      = $200000;

 BASS_UNICODE            = $80000000;

 BASS_SAMPLE_LOOP        = 4;

 BASS_MUSIC_STOPBACK     = $80000;
 BASS_MUSIC_PRESCAN      = BASS_STREAM_PRESCAN;
 BASS_MUSIC_CALCLEN      = BASS_MUSIC_PRESCAN;
 BASS_MUSIC_NOSAMPLE     = $100000;

 BASS_POS_BYTE           = 0;

 BASS_DATA_FFT256   = $80000000;
 BASS_DATA_FFT512   = $80000001;
 BASS_DATA_FFT1024  = $80000002;
 BASS_DATA_FFT2048  = $80000003;
 BASS_DATA_FFT4096  = $80000004;
 BASS_DATA_FFT8192  = $80000005;
 BASS_DATA_FFT16384 = $80000006;
 BASS_DATA_FFT32768 = $80000007;
 BASS_DATA_FFT_NOWINDOW = $20;
 BASS_DATA_FFT_REMOVEDC = $40;

 BASS_SYNC_POS           = 0;
 BASS_SYNC_END           = 2;
 BASS_SYNC_META          = 4;
 {$IFDEF UseBassForEmu}
 BASS_STREAMPROC_END = $80000000;
 BASS_SAMPLE_8BITS       = 1;
 {$ENDIF UseBassForEmu}
 BASS_ATTRIB_FREQ           = 1;
 // BASS_ATTRIB_VOL         = 2;

 // BASS_MP3_SETPOS         = BASS_STREAM_PRESCAN;

var
 BASSErrorString:string;
 BASSErCode:DWORD;

 //Some BASS.DLL function addresses (see description in original BASS.PAS)
 BASS_GetVersion:function: DWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ErrorGetCode:function: Integer; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_PluginLoad:function (filename: PChar; flags: DWORD): HPLUGIN; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_GetConfigPtr:function (option: DWORD): Pointer; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_SetConfigPtr:function (option: DWORD; value: Pointer): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 {$IFDEF MSWINDOWS}
 BASS_Init:function (device: Integer; freq, flags: DWORD; win: HWND; clsid: PGUID): BOOL; stdcall;
 {$ELSE}
 BASS_Init:function (device: Integer; freq, flags: DWORD; win: Pointer; clsid: Pointer): BOOL; cdecl;
 {$ENDIF}
 BASS_Free:function: BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_StreamCreateFile:function (mem: BOOL; f: Pointer; offset, length: QWORD; flags: DWORD): HSTREAM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_StreamCreateURL:function (url: PChar; offset: DWORD; flags: DWORD; proc: DOWNLOADPROC; user: Pointer):HSTREAM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_StreamCreate:function  (freq, chans, flags: DWORD; proc: STREAMPROC; user: Pointer): HSTREAM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_StreamFree:function (handle: HSTREAM): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelPlay:function (handle: DWORD; restart: BOOL): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelSetSync:function (handle: DWORD; type_: DWORD; param: QWORD; proc: SYNCPROC; user: Pointer): HSYNC; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelRemoveSync:function (handle: DWORD; sync: HSYNC): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelPause:function (handle: DWORD): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelStop:function (handle: DWORD): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelGetLength:function (handle, mode: DWORD): QWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelGetPosition:function (handle, mode: DWORD): QWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelSetPosition:function (handle: DWORD; pos: QWORD; mode: DWORD): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelGetLevel:function (handle: DWORD): DWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelGetData:function (handle: DWORD; buffer: Pointer; length: DWORD): DWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
// BASS_ChannelSetAttribute: function (handle, attrib: DWORD; value: Single): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelGetAttribute:function (handle, attrib: DWORD; var value: Single): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelBytes2Seconds:function (handle: DWORD; pos: QWORD): Double; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelSeconds2Bytes:function (handle: DWORD; pos: Double): QWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelFlags:function (handle, flags, mask: DWORD): DWORD; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelGetInfo:function (handle: DWORD; var info: BASS_CHANNELINFO):BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_ChannelGetTags:function (handle: HSTREAM; tags: DWORD): PAnsiChar; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_MusicLoad:function (mem: BOOL; f: Pointer; offset: QWORD; length, flags, freq: DWORD): HMUSIC; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
 BASS_MusicFree:function (handle: HMUSIC): BOOL; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

// BASS_WMA_StreamCreateFile:function (mem:BOOL; fl:pointer; offset,length:QWORD; flags:DWORD): HSTREAM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
// BASS_APE_StreamCreateFile:function (mem: BOOL; f: Pointer; offset, length: QWORD; flags: DWORD): HSTREAM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
// BASS_FLAC_StreamCreateFile:function (mem:BOOL; f:Pointer; offset,length:QWORD; flags:DWORD): HSTREAM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
// BASS_WV_StreamCreateFile:function (mem:BOOL; fl:pointer; offset,length:QWORD; flags:DWORD): HSTREAM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
// BASS_AC3_StreamCreateFile:function (mem:BOOL; f:Pointer; offset,length:QWORD; flags:DWORD): HSTREAM; {$IFDEF MSWINDOWS}stdcall{$ELSE}cdecl{$ENDIF};

implementation

var
 Hnd:{$IFDEF MSWINDOWS}HINST{$ELSE}PtrInt{$ENDIF} = 0;
const
 Libs = 9;
 LibNames:array[0..Libs] of string =
  ({$IFDEF MSWINDOWS}'bass.dll'{$ELSE}'libbass.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'basswma.dll'{$ELSE}'libbasswma.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'bass_ape.dll'{$ELSE}'libbass_ape.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'bassflac.dll'{$ELSE}'libbassflac.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'basswv.dll'{$ELSE}'libbasswv.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'bass_ac3.dll'{$ELSE}'libbass_ac3.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'bass_aac.dll'{$ELSE}'libbass_aac.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'bassalac.dll'{$ELSE}'libbassalac.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'bassdsd.dll'{$ELSE}'libbassdsd.so'{$ENDIF},
   {$IFDEF MSWINDOWS}'bassopus.dll'{$ELSE}'libbassopus.so'{$ENDIF}
   );

resourcestring

 BASSE_OK = 'All is OK';
 BASSE_Mem = 'Memory error';
 BASSE_CantOpenFile = 'Can''t open the file';
 BASSE_CantFindSndDrv = 'Can''t find a free sound driver';
 BASSE_SampleBufLost = 'The sample buffer was lost';
 BASSE_InvalidHnd = 'Invalid handle';
 BASSE_UnsupSmpFormat = 'Unsupported sample format';
 BASSE_InvalidPos = 'Invalid position';
 BASSE_NoInit = 'BASS_Init has not been successfully called';
 BASSE_NoStart = 'BASS_Start has not been successfully called';
 BASSE_Unknown = 'Unknown error';
 BASSE_Already = 'Already initialized/paused/whatever';
 BASSE_CantGetChan = 'Can''t get a free channel';
 BASSE_IllegalType = 'An illegal type was specified';
 BASSE_IllegalParam = 'An illegal parameter was specified';
 BASSE_No3D = 'No 3D support';
 BASSE_NoEAX = 'No EAX support';
 BASSE_IllegalDevice = 'Illegal device number';
 BASSE_NotPlaying = 'Not playing';
 BASSE_IllegalSampleRate = 'Illegal sample rate';
 BASSE_NotFileStream = 'The stream is not a file stream';
 BASSE_NoHardVoices = 'No hardware voices available';
 BASSE_MODNoSeqData = 'The MOD music has no sequence data';
 BASSE_NoInternet = 'No internet connection could be opened';
 BASSE_CantCrateFile = 'Couldn''t create the file';
 BASSE_EffectsNotEnabled = 'Effects are not enabled';
 BASSE_ReqDataNotAvail = 'Requested data is not available';
 BASSE_DecodChan = 'The channel is/isn''t a "decoding channel"';
 BASSE_DirectXVer = 'A sufficient DirectX version is not installed';
 BASSE_ConnectionTimedout = 'Connection timedout';
 BASSE_UnsupFileFormat = 'Unsupported file format';
 BASSE_UnavailSpeaker = 'Unavailable speaker';
 BASSE_Version = 'Invalid BASS version';
 BASSE_Codec = 'Codec is not available/supported';
 BASSE_ChanFileEnd = 'The channel/file has ended';
 BASSE_DeviceBusy = 'The device is busy';

procedure RaiseLastBASSError;
const
 BASSErCodes:array[0..46] of string =
 (BASSE_OK,
  BASSE_Mem,
  BASSE_CantOpenFile,
  BASSE_CantFindSndDrv,
  BASSE_SampleBufLost,
  BASSE_InvalidHnd,
  BASSE_UnsupSmpFormat,
  BASSE_InvalidPos,
  BASSE_NoInit,
  BASSE_NoStart,
  BASSE_Unknown,
  BASSE_Unknown,
  BASSE_Unknown,
  BASSE_Unknown,
  BASSE_Already,
  BASSE_Unknown,
  BASSE_Unknown,
  BASSE_Unknown,
  BASSE_CantGetChan,
  BASSE_IllegalType,
  BASSE_IllegalParam,
  BASSE_No3D,
  BASSE_NoEAX,
  BASSE_IllegalDevice,
  BASSE_NotPlaying,
  BASSE_IllegalSampleRate,
  BASSE_Unknown,
  BASSE_NotFileStream,
  BASSE_Unknown,
  BASSE_NoHardVoices,
  BASSE_Unknown,
  BASSE_MODNoSeqData,
  BASSE_NoInternet,
  BASSE_CantCrateFile,
  BASSE_EffectsNotEnabled,
  BASSE_Unknown,
  BASSE_Unknown,
  BASSE_ReqDataNotAvail,
  BASSE_DecodChan,
  BASSE_DirectXVer,
  BASSE_ConnectionTimedout,
  BASSE_UnsupFileFormat,
  BASSE_UnavailSpeaker,
  BASSE_Version,
  BASSE_Codec,
  BASSE_ChanFileEnd,
  BASSE_DeviceBusy);
var
 ErCode:DWORD;
begin
BASSErCode := BASS_ErrorGetCode();
if BASSErCode > 46 then ErCode := 26 else ErCode := BASSErCode;
BASSErrorString := BASSErCodes[ErCode];
raise EBASSError.Create(BASSErCodes[ErCode]);
end;

function TryGet(const p:pointer):pointer;
begin
Result := p;
if p = nil then
 begin
  BASSErrorString := '';
  BASSErCode := 0;
  RaiseLastOSError;
 end;
end;

procedure CheckVersion;
const
 errs = 'Sorry, BASS version 2.4 required';
begin
if BASS_GetVersion() and $FFFF0000 <> $02040000 then
 begin
  BASSErrorString := errs;
  BASSErCode := 43;
  raise EBASSError.Create(errs);
 end;
end;

procedure LoadBASS;

  function TryGetProcAddress(const prcname:string):pointer;
  begin
   {$IFDEF MSWINDOWS}
   Result := TryGet(GetProcAddress(Hnd,pchar(prcname)));
   {$ELSE}
   Result := TryGet(dlsym(Hnd,pchar(prcname)));
   {$ENDIF}
  end;

var
 ExeDir:string;
 i:integer;

 {$IFDEF dbgmode}
 Tst:HPLUGIN;
 {$ENDIF dbgmode}

begin
ExeDir := IncludeTrailingBackslash(ExtractFileDir(ParamStr(0)));
if Hnd = 0 then
 begin
  {$IFDEF MSWINDOWS}
  Hnd := LoadLibraryW(PWideChar(UTF8Decode(ExeDir+LibNames[0])));
  {$ELSE}
  Hnd := {%H-}PtrInt(dlopen(PChar(ExeDir+LibNames[0]),RTLD_LAZY or RTLD_GLOBAL));
  {$ENDIF}
  if Hnd = 0 then
   begin
    BASSErrorString := LibNames[0]+' 2.4 by Ian Luck required for playing extra file types';
    BASSErCode := 43;
    raise EBASSError.Create(BASSErrorString);
   end;
  try
   pointer(BASS_GetVersion) := TryGetProcAddress('BASS_GetVersion');
   CheckVersion;
   pointer(BASS_ErrorGetCode) := TryGetProcAddress('BASS_ErrorGetCode');
   pointer(BASS_PluginLoad) := TryGetProcAddress('BASS_PluginLoad');
   pointer(BASS_GetConfigPtr) := TryGetProcAddress('BASS_GetConfigPtr');
   pointer(BASS_SetConfigPtr) := TryGetProcAddress('BASS_SetConfigPtr');
   pointer(BASS_Init) := TryGetProcAddress('BASS_Init');
   pointer(BASS_Free) := TryGetProcAddress('BASS_Free');
   pointer(BASS_StreamCreateFile) := TryGetProcAddress('BASS_StreamCreateFile');
   pointer(BASS_StreamCreateURL) := TryGetProcAddress('BASS_StreamCreateURL');
   pointer(BASS_StreamCreate) := TryGetProcAddress('BASS_StreamCreate');
   pointer(BASS_StreamFree) := TryGetProcAddress('BASS_StreamFree');
   pointer(BASS_ChannelPlay) := TryGetProcAddress('BASS_ChannelPlay');
   pointer(BASS_ChannelSetSync) := TryGetProcAddress('BASS_ChannelSetSync');
   pointer(BASS_ChannelRemoveSync) := TryGetProcAddress('BASS_ChannelRemoveSync');
   pointer(BASS_ChannelPause) := TryGetProcAddress('BASS_ChannelPause');
   pointer(BASS_ChannelStop) := TryGetProcAddress('BASS_ChannelStop');
   pointer(BASS_ChannelGetLength) := TryGetProcAddress('BASS_ChannelGetLength');
   pointer(BASS_ChannelGetPosition) := TryGetProcAddress('BASS_ChannelGetPosition');
   pointer(BASS_ChannelSetPosition) := TryGetProcAddress('BASS_ChannelSetPosition');
   pointer(BASS_ChannelGetLevel) := TryGetProcAddress('BASS_ChannelGetLevel');
   pointer(BASS_ChannelGetData) := TryGetProcAddress('BASS_ChannelGetData');
//   pointer(BASS_ChannelSetAttribute) := TryGetProcAddress('BASS_ChannelSetAttribute');
   pointer(BASS_ChannelGetAttribute) := TryGetProcAddress('BASS_ChannelGetAttribute');
   pointer(BASS_ChannelBytes2Seconds) := TryGetProcAddress('BASS_ChannelBytes2Seconds');
   pointer(BASS_ChannelSeconds2Bytes) := TryGetProcAddress('BASS_ChannelSeconds2Bytes');
   pointer(BASS_ChannelFlags) := TryGetProcAddress('BASS_ChannelFlags');
   pointer(BASS_ChannelGetInfo) := TryGetProcAddress('BASS_ChannelGetInfo');
   pointer(BASS_ChannelGetTags) := TryGetProcAddress('BASS_ChannelGetTags');
   pointer(BASS_MusicLoad) := TryGetProcAddress('BASS_MusicLoad');
   pointer(BASS_MusicFree) := TryGetProcAddress('BASS_MusicFree');
  except
   UnloadBASS;
   raise;
  end;
 end;
for i := 1 to Libs do
 {$IFDEF dbgmode}
 begin tst :=
 {$endif dbgmode}
 BASS_PluginLoad(PChar({$IFDEF MSWINDOWS}UTF8Decode({$ENDIF}ExeDir+LibNames[i]){$IFDEF MSWINDOWS}){$ENDIF},
   {$IFDEF MSWINDOWS}BASS_UNICODE{$ELSE}0{$ENDIF});
 {$IFDEF dbgmode}
 if tst = 0 then
  try
   RaiseLastBASSError;
  except
   if BASSErCode <> 14{Already} then
    ShowMessage('BASSPlugInLoad Error ' + BASSErrorString + ' ('+ExeDir+LibNames[i]+')');
  end;
 end;
 {$ENDIF dbgmode}
end;

procedure UnloadBASS;
begin
 if Hnd <> 0 then
   begin
    {$IFDEF MSWINDOWS}
    FreeLibrary(Hnd);
    {$ELSE}
    dlClose(Hnd);
    {$ENDIF}
    Hnd := 0;
   end;
end;

end.
