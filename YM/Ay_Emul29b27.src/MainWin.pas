{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit MainWin;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType,
  {$IFDEF Windows}
   Windows, MMSystem,
  {$ELSE Windows}
   LMessages,
  {$ENDIF Windows}
  digsound, digsoundcode, mixerctl,
  SysUtils, LazFileUtils, Classes, Graphics, Controls, Forms, Dialogs, About,
  LH5, UniReader, AY, WinVersion, Languages, lazutf8, ExtCtrls, LConvEncoding;

const
//User defined windows messages
 WM_PLAYNEXTITEM   = WM_USER + 1;
 WM_PLAYERROR      = WM_USER + 2;
 WM_FINALIZEWO     = WM_USER + 5;
 WM_HIDEMINIMIZE   = WM_USER + 6;
 WM_GETTIMELENGTH  = WM_USER + 8;
 WM_BASSMETADATA   = WM_USER + 9;
 WM_VOLUMECHANGED  = WM_USER + 10;

//Metrics of some controls
 //Main window
 MWWidth = 358;
 MWHeight = 123;

 //Spectrum analizer
 spa_num = 91 - 26 - 2;
 spa_width = spa_num + 2; spa_height = 20;
 spa_x = 26; spa_y = 34;

 //Amplitude analizer
 amp_width = 17; amp_height = 15;
 amp_x = 50; amp_y = 18;

 max_width2 = spa_width; max_height2 = spa_height;

 //Scrolling title
 scr_lineheight = 24;
 scr_x = 108;scr_y = 48;
 scr_width = 197; scr_height = scr_lineheight;

 //Time label
 time_x = 24; time_y = 65;
 time_width = 93-24;time_height = 20;

 max_height = scr_height;

 //Offsets of background bitmaps for controls
 spa_src = 0;
 amp_src = spa_width;
 time_src = spa_width + amp_width;
 scr_src = spa_width + amp_width + time_width;
 max_src = scr_src + scr_width;

 //Skin 2.0 identificator
 SkinId:string = 'Ay_Emul 2.0 Skin File'#13#10#26;
 SkinIdLen = 24;

 VTPath:string = 'VT.exe';

 Zero:integer = 0; //:-)

type

 EMultiMediaError = class(Exception);

 //Spectrum analizer values
 TSpa = array[0..spa_num - 1] of integer;
 PSpa = ^TSpa;

 //Own sens object
 PSensZone = ^TSensZone;
 TSensZone = class(TObject)
 constructor Create(ps:PSensZone;x,y,w,h:integer;pr:TNotifyEvent);
 function Touche(x,y:integer):boolean;
 public
 Next:PSensZone;
 zx,zy,zw,zh:integer;
 Clicked:boolean;
 Action:TNotifyEvent;
 end;

 //Own button object
 PButtZone = ^TButtZone;
 TButtZone = class(TObject)
 constructor Create(ps:PButtZone;x,y,w,h:integer;rh:HRGN;Bmp:TBitmap;x1,y1,x2,y2:integer;pr:TNotifyEvent);
 procedure Free;
 function Touche(x,y:integer):boolean;
 procedure Push;
 procedure UnPush;
 procedure Switch_On;
 procedure Switch_Off;
 procedure Redraw(OnCanvas:boolean);
 public
 Next:PButtZone;
 zx,zy,zw,zh:integer;
 RgnHandle:HRGN;
 Clicked:integer;
 Is_On,Is_Pushed:boolean;
 Bmp1,Bmp2:TBitmap;
 Action:TNotifyEvent;
 end;

 //Own led object
 PLedZone = ^TLedZone;
 TLedZone = class(TObject)
 constructor Create(ps:PLedZone;x,y,w,h:integer;Bmp:TBitmap;x1,y1,x2,y2:integer);
 procedure Free;
 procedure Redraw(OnCanvas:boolean);
 public
 Next:PLedZone;
 zx,zy,zw,zh:integer;
 State:boolean;
 Bmp1,Bmp2:TBitmap;
 end;

 //Own mouse moving object
 PMoveZone = ^TMoveZone;
 TMoveZone = class(TObject)
 constructor Create(ps:PMoveZone;x,y,w,h,y1,h1:integer;rh:HRGN;pr:TNotifyEvent);
 procedure Free;
 function Touche(x,y:integer):boolean;
 function ToucheBut(x,y:integer):boolean;
 procedure AddBitmaps(Bmp:TBitmap;x1,y1,bw,bh:integer;m:boolean);
 procedure Redraw(OnCanvas:boolean);
 procedure HideBmp;
 public
 Next:PMoveZone;
 zx,zy,zw,zh,zy1,zh1,Delt,OldX,OldY,PosX,PosY,bm1h,bm1w:integer;
 RgnHandle:HRGN;
 Clicked,State,Bmps:boolean;
 Bmp1,Bmp2:TBitmap;
 Action:TNotifyEvent;
 end;

 FIDO_Status = (FIDO_Nothing,FIDO_Playing,FIDO_Exit);

//Main window form

  { TFrmMain }

  TFrmMain = class(TForm)
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    TrayIcon1: TTrayIcon;
    procedure ButOpenClick(Sender: TObject);
    procedure DoMovingWindow(Sender: TObject);
    procedure DoMovingVol(Sender: TObject);
    procedure DoMovingProgr(Sender: TObject);
    procedure DoMovingScroll(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormPaint(Sender: TObject);
    {$IFNDEF Windows}
    procedure DoSetRgn(Sender: TObject);
    {$ENDIF Windows}
    procedure FormShow(Sender: TObject);
    procedure PlayClick(Sender: TObject);
    procedure SetDefault;
    procedure ButPauseClick(Sender: TObject);
    procedure ButStopClick(Sender: TObject);
    procedure CommandLineInterpreter(CL:string;Start:boolean);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TrayIcon1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WMPLAYNEXTITEM(var Msg: TMsg);message WM_PLAYNEXTITEM;
    procedure WMBASSMETADATA(var Msg: TMsg);message WM_BASSMETADATA;
    procedure WMPLAYERROR(var Msg: TMsg);message WM_PLAYERROR;
    procedure IPCMessage(Sender: TObject);
    procedure WMFINALIZEWO(var Msg: TMsg);message WM_FINALIZEWO;
    procedure HideMinimize(var Msg: TMsg);message WM_HIDEMINIMIZE;
    procedure WMVOLUMECHANGED(var Msg: TMsg);message WM_VOLUMECHANGED;
    procedure DoMinimize;
    procedure DoRestore;
    procedure DoVisualisation;
    procedure MessageSkipper;
    procedure NewMessageSkipper;
//    procedure SwapLan;
    procedure Set_Chip_Frq(Fr:integer);
    procedure Set_Player_Frq(Fr:integer);
    procedure ButMixerClick(Sender: TObject);
    procedure ButMinClick(Sender: TObject);
    procedure ButCloseClick(Sender: TObject);
    procedure ButAboutClick(Sender: TObject);
    procedure ButAmpClick(Sender: TObject);
    procedure ButTimeClick(Sender: TObject);
    procedure ButSpaClick(Sender: TObject);
    procedure ShowAllParams;
    procedure RestoreAllParams;
    procedure ButListClick(Sender: TObject);
    procedure ButNextClick(Sender: TObject);
    procedure ButPrevClick(Sender: TObject);
    procedure CalcModeCoefs(Mode:Integer;ChType:ChTypes;TS,DMA:boolean;
               out Index_AL,Index_AR,Index_BL,Index_BR,Index_CL,Index_CR,
               BeeperMax,Atari_DMAMax:byte);
    procedure Set_Mode(Mode:Integer);
    procedure Set_Mode_Manual(AL,AR,BL,BR,CL,CR:byte);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButToolsClick(Sender: TObject);
    procedure ButLoopClick(Sender: TObject);
    procedure Set_Z80_Frq(NewF:integer);
    procedure Set_MC68K_Frq(NewF:integer);
    procedure Set_N_Tact(NewF:integer);
    procedure CommandLineAndRegCheck;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AppRestore(Sender: TObject);
    procedure AppMinimize(Sender: TObject);
    procedure AppModalBegin(Sender: TObject);
    procedure AppModalEnd(Sender: TObject);
    procedure AppEndSession(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RemoveTrayIcon;
    procedure AddTrayIcon;
    function LoadSkin(FName:string;First:boolean):boolean;
    procedure SetMainBmp(p:pointer;size:integer);
    procedure BmpFree;
    procedure CopyBmpSources;
    procedure Set_MFP_Frq(Md,Fr:integer);
    procedure ShowApp(Tray:boolean);
    procedure FIDO_SaveStatus(Status:FIDO_Status);
    procedure JumpToTime;
    procedure CallHelp;
    procedure VolUp;
    procedure VolDown;
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure SaveParams;
    procedure SetVisTimerPeriod(VTP:integer);
    procedure Set_Sample_Rate2(SR:integer);
    procedure Set_Sample_Bit2(SB:integer);
    procedure Set_Stereo2(St:integer);
    procedure SetBuffers(len,num:integer);
    procedure Set_WODevice2(WOD:integer;NM:string);
    {$IFDEF Windows}
    procedure Set_MIDIDevice2(MD:integer;NM:string);
    {$ENDIF Windows}
    procedure Set_BufLen_ms2(BL:integer);
    procedure Set_NumberOfBuffers2(NB:integer);
    procedure Set_Chip2(Ch:ChTypes);
    procedure Set_Z80_Frq2(NewF:integer);
    procedure Set_MC68K_Frq2(NewF: integer);
    procedure Set_Chip_Frq2(Fr:integer);
    procedure Set_Player_Frq2(Fr:integer);
    procedure Set_IntOffset2(InO:integer);
    procedure Set_N_Tact2(NT:integer);
    procedure Set_N_TactS(t:string);
    procedure Set_Language2(const aLang:string);
    function Get_Language:string;
    procedure Set_Loop2(Lp:boolean);
    procedure Set_TrayMode2(TM:integer);
    procedure Set_MFP_Frq2(Md,Fr:integer);
    procedure SetAutoSaveDefDir2(ASD:boolean);
    procedure SetAutoSaveWindowsPos2(ASW:boolean);
    procedure SetAutoSaveVolumePos2(ASV:boolean);
    procedure SetChan2(u,i:integer);
    procedure SetFilter(FQ:integer);
    procedure SetFilter2(FQ:integer);
    procedure CalcFiltKoefs;
    procedure SaveAllParams;
    procedure DoCloseActions;
    procedure SelectTrayIcon(n:integer);
    procedure SelectAppIcon(n:integer);
    {$IFDEF Windows}
    procedure SetPriority2(NP:DWORD);
    {$ENDIF Windows}
    procedure VisTimerEvent(Sender: TObject);
    procedure Ay_Emul_ShowExceptionA(Sender : TObject; E : Exception);
  private
    { Private declarations }
  public
    { Public declarations }
    SkinFileName,SkinAuthor,SkinComment:string;
    DefaultDirectory,SkinDirectory:string;
    LastTimeComLine:DWORD;
  end;

function DivMul(q1,q2,q3:int64):dword;

procedure PlayCurrent;
procedure StopAndFreeAll;
procedure StopPlaying;
procedure RestoreControls;

procedure AYVisualisation(smp:DWORD);

procedure RedrawVisChannels(ca,cb,cc,mh:integer);
procedure RedrawVisSpectrum(CP:PVisPoint;MaxVal:integer);

procedure ShowProgress(a1:integer);

procedure Set_Sample_Rate(SR:integer);
procedure Set_Sample_Bit(SB:integer);
procedure Set_Stereo(St:integer);

procedure Calculate_Level_Tables2;

procedure Rewind(newpos,maxpos:integer);

procedure SetScrollString(const scrstr:string);
procedure ReprepareScroll;

procedure GetSysVolume;
procedure SetSysVolume;
procedure RedrawVolume;

procedure Ay_Emul_ShowException (Msg : ShortString);

procedure SetCommandLine(clstr:string);

procedure AdjustFormOnDesktop(Frm:TForm);

var
  FrmMain: TFrmMain;

  MFPTimerFrq,MFPTimerMode:integer;

  VisTimer:TTimer;
  VisTimerPeriod:integer = 30;

  Spa_points:array[0..spa_num] of integer;
  Spa_piks,Spa_prev:TSpa;
  PSpa_Piks,PSpa_prev:PSpa;

  Scr_Left:boolean = False;
  ScrFlg:boolean = True;
  Scr_Pause:integer = 1;
  Scroll_Distination:integer = -1;
  Item_Displayed:integer = -1;
  HorScrl_Offset:integer = 0;
  Scroll_Offset:integer = scr_lineheight;
  ClearTimeInd:boolean;
  TimeMode:integer = 0;
  CurrTime_Rasch:integer;
  BaseSample:DWORD;

  BMP_Sources,BMP_Time,BMP_Vis:TBitmap;
  BMP_VScroll,BMP_Scroll:TBitmap;
  
  BMP_DBuffer:TBitmap;

  VProgrPos:integer;
  ProgrMax,ProgrPos:longword;
  ProgrWidth:word;

  OUTZXAYConv_TotalTime:integer;

  Lang:string = 'en';
  PSG_Skip:word;
  May_Quit,May_Quit2:boolean;
  Do_Scroll:boolean = True;
  Time_ms:integer = 0;
  TimeShown:integer = -MaxInt;

  ButPlay,ButNext,ButPrev,ButOpen,ButStop,ButPause,ButAbout,
  ButLoop,ButMixer,ButTools,ButList,ButMinimize,ButClose:TButtZone;
  SensSpa,SensAmp,SensTime:TSensZone;
  MoveWin,MoveVol,MoveProgr,MoveScr:TMoveZone;
  Led_AY,Led_YM,Led_Stereo:TLedZone;
  MyFormRgn,RgnClose,RgnMin,RgnMixer,RgnTools,RgnPList,
  RgnLoop,RgnBack,RgnPlay,RgnNext,RgnStop,RgnPause,RgnOpen,
  RgnVol,RgnProgr:HRGN;

  IndicatorChecked:boolean = True;
  SpectrumChecked:boolean = True;
  AutoSaveDefDir:boolean = True;

  //Tray Icon Data
  TrayMode:integer = 0;
  TrayIconNumber:integer = 11;
  TrayIconClicked:boolean = False;

  AddFolderRecurseDirs:boolean = True;
  AddFolderDoDetect:boolean = False;
  AddFolderPlaylists:integer = 0; //0 - добавлять, 1 - пропускать, 2 - добавлять только плейлисты

  AppIsModal:boolean = False;

  MenuIconNumber:integer = 0;
  AppIconNumber:integer = 0;
  MusIconNumber:integer = 10;
  SkinIconNumber:integer = 3;
  ListIconNumber:integer = 2;
  BASSIconNumber:integer = 4;

  FIDO_Descriptor_Enabled:boolean = False;
  FIDO_Descriptor_Enc:string = {$IFDEF Windows}'Ansi'{$ELSE Windows}'UTF-8'{$ENDIF Windows};
  FIDO_Descriptor_KillOnNothing:boolean = False;
  FIDO_Descriptor_KillOnExit:boolean = True;
  FIDO_Descriptor_Prefix:string = '... Ay_Emul: ';
  FIDO_Descriptor_Suffix:string = '';
  FIDO_Descriptor_Nothing:string = Mes_NoSongPlaying;
  FIDO_Descriptor_Filename:string;
  FIDO_Descriptor_String:string = '';

  ToolsX:integer = MaxInt;
  ToolsY:integer;
  AutoSaveWindowsPos:boolean = True;
  AutoSaveVolumePos:boolean = False;
  Uninstall:boolean = False;

const
  ButtZoneRoot:PButtZone = nil;
  SensZoneRoot:PSensZone = nil;
  MoveZoneRoot:PMoveZone = nil;
  LedZoneRoot:PLedZone = nil;
  CLFast = 800;
  InitialScan:boolean = False;

var
  AfterScan:array of string;

  IsPlaying:boolean = False;
  Paused:boolean;
  NOfTicks:DWORD;
  {$IFNDEF Windows}
  Timer1:TTimer; //для обхода глюков GTK
  {$ENDIF Windows}

 
implementation

uses Mixer, PlayList, Tools, Z80, JmpTime, Players, Options,
     basslight, basscode, basstags
     {$IFDEF Windows}
     , ProgBox, CDviaMCI, Midi
     {$ENDIF Windows}
     , Convs, FileTypes, settings, atari, LCLTranslator;

{$R *.lfm}

var
  CloseActionsDone:boolean = False;

  sw:integer = scr_width;
  sj,sw1,sj1,sw2,sj2:integer;
  ss,ss1,ss2:string;

  {$IFDEF Windows}
  PrevWndProc: WNDPROC;
  PrevAWndProc: WNDPROC;
  {$ENDIF Windows}

function DivMul(q1,q2,q3:int64):dword;
begin
Result := q1 * q2 div q3;
end;

procedure GetStringWnJ(const s:string; var w,j:integer);
begin
w := BMP_VScroll.Canvas.TextWidth(s);
j := 0;
if scr_width > w then
 j := (scr_width - w) div 2;
end;

procedure RedrawScroll;
begin
BMP_Scroll.Canvas.CopyMode:=cmSrcCopy;
BMP_Scroll.Canvas.CopyRect(Rect(0,0,scr_width,scr_height),BMP_Sources.Canvas,Bounds(scr_src,0,scr_width,scr_height));
BMP_VScroll.Canvas.TextOut(-HorScrl_Offset + sj,scr_height,ss);
BMP_Scroll.Canvas.CopyMode:=cmSrcAnd;
BMP_Scroll.Canvas.CopyRect(Rect(0,0,scr_width,scr_height),BMP_VScroll.Canvas,Bounds(0,scr_height,scr_width,scr_height));
FrmMain.Canvas.CopyMode:=cmSrcCopy;
FrmMain.Canvas.CopyRect(Bounds(scr_x,scr_y,scr_width,scr_height),BMP_Scroll.Canvas,Rect(0,0,scr_width,scr_height));
end;

procedure RedrawTime;
var
 CurTimeJ,CurTimeH,TmS:integer;
 CurrTimeStr,sig:string;
begin
if TimeMode = 1 then sig := '-' else sig := '';
TmS := abs(TimeShown);
CurrTimeStr := sig + TimeSToStr(TmS);
if TmS < 60*60 then
 BMP_Time.Canvas.Font.Height:=-20
else
 BMP_Time.Canvas.Font.Height:=-16;
CurTimeJ := time_width - BMP_Time.Canvas.TextWidth(CurrTimeStr);
if CurTimeJ > 0 then CurTimeJ := CurTimeJ div 2;
CurTimeH := (time_height - abs(BMP_Time.Canvas.Font.Height)) div 2;
if CurTimeH < 0 then CurTimeH := 0;
BMP_Time.Canvas.CopyMode:=cmSrcCopy;
BMP_Time.Canvas.CopyRect(Rect(0,0,time_width,time_height),BMP_Sources.Canvas,Bounds(time_src,0,time_width,time_height));
BMP_Time.Canvas.TextOut(CurTimeJ,CurTimeH,CurrTimeStr);
FrmMain.Canvas.CopyMode:=cmSrcCopy;
FrmMain.Canvas.CopyRect(Bounds(time_x,time_y,time_width,time_height),BMP_Time.Canvas,Rect(0,0,time_width,time_height));
end;

procedure CalculateSpectrumPoints;
var
 i:integer;
begin
Spa_points[0] := $FFF;
for i := 1 to spa_num do
 Spa_points[i] := round($FFF * exp(-ln(16 * 22050 * $FFF/AY_Freq)*i/spa_num));
end;

procedure TFrmMain.DoVisualisation;
var
 Y_Stp:integer;
 Points_To_Scroll:integer;
 Temp,Temp1:integer;
begin
 digsoundVisualisation;
 BASSVisualisation;
{$IFDEF Windows}
 CDVisualisation;
 MIDIVisualisation;
{$ENDIF Windows}
 if ClearTimeInd then
  begin
   BMP_Time.Canvas.CopyMode:=cmSrcCopy;
   BMP_Time.Canvas.CopyRect(Rect(0,0,time_width,time_height),BMP_Sources.Canvas,Bounds(time_src,0,time_width,time_height));
   Canvas.CopyMode:=cmSrcCopy;
   Canvas.CopyRect(Bounds(time_x,time_y,time_width,time_height),BMP_Time.Canvas,Rect(0,0,time_width,time_height));
   TimeShown := -MaxInt;
   ClearTimeInd := False;
  end;
 if Time_ms <> 0 then
  begin
   case TimeMode of
   0: Temp := round(CurrTime_Rasch / 1000);
   1:
    begin
     Temp := Time_ms - CurrTime_Rasch;
     if Temp < 0 then Temp := 0;
     Temp := -round(Temp / 1000);
    end;
   else
    begin
     Temp := round(Time_ms / 1000);
     if Temp < 0 then Temp := 0;
    end;
   end;
   if Temp <> TimeShown then
    begin
     TimeShown := Temp;
     RedrawTime;
    end;
  end;
 Temp := Item_Displayed;
 Temp1 := Scroll_Distination;
 if Abs(Temp1 - Temp) > 16 then
  begin
   if Temp1 > Temp then
    Temp := Temp1 - 16
   else
    Temp := Temp1 + 16;
   Item_Displayed := Temp;
   ss := GetPlayListString(PlaylistItems[Temp]);
   GetStringWnJ(ss,sw,sj);
   BMP_VScroll.Canvas.TextOut(sj,scr_lineheight,ss);
  end;
 Points_To_Scroll := scr_lineheight*(Temp1 - Temp + 1) - Scroll_Offset;
 if Points_To_Scroll <> 0 then
  begin
   ScrFlg := False;
   Y_Stp := (Abs(Points_To_Scroll) - 1) div scr_lineheight + 1;
   if Y_Stp >= scr_lineheight then Y_Stp := scr_lineheight - 1;
   if Points_To_Scroll > 0 then
    begin
     if (Scroll_Offset >= scr_lineheight) then
      begin
       BMP_VScroll.Canvas.FillRect(0,scr_lineheight*2,scr_width,scr_lineheight*3);
       if Temp + 1 < Length(PlaylistItems) then
        begin
         ss2 := GetPlayListString(PlaylistItems[Temp + 1]);
         GetStringWnJ(ss2,sw2,sj2);
         BMP_VScroll.Canvas.TextOut(sj2,scr_lineheight*2,ss2);
        end
      end;
     Inc(Scroll_Offset,Y_Stp);
     if Scroll_Offset >= 2*scr_lineheight then
      begin
       HorScrl_Offset := 0;
       ss := ss2; sw := sw2; sj := sj2;
       BMP_VScroll.Canvas.CopyMode:=cmSrcCopy;
       BMP_VScroll.Canvas.CopyRect(Rect(0,0,scr_width,scr_lineheight*2),BMP_VScroll.Canvas,Bounds(0,scr_lineheight,scr_width,scr_lineheight*2));
       Dec(Scroll_Offset,scr_lineheight);
       Inc(Temp);
       Item_Displayed := Temp;
      end;
    end
   else
    begin
     if (Scroll_Offset <= scr_lineheight) then
      begin
       BMP_VScroll.Canvas.FillRect(0,0,scr_width,scr_lineheight);
       if Temp - 1 >= 0 then
        begin
         ss1 := GetPlayListString(PlaylistItems[Temp - 1]);
         GetStringWnJ(ss1,sw1,sj1);
         BMP_VScroll.Canvas.TextOut(sj1,0,ss1);
        end
      end;
     Dec(Scroll_Offset,Y_Stp);
     if Scroll_Offset <= 0 then
      begin
       HorScrl_Offset := 0;
       ss := ss1; sw := sw1; sj := sj1;
       BMP_VScroll.Canvas.CopyMode:=cmSrcCopy;
       BMP_VScroll.Canvas.CopyRect(Bounds(0,scr_lineheight,scr_width,scr_lineheight*2),BMP_VScroll.Canvas,Rect(0,0,scr_width,scr_lineheight*2));
       Inc(Scroll_Offset,scr_lineheight);
       Dec(Temp);
       Item_Displayed := Temp;
      end;
    end;
   BMP_Scroll.Canvas.CopyMode:=cmSrcCopy;
   BMP_Scroll.Canvas.CopyRect(Rect(0,0,scr_width,scr_height),BMP_Sources.Canvas,Bounds(scr_src,0,scr_width,scr_height));
   BMP_Scroll.Canvas.CopyMode:=cmSrcAnd;
   BMP_Scroll.Canvas.CopyRect(Rect(0,0,scr_width,scr_height),BMP_VScroll.Canvas,Bounds(0,Scroll_Offset,scr_width,scr_height));
   Canvas.CopyMode:=cmSrcCopy;
   Canvas.CopyRect(Bounds(scr_x,scr_y,scr_width,scr_height),BMP_Scroll.Canvas,Rect(0,0,scr_width,scr_height));
  end;
 if Do_Scroll and ScrFlg and (sw > scr_width) and
    not MoveScr.Clicked then
  begin
   Dec(Scr_Pause);
   if Scr_Pause = 0 then
    begin
     Inc(Scr_Pause);
     if Scr_Left then
      begin
       Dec(HorScrl_Offset);
       if HorScrl_Offset < 0 then
        begin
         Scr_Left := False;
         HorScrl_Offset := 0;
         Scr_Pause := 50;
        end
       else
        RedrawScroll;
      end
     else
      begin
       Inc(HorScrl_Offset);
       if HorScrl_Offset > sw - scr_width then
        begin
         Scr_Left := True;
         HorScrl_Offset := sw - scr_width;
         Scr_Pause := 50;
        end
       else
        RedrawScroll;
      end;
    end;
  end
 else
  ScrFlg := True;
end;

procedure TFrmMain.VisTimerEvent(Sender: TObject);
begin
if WindowState <> wsMinimized then DoVisualisation;
end;

procedure RedrawVisChannels(ca,cb,cc,mh:integer);
begin
if IndicatorChecked then
 begin
  BMP_Vis.Canvas.CopyMode:=cmSrcCopy;
  BMP_Vis.Canvas.CopyRect(Rect(0,0,amp_width,amp_height),BMP_Sources.Canvas,Bounds(amp_src,0,amp_width,amp_height));
  if ca > 0 then
   begin
    BMP_Vis.Canvas.MoveTo(1,amp_height);
    BMP_Vis.Canvas.LineTo(1,amp_height + 1 - ca * amp_height div mh);
   end;
  if cb > 0 then
   begin
    BMP_Vis.Canvas.MoveTo(8,amp_height);
    BMP_Vis.Canvas.LineTo(8,amp_height + 1 - cb * amp_height div mh);
   end;
  if cc > 0 then
   begin
    BMP_Vis.Canvas.MoveTo(15,amp_height);
    BMP_Vis.Canvas.LineTo(15,amp_height + 1 - cc * amp_height div mh);
   end;
  FrmMain.Canvas.CopyMode:=cmSrcCopy;
  FrmMain.Canvas.CopyRect(Bounds(amp_x,amp_y,amp_width,amp_height),BMP_Vis.Canvas,Rect(0,0,amp_width,amp_height));
 end;
end;

procedure RedrawVisSpectrum(CP:PVisPoint;MaxVal:integer);
var
 p:pointer;
 i,j,n:integer;
begin
if SpectrumChecked then
 begin
  p := PSpa_prev;
  PSpa_prev := PSpa_piks;
  PSpa_piks := p;
  if CP <> nil then
   begin
    FillChar(PSpa_piks^,SizeOf(TSpa),0);
    for n := 0 to 1 do
     begin
      for i := 0 to spa_num - 1 do
       begin
        if (CP^.R[n].TnA > Spa_Points[i + 1]) and (CP^.R[n].TnA <= Spa_Points[i]) then
         if PSpa_piks^[i] < CP^.R[n].AmpA then
          PSpa_piks^[i] := CP^.R[n].AmpA;
        if (CP^.R[n].TnB > Spa_Points[i + 1]) and (CP^.R[n].TnB <= Spa_Points[i]) then
         if PSpa_piks^[i] < CP^.R[n].AmpB then
          PSpa_piks^[i] := CP^.R[n].AmpB;
        if (CP^.R[n].TnC > Spa_Points[i + 1]) and (CP^.R[n].TnC <= Spa_Points[i]) then
         if PSpa_piks^[i] < CP^.R[n].AmpC then
          PSpa_piks^[i] := CP^.R[n].AmpC;
       end;
      if not TSMode then break;
     end;
   end;
  BMP_Vis.Canvas.CopyMode:=cmSrcCopy;
  BMP_Vis.Canvas.CopyRect(Rect(0,0,spa_width,spa_height),BMP_Sources.Canvas,Bounds(spa_src,0,spa_width,spa_height));
  for i := 0 to spa_num - 1 do
   begin
    if PSpa_Piks^[i] > 0 then
     begin
      BMP_Vis.Canvas.MoveTo(i + 1,spa_height);
      BMP_Vis.Canvas.LineTo(i + 1,(MaxVal - PSpa_Piks^[i])*spa_height div MaxVal);
     end;
    if PSpa_Prev^[i] > PSpa_Piks^[i] then
     begin
      PSpa_Piks^[i] := PSpa_Prev^[i];
      if PSpa_Piks^[i] > 0 then
       begin
        j := (MaxVal - PSpa_Piks^[i])*spa_height div MaxVal;
        BMP_Vis.Canvas.Pixels[i,j]:=$0a0a0a;
        BMP_Vis.Canvas.Pixels[i+1,j]:=$0a0a0a;
        BMP_Vis.Canvas.Pixels[i+2,j]:=$0a0a0a;
       end;
      Dec(PSpa_Piks^[i],(MaxVal + 1) div 16);
     end
   end;
  FrmMain.Canvas.CopyMode:=cmSrcCopy;
  FrmMain.Canvas.CopyRect(Bounds(spa_x,spa_y,spa_width,spa_height),BMP_Vis.Canvas,Rect(0,0,spa_width,spa_height));
 end;
end;

procedure ShowProgress(a1:integer);
var
 x:word;
begin
if (ProgrMax = 0) or MoveProgr.Clicked then exit;
if ProgrMax <> longword(-1) then
 ProgrPos := a1
else
 ProgrPos := 0;
if ProgrMax < ProgrPos then ProgrPos := ProgrMax;
x := DivMul(ProgrWidth,ProgrPos,ProgrMax);
if MoveProgr.PosX <> x then
 begin
  MoveProgr.HideBmp;
  OffsetRgn(MoveProgr.RgnHandle,x - MoveProgr.PosX,0);
  MoveProgr.PosX := x;
  MoveProgr.Redraw(False);
 end;
end;

procedure TFrmMain.SetDefault;
var
 IsPl:boolean;
begin
IsPl := digsoundthread_active;
PreAmp := PreAmpDef;
BeeperMax := BeeperMaxDef;
Atari_DMAMax := Atari_DMAMaxDef;
Set_Z80_Frq(FrqZ80Def);
Set_Player_Frq(Interrupt_FreqDef);
if not IsPl then Set_Sample_Rate(SampleRateDef);
Atari_SetDefault;
Set_Chip_Frq(AY_FreqDef);
Set_MFP_Frq(MFPTimerModeDef,MFPTimerFrqDef);
IntOffset := IntOffsetDef;
Set_N_Tact(MaxTStatesDef);
if not IsPl then
 begin
  Set_Sample_Bit(SampleBitDef);
  Set_Stereo(NumOfChanDef);
  SetBuffers(BufLen_msDef,NumberOfBuffersDef);
  digsoundDevice := digsoundDeviceDef;
 end;
Set_Mode_Manual(Index_ALDef,Index_ARDef,Index_BLDef,Index_BRDef,
                Index_CLDef,Index_CRDef);
ChType := YM_Chip;
SetFilter(1);
BASSFFTType := BASS_DATA_FFT8192;
BASSFFTNoWin := 0;//BASS_DATA_FFT_NOWINDOW;
BASSFFTRemDC := BASS_DATA_FFT_REMOVEDC;
BASSAmpMin := 0.003;
BASSNetAgent := '';
BASSNetUseProxy := True;
BASSNetProxy := '';
Calculate_Level_Tables2;
RedrawPlaylist(ShownFrom,False);
CalculateTotalTime(False);
end;

procedure TFrmMain.ButOpenClick(Sender: TObject);
begin
ButOpen.UnPush;
if GetKeyState(VK_SHIFT) and 128 <> 0 then
 FrmPLst.Add_Directory_Dialog(False)
{$IFDEF Windows}
else if GetKeyState(VK_CONTROL) and 128 <> 0 then
 FrmPLst.Add_CD_Dialog(False)
{$ENDIF Windows}
else
 FrmPLst.Add_Item_Dialog(False);
end;

procedure TFrmMain.PlayClick(Sender: TObject);
begin
if IsPlaying then exit;
if not FileAvailable then
 begin
  ButPlay.UnPush;
  exit;
 end;
PlayCurrent;
end;

procedure TFrmMain.ButPauseClick(Sender: TObject);
begin
if not IsPlaying then
 begin
  ButPause.UnPush;
  exit;
 end;
if IsStreamOrModuleFileType(CurFileType) then
// {$IFDEF UseBassForEmu}or MinAYChipFile..MaxAYChipFile{$ENDIF UseBassForEmu}
 begin
  Paused := True;
  SwitchPause;
  Paused := BASSPaused;
 end
{$IFDEF Windows}
else if IsCDFileType(CurFileType) then
 begin
  CDSwitchPause(CurCDNum,Handle);
  Paused := CDPlayingPaused;
 end
else if IsMIDIFileType(CurFileType) then
 begin
  MIDIParams^.paused := not MIDIParams^.paused;
  Paused := MIDIParams^.paused;
 end
{$ENDIF Windows}
else
 digsound_pauseswitch;
if not Paused then
 begin
  FIDO_SaveStatus(FIDO_Playing);
  ButPause.Switch_Off;
 end
else
 begin
  FIDO_SaveStatus(FIDO_Nothing);
  ButPause.Switch_On;
 end;
end;

procedure TFrmMain.ButStopClick(Sender: TObject);
begin
try
 StopAndFreeAll;
finally
 ButStop.UnPush;
end;
end;

procedure RestoreControls;
begin
 FrmMain.FIDO_SaveStatus(FIDO_Nothing);
 ButPlay.Switch_Off;

 FrmMixer.GroupBox3.Enabled := True;

 FrmMixer.GroupBox4.Enabled := True;
 FrmMixer.Buff.Enabled := True;
 FrmMixer.GroupBox10.Enabled := True;
 FrmMixer.GroupBox13.Enabled := True;
 FrmMixer.RadioButton13.Enabled := True;
 FrmMixer.RadioButton14.Enabled := True;

 ButStop.UnPush;
 ButPause.Switch_Off;
 FrmMixer.Edit12.Text := ''; FrmMixer.Edit13.Text := ''; FrmMixer.Edit14.Text := '';
 FrmMixer.Edit15.Text := ''; FrmMixer.Edit16.Text := ''; FrmMixer.Edit17.Text := '';
 FrmMixer.Edit18.Text := ''; FrmMixer.Edit23.Text := ''; FrmMixer.Edit26.Text := '';
 FrmMixer.CheckBox4.Checked := False;
 FrmMixer.CheckBox5.Checked := False;
 FrmMixer.CheckBox6.Checked := False;
 FrmMixer.CheckBox7.Checked := False;
end;

procedure PlayCurrent;
begin
case ChType of
AY_Chip:
 begin
  Led_AY.State := False;
  Led_YM.State := True
 end;
YM_Chip:
 begin
  Led_AY.State := True;
  Led_YM.State := False
 end
end;
Led_Stereo.State := NumberOfChannels = 1;
Led_AY.Redraw(False);
Led_YM.Redraw(False);
Led_Stereo.Redraw(False);

ButPlay.Switch_On;
FrmMain.ShowAllParams;
ButPause.Switch_Off;
ButStop.UnPush;

FrmMixer.GroupBox3.Enabled := False;

FrmMixer.GroupBox4.Enabled := False;
FrmMixer.Buff.Enabled := False;
FrmMixer.GroupBox10.Enabled := False;
FrmMixer.GroupBox13.Enabled := False;
FrmMixer.RadioButton13.Enabled := False;
FrmMixer.RadioButton14.Enabled := False;

FrmMain.FIDO_SaveStatus(FIDO_Playing);

try
  InitForAllTypes(True);
  if IsStreamOrModuleFileType(CurFileType) then
   StartBASS
  {$IFDEF Windows}
  else if IsCDFileType(CurFileType) then
   StartCD(CurCDNum,CurCDTrk)
  else if IsMIDIFileType(CurFileType) then
   midithread_start
  {$ENDIF Windows}
  else
   digsoundthread_start;
except
 RestoreControls;
 ShowException(ExceptObject, ExceptAddr);
end;
end;

procedure TFrmMain.MessageSkipper;
{$IFDEF Windows}
var
 masg:TMsg;
{$ENDIF Windows}
begin
{$IFDEF Windows}
if PeekMessage(masg,Handle,WM_LBUTTONDOWN,WM_LBUTTONDOWN,PM_REMOVE) then
 May_Quit:=True;
while PeekMessage(masg,0,0,0,PM_REMOVE) do
 case masg.message of
 WM_KEYDOWN:
  if masg.wparam=VK_ESCAPE then May_Quit:=True;
 WM_PAINT:
  begin
   TranslateMessage(Masg);
   DispatchMessage(Masg);
  end;
 end;
{$ELSE Windows}
Application.ProcessMessages; //TODO: Non Win32 MessageSkipper
{$ENDIF Windows}
end;


procedure TFrmMain.NewMessageSkipper;
{$IFNDEF Windows}
begin
Application.ProcessMessages; //TODO: non Win32 NewMessageSkipper
end;
{$ELSE Windows}
var
 masg:TMsg;
begin
if PrgBox then
 while PeekMessage(masg,FrmPrBox.Handle,WM_MOUSEFIRST,WM_MOUSELAST,PM_REMOVE) do
  begin
   TranslateMessage(Masg);
   DispatchMessage(Masg);
  end;
while PeekMessage(masg,0,0,0,PM_REMOVE) do
 case masg.message of
 WM_KEYDOWN:
  if masg.wparam=VK_ESCAPE then May_Quit:=True;
 WM_PAINT:
  begin
   TranslateMessage(Masg);
   DispatchMessage(Masg);
  end;
 end;
end;
{$ENDIF Windows}

procedure SetCommandLine(clstr:string);
begin
if InitialScan then
 FrmMain.CommandLineInterpreter(clstr,False)
else
 begin
  SetLength(AfterScan,Length(AfterScan) + 1);
  AfterScan[Length(AfterScan) - 1] := clstr;
 end;
end;

procedure TFrmMain.IPCMessage(Sender: TObject);
begin
SetCommandLine(IPCServer.StringMessage);
end;

procedure TFrmMain.CommandLineInterpreter(CL:string;Start:boolean);
var
 CLPos,CLLen,fileadp:integer;
 Param:string;
 fileex,quote,Fast,fileadd:boolean;
 ParamFiles:TStringList;

 procedure CommandLineParameter(CLP:string);

   procedure CLFile;
   begin
    if not IsSkinFileType(GetFileTypeFromFNExt(ExtractFileExt(CLP))) then
     fileex := True;
    ParamFiles.Add(ExpandFileName(CLP));
   end;

 var
  {$IFDEF Windows}
  Ch:char;
  {$ENDIF Windows}
  ErrPos,NewFrq,i,j:integer;
  usils:array[0..5]of byte;
  TempStr:string;
  EmChip:ChTypes;
  d1,d2:byte;
 begin
  if CLP = '' then exit;
  if (CLP[1] = '-')
     {$IFDEF Windows} or (CLP[1] = '/'){$ENDIF Windows} then //todo add to help '/'-->'-'
   begin
    if Length(CLP) < 2 then
     CLFile
    else case char(byte(CLP[2]) or $20) of
    's':
      begin
       Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
       if ErrPos = 0 then
        Set_Sample_Rate2(NewFrq)
      end;
    'b':
     begin
      Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
      if ErrPos = 0 then
       Set_Sample_Bit2(NewFrq)
     end;
    'z':
     begin
      Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
      if ErrPos = 0 then Set_Z80_Frq2(NewFrq)
     end;
    'y':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      Val(CLP,NewFrq,ErrPos);
      if ErrPos = 0 then Set_Chip_Frq2(NewFrq)
      else if CLP = 'list' then FrmMixer.CheckBox3.Checked := True
      else if CLP = 'mixer' then FrmMixer.CheckBox3.Checked := False
     end;
    'q':
     begin
      CLP := Trim(Copy(CLP,3,Length(CLP) - 2));
      if CLP = '' then
       Set_MFP_Frq2(0,0)
      else
       begin
        Val(CLP,NewFrq,ErrPos);
        if ErrPos = 0 then
         Set_MFP_Frq2(1,NewFrq)
       end
     end;
    't':
     begin
      Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
      if ErrPos = 0 then Set_IntOffset2(Newfrq)
     end;
    'a':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       IndicatorChecked := True
      else if CLP = 'off' then
       IndicatorChecked := False
      else if CLP = 'dd' then
       begin
        fileadd := True;
        fileadp := -1
       end
      else if CLP = 'dp' then
       fileadd := True
     end;
    'f':
     begin
      TempStr := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if TempStr = 'on' then
       SpectrumChecked := True
      else if TempStr = 'off' then
       SpectrumChecked := False
      else if (Length(TempStr) > 2) and (TempStr[1] = 'd') then
       begin
        CLP := Copy(CLP,5,Length(CLP) - 4);
        case TempStr[2] of
        'f':FIDO_Descriptor_FileName := CLP;
        'n':FIDO_Descriptor_Nothing := CLP;
        's':FIDO_Descriptor_Suffix := CLP;
        'p':FIDO_Descriptor_Prefix := CLP;
        'e':FIDO_Descriptor_Enabled := CLP <> '0';
        'k':FIDO_Descriptor_KillOnNothing := CLP <> '0';
        'x':FIDO_Descriptor_KillOnExit := CLP <> '0';
        'c':FIDO_Descriptor_Enc := CLP; //todo: add description to help-file
        end;
       end;
     end;
    'i':
     Set_N_TactS(Copy(CLP,3,Length(CLP) - 2));
    'l':
     if Length(CLP) >= 3 then
      Set_Language2(Copy(CLP,3,Length(CLP) - 2));
    'n':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      Val(CLP,NewFrq,ErrPos);
      if ErrPos = 0 then
       Set_Player_Frq2(NewFrq)
      else if CLP = 'list' then
       FrmMixer.CheckBox9.Checked := True
      else if CLP = 'mixer' then
       FrmMixer.CheckBox9.Checked := False
     end;
    'c':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       Set_Loop2(True)
      else if CLP = 'off' then
       Set_Loop2(False)
     end;
    {$IFDEF Windows}
    'r':
     if Length(CLP) = 3 then
      begin
       Ch := char(byte(CLP[3]) or $20);
       if Ch in ['i','n','h'] then
        begin
         case Ch of
         'i':SetPriority2(IDLE_PRIORITY_CLASS);
         'n':SetPriority2(NORMAL_PRIORITY_CLASS)
         else SetPriority2(HIGH_PRIORITY_CLASS)
         end
        end;
      end;
    {$ENDIF Windows}
    'h':
     begin
      CLP := UpperCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'MONO' then NewFrq := 0
      else if CLP = 'AYABC' then NewFrq := 1
      else if CLP = 'AYACB' then NewFrq := 2
      else if CLP = 'AYBAC' then NewFrq := 3
      else if CLP = 'AYBCA' then NewFrq := 4
      else if CLP = 'AYCAB' then NewFrq := 5
      else if CLP = 'AYCBA' then NewFrq := 6
      else if CLP = 'YMABC' then NewFrq := 7
      else if CLP = 'YMACB' then NewFrq := 8
      else if CLP = 'YMBAC' then NewFrq := 9
      else if CLP = 'YMBCA' then NewFrq := 10
      else if CLP = 'YMCAB' then NewFrq := 11
      else if CLP = 'YMCBA' then NewFrq := 12
      else if CLP = 'LIST' then
       begin
        FrmMixer.CheckBox1.Checked := True;
        NewFrq := -1
       end
      else if CLP = 'MIXER' then
       begin
        FrmMixer.CheckBox1.Checked := False;
        NewFrq := -1
       end
      else
       begin
        i := 1;
        CLP := CLP + ',';
        for j := 0 to 5 do
         begin
          TempStr := '';
          while (i <= Length(CLP)) and (CLP[i] <> ',') do
           begin
            TempStr := TempStr + CLP[i];
            Inc(i)
           end;
          Inc(i);
          if i - 1 > Length(CLP) then break;
          Val(TempStr,usils[j],ErrPos);
          if ErrPos <> 0 then break
         end;
        if (i - 1 <= Length(CLP)) and (ErrPos = 0) then
         with FrmMixer do
          for j := 0 to 5 do
           SetChan2(usils[j],j);
        NewFrq := -1
       end;
      if NewFrq >= 0 then
       begin
        if NewFrq > 6 then
         begin
          dec(NewFrq,6);
          EmChip:=YM_Chip;
         end
        else
         EmChip:=AY_Chip;
        FrmMain.CalcModeCoefs(NewFrq,EmChip,True,True,
                 Index_AL,Index_AR,Index_BL,Index_BR,Index_CL,Index_CR,
                 d1,d2);
        FrmMixer.UpdateAmplFields;
       end;
     end;
    'd':
     begin
      CLP := UpperCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'MONO' then Set_Stereo2(1)
      else if CLP = 'STEREO' then Set_Stereo2(2)
      else if CLP = 'LIST' then FrmMixer.CheckBox8.Checked := True
      else if CLP = 'MIXER' then FrmMixer.CheckBox8.Checked := False
     end;
    'e':
     begin
      CLP := UpperCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'AY' then Set_Chip2(AY_Chip)
      else if CLP = 'YM' then Set_Chip2(YM_Chip)
      else if CLP = 'LIST' then FrmMixer.CheckBox2.Checked := True
      else if CLP = 'MIXER' then FrmMixer.CheckBox2.Checked := False
     end;
    'g':
     begin
      CLP := Copy(CLP,3,Length(CLP) - 2);
      if CLP = '0' then
       Set_TrayMode2(0)
      else if CLP = '1' then
       Set_TrayMode2(1)
      else if CLP = '2' then
       Set_TrayMode2(2)
     end;
    'j':
     begin
      CLP := Copy(CLP,3,Length(CLP) - 2);
      if CLP = '0' then
       TimeMode := 0
      else if CLP = '1' then
       TimeMode := 1
      else if CLP = '2' then
       TimeMode := 2;
      TimeShown := -MaxInt;
     end;
    'k':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then Do_Scroll := True
      else if CLP = 'off' then Do_Scroll := False
     end;
    'p':
     LoadSkin(ExpandFileName(Copy(CLP,3,Length(CLP) - 2)),False);
    'w':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       SetAutoSaveDefDir2(True)
      else if CLP = 'off' then
       SetAutoSaveDefDir2(False)
      else if (Length(CLP) > 2) and (CLP[1] = 'o') then
       begin
        Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
        if ErrPos = 0 then
         case CLP[2] of
         'n':Set_NumberOfBuffers2(NewFrq);
         'l':Set_BufLen_ms2(NewFrq);
         'd':Set_WODevice2(NewFrq,'')
         end
       end
     end;
    'u':
     begin
      Val(Copy(CLP,3,Length(CLP) - 2),NewFrq,ErrPos);
      if ErrPos = 0 then SetChan2(NewFrq,6)
     end;
    'v':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'hide' then
       PostMessage(Handle,WM_HIDEMINIMIZE,0,0)
      else if CLP = 'show' then
       ShowApp(False);
     end;
    'x':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       SetAutoSaveWindowsPos2(True)
      else if CLP = 'off' then
       SetAutoSaveWindowsPos2(False);
     end;
    '!':
     begin
      CLP := LowerCase(Copy(CLP,3,Length(CLP) - 2));
      if CLP = 'on' then
       SetAutoSaveVolumePos2(True)
      else if CLP = 'off' then
       SetAutoSaveVolumePos2(False);
     end;
    else
     CLFile;
    end;
   end
  else
   CLFile;
 end;

var
 First:integer;
 dir:string;

begin
if AppIsModal or not IsWindowEnabled(Handle) then
 //ignore command line scan for closing modal window to finish playlist operations
 exit;

Fast := GetTickCount - LastTimeComLine < CLFast;
dir := GetCurrentDir;
ParamFiles := TStringList.Create;
fileex := False; fileadd := False; fileadp := Length(PlayListItems);
CLPos := 1;
CLLen := Length(CL);
First := 0;
while CLPos <= CLLen do
 begin
  quote := False;
  Param := '';
  while (CLPos <= CLLen) and (quote or (CL[CLPos] > ' ')) do
   begin
    if CL[CLPos] = '"' then
     quote := not quote
    else
     Param := Param + CL[CLPos];
    Inc(CLPos);
   end;
  case First of
  0:
   begin
    First := 1;
    SetCurrentDir(Param);
   end;
  1:
   First := 2;
  else
   CommandLineParameter(Param);
  end;
  Inc(CLPos);
 end;
SetCurrentDir(dir);
if ParamFiles.Count <> 0 then
 begin
  try
   if FileEx then
    if not fileadd and not Start and not Fast then
     begin
      StopPlaying;
      ClearPlayList;
     end
    else if fileadd and (fileadp >= 0) and not Fast then
     StopPlaying;
   FrmPLst.Add_Files(ParamFiles);
   if FileEx then
    CalculateTotalTime(False);
  finally
   ParamFiles.Free;
   if FileEx then
    begin
     CreatePlayOrder;
     if (fileadp >= 0) and (fileadp < Length(PlayListItems)) then
      RedrawPlaylist(fileadp,True)
     else
      RedrawPlaylist(0,True);
    end;
  end;
  if FileEx then
   begin
    First := -1; if not Start then First := 0;
    if not fileadd then
     begin
      if not Fast then PlayItem(0,First)
     end
    else if (fileadp >= 0) and (fileadp < Length(PlayListItems)) and not Fast then
     PlayItem(PlayListItems[fileadp]^.Tag,First);
   end;
 end;
LastTimeComLine := GetTickCount;
end;

procedure TFrmMain.Set_Chip_Frq2(Fr: integer);
begin
if Fr <> AY_Freq then
 begin
  Set_Chip_Frq(Fr);
  FrmMixer.FrqAYTemp := AY_Freq;
  FrmMixer.Set_Frqs;
 end;
end;

procedure TFrmMain.Set_Chip_Frq(Fr:integer);
begin
if (Fr >= 1000000) and (Fr <= 3546800) then
 begin
  digsoundloop_catch;
  try
    AY_Freq := Fr;
    CalculateSpectrumPoints;
    if MFPTimerMode = 0 then
     //MFPTimerFrq := round(AY_Freq * 16 / 13);
     Set_MFP_Frq(0,0);
    Delay_In_Tiks := round(8192/SampleRate * AY_Freq);
    FrqAyByFrqZ80 := round(AY_Freq/FrqZ80/8 * 4294967296);
    Tik.Re := Delay_In_Tiks;
    AY_Tiks_In_Interrupt := round(AY_Freq/(Interrupt_Freq/1000 * 8));
    YM6TiksOnInt := AY_Freq/(Interrupt_Freq/1000 * 8);
    SetFilter(FilterQuality);
    if IsPlaying then
     begin
      FrmMixer.Edit18.Text := IntToStr(AY_Freq);
      FrmMixer.Edit26.Text := IntToStr(MFPTimerFrq);
     end;
    AyFreq := AY_Freq;
    FrqAyByFrqMC68000 := round(AyFreq/MC68000Freq/8*4294967296);
  finally
    digsoundloop_release;
  end;
 end;
end;

procedure TFrmMain.Set_MFP_Frq(Md, Fr: integer);
begin
digsoundloop_catch;
try
  if Md = 0 then
   begin
    MFPTimerMode := 0;
    MFPTimerFrq := round(AY_Freq * 16 / 13)
   end
  else
   if (Fr >= 1000000) and (Fr <= 4365292) then
    begin
     MFPTimerMode := 1;
     MFPTimerFrq := Fr;
    end;
  if IsPlaying then
   FrmMixer.Edit26.Text := IntToStr(MFPTimerFrq);
  MFPFreq := MFPTimerFrq;
  MCbyMFP := MC68000Freq/MFPFreq;
finally
  digsoundloop_release;
end;
end;

procedure TFrmMain.ButMixerClick(Sender: TObject);
begin
if ButMixer.Is_On then
 ButMixer.Switch_Off
else
 ButMixer.Is_On := True;
FrmMixer.Visible := ButMixer.Is_On;
{$IFNDEF Windows}
if FrmMixer.WindowState = wsMinimized then //mask GTK error (minimize button is always visible (do bug report?)
 FrmMixer.WindowState := wsNormal;
{$ENDIF Windows}
end;

procedure TFrmMain.Set_Z80_Frq(NewF: integer);
begin
if (NewF >= 1000000) and (NewF <= 8000000) then
 begin
  digsoundloop_catch;
  try
    if (FrqZ80 <> NewF) and FileAvailable and
       ((CurFileType = FT.OUT) or (CurFileType = FT.ZXAY) or
        (CurFileType = FT.AY) or (CurFileType = FT.AYM) or
        (CurFileType = FT.EPSG)) then
     begin
      Time_ms := trunc(Time_ms/NewF*FrqZ80+0.5);
      ProgrMax := trunc(Time_ms/1000*SampleRate+0.5);
      VProgrPos := trunc(VProgrPos/NewF*FrqZ80+0.5)
     end;
    FrqZ80 := NewF;
    FrqAyByFrqZ80 := trunc(AY_Freq/FrqZ80/8*4294967296+0.5);
  finally
    digsoundloop_release;
  end;
  RedrawPlaylist(ShownFrom,False);
  CalculateTotalTime(False);
 end;
end;

procedure TFrmMain.Set_MC68K_Frq(NewF: integer);
begin
if (NewF >= 2000000) and (NewF <= 16000000) then
 begin
  digsoundloop_catch;
  try
    MC68000Freq := NewF;
    VBLPeriod := round (MC68000Freq / VBLFreq);
    FrqAyByFrqMC68000 := round(AyFreq/MC68000Freq/8*4294967296);
    MCbyMFP := MC68000Freq/MFPFreq;
  finally
    digsoundloop_release;
  end;
 end;
end;

procedure TFrmMain.Set_Z80_Frq2(NewF: integer);
begin
if NewF <> FrqZ80 then
 begin
  Set_Z80_Frq(NewF);
  FrmMixer.Set_Z80Frqs;
 end; 
end;

procedure TFrmMain.Set_MC68K_Frq2(NewF: integer);
begin
if NewF <> MC68000Freq then
 begin
  Set_MC68K_Frq(NewF);
  FrmMixer.Set_MC68KFrqs;
 end;
end;

procedure TFrmMain.Set_N_Tact(NewF:integer);
begin
if (NewF > 9999) and (NewF <= 200000) then
 begin
  digsoundloop_catch;
  try
    if (MaxTStates <> NewF) and FileAvailable and
       IsZ80EmuFileType(CurFileType) then
     begin
      Time_ms := trunc(Time_ms/MaxTStates*NewF+0.5);
      ProgrMax := trunc(Time_ms/1000*SampleRate+0.5);
      VProgrPos := trunc(VProgrPos/MaxTStates*NewF+0.5)
     end;
    MaxTStates := NewF;
    if IntOffset >= MaxTStates then
     begin
      IntOffset := MaxTStates - 1;
      FrmMixer.FTact.Text := IntToStr(IntOffset);
     end;
  finally
    digsoundloop_release;
  end;
  RedrawPlaylist(ShownFrom,False);
  CalculateTotalTime(False);
 end;
end;

procedure TFrmMain.Set_N_Tact2(NT: integer);
begin
if NT <> MaxTStates then
 begin
  Set_N_Tact(NT);
  FrmMixer.Edit19.Text := IntToStr(MaxTStates);
 end;
end;

procedure TFrmMain.Set_N_TactS(t: string);
var
 V,ErrPos:integer;
begin
Val(t,V,ErrPos);
if ErrPos = 0 then Set_N_Tact2(V);
end;

procedure TFrmMain.SetVisTimerPeriod(VTP:integer);
begin
if (VTP > 9) and (VTP < 101) then
 begin
  VisTimerPeriod := VTP;
  VisTimer.Interval := VTP;
 end;
end;

procedure TFrmMain.Set_Sample_Rate2(SR:integer);
begin
if (SR <> SampleRate) and not IsPlaying then
 begin
  Set_Sample_Rate(SR);
  FrmMixer.SetSRs;
 end;
end;

procedure Set_Sample_Rate(SR:integer);
begin
if IsPlaying then exit;
if not ((SR >= 8000) and (SR < 300000)) then exit;
SampleRate := SR;
VisStep := round(SampleRate/100);
BufferLength := round(BufLen_ms * SampleRate / 1000);
VisPosMax := round(BufferLength * NumberOfBuffers / VisStep) + 1;
VisTickMax := VisStep * VisPosMax;
SetLength(VisPoints,VisPosMax);
Delay_In_Tiks := round(8192/SampleRate*AY_Freq);
FrmMain.SetFilter(FilterQuality);
end;

procedure SetSynthesizer;
begin
if NumberOfChannels = 2 then
 begin
  if SampleBit = 8 then
   Synthesizer := @Synthesizer_Stereo8
  else
   Synthesizer := @Synthesizer_Stereo16;
 end
else if SampleBit = 8 then
 Synthesizer := @Synthesizer_Mono8
else
 Synthesizer := @Synthesizer_Mono16;
Calculate_Level_Tables2;
end;

procedure TFrmMain.Set_Sample_Bit2(SB: integer);
begin
if (SampleBit <> SB) and ((SB = 16) or (SB = 8)) and not IsPlaying then
 begin
  Set_Sample_Bit(SB);
  case SB of
  16:FrmMixer.RadioButton11.Checked := True;
  8:FrmMixer.RadioButton12.Checked := True;
  end;
 end; 
end;

procedure Set_Sample_Bit(SB:integer);
begin
if IsPlaying then exit;
SampleBit := SB;
SetSynthesizer;
end;

procedure TFrmMain.Set_Stereo2(St: integer);
begin
if (St <> NumberOfChannels) and (St in [1,2]) and not IsPlaying then
 begin
  Set_Stereo(St);
  case St of
  1:FrmMixer.RadioButton14.Checked := True;
  2:FrmMixer.RadioButton13.Checked := True;
  end;
 end;
end;

procedure Set_Stereo(St:integer);
begin
if IsPlaying then exit;
NumberOfChannels := St;
SetSynthesizer;
end;

procedure Calculate_Level_Tables2;
var
 Max,MaxL:integer;
begin
Calculate_Level_Tables;
Get_Max_of_Level_Tables(Max);
if SampleBit = 8 then
 MaxL := 127
else
 MaxL := 32767;
FrmMixer.AYOverflowLbl.Visible := Max > MaxL;
FrmMixer.TSOverflowLbl.Visible := Max*2 > MaxL;
inc(Max,Atari_DMALevel); if NumberOfChannels = 1 then
 inc(Max,Atari_DMALevel);
FrmMixer.DMAOverflowLbl.Visible := (Atari_DMALevel <> 0) and (Max > MaxL);
end;

procedure TFrmMain.ShowAllParams;
begin
FrmMixer.Edit12.Text := IntToStr(Index_AL);
FrmMixer.Edit13.Text := IntToStr(Index_AR);
FrmMixer.Edit14.Text := IntToStr(Index_BL);
FrmMixer.Edit15.Text := IntToStr(Index_BR);
FrmMixer.Edit16.Text := IntToStr(Index_CL);
FrmMixer.Edit17.Text := IntToStr(Index_CR);
FrmMixer.Edit18.Text := IntToStr(AY_Freq);
FrmMixer.Edit23.Text := FloatToStrF(Interrupt_Freq/1000,ffFixed,7,3);
FrmMixer.Edit26.Text := IntToStr(MFPTimerFrq);
if ChType = AY_Chip then
 FrmMixer.CheckBox4.Checked := True
else
 FrmMixer.CheckBox5.Checked := True;
if NumberOfChannels = 2 then
 FrmMixer.CheckBox7.Checked := True
else
 FrmMixer.CheckBox6.Checked := True;
end;

procedure TFrmMain.RestoreAllParams;
begin
with FrmMixer do
 begin
  if RadioButton2.Checked then
   ChType := YM_Chip
  else
   ChType := AY_Chip;
  SetChan2(TrackBar1.Position,0);
  SetChan2(TrackBar2.Position,1);
  SetChan2(TrackBar3.Position,2);
  SetChan2(TrackBar4.Position,3);
  SetChan2(TrackBar5.Position,4);
  SetChan2(TrackBar6.Position,5);
  Set_Chip_Frq(FrqAYTemp);
  Set_Player_Frq(FrqPlTemp);
  if RadioButton13.Checked then
   Set_Stereo(2)
  else
   Set_Stereo(1);
 end;
end;

procedure TFrmMain.ButListClick(Sender: TObject);
begin
if ButList.Is_On then
 ButList.Switch_Off
else
 ButList.Is_On := True;
FrmPLst.Visible := ButList.Is_On;
{$IFNDEF Windows}
if FrmPLst.WindowState = wsMinimized then //mask GTK error (minimize button is always visible (do bug report?)
 FrmPLst.WindowState := wsNormal;
{$ENDIF Windows}
end;

procedure TFrmMain.ButNextClick(Sender: TObject);
begin
ButNext.UnPush;
FrmPLst.PlayNextItem;
end;

procedure TFrmMain.ButPrevClick(Sender: TObject);
begin
ButPrev.UnPush;
FrmPLst.PlayPreviousItem;
end;

procedure TFrmMain.WMPLAYNEXTITEM(var Msg: TMsg);
var
 Flg:boolean;
begin
{$IFDEF Windows}
if not IsCDFileType(CurFileType) then
 StopPlaying
else
 begin
  IsPlaying := False;
  Paused := False;
  RestoreControls;
 end;
{$ELSE Windows}
StopPlaying;
{$ENDIF Windows}
Flg := (Direction = 3) and (not ListLooped);
if not Flg then
 begin
  if Direction <> 3 then
   begin
    FrmPLst.PlayNextItem;
    Flg := PlayingItem >= Length(PlayListItems) - 1
   end
  else
   PlayCurrent;
 end;
if not IsPlaying and Flg then
 begin
  FreeAndUnloadBASS;
  {$IFDEF Windows}
  CloseCDDevice(CurCDNum);
  {$ENDIF Windows}
 end;
end;

procedure TFrmMain.WMBASSMETADATA(var Msg: TMsg);
var
 Tags:TTags;
 s:string;
begin
if (MusicHandle <> 0) and MusicIsStream and TAGS_Read_Meta(MusicHandle,Tags) then
 begin
  ForceScrollForDisplay;
  s := FormatScrollString(Tags.Artist,Tags.Title,'',-1);
  if s = '' then ReprepareScroll else SetScrollString(s);
  CurItem.PLStr := ss;
  if not Paused then FIDO_SaveStatus(FIDO_Playing);
  TrayIcon1.Hint := ss;
 end;
end;

procedure TFrmMain.Set_Mode_Manual(AL,AR,BL,BR,CL,CR:byte);
begin
Index_AL := AL; Index_AR := AR;
Index_BL := BL; Index_BR := BR;
Index_CL := CL; Index_CR := CR;
Calculate_Level_Tables2;
end;

procedure TFrmMain.CalcModeCoefs(Mode:Integer;ChType:ChTypes;TS,DMA:boolean;
           out Index_AL,Index_AR,Index_BL,Index_BR,Index_CL,Index_CR,
           BeeperMax,Atari_DMAMax:byte);
var
 Echo:integer;
begin
if not DMA then
 Atari_DMAMax := 0;
if Mode > 0 then
 begin
  if ChType = AY_Chip then Echo := 85 else Echo := 13;
  BeeperMax := (255+170+Echo) div 3;
  if DMA then
   Atari_DMAMax := BeeperMax;
  case Mode of
  1: begin
      Index_AL := 255; Index_AR := Echo;
      Index_BL := 170; Index_BR := 170;
      Index_CL := Echo; Index_CR := 255;
     end;
  2: begin
      Index_AL :=255; Index_AR := Echo;
      Index_BL :=Echo; Index_BR := 255;
      Index_CL :=170; Index_CR := 170;
     end;
  3: begin
      Index_AL :=170; Index_AR := 170;
      Index_BL :=255; Index_BR := Echo;
      Index_CL :=Echo; Index_CR := 255;
     end;
  4: begin
      Index_AL :=Echo; Index_AR := 255;
      Index_BL :=255; Index_BR := Echo;
      Index_CL :=170; Index_CR := 170;
     end;
  5: begin
      Index_AL := 170; Index_AR := 170;
      Index_BL := Echo; Index_BR := 255;
      Index_CL := 255; Index_CR := Echo;
     end;
  6: begin
      Index_AL := Echo; Index_AR := 255;
      Index_BL := 170; Index_BR := 170;
      Index_CL := 255; Index_CR := Echo;
     end;
   end;
 end
else
 begin
  BeeperMax := 255;
  if DMA then
   Atari_DMAMax := BeeperMax;
  Index_AL := 255; Index_AR := 255;
  Index_BL := 255; Index_BR := 255;
  Index_CL := 255; Index_CR := 255;
 end;
end;

procedure TFrmMain.Set_Mode(Mode:Integer);
var
 d1,d2:byte;
begin
CalcModeCoefs(Mode,ChType,True,True,Index_AL,Index_AR,Index_BL,Index_BR,Index_CL,Index_CR,d1,d2);
Calculate_Level_Tables2;
end;

procedure TFrmMain.Set_Player_Frq2(Fr:integer);
begin
if Fr <> Interrupt_Freq then
 begin
  Set_Player_Frq(Fr);
  FrmMixer.FrqPlTemp := Interrupt_Freq;
  FrmMixer.Set_Pl_Frqs;
  RedrawPlaylist(ShownFrom,False);
  CalculateTotalTime(False);
 end;
end;

procedure TFrmMain.Set_Player_Frq(Fr:integer);
begin
if (Fr >= 1000) and (Fr <= 2000000) and (Interrupt_Freq <> Fr) then
 begin
  digsoundloop_catch;
  try
    if FileAvailable and IsVBLFileType(CurFileType) then
     begin
      Time_ms := trunc(Time_ms/Fr*Interrupt_Freq+0.5);
      ProgrMax := trunc(Time_ms/1000*SampleRate+0.5);
      VProgrPos := trunc(VProgrPos/Fr*Interrupt_Freq+0.5)
     end;
    Interrupt_Freq := Fr;
    if IsPlaying then
     FrmMixer.Edit23.Text := FloatToStrF(Interrupt_Freq/1000,ffFixed,70,3);
    AY_Tiks_In_Interrupt := trunc(AY_Freq/(Interrupt_Freq/1000*8)+0.5);
    YM6TiksOnInt := AY_Freq/(Interrupt_Freq/1000*8);
    VBLFreq := Interrupt_Freq/1000;
    VBLPeriod := round (MC68000Freq / VBLFreq);
  finally
    digsoundloop_release;
  end;
 end;
end;

procedure TFrmMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 p:PSensZone;
 p1:PMoveZone;
 p2:PButtZone;
 OfsR:integer;
//{$IFDEF Windows}
// r:TRect;
//{$ENDIF Windows}
begin
if ssDouble in Shift then
 if (X >= scr_x) and (X < scr_x + scr_width) and
    (Y >= scr_y) and (Y < scr_y + scr_height) then
  begin
   Do_Scroll := not Do_Scroll;
   exit
  end;

if Button = mbLeft then
 begin
  if MoveWin.Touche(X,Y) then
   begin
//{$IFDEF Windows}
//    SystemParametersInfo(SPI_GETWORKAREA,0,@r,0);
//    ClipCursor(@r);
//{$ELSE Windows}
{$IFNDEF Windows}
//    BeginAutoDrag;
   BeginDrag(False);
{$ENDIF Windows}
   end;
  p := SensZoneRoot;
  while p <> nil do
   begin
    if p^.Touche(X,Y) then
     p^.Clicked := True;
    p := p^.Next;
   end;
  p2 := ButtZoneRoot;
  while p2 <> nil do
   begin
    if (p2^.Clicked = 0) and p2^.Touche(X,Y) then
     begin
      p2^.Clicked := 1;
      p2^.Push;
     end;
    p2 := p2^.Next
   end;
  p1 := MoveZoneRoot;
  while p1 <> nil do
   begin
    if p1^.Bmps then
     begin
      if p1^.ToucheBut(X,Y) then
       begin
        p1^.OldX := X;
        p1^.Delt := X - p1^.posX;
        p1^.Clicked := True
       end
      else if p1^.Touche(X,Y) then
       begin
        p1^.Clicked := True;
        OfsR := X - p1^.zx - p1^.bm1w div 2;
        if OfsR > p1^.zw - p1^.bm1w then
         OfsR := p1^.zw - p1^.bm1w
        else if OfsR < 0 then
         OfsR := 0;
        if OfsR <> p1^.PosX then
         begin
          p1^.HideBmp;
          OffsetRgn(p1^.RgnHandle,OfsR - p1^.PosX,0);
          p1^.PosX := OfsR;
          p1^.Redraw(False);
          p1^.Action(Self)
         end;
        p1^.OldX := X;
        p1^.Delt := X - p1^.posX;
       end;
     end
    else if p1^.Touche(X,Y) then
     begin
      p1^.OldX := X;
      p1^.OldY := Y;
      p1^.Clicked := True;
     end;
    p1 := p1^.Next;
   end;
 end;
end;

procedure TFrmMain.ButToolsClick(Sender: TObject);
begin
if not ButTools.Is_On then
 begin
  ButTools.Is_On := True;
  FinderWorksNow := False;
  FrmTools := TFrmTools.Create(Self);
 end
else if not FinderWorksNow then
{$IFDEF Windows}
 PostMessage(FrmTools.Handle,WM_CLOSE,0,0);
{$ELSE Windows}
 FrmTools.Close;
{$ENDIF Windows}
end;

procedure MainWinRepaint;
var
 p:PButtZone;
 p1:PMoveZone;
 p2:PLedZone;
begin
if LedZoneRoot <> nil then
 begin
  p2 := LedZoneRoot;
  repeat
   p2^.Redraw(True);
   p2 := p2^.Next;
  until p2 = nil;
 end;
if ButtZoneRoot <> nil then
 begin
  p := ButtZoneRoot;
  repeat
   p^.Redraw(True);
   p := p^.Next;
  until p = nil;
 end;
if MoveZoneRoot <> nil then
 begin
  p1 := MoveZoneRoot;
  repeat
   p1^.Redraw(True);
   p1 := p1^.Next;
  until p1 = nil;
 end;

BMP_DBuffer.Canvas.CopyMode:=cmSrcCopy;
BMP_DBuffer.Canvas.CopyRect(Bounds(scr_x,scr_y,scr_width,scr_height),BMP_Scroll.Canvas,Rect(0,0,scr_width,scr_height));
BMP_DBuffer.Canvas.CopyRect(Bounds(time_x,time_y,time_width,time_height),BMP_Time.Canvas,Rect(0,0,time_width,time_height));
FrmMain.Canvas.CopyMode:=cmSrcCopy;
FrmMain.Canvas.CopyRect(Rect(0,0,MWWidth,MWHeight),BMP_DBuffer.Canvas,Rect(0,0,MWWidth,MWHeight));
end;

procedure TFrmMain.ButLoopClick(Sender: TObject);
begin
if ButLoop.Is_On then
 ButLoop.Switch_Off
else
 ButLoop.Is_On := True;
Do_Loop := ButLoop.Is_On;
BASS_SetLoop;
{$IFDEF Windows}
MIDI_SetLoop;
{$ENDIF Windows}
end;

constructor TSensZone.Create(ps:PSensZone;x,y,w,h:integer;pr:TNotifyEvent);
var
 p:PSensZone;
begin
inherited Create;
zx := x; zy := y; zw := w; zh := h;
if SensZoneRoot = nil then
 SensZoneRoot := ps
else
 begin
  p := SensZoneRoot;
  while p^.Next <> nil do p := p^.Next;
  p^.Next := ps;
 end;
Next := nil;
Clicked := False;
Action := pr;
end;

function TSensZone.Touche(x,y:integer):boolean;
begin
Result := (x >= zx) and (x < zx + zw) and (y >= zy) and (y < zy + zh);
end;

procedure TFrmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 p:PButtZone;
 p1:PMoveZone;
 OfsR:integer;
begin
if ssShift in Shift then Shift := Shift - [ssShift];
if [ssLeft] = Shift then
 begin
  p := ButtZoneRoot;
  while p <> nil do
   begin
    if (p^.Clicked = 1) and not p^.Is_On then
     if p^.Touche(X,Y) then
      p^.Push
     else
      p^.UnPush;
    p := p^.Next
   end;
  p1 := MoveZoneRoot;
  while p1 <> nil do
   begin
    if p1^.Clicked then
     begin
      if p1^.Bmps then
       begin
        OfsR := p1^.posX + X - p1^.OldX;
        p1^.OldX := X;
        if OfsR < 0 then
         begin
          p1^.OldX := p1^.Delt;
          OfsR := 0;
         end
        else if OfsR > p1^.zw - p1^.bm1w then
         begin
          OfsR := p1^.zw - p1^.bm1w;
          p1^.OldX := OfsR + p1^.Delt;
         end;
        if OfsR <> p1^.PosX then
         begin
          p1^.HideBmp;
          OffsetRgn(p1^.RgnHandle,OfsR - p1^.PosX,0);
          p1^.PosX := OfsR;
          p1^.Redraw(False);
          p1^.Action(Self);
         end;
       end
      else
       begin
        p1^.PosX := X - p1^.OldX;
        p1^.PosY := Y - p1^.OldY;
        p1^.Action(Self);
       end;
     end;
    p1 := p1^.Next;
   end;
 end;
end;

procedure TFrmMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 p:PSensZone;
 p1:PMoveZone;
 p2:PButtZone;
begin
if Button = mbLeft then
 begin
//{$IFDEF Windows}
//  ClipCursor(nil);
//{$ENDIF Windows}
  p := SensZoneRoot;
  while p <> nil do
   begin
    if p^.Clicked then
     begin
      if p^.Touche(X,Y) then
       p^.Action(Self);
      p^.Clicked := False;
     end;
    p := p^.Next;
   end;
  p2 := ButtZoneRoot;
  while p2 <> nil do
   begin
    if p2^.Clicked = 1 then
     begin
      if p2^.Touche(X,Y) then
       p2^.Action(Self);
      if ButtZoneRoot = nil then break; //FPC
      p2^.Clicked := 0;
     end;
    p2 := p2^.Next;
   end;
  p1 := MoveZoneRoot;
  while p1 <> nil do
   begin
    if p1^.Clicked then
     begin
      p1^.Clicked := False;
      p1^.Action(Self);
     end;
    p1 := p1^.Next;
   end;
 end;
end;

constructor TButtZone.Create(ps:PButtZone;x,y,w,h:integer;rh:HRGN;Bmp:TBitmap;x1,y1,x2,y2:integer;pr:TNotifyEvent);
var
 p:PButtZone;
begin
inherited Create;
zx := x; zy := y; zw := w; zh := h;
RgnHandle := rh;
if ButtZoneRoot = nil then
 ButtZoneRoot := ps
else
 begin
  p := ButtZoneRoot;
  while p^.Next <> nil do p := p^.Next;
  p^.Next := ps
 end;
Next := nil;
Is_On := False;
Is_Pushed := False;
Clicked := 0;
Action := pr;
Bmp1 := TBitmap.Create; Bmp1.Width:=zw; Bmp1.Height:=zh;
Bmp1.Canvas.CopyMode:=cmSrcCopy;
Bmp1.Canvas.CopyRect(Rect(0,0,zw,zh),Bmp.Canvas,Bounds(x1,y1,zw,zh));
Bmp2 := TBitmap.Create; Bmp2.Width:=zw; Bmp2.Height:=zh;
Bmp2.Canvas.CopyMode:=cmSrcCopy;
Bmp2.Canvas.CopyRect(Rect(0,0,zw,zh),Bmp.Canvas,Bounds(x2,y2,zw,zh));
end;

function TButtZone.Touche(x,y:integer):boolean;
begin
if RgnHandle <> 0 then
 Result := PtInRegion(RgnHandle,x,y)
else
 Result := (x >= zx) and (x < zx + zw) and (y >= zy) and (y < zy + zh);
end;

procedure TButtZone.Free;
begin
Bmp1.Free;
Bmp2.Free;
inherited;
end;

procedure TButtZone.Redraw(OnCanvas:boolean);
begin
if OnCanvas then
 begin
 BMP_DBuffer.Canvas.CopyMode:=cmSrcCopy;
 if not Is_Pushed then
  BMP_DBuffer.Canvas.CopyRect(Bounds(zx,zy,zw,zh),Bmp1.Canvas,Rect(0,0,zw,zh))
 else
  BMP_DBuffer.Canvas.CopyRect(Bounds(zx,zy,zw,zh),Bmp2.Canvas,Rect(0,0,zw,zh));
 end
else
 begin
 FrmMain.Canvas.CopyMode:=cmSrcCopy;
 if not Is_Pushed then
  FrmMain.Canvas.CopyRect(Bounds(zx,zy,zw,zh),Bmp1.Canvas,Rect(0,0,zw,zh))
 else
  FrmMain.Canvas.CopyRect(Bounds(zx,zy,zw,zh),Bmp2.Canvas,Rect(0,0,zw,zh));
 end;
end;

procedure TButtZone.Push;
begin
if not Is_Pushed then
 begin
  Is_Pushed := True;
  Redraw(False);
 end;
end;

procedure TButtZone.UnPush;
begin
if Is_Pushed then
 begin
  Is_Pushed := False;
  Redraw(False);
 end;
end;

procedure TButtZone.Switch_On;
begin
if not Is_On then
 Is_On := True;
Push;
end;

procedure TButtZone.Switch_Off;
begin
if Is_On then
 Is_On := False;
UnPush;
end;

constructor TLedZone.Create(ps:PLedZone;x,y,w,h:integer;Bmp:TBitmap;x1,y1,x2,y2:integer);
var
 p:PLedZone;
begin
inherited Create;
zx := x; zy := y; zw := w; zh := h;
if LedZoneRoot = nil then
 LedZoneRoot := ps
else
 begin
  p := LedZoneRoot;
  while p^.Next <> nil do p := p^.Next;
  p^.Next := ps;
 end;
Next := nil;
State := False;
Bmp1 := TBitmap.Create; Bmp1.Width:=zw; Bmp1.Height:=zh;
Bmp1.Canvas.CopyMode:=cmSrcCopy;
Bmp1.Canvas.CopyRect(Rect(0,0,zw,zh),Bmp.Canvas,Bounds(x1,y1,zw,zh));
Bmp2 := TBitmap.Create; Bmp2.Width:=zw; Bmp2.Height:=zh;
Bmp2.Canvas.CopyMode:=cmSrcCopy;
Bmp2.Canvas.CopyRect(Rect(0,0,zw,zh),Bmp.Canvas,Bounds(x2,y2,zw,zh));
end;

procedure TLedZone.Redraw(OnCanvas:boolean);
begin
if OnCanvas then
 begin
 BMP_DBuffer.Canvas.CopyMode:=cmSrcCopy;
 if not State then
  BMP_DBuffer.Canvas.CopyRect(Bounds(zx,zy,zw,zh),Bmp1.Canvas,Rect(0,0,zw,zh))
 else
  BMP_DBuffer.Canvas.CopyRect(Bounds(zx,zy,zw,zh),Bmp2.Canvas,Rect(0,0,zw,zh));
 end
else
 begin
 FrmMain.Canvas.CopyMode:=cmSrcCopy;
 if not State then
  FrmMain.Canvas.CopyRect(Bounds(zx,zy,zw,zh),Bmp1.Canvas,Rect(0,0,zw,zh))
 else
  FrmMain.Canvas.CopyRect(Bounds(zx,zy,zw,zh),Bmp2.Canvas,Rect(0,0,zw,zh));
 end;
end;

procedure TLedZone.Free;
begin
Bmp1.Free;
Bmp2.Free;
inherited;
end;

procedure TFrmMain.ButCloseClick(Sender: TObject);
begin
Close;
end;

procedure TFrmMain.ButAboutClick(Sender: TObject);
begin
  with TAboutBox.Create(Self) do
  try
   {$ifdef beta}
   AbDBuffer.Canvas.TextOut(122-AbDBuffer.Canvas.TextWidth(BetaNumber) div 2,236,BetaNumber);
   {$endif beta}
   ShowModal;
  finally
   Free;
   ButAbout.UnPush;
  end;
end;

procedure TFrmMain.ButSpaClick(Sender: TObject);
begin
SpectrumChecked := not SpectrumChecked;
end;

procedure TFrmMain.ButAmpClick(Sender: TObject);
begin
IndicatorChecked := not IndicatorChecked;
end;

procedure TFrmMain.ButTimeClick(Sender: TObject);
begin
Inc(TimeMode);
if TimeMode > 2 then TimeMode := 0;
TimeShown := -MaxInt;
end;

constructor TMoveZone.Create(ps:PMoveZone;x,y,w,h,y1,h1:integer;rh:HRGN;
                                                        pr:TNotifyEvent);
var
 p:PMoveZone;
begin
inherited Create;
zx := x; zy := y; zw := w; zh := h;
zy1 := y1; zh1 := h1;
RgnHandle := rh;
PosX := 0;
if MoveZoneRoot = nil then
 MoveZoneRoot := ps
else
 begin
  p := MoveZoneRoot;
  while p^.Next <> nil do p := p^.Next;
  p^.Next := ps;
 end;
Next := nil;
Bmps := False;
State := False;
Clicked := False;
Action := pr;
end;

function TMoveZone.ToucheBut(x,y:integer):boolean;
begin
Result :=
 PtInRegion(RgnHandle,x,y);
// ((x >= PosX + zx) and (x < PosX + zx + Bm1w) and (y >= zy) and (y < zy + Bm1h));
end;

function TMoveZone.Touche(x,y:integer):boolean;
begin
Result := ((x >= zx) and (x < zx + zw) and (y >= zy + zy1) and (y < zy + zy1 + zh1));
end;

procedure TFrmMain.DoMovingWindow(Sender: TObject);
begin
(*{$IFNDEF Windows}
Left := Left + MoveWin.PosX;
Top := Top + MoveWin.PosY;
{$ENDIF Windows}*)
end;

procedure TFrmMain.DoMovingScroll(Sender: TObject);
begin
Inc(MoveScr.OldX,MoveScr.PosX);
if sw <= scr_width then exit;
if Scroll_Distination <> Item_Displayed then exit;
Dec(HorScrl_Offset,MoveScr.PosX);
if HorScrl_Offset < 0 then
 HorScrl_Offset := 0
else if HorScrl_Offset > sw - scr_width then
 HorScrl_Offset := sw - scr_width;
RedrawScroll;
end;

procedure TMoveZone.AddBitmaps(Bmp:TBitmap;x1,y1,bw,bh:integer;m:boolean);
begin
Bmps := True;
Bmp1 := TBitmap.Create; Bmp1.Width:=bw; Bmp1.Height:=bh;
Bm1w := bw;
Bm1h := bh;
Bmp1.Canvas.CopyMode:=cmSrcCopy;
Bmp1.Canvas.CopyRect(Rect(0,0,bw,bh),Bmp.Canvas,Bounds(x1,y1,bw,bh));
if m then
 begin
  Bmp1.TransparentColor:=Bmp1.Canvas.Pixels[0,0];
  Bmp1.Transparent:=True;
  Bmp1.TransparentMode:=tmFixed;
 end;
Bmp2 := TBitmap.Create; Bmp2.Width:=zw; Bmp2.Height:=zh;
Bmp2.Canvas.CopyMode:=cmSrcCopy;
Bmp2.Canvas.CopyRect(Rect(0,0,zw,zh),Bmp.Canvas,Bounds(zx,zy,zw,zh));
end;

procedure TMoveZone.Free;
begin
if Bmps then
 begin
  Bmp1.Free;
  Bmp2.Free;
 end;
inherited;
end;

procedure TMoveZone.Redraw(OnCanvas:boolean);
begin
if Bmps then
 begin
    BMP_DBuffer.Canvas.Draw(zx + PosX,zy,Bmp1);
  if not OnCanvas then
   begin
    FrmMain.Canvas.CopyMode:=cmSrcCopy;
    FrmMain.Canvas.CopyRect(Bounds(zx,zy,zw,zh),BMP_DBuffer.Canvas,Bounds(zx,zy,zw,zh));
   end;
 end;
end;

procedure TMoveZone.HideBmp;
begin
if Bmps then
 begin
  BMP_DBuffer.Canvas.CopyMode:=cmSrcCopy;
  BMP_DBuffer.Canvas.CopyRect(Bounds(zx + PosX,zy,Bm1w,Bm1h),Bmp2.Canvas,Bounds(PosX,0,Bm1w,Bm1h));
 end;
end;

procedure TFrmMain.DoMovingVol(Sender: TObject);
begin
VolumeCtrl := MoveVol.PosX;
SetSysVolume;
end;

procedure Rewind(newpos,maxpos:integer);
var
 i,d:longword;
{$IFDEF Windows}
 MSF:packed record
  case boolean of
  True: (MSF:DWORD);
  False:(M,S,F:byte);
 end;
{$ENDIF Windows}
begin
if not IsPlaying or Paused or MoveProgr.Clicked
{$IFDEF Windows}
   or (IsMIDIFileType(CurFileType) and MIDIParams^.seeking)
{$ENDIF Windows}
 then exit;
if ProgrMax = longword(-1) then
 exit;
if newpos < 0 then
 newpos := 0
else if newpos > maxpos then
 newpos := maxpos;
i := round(newpos/maxpos * ProgrMax);
ShowProgress(i);
if IsStreamOrModuleFileType(CurFileType) then
 begin
  //Mask BASS error: if seeking to the end on some mod-music, sync_end message is not sent
  if not Do_Loop and (i >= ProgrMax) then
   PostMessage(FrmMain.Handle,WM_PLAYNEXTITEM,0,0)
  else
   begin
    d := 0;
    if IsStreamFileType(CurFileType) and (StreamPlayFrom > 0) then
     d := StreamPlayFrom;
    //BASS cannot seek to the end of some mod-music, but I havn't any idea how to fix it
    if BASS_ChannelSetPosition(MusicHandle,BASS_ChannelSeconds2Bytes(MusicHandle,(i + d) / 1000),BASS_POS_BYTE) then
     CurrTime_Rasch := i
    //Temporary solving problem so:
    else if i >= 50 then
     begin
      dec(i,50);
      if BASS_ChannelSetPosition(MusicHandle,BASS_ChannelSeconds2Bytes(MusicHandle,(i + d) / 1000),BASS_POS_BYTE) then
       CurrTime_Rasch := i;
     end;
   end;
 end
{$IFDEF Windows}
else if IsCDFileType(CurFileType) then
 begin
  CurrTime_Rasch := round(i / 75 * 1000);
  MSF.F := i mod 75;
  i := i div 75;
  MSF.S := i mod 60;
  MSF.M := i div 60;
  CDSetPosition(CurCDNum,CurCDTrk,MSF.MSF,FrmMain.Handle);
 end
else if IsMIDIFileType(CurFileType) then
 begin
  MIDIParams^.seek_to := i;
  CurrTime_Rasch := i;
  MIDIParams^.seeking := True;
 end
{$ENDIF Windows}
else
 begin
  {$IFNDEF UseBassForEmu}
  digsoundloop_catch;
  {$ELSE UseBassForEmu}
  BASS_ChannelStop(MusicHandle);
  {$ENDIF UseBassForEmu}
  try
   RerollMusic(newpos,maxpos);
  finally
  {$IFNDEF UseBassForEmu}
   digsound_reset;
   MkVisPos := 0;
   VisPoint := 0;
   NOfTicks := 0;
   digsoundloop_release;
  {$ELSE UseBassForEmu}
   BASS_ChannelPlay(MusicHandle,True);
  {$ENDIF UseBassForEmu}
  end;
 end;
end;

procedure TFrmMain.DoMovingProgr(Sender: TObject);
begin
Rewind(MoveProgr.PosX,ProgrWidth);
end;

procedure TFrmMain.DoMinimize;
begin
Application.Minimize;
{$IFNDEF Windows}
FrmMain.WindowState:=wsMinimized; //prevent GTK widgetset error
AppMinimize(Self); //second bug - onminimize is not raised
{$ENDIF Windows}
end;

procedure TFrmMain.ButMinClick(Sender: TObject);
begin
ButMinimize.UnPush;
DoMinimize;
end;

//todo: bugreport for LCL (not fired during OpenDialog execute, maybe some other Std dialogs too)
procedure TFrmMain.AppModalBegin(Sender: TObject);
begin
AppIsModal := True;
end;

procedure TFrmMain.AppModalEnd(Sender: TObject);
begin
AppIsModal := False;
end;

procedure TFrmMain.AppMinimize(Sender: TObject);
begin
case TrayMode of
{$IFDEF Windows}
1:
 ShowWindow(GetParent(FrmMain.Handle),SW_HIDE); //LCL cannot minimize tool window app
{$ENDIF Windows}
2:
 begin
  AddTrayIcon;
  RemoveTaskbarButton;
 end;
end;
end;

procedure TFrmMain.AppRestore(Sender: TObject);
begin
if TrayMode = 2 then
 begin
  RemoveTrayIcon;
  AddTaskbarButton;
 end;
end;

procedure TFrmMain.DoRestore;
begin
Application.Restore; //not work in gtk, bug?
{$IFNDEF Windows}
FrmMain.WindowState:=wsNormal; //prevent GTK widgetset error
AppRestore(Self); //second bug - onrestore is not raised
{$ENDIF Windows}
end;

procedure TFrmMain.ShowApp(Tray:boolean);
begin
if WindowState = wsMinimized then
 DoRestore
{$IFDEF Windows}
else if not Tray then
 begin //real bring to front instead of taskbar button flashing
  if TrayMode = 2 then TrayMode := -1;
//  Application.Minimize;
//  Application.Restore;
  DoMinimize;
  DoRestore;
  if TrayMode = -1 then TrayMode := 2;
 end
{$ENDIF Windows}
else
 Application.BringToFront; //todo в GTK не работает
end;

{$IFDEF Windows}
function IsWindowStayOnTop(h:THandle):boolean;
begin
Result := GetWindowLong(h, GWL_EXSTYLE) and WS_EX_TOPMOST <> 0;
end;

function IsApplicationForm(h:THandle):boolean;
var
 i:integer;
begin
Result := False;
for i := 0 to Screen.CustomFormCount - 1 do
 if Screen.CustomForms[i].Handle = h then
  begin
   Result := True;
   exit;
  end;
end;

function Overlapped:boolean;
var
 R1,R2:TRect;
 h:THandle;
begin
Result := False;
h := FrmMain.Handle;
if not GetWindowRect(h,R1) then exit;
repeat
  h := GetNextWindow(h,GW_HWNDPREV); if h = 0 then exit;
  if not IsWindowVisible(h) then continue;
  if IsWindowStayOnTop(h) then continue;
  if not GetWindowRect(h,R2) then continue;
  if R2.Left = R2.Right then continue;
  if R2.Top = R2.Bottom then continue;
  if R1.Left > R2.Right then continue;
  if R1.Right < R2.Left then continue;
  if R1.Top > R2.Bottom then continue;
  if R1.Bottom < R2.Top then continue;
  if IsApplicationForm(h) then continue;
  Result := True; exit;
until False;
end;
{$ENDIF Windows}

procedure TFrmMain.TrayIcon1DblClick(Sender: TObject);
begin
 TrayIconClicked := True;
end;

procedure TFrmMain.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Button = mbLeft then TrayIconClicked := True;
end;

procedure TFrmMain.TrayIcon1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Button <> mbLeft then exit;
if TrayIconClicked then
 begin
  TrayIconClicked := False;
  if (WindowState = wsMinimized)
     {$IFDEF Windows}
     or Overlapped
     {$ENDIF Windows}
  then
   ShowApp(True)
  else
   DoMinimize;
 end;
end;

{$IFDEF Windows}
var
 WM_RESTORETRAY:DWORD;
function WndCallback(Ahwnd: HWND; uMsg: UINT; wParam: WParam; lParam: LParam):LRESULT; stdcall;
var
 r:_RECT;
begin
 case uMsg of
 WM_NCHITTEST:
  begin
   if GetWindowRect(Ahwnd,r) and
//      MoveWin.Touche(smallint(lParam and $FFFF) - r.Left,smallint(lParam shr 16) - r.Top) then
      MoveWin.Touche(GET_X_LPARAM(lParam) - r.Left,GET_Y_LPARAM(lParam) - r.Top) then
    Result := HTCAPTION
   else
    Result := DefWindowProc(Ahwnd,uMsg,wParam,lParam);
   exit;
  end;
 MM_MCINOTIFY:
  begin
   if CheckCDNum(CurCDNum) then
    if LParam = integer(CDIDs[CurCDNum]) then
     if WParam = MCI_NOTIFY_SUCCESSFUL then
      begin
       PostMessage(Ahwnd,WM_PLAYNEXTITEM,0,0);
       Result := 0;
       exit;
      end;
  end
 else if uMsg = WM_RESTORETRAY then
  if FrmMain.TrayIcon1.Visible then
   FrmMain.TrayIcon1.Show;
 end;
 Result:=CallWindowProc(PrevWndProc,Ahwnd, uMsg, WParam, LParam);
end;

function AWndCallback(Ahwnd: HWND; uMsg: UINT; wParam: WParam; lParam: LParam):LRESULT; stdcall;
begin
 case uMsg of
 WM_SYSCOMMAND:
  case (WParam and $FFF0) of
  SC_MINIMIZE:
   if TrayMode = 1 then ShowWindow(GetParent(FrmMain.Handle), SW_HIDE); //LCL cannot minimize app tool window
  SC_RESTORE:
   if TrayMode = 1 then ShowWindow(GetParent(FrmMain.Handle), SW_SHOWNA); //LCL cannot restore hidden app tool window
  end;
 end;
 Result:=CallWindowProc(PrevAWndProc,Ahwnd, uMsg, WParam, LParam);
end;
{$ENDIF Windows}

procedure TFrmMain.FormCreate(Sender: TObject);

//{$define CreateRgn}

{$ifdef CreateRgn}
 function AddRoundRectRgnR(a,b,c,d,e,f:integer):HRGN;
 begin
  Result := CreateRoundRectRgn(a,b,c,d,e,f);
  CombineRgn(MyFormRgn,MyFormRgn,Result,RGN_OR);
 end;

 procedure AddRoundRectRgn(a,b,c,d,e,f:integer);
 begin
  DeleteObject(AddRoundRectRgnR(a,b,c,d,e,f));
 end;
{$endif CreateRgn}

var
 i:integer;
{$ifndef CreateRgn}
 hr:HRGN;
{$endif CreateRgn}

const
 RegionVolPoints:array[0..2] of TPoint =
  ((x:237+70-18;y:21+11+1),(x:237+70;y:21+11+1),(x:237+70;y:21+1));
 RegionProgrPoints:array[0..11] of TPoint =
  ((x:96;y:84),(x:100;y:84),(x:100;y:83),(x:112;y:83),(x:112;y:84),
   (x:116;y:84),(x:116;y:92),(x:112;y:92),(x:112;y:93),(x:100;y:93),
   (x:100;y:92),(x:96;y:92));

{$ifndef CreateRgn}
{$i rgn.inc}
{$endif CreateRgn}

begin

Randomize;

{$ifdef CreateRgn}
MyFormRgn := CreateRectRgn(51,1,311,114);
AddRoundRectRgn(0,0,115,115,115,115);
AddRoundRectRgn(358-115,0,358,115,115,115);
{$endif CreateRgn}
RgnLoop := {$ifdef CreateRgn}AddRoundRectRgnR{$else CreateRgn}CreateRoundRectRgn{$endif CreateRgn}(62-10,110-10,62+11,110+11,21,21);
RgnBack := {$ifdef CreateRgn}AddRoundRectRgnR{$else CreateRgn}CreateRoundRectRgn{$endif CreateRgn}(80,96,80+35,123,14,14);
RgnPlay := {$ifdef CreateRgn}AddRoundRectRgnR{$else CreateRgn}CreateRoundRectRgn{$endif CreateRgn}(119,96,119+35,123,14,14);
RgnPause := {$ifdef CreateRgn}AddRoundRectRgnR{$else CreateRgn}CreateRoundRectRgn{$endif CreateRgn}(158,96,158+35,123,14,14);
RgnStop := {$ifdef CreateRgn}AddRoundRectRgnR{$else CreateRgn}CreateRoundRectRgn{$endif CreateRgn}(197,96,197+35,123,14,14);
RgnNext := {$ifdef CreateRgn}AddRoundRectRgnR{$else CreateRgn}CreateRoundRectRgn{$endif CreateRgn}(235,96,235+35,123,14,14);
RgnOpen := {$ifdef CreateRgn}AddRoundRectRgnR{$else CreateRgn}CreateRoundRectRgn{$endif CreateRgn}(275,96,275+35,123,14,14);
RgnMixer := CreateRoundRectRgn(318,21,318+26,21+26,26,26);
RgnPList := CreateRoundRectRgn(310,77,310+26,77+26,26,26);
RgnTools := CreateRoundRectRgn(322,50,322+26,50+26,26,26);
RgnMin := CreateRoundRectRgn(282,6,282+16,6+16,16,16);
RgnClose := CreateRoundRectRgn(304,6,304+16,6+16,16,16);
RgnVol := CreatePolygonRgn(RegionVolPoints,3,ALTERNATE);
RgnProgr := CreatePolygonRgn(RegionProgrPoints,12,ALTERNATE);

SensSpa := TSensZone.Create(@SensSpa,spa_x,spa_y,spa_width,spa_height,@ButSpaClick);
SensAmp := TSensZone.Create(@SensAmp,amp_x,amp_y,amp_width,amp_height,@ButAmpClick);
SensTime := TSensZone.Create(@SensTime,time_x,time_y,time_width,time_height,@ButTimeClick);
MoveWin := TMoveZone.Create(@MoveWin,84,5,279-84,22-5,0,22-5,0,@DoMovingWindow);
MoveVol := TMoveZone.Create(@MoveVol,237,21+1,70,12,4,8,RgnVol,@DoMovingVol);
MoveProgr := TMoveZone.Create(@MoveProgr,96,83,255-96,10,2,5,RgnProgr,@DoMovingProgr);
MoveScr := TMoveZone.Create(@MoveScr,scr_x,scr_y,scr_width,scr_height,0,scr_height,0,@DoMovingScroll);

BMP_DBuffer := TBitmap.Create; BMP_DBuffer.Width := MWWidth; BMP_DBuffer.Height := MWHeight;

LoadSkin('',True);

VolumeCtrl := MoveVol.zw - MoveVol.Bm1w;
VolumeCtrlMax := VolumeCtrl;
MoveVol.PosX := VolumeCtrl;

ProgrWidth := MoveProgr.zw - MoveProgr.Bm1w;

Led_AY.State := True;

{$ifndef CreateRgn}
with rgn[0] do
 MyFormRgn := CreateRectRgn(x,y,x+w,y+h);
for i := 1 to nrects do
 with rgn[i] do
  begin
   hr := CreateRectRgn(x,y,x+w,y+h);
   CombineRgn(MyFormRgn,MyFormRgn,hr,RGN_OR);
   DeleteObject(hr);
  end;
{$endif CreateRgn}

{$IFDEF Windows}
SetWindowRgn(Handle,MyFormRgn,True);
{$ENDIF Windows}

PSpa_prev := @Spa_prev;
PSpa_piks := @Spa_piks;
Synthesizer := @Synthesizer_Stereo16;
Application.OnRestore := @AppRestore;
Application.OnMinimize := @AppMinimize;
Application.OnModalBegin := @AppModalBegin;
Application.OnModalEnd := @AppModalEnd;
Application.OnEndSession := @AppEndSession;
Application.TaskBarBehavior := tbSingleButton;

//Application.MainFormOnTaskBar:=False;

//Application.Title := 'Ay_Emul'; //avoid undesired behavior of GetAppConfigDirUTF8
FIDO_Descriptor_Filename := GetAppConfigDirUTF8(False) + 'aystatus.txt';

for i := 0 to spa_num - 1 do Spa_piks[i] := 0;

BMP_Sources := TBitmap.Create; BMP_Sources.Width:=max_src; BMP_Sources.Height:=max_height;

BMP_Time := TBitmap.Create; BMP_Time.Width:=time_width; BMP_Time.Height:=time_height;
{$IFDEF Windows}
BMP_Time.Canvas.Font.Name:='MS Sans Serif'; //todo
{$ENDIF Windows}
BMP_Time.Canvas.Font.Bold:=True;
BMP_Time.Canvas.Font.Color:=$464646;
BMP_Time.Canvas.Brush.Style:=bsClear;

BMP_Vis := TBitmap.Create; BMP_Vis.Width:=max_width2; BMP_Vis.Height:=max_height2;
BMP_Vis.Canvas.Pen.Color:=$464646;
BMP_Vis.Canvas.Pen.Width:=3;

BMP_VScroll := TBitmap.Create; BMP_VScroll.Width:=scr_width; BMP_VScroll.Height:=scr_lineheight*3;
{$IFDEF Windows}
BMP_VScroll.Canvas.Font.Name:='MS Sans Serif'; //todo
{$ENDIF Windows}
BMP_VScroll.Canvas.Font.Height:=-20;
BMP_VScroll.Canvas.Font.Color:=$606060;

BMP_Scroll := TBitmap.Create; BMP_Scroll.Width:=scr_width; BMP_Scroll.Height:=scr_lineheight;

BMP_VScroll.Canvas.Brush.Color:=clWhite;
BMP_VScroll.Canvas.FillRect(0,0,scr_width,scr_lineheight*3);
CopyBmpSources;

VisTimer := TTimer.Create(Self);
VisTimer.Interval:=VisTimerPeriod;
VisTimer.OnTimer:=@VisTimerEvent;
VisTimer.Enabled:=True;

{$IFDEF Windows}
WM_RESTORETRAY := RegisterWindowMessage('TaskbarCreated');
PrevWndProc:={%H-}Windows.WNDPROC(SetWindowLongPtr(Handle,GWL_WNDPROC,{%H-}PtrInt(@WndCallback)));
PrevAWndProc:={%H-}Windows.WNDPROC(SetWindowLongPtr(GetParent(Handle),GWL_WNDPROC,{%H-}PtrInt(@AWndCallback)));
{$ENDIF Windows}

IPCServer.OnMessage := @IPCMessage;

end;

procedure SetScrollString(const scrstr:string);
begin
ss := scrstr;
GetStringWnJ(ss,sw,sj);
if scr_lineheight*(Scroll_Distination - Item_Displayed + 1) - Scroll_Offset = 0 then
 begin
  if scr_width < sw then
   begin
    if HorScrl_Offset > sw - scr_width then
     HorScrl_Offset := sw - scr_width - 1
   end
  else
   begin
    HorScrl_Offset := 0;
    BMP_VScroll.Canvas.FillRect(Rect(0,scr_lineheight,scr_width,scr_lineheight*2));
   end;
  RedrawScroll;
 end;
end;

procedure ReprepareScroll;
begin
if Item_Displayed > 0 then
 begin
  ss1 := GetPlayListString(PlaylistItems[Item_Displayed - 1]);
  GetStringWnJ(ss1,sw1,sj1)
 end;
if Item_Displayed < Length(PlaylistItems) - 1 then
 begin
  ss2 := GetPlayListString(PlaylistItems[Item_Displayed + 1]);
  GetStringWnJ(ss2,sw2,sj2)
 end;
if (Item_Displayed >= 0) and (Item_Displayed < Length(PlaylistItems)) then
 SetScrollString(GetPlayListString(PlaylistItems[Item_Displayed]));
end;

procedure TFrmMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);

 procedure TryClick(Bt:TButtZone);
 begin
  if Bt.Clicked = 2 then
   begin
    Bt.Clicked := 0;
    Bt.Action(Sender);
   end;
 end;

begin
case Key of
byte('T'):
 ButTimeClick(Sender);
byte('1'):
 ButAmpClick(Sender);
byte('2'):
 ButSpaClick(Sender);
byte('P'):
 TryClick(ButTools);
byte('E'):
 TryClick(ButList);
byte('G'):
 TryClick(ButMixer);
byte('R'):
 TryClick(ButLoop);
byte('X'):
 TryClick(ButPlay);
VK_NUMPAD5:
 if not IsPlaying then
  TryClick(ButPlay)
 else
  TryClick(ButPause);
byte('V'):
 TryClick(ButStop);
byte('C'):
 TryClick(ButPause);
byte('B'),VK_NUMPAD6:
 TryClick(ButNext);
byte('Z'),VK_NUMPAD4:
 TryClick(ButPrev);
byte('L'),VK_NUMPAD0:
 TryClick(ButOpen);
end;
end;

procedure TFrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

 procedure UnClickAllButButt(Butt:TButtZone);
 var
  p:PButtZone;
 begin
  p := ButtZoneRoot;
  while p <> nil do
   begin
    if p <> @Butt then
     if p^.Clicked <> 0 then
      begin
       p^.Clicked := 0;
       if not p^.Is_On then p^.UnPush;
      end;
    p := p^.Next;
   end;
 end;

 procedure Push(Bt:TButtZone);
 begin
  if Bt.Clicked = 0 then
   begin
    UnClickAllButButt(Bt);
    Bt.Clicked := 2;
    Bt.Push;
   end;
 end;

begin
case Key of
byte('P'):
 Push(ButTools);
byte('J'):
 begin
  UnClickAllButButt(nil);
  JumpToTime
 end;
byte('E'):
 Push(ButList);
byte('G'):
 Push(ButMixer);
byte('R'):
 Push(ButLoop);
byte('X'):
 Push(ButPlay);
VK_NUMPAD5:
 if not IsPlaying then
  Push(ButPlay)
 else
  Push(ButPause);
byte('V'):
 Push(ButStop);
byte('C'):
 Push(ButPause);
byte('B'),VK_NUMPAD6:
 Push(ButNext);
byte('Z'),VK_NUMPAD4:
 Push(ButPrev);
byte('L'),VK_NUMPAD0:
 Push(ButOpen);
VK_UP,VK_NUMPAD8:
 VolUp;
VK_DOWN,VK_NUMPAD2:
 VolDown;
VK_LEFT:
 begin
  UnClickAllButButt(nil);
  if Time_ms > 0 then
   Rewind(CurrTime_Rasch - 5000,Time_ms);
 end;
VK_RIGHT:
 begin
  UnClickAllButButt(nil);
  if Time_ms > 0 then
   Rewind(CurrTime_Rasch + 5000,Time_ms);
 end;
VK_F1:
 begin
  UnClickAllButButt(nil);
  CallHelp;
 end;
VK_ESCAPE:
 DoMinimize;
end;
end;

procedure TFrmMain.VolUp;
begin
if MoveVol.PosX < MoveVol.zw - MoveVol.Bm1w then
 begin
  MoveVol.Clicked := False;
  MoveVol.HideBmp;
  Inc(MoveVol.PosX);
  OffsetRgn(MoveVol.RgnHandle,1,0);
  MoveVol.Redraw(False);
  MoveVol.Action(Self);
 end
end;

procedure TFrmMain.VolDown;
begin
if MoveVol.posX > 0 then
 begin
  MoveVol.Clicked := False;
  MoveVol.HideBmp;
  Dec(MoveVol.PosX);
  OffsetRgn(MoveVol.RgnHandle,-1,0);
  MoveVol.Redraw(False);
  MoveVol.Action(Self);
 end;
end;

procedure TFrmMain.AddTrayIcon;
begin
TrayIcon1.Icon.LoadFromResourceName(hInstance,Format('ICON%.2u',[TrayIconNumber]));
if not FileAvailable then
 TrayIcon1.Hint := 'AY Emulator';
TrayIcon1.Show;
end;

procedure TFrmMain.RemoveTrayIcon;
begin
TrayIcon1.Hide;
end;

function TFrmMain.LoadSkin(FName:string;First:boolean):boolean;
var
 Buffer:array of byte;
 Author,Comment:string;
 rs:TResourceStream;
 s:string;
 i:integer;
 tl,mx,pl,ls,pa,l1,l2,l3,lp:boolean;
 URHandle:integer;
begin
Result := False;
try
 if FName = '' then
  begin
   rs := TResourceStream.Create(HInstance,'DEFAULTSKIN',RT_RCDATA);
   UniReadInit(URHandle,URMemory,'',rs.Memory,rs.Size);
   Compressed_Size := rs.Size - SkinIdLen - 4;
  end
 else
  begin
   try
    UniReadInit(URHandle,URFile,FName,nil,-1);
   except
    ShowException(ExceptObject, ExceptAddr);
    exit;
   end;
   Compressed_Size := UniReadersData[URHandle]^.UniFileSize - SkinIdLen - 4;
  end;
 try
  SetLength(s,SkinIdLen);
  UniRead(URHandle,@s[1],SkinIdLen);
  if s <> SkinId then
   begin
    ShowMessage(Mes_File + ' ' + FName + ' ' + Mes_notAy_Emul20Skin);
    exit;
   end;
  UniRead(URHandle,@Original_Size,4);
  UniAddDepacker(URHandle,UDLZH);
  SetLength(Buffer,Original_Size);
  UniRead(URHandle,@Buffer[0],Original_Size)
 finally
  UniReadClose(URHandle);
  if FName = '' then rs.Free;
 end;

 Author := '';
 i := 0;
 while (i < Original_Size) and (Buffer[i] <> 0) do
  begin
   Author := Author + char(Buffer[i]);
   Inc(i);
  end;
 Author := CPToUTF8(Author); //todo - skins only utf8 encoding
 Comment := '';
 Inc(i);
 while (i < Original_Size) and (Buffer[i] <> 0) do
  begin
   Comment := Comment + char(Buffer[i]);
   Inc(i);
  end;
 Comment := CPToUTF8(Comment);
 Inc(i);

 if not First then
  begin
   tl := ButTools.Is_On;
   mx := ButMixer.Is_On;
   ls := ButList.Is_On;
   pa := ButPause.Is_Pushed;
   pl := ButPlay.Is_Pushed;
   lp := ButLoop.Is_Pushed;
   l1 := Led_AY.State;
   l2 := Led_YM.State;
   l3 := Led_Stereo.State;
   BmpFree;
   MoveVol.Bmp1.Free;
   MoveVol.Bmp2.Free;
   MoveVol.Bmps := False;
   MoveProgr.Bmp1.Free;
   MoveProgr.Bmp2.Free;
   MoveProgr.Bmps := False;
   SetMainBmp(@Buffer[i],Original_Size - i);
   CopyBmpSources;
   ButTools.Is_On := tl;
   ButTools.Is_Pushed := tl;
   ButMixer.Is_On := mx;
   ButMixer.Is_Pushed := mx;
   ButList.Is_On := ls;
   ButList.Is_Pushed := ls;
   ButPause.Is_Pushed := pa;
   ButPlay.Is_Pushed := pl;
   ButLoop.Is_Pushed := lp;
   ButLoop.Is_On := lp;
   Led_AY.State := l1;
   Led_YM.State := l2;
   Led_Stereo.State := l3;
   if ButTools.Is_On then
    begin
     FrmTools.Edit1.Text := Author;
     FrmTools.Edit2.Text := Comment;
     FrmTools.Edit3.Text := FName;
    end;
  end
 else
  SetMainBmp(@Buffer[i],Original_Size - i);
except
 ShowException(ExceptObject, ExceptAddr);
 exit;
end;
SkinAuthor := Author;
SkinComment := Comment;
SkinFileName := FName;
Result := True;
if FileAvailable then
 begin
  RedrawTime;
  RedrawScroll;
 end;
Refresh;
end;

procedure TFrmMain.SetMainBmp(p:pointer;size:integer);
var
 Stream:TStream;
 Bitmap:TBitmap;
begin
Stream := TMemoryStream.Create;
Stream.Write(p^,size);
Stream.Position := 0;
Bitmap := TBitmap.Create;
Bitmap.LoadFromStream(Stream);
Stream.Free;
BMP_DBuffer.Canvas.CopyMode:=cmSrcCopy;
BMP_DBuffer.Canvas.CopyRect(Rect(0,0,MWWidth,MWHeight),Bitmap.Canvas,Rect(0,0,MWWidth,MWHeight));
ButPlay := TButtZone.Create(@ButPlay,119,96,35,27,RgnPlay,
                            Bitmap,119,96,119,122,@PlayClick);
ButPrev := TButtZone.Create(@ButPrev,80,96,35,27,RgnBack,
                            Bitmap,80,96,80,122,@ButPrevClick);
ButNext := TButtZone.Create(@ButNext,235,96,35,27,RgnNext,
                            Bitmap,235,96,235,122,@ButNextClick);
ButOpen := TButtZone.Create(@ButOpen,275,96,35,27,RgnOpen,
                            Bitmap,275,96,275,122,@ButOpenClick);
ButStop := TButtZone.Create(@ButStop,197,96,35,27,RgnStop,
                            Bitmap,197,96,197,122,@ButStopClick);
ButPause := TButtZone.Create(@ButPause,158,96,35,27,RgnPause,
                             Bitmap,158,96,158,122,@ButPauseClick);
ButLoop := TButtZone.Create(@ButLoop,62-10,110-10,21,21,RgnLoop,
                             Bitmap,62-10,110-10,358-21,110-7,@ButLoopClick);
ButMixer := TButtZone.Create(@ButMixer,318,21,26,26,RgnMixer,
                             Bitmap,318,21,26*2,124,@ButMixerClick);
ButList := TButtZone.Create(@ButList,310,77,26,26,RgnPList,
                            Bitmap,310,77,26,124,@ButListClick);
ButTools := TButtZone.Create(@ButTools,322,50,26,26,RgnTools,
                             Bitmap,322,50,0,124,@ButToolsClick);
ButMinimize := TButtZone.Create(@ButMinimize,282,6,16,16,RgnMin,
                                Bitmap,282,6,0,0,@ButMinClick);
ButClose := TButtZone.Create(@ButClose,304,6,16,16,RgnClose,
                             Bitmap,304,6,358-16,0,@ButCloseClick);
ButAbout := TButtZone.Create(@ButAbout,258,84,307-258,92-84,0,
                             Bitmap,258,84,0,123-(92-84),@ButAboutClick);
MoveVol.AddBitmaps(Bitmap,358-41,113,18,11,True);
MoveProgr.AddBitmaps(Bitmap,0,103,20,10,True);
Led_AY := TLedZone.Create(@Led_AY,99,26,144-99,33-26,
                          Bitmap,99,26,358-(144-99)-1,150-(33-26)-1);
Led_YM := TLedZone.Create(@Led_YM,144,26,190-144,33-26,
                          Bitmap,144,26,358-(190-144)-1,150-(33-26)*2-2);
Led_Stereo := TLedZone.Create(@Led_Stereo,190,26,234-190,33-26,
                              Bitmap,190,26,358-(234-190)-1,150-(33-26)*3-3);
Bitmap.Free;
end;

procedure TFrmMain.BmpFree;
var
 pppp,pppp1:PButtZone;
 ppp,ppp1:PLedZone;
begin
if ButtZoneRoot <> nil then
 begin
  pppp := ButtZoneRoot;
  ButtZoneRoot := nil;
  repeat
   pppp1 := pppp^.Next;
   pppp^.Free;
   pppp := pppp1;
  until pppp = nil;
 end;
if LedZoneRoot <> nil then
 begin
  ppp := LedZoneRoot;
  LedZoneRoot := nil;
  repeat
   ppp1 := ppp^.Next;
   ppp^.Free;
   ppp := ppp1;
  until ppp = nil;
 end;
end;

procedure TFrmMain.CopyBmpSources;
begin
BMP_Sources.Canvas.CopyMode:=cmSrcCopy;
BMP_Sources.Canvas.CopyRect(Bounds(spa_src,0,spa_width,spa_height),BMP_DBuffer.Canvas,Bounds(spa_x,spa_y,spa_width,spa_height));
BMP_Sources.Canvas.CopyRect(Bounds(amp_src,0,amp_width,amp_height),BMP_DBuffer.Canvas,Bounds(amp_x,amp_y,amp_width,amp_height));
BMP_Sources.Canvas.CopyRect(Bounds(time_src,0,time_width,time_height),BMP_DBuffer.Canvas,Bounds(time_x,time_y,time_width,time_height));
BMP_Sources.Canvas.CopyRect(Bounds(scr_src,0,scr_width,scr_height),BMP_DBuffer.Canvas,Bounds(scr_x,scr_y,scr_width,scr_height));
BMP_Time.Canvas.CopyMode:=cmSrcCopy;
BMP_Time.Canvas.CopyRect(Rect(0,0,time_width,time_height),BMP_Sources.Canvas,Bounds(time_src,0,time_width,time_height));
BMP_Scroll.Canvas.CopyMode:=cmSrcCopy;
BMP_Scroll.Canvas.CopyRect(Rect(0,0,scr_width,scr_height),BMP_Sources.Canvas,Bounds(scr_src,0,scr_width,scr_height));
end;

procedure TFrmMain.FormDropFiles(Sender: TObject; const FileNames: array of String);
var
 nFiles,i:integer;
 Skin:boolean;
begin
Screen.Cursor := crHourGlass;
Skin := True;
for i := 0 to Length(FileNames) - 1 do
 if not IsSkinFileType(GetFileTypeFromFNExt(ExtractFileExt(FileNames[i]))) then
  begin
   Skin := False;
   break;
  end;
if not Skin then
 begin
  StopAndFreeAll;
  ClearPlayList;
 end;
May_Quit2 := False;
 try
  nFiles := Length(FileNames);
  for i := 0 to nFiles - 1 do
   begin
    if not DirectoryExists(FileNames[i]) then
     FrmPLst.Add_File(FileNames[i],True,0)
    else
     FrmPLst.SearchFilesInFolder(FileNames[i],{-1,}True,True,0);
   end;
 finally
  if not Skin then
   begin
    CalculateTotalTime(False);
    CreatePlayOrder;
   end;
  Screen.Cursor := crDefault;
 end;
if not Skin then
 PlayItem(0,0);
end;

procedure TFrmMain.FIDO_SaveStatus(Status:FIDO_Status);
var
 f:TextFile;
 s:string;

 procedure KillFile;
 begin
   try
    if FileExists(FIDO_Descriptor_FileName) then
     DeleteFile(FIDO_Descriptor_FileName);
   except
   end;
 end;

begin
if not FIDO_Descriptor_Enabled or Uninstall then exit;
case Status of
FIDO_Nothing:
        begin
         if FIDO_Descriptor_KillOnNothing then
          begin
           KillFile;
           exit;
          end;
         s := FIDO_Descriptor_Prefix + FIDO_Descriptor_Nothing
        end;
FIDO_Exit:
        begin
         if FIDO_Descriptor_KillOnExit then
          begin
           KillFile;
           exit;
          end;
         s := FIDO_Descriptor_Prefix + FIDO_Descriptor_Nothing
        end;
else    s := FIDO_Descriptor_Prefix +
                CurItem.PLStr + FIDO_Descriptor_Suffix;
end;
if s <> FIDO_Descriptor_String then
 begin
  FIDO_Descriptor_String := s;
  s := ConvertEncoding(s,'UTF8',FIDO_Descriptor_Enc);

//FIDO вроде уже не актуально, обходить его ограничения больше нет смысла
(*  for i := 1 to Length(s) do //меняем русские 'Н' 'р' (т.е. только для CP1251 и CP866)
   case s[i] of
    #205: s[i] := 'H';
    #240: s[i] := 'p'
   end;
   if not FIDO_Descriptor_WinEnc then
    AnsiToOemBuff(@s[1], @s[1], Length(s));
*)

  try
   AssignFile(f,FIDO_Descriptor_FileName);
   Rewrite(f);
   try
    Write(f,s);
   finally
    CloseFile(f);
   end;
  except;
  end;
 end;
end;

procedure TFrmMain.JumpToTime;

function TimeValid(stime:string;var time:integer):boolean;
var
 temp,t1:integer;
begin
Result := True;
Val(stime,time,temp);
if temp = 0 then exit;
if (temp > 1) and (temp < Length(stime)) and (stime[temp] = ':') then
 begin
  Val(Copy(stime,temp + 1,Length(stime) - temp),time,t1);
  if t1 = 0 then
   begin
    Val(Copy(stime,1,temp - 1),t1,temp);
    if temp = 0 then
     begin
      inc(time,t1*60);
      exit
     end;
   end;
 end;
Result := False
end;

var
 time:integer;
begin
if not IsPlaying then exit;
if Paused then exit;
with TFrmJpTime.Create(Self) do
 try
  Edit1.Text := TimeSToStr(round(CurrTime_Rasch / 1000));
  lbTrkLen.Caption := Mes_TrackLength + ' ' + TimeSToStr(round(Time_ms / 1000));
  if ShowModal = mrOK then
   if TimeValid(Edit1.Text,time) then
    Rewind(time*1000,Time_ms);
 finally
  Free;
 end;
end;

procedure TFrmMain.CallHelp;
var
 f:string;
begin
f := ExtractFilePath(GetProcessFileName);
//todo langs
if Pos('ru',Get_Language) = 1  then
 f := f+'Ay_Rus.chm'
else
 f := f+'Ay_Eng.chm';
if not OpenDocument(f) then
 ShowMessage(Mes_CantOpen + ' ' + f);
end;

procedure TFrmMain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
VolDown;
end;

procedure TFrmMain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
VolUp;
end;

procedure TFrmMain.WMFINALIZEWO(var Msg: TMsg);
begin
if not IsPlaying then exit;
digsoundthread_free;
RestoreControls;
PostMessage(FrmMain.Handle,WM_PLAYNEXTITEM,0,0);
end;

procedure TFrmMain.FormDeactivate(Sender: TObject);
var
 p:PSensZone;
 p1:PMoveZone;
 p2:PButtZone;
begin
//{$IFDEF Windows}
//  ClipCursor(nil);
//{$ENDIF Windows}
  p := SensZoneRoot;
  while p <> nil do
   begin
    p^.Clicked := False;
    p := p^.Next;
   end;
  p2 := ButtZoneRoot;
  while p2 <> nil do
   begin
    if (p2^.Clicked = 1) and not p2^.Is_On then
     p2^.UnPush;
    p2^.Clicked := 0;
    p2 := p2^.Next;
   end;
  p1 := MoveZoneRoot;
  while p1 <> nil do
   begin
    p1^.Clicked := False;
    p1 := p1^.Next;
   end;
end;

procedure TFrmMain.FormPaint(Sender: TObject);
begin
  MainWinRepaint;
end;

{$IFNDEF Windows}
procedure TFrmMain.DoSetRgn(Sender: TObject);
begin
  Timer1.Enabled := False;
  SetWindowRgn(Handle,MyFormRgn,True);
end;
{$ENDIF Windows}

procedure TFrmMain.FormShow(Sender: TObject);
begin
{$IFNDEF Windows} //GTK can set region after OnShow only :(
Timer1 := TTimer.Create(Self);
Timer1.Interval:=1;
Timer1.OnTimer:=@DoSetRgn;
{$ENDIF Windows}
end;

procedure StopPlaying;
begin
try
 if IsStreamOrModuleFileType(CurFileType) then
// {$IFDEF UseBassForEmu}or MinAYChipFile..MaxAYChipFile{$ENDIF UseBassForEmu}
   PlayFreeBASS
  {$IFDEF Windows}
  else if IsCDFileType(CurFileType) then
   StopCDDevice(CurCDNum)
  else if IsMIDIFileType(CurFileType) then
   midithread_stop
  {$ENDIF Windows}
  else
   begin
    digsoundthread_stop;
    if CurFileType = FT.SNDH then
     Atari_StopEmu;
   end;
finally
  IsPlaying := False;
  Paused := False;
  RestoreControls;
end;
end;

procedure GetSysVolume;
var
 v:single;
begin
if mixerctl_getvolume(v) <> 0 then exit;
if VolLinear then
 VolumeCtrl := round(v * VolumeCtrlMax)
else
 VolumeCtrl := round(
            ln(v
//                         + 1) / ln(2)  //closer to linear version
           * (exp(1) - 1) + 1)
                      * VolumeCtrlMax);
RedrawVolume;
end;

procedure SetSysVolume;
var
 v:Single;
begin
if VolLinear then
 v := VolumeCtrl / VolumeCtrlMax
else
 //(exp(VolumeCtrl / VolumeCtrlMax * ln(2)) - 1) //closer to linear version
 v := (exp((VolumeCtrl / VolumeCtrlMax)) - 1) / (exp(1) - 1);
mixerctl_setvolume(v);
RedrawVolume;
end;

procedure RedrawVolume;
begin
if VolumeCtrl = MoveVol.PosX then exit;
MoveVol.HideBmp;
OffsetRgn(MoveVol.RgnHandle,VolumeCtrl - MoveVol.PosX,0);
MoveVol.PosX := VolumeCtrl;
MoveVol.Redraw(False);
end;

procedure TFrmMain.WMPLAYERROR(var Msg: TMsg);
begin
ButStopClick(Self);
end;

procedure StopAndFreeAll;
begin
try
 StopPlaying;
finally
 FreeAndUnloadBASS;
{$IFDEF Windows}
 try
  FreeAllCD;
 except
 end;
{$ENDIF Windows}
end;
end;

procedure TFrmMain.SaveParams;

 procedure SaveDW(Nm:PChar; const Vl:integer);
 begin
 OptionsWrite(Nm,IntToStr(Vl));
 end;

 procedure SaveStr(Nm:PChar; const Vl:string);
 begin
 OptionsWrite(Nm,Vl);
 end;

begin
if Uninstall then exit;

if OptionsInit(True) then
try
 SaveDW('SampleRate',SampleRate);
 SaveDW('SampleBit',SampleBit);
 SaveDW('OutChansMono',Ord(FrmMixer.RadioButton14.Checked));
 SaveDW('OutChansList',Ord(FrmMixer.CheckBox8.Checked));
 SaveDW('BufLen_ms',BufLen_ms);
 SaveDW('NumberOfBuffers',NumberOfBuffers);
 SaveDW('Chip',Ord(not FrmMixer.RadioButton1.Checked) + 1);
 SaveDW('ChipList',Ord(FrmMixer.CheckBox2.Checked));
 SaveDW('FrqZ80',FrqZ80);
 SaveDW('FrqMC68K',trunc(MC68000Freq));
 SaveDW('FrqAY',FrmMixer.FrqAYTemp);
 SaveDW('FrqAYList',Ord(FrmMixer.CheckBox3.Checked));
 SaveDW('FrqPl',FrmMixer.FrqPlTemp);
 SaveDW('FrqPlList',Ord(FrmMixer.CheckBox9.Checked));
 SaveDW('IntOffset',IntOffset);
 SaveDW('AtariSTe',Ord(FrmMixer.STeRB.Checked));
 SaveDW('AtariYMMono',Ord(FrmMixer.AtariYMMonoChk.Checked));
 SaveDW('AtariMono',Ord(FrmMixer.AtariMonoChk.Checked));
 SaveDW('MaxTStates',MaxTStates);
 SaveDW('VisAmpls',Ord(IndicatorChecked));
 SaveDW('VisSpectrum',Ord(SpectrumChecked));
 SaveDW('VisScroll',Ord(Do_Scroll));
 SaveDW('VisPeriod',VisTimerPeriod);
 SaveStr('Lang',Lang);
 SaveDW('Loop',Ord(Do_Loop));
 SaveDW('TrayMode',TrayMode);
 SaveDW('TimeMode',TimeMode);
 SaveStr('Skin',SkinFileName);
 SaveDW('MFPTimerMode',MFPTimerMode);
 SaveDW('MFPTimerFrq',MFPTimerFrq);
 SaveDW('AutoSaveDefDir',Ord(AutoSaveDefDir));
 SaveDW('AutoSaveWindowsPos',Ord(AutoSaveWindowsPos));
 SaveDW('AutoSaveVolumePos',Ord(AutoSaveVolumePos));
 SaveDW('BeeperMax',BeeperMax);
 SaveDW('DMAMax',Atari_DMAMax);
 SaveDW('ChanAL',FrmMixer.TrackBar1.Position);
 SaveDW('ChanAR',FrmMixer.TrackBar2.Position);
 SaveDW('ChanBL',FrmMixer.TrackBar3.Position);
 SaveDW('ChanBR',FrmMixer.TrackBar4.Position);
 SaveDW('ChanCL',FrmMixer.TrackBar5.Position);
 SaveDW('ChanCR',FrmMixer.TrackBar6.Position);
 SaveDW('ChansList',Ord(FrmMixer.CheckBox1.Checked));
 SaveStr('EditorPath',VTPath);
 SaveDW('FIDO_Descriptor_Enabled',Ord(FIDO_Descriptor_Enabled));
 SaveDW('FIDO_Descriptor_KillOnExit',Ord(FIDO_Descriptor_KillOnExit));
 SaveDW('FIDO_Descriptor_KillOnNothing',Ord(FIDO_Descriptor_KillOnNothing));
 SaveStr('FIDO_Descriptor_Enc',FIDO_Descriptor_Enc);
 SaveStr('FIDO_Descriptor_FileName',FIDO_Descriptor_FileName);
 SaveStr('FIDO_Descriptor_Nothing',FIDO_Descriptor_Nothing);
 SaveStr('FIDO_Descriptor_Suffix',FIDO_Descriptor_Suffix);
 SaveStr('FIDO_Descriptor_Prefix',FIDO_Descriptor_Prefix);
 SaveStr('DefaultCodePage',CodePageDef);
 SaveDW('FilterQuality',FilterQuality);
 SaveDW('PreAmp',PreAmp);
 SaveDW('VolLinear',Ord(VolLinear));
 if AutoSaveVolumePos then
  SaveDW('Volume',VolumeCtrl);
 if AutoSaveWindowsPos then
  begin
   SaveDW('MainX',FrmMain.Left);
   SaveDW('MainY',FrmMain.Top);
   SaveDW('ListX',FrmPLst.Left);
   SaveDW('ListY',FrmPLst.Top);
   SaveDW('ListW',FrmPLst.Width);
   SaveDW('ListH',FrmPLst.Height);
   SaveDW('ListVis',Ord(FrmPLst.Visible));
   SaveDW('MixerX',FrmMixer.Left);
   SaveDW('MixerY',FrmMixer.Top);
   if ButTools.Is_On then
    begin
     ToolsY := FrmTools.Top;
     ToolsX := FrmTools.Left
    end;
   SaveDW('ToolsX',ToolsX);
   SaveDW('ToolsY',ToolsY)
  end;
 SaveDW('ListItem',PlayingItem);
 SaveDW('AppIcon',AppIconNumber);
 SaveDW('TrayIcon',TrayIconNumber);
 SaveDW('MenuIcon',MenuIconNumber);
 SaveDW('MusIcon',MusIconNumber);
 SaveDW('SkinIcon',SkinIconNumber);
 SaveDW('ListIcon',ListIconNumber);
 SaveDW('BASSIcon',BASSIconNumber);
 SaveStr('SkinDirectory',SkinDirectory);
 SaveDW('PlayListDirection',Direction);
 SaveDW('PlayListLoop',Ord(ListLooped));
 SaveDW('PLColorBkSel',PLColorBkSel);
 SaveDW('PLColorBkPl',PLColorBkPl);
 SaveDW('PLColorBk',PLColorBk);
 SaveDW('PLColorPlSel',PLColorPlSel);
 SaveDW('PLColorPl',PLColorPl);
 SaveDW('PLColorSel',PLColorSel);
 SaveDW('PLColor',PLColor);
 SaveDW('PLColorErrSel',PLColorErrSel);
 SaveDW('PLColorErr',PLColorErr);
 SaveStr('PLFontName',PLArea.Font.Name);
 SaveDW('PLFontSize',PLArea.Font.Size);
 SaveDW('PLFontBold',Ord(PLArea.Font.Bold));
 SaveDW('PLFontItalic',Ord(PLArea.Font.Italic));
 SaveDW('digsoundDevice',digsoundDevice);
 SaveStr('digsoundDeviceName',FrmMixer.cbWODevice.Items[digsoundDevice]);
{$IFDEF Windows}
 SaveDW('MIDIDevice',MIDIDevice);
 SaveStr('MIDIDeviceName',FrmMixer.cbMODevice.Items[integer(MIDIDevice) + 1]);
 SaveDW('MIDISeekToFirstNote',Ord(MIDISeekToFirstNote));
 SaveDW('Priority',Priority);
{$ENDIF Windows}
 SaveDW('BASSFFTType',BASSFFTType);
 SaveDW('BASSFFTNoWin',BASSFFTNoWin);
 SaveDW('BASSFFTRemDC',BASSFFTRemDC);
 SaveDW('BASSAmpMin',round(BASSAmpMin * 10000));
 SaveStr('BASSNetAgent',BASSNetAgent);
 SaveDW('BASSNetUseProxy',Ord(BASSNetUseProxy));
 SaveStr('BASSNetProxy',BASSNetProxy);
 SaveStr('mixerctlPath1',mixerctl_Path1);
 SaveStr('mixerctlPath2',mixerctl_Path2);
 SaveStr('mixerctlPath3',mixerctl_Path3);
 if AutoSaveDefDir then SaveDefaultDir2;
finally
 OptionsDone;
end;
end;

procedure AdjustFormOnDesktop(Frm:TForm);
var
 i:integer;
begin
//Frm.MakeFullyVisible; не годится, работает с каким-либо монитором, а не со всем рабочим столом
//подумать еще
if Frm.Left >= Screen.DesktopLeft+Screen.DesktopWidth-Frm.Width then
 begin
  i := Screen.DesktopLeft+Screen.DesktopWidth-Frm.Width; if i < Screen.DesktopLeft then i := Screen.DesktopLeft;
  Frm.Left := i;
 end
else if Frm.Left < Screen.DesktopLeft then
 Frm.Left := Screen.DesktopLeft;
if Frm.Top >= Screen.DesktopTop+Screen.DesktopHeight-Frm.Height then
 begin
  i := Screen.DesktopTop+Screen.DesktopHeight-Frm.Height; if i < Screen.DesktopTop then i := Screen.DesktopTop;
  Frm.Top := i;
 end
else if Frm.Top < Screen.DesktopTop then
 Frm.Top := Screen.DesktopTop;
end;

procedure TFrmMain.CommandLineAndRegCheck;

 function GetDW(Nm:PChar; out Vl:integer):boolean;
 var
  s:string;
 begin
 Result := OptionsRead(Nm,s) and TryStrToInt(s,Vl);
 end;

 function GetStr(Nm:PChar; var Vl:string):boolean;
 begin
 Result := OptionsRead(Nm,Vl);
 end;

var
 i,v,v1:integer;
 dir,s1,s2,s3:string;
 CanReadOptions,LangSet:boolean;
begin
ClearParams;
CanReadOptions := OptionsInit(False);
SetDefault;
FrmMixer.UpdateBuffLables; //todo упростить установку параметров
AppIconNumber := -1; SelectAppIcon(0);
LangSet := False;

try
try
if CanReadOptions then
 begin
  if GetDW('SampleRate',v) then Set_Sample_Rate2(v);
  if GetDW('SampleBit',v) then Set_Sample_Bit2(v);
  if GetDW('OutChansMono',v) then Set_Stereo2(v);
  if GetDW('OutChansList',v) then FrmMixer.CheckBox8.Checked := v <> 0;
  if GetDW('BufLen_ms',v) then Set_BufLen_ms2(v);
  if GetDW('NumberOfBuffers',v) then Set_NumberOfBuffers2(v);
  if GetDW('Chip',v) then Set_Chip2(ChTypes(v));
  if GetDW('ChipList',v) then FrmMixer.CheckBox2.Checked := v <> 0;
  if GetDW('FrqZ80',v) then Set_Z80_Frq2(v);
  if GetDW('FrqMC68K',v) then Set_MC68K_Frq2(v);
  if GetDW('FrqAY',v) then Set_Chip_Frq2(v);
  if GetDW('FrqAYList',v) then FrmMixer.CheckBox3.Checked := v <> 0;
  if GetDW('FrqPl',v) then Set_Player_Frq2(v);
  if GetDW('FrqPlList',v) then FrmMixer.CheckBox9.Checked := v <> 0;
  if GetDW('MaxTStates',v) then Set_N_Tact2(v);
  if GetDW('IntOffset',v) then Set_IntOffset2(v);
  if GetDW('AtariSTe',v) then
   begin
    FrmMixer.STRB.Checked := v = 0;
    FrmMixer.STeRB.Checked := v <> 0;
   end;
  if GetDW('AtariYMMono',v) then FrmMixer.AtariYMMonoChk.Checked := v <> 0;
  if GetDW('AtariMono',v) then FrmMixer.AtariMonoChk.Checked := v <> 0;
  if GetDW('VisAmpls',v) then IndicatorChecked := v <> 0;
  if GetDW('VisSpectrum',v) then SpectrumChecked := v <> 0;
  if GetDW('VisScroll',v) then Do_Scroll := v <> 0;
  if GetDW('VisPeriod',v) then SetVisTimerPeriod(v);
  if GetDW('FilterQuality',v) then SetFilter2(v);
  if GetStr('Lang',dir) then
   begin
    LangSet := True;
    Set_Language2(dir);
   end;
  if GetDW('Loop',v) then Set_Loop2(v <> 0);
  if GetDW('TimeMode',v) then if v in [0..2] then TimeMode := v;
  SkinDirectory := '';
  if GetStr('Skin',dir) then if dir <> '' then
   if LoadSkin(dir,False) then SkinDirectory := ExtractFileDir(dir);
  if GetStr('SkinDirectory',dir) then if dir <> '' then
   SkinDirectory := dir;
  v1 := MFPTimerMode;
  if GetDW('MFPTimerMode',v) then v1 := v;
  if v1 = 0 then
   Set_MFP_Frq2(0,0)
  else
   begin
    v1 := MFPTimerFrq;
    if GetDW('MFPTimerFrq',v) then v1 := v;
    Set_MFP_Frq2(1,v1)
   end;
  if GetDW('AutoSaveDefDir',v) then SetAutoSaveDefDir2(v <> 0);
  if GetDW('AutoSaveWindowsPos',v) then SetAutoSaveWindowsPos2(v <> 0);
  if GetDW('AutoSaveVolumePos',v) then SetAutoSaveVolumePos2(v <> 0);
  if GetDW('ChanAL',v) then SetChan2(v,0);
  if GetDW('ChanAR',v) then SetChan2(v,1);
  if GetDW('ChanBL',v) then SetChan2(v,2);
  if GetDW('ChanBR',v) then SetChan2(v,3);
  if GetDW('ChanCL',v) then SetChan2(v,4);
  if GetDW('ChanCR',v) then SetChan2(v,5);
  if GetDW('BeeperMax',v) then SetChan2(v,6);
  if GetDW('DMAMax',v) then SetChan2(v,7);
  if GetDW('PreAmp',v) then SetChan2(v,-1);
  if GetDW('ChansList',v) then FrmMixer.CheckBox1.Checked := v <> 0;
  if GetStr('EditorPath',dir) then VTPath := dir;
  if GetDW('FIDO_Descriptor_Enabled',v) then FIDO_Descriptor_Enabled := v <> 0;
  if GetDW('FIDO_Descriptor_KillOnExit',v) then FIDO_Descriptor_KillOnExit := v <> 0;
  if GetDW('FIDO_Descriptor_KillOnNothing',v) then FIDO_Descriptor_KillOnNothing := v <> 0;
  if GetStr('FIDO_Descriptor_Enc',dir) then FIDO_Descriptor_Enc := dir;
  if GetStr('FIDO_Descriptor_FileName',dir) then FIDO_Descriptor_FileName := dir;
  if GetStr('FIDO_Descriptor_Nothing',dir) then FIDO_Descriptor_Nothing := dir;
  if GetStr('FIDO_Descriptor_Suffix',dir) then FIDO_Descriptor_Suffix := dir;
  if GetStr('FIDO_Descriptor_Prefix',dir) then FIDO_Descriptor_Prefix := dir;
  if GetStr('DefaultCodePage',dir) then CodePageDef := dir;
  if GetDW('PlayListDirection',v) then if v in [0..3] then FrmPLst.SetDirection(v);
  if GetDW('PlayListLoop',v) then
   begin
    ListLooped := v <> 0;
    FrmPLst.LoopListButton.Down := ListLooped
   end;
  if GetDW('PLColorBkSel',v) then PLColorBkSel := v;
  if GetDW('PLColorBkPl',v) then PLColorBkPl := v;
  if GetDW('PLColorBk',v) then PLColorBk := v;
  if GetDW('PLColorPlSel',v) then PLColorPlSel := v;
  if GetDW('PLColorPl',v) then PLColorPl := v;
  if GetDW('PLColorSel',v) then PLColorSel := v;
  if GetDW('PLColor',v) then PLColor := v;
  if GetDW('PLColorErrSel',v) then PLColorErrSel := v;
  if GetDW('PLColorErr',v) then PLColorErr := v;
  if GetStr('PLFontName',dir) then PLArea.Font.Name := dir;
  if GetDW('PLFontSize',v) then PLArea.Font.Size := v;
  if GetDW('PLFontBold',v) then PLArea.Font.Bold := v <> 0;
  if GetDW('PLFontItalic',v) then PLArea.Font.Italic := v <> 0;
  ListLineHeight := PLArea.Canvas.TextHeight('0');

  if not GetStr('digsoundDeviceName',dir) then dir := '';
  if GetDW('digsoundDevice',v) then Set_WODevice2(v,dir);
{$IFDEF Windows}
  if not GetStr('MIDIDeviceName',dir) then dir := '';
  if GetDW('MIDIDevice',v) then Set_MIDIDevice2(v,dir);
  if GetDW('MIDISeekToFirstNote',v) then
   MIDISeekToFirstNote := v <> 0;
{$ENDIF Windows}
  if GetDW('BASSFFTType',v) then
   if (DWORD(v) >= BASS_DATA_FFT256) and (DWORD(v) <= BASS_DATA_FFT32768) then
    BASSFFTType := v;
  if GetDW('BASSFFTNoWin',v) then
   if v in [0,BASS_DATA_FFT_NOWINDOW] then
    BASSFFTNoWin := v;
  if GetDW('BASSFFTRemDC',v) then
   if v in [0,BASS_DATA_FFT_REMOVEDC] then
    BASSFFTRemDC := v;
  if GetDW('BASSAmpMin',v) then
   if (v >= 1) and (v <= 200) then
    BASSAmpMin := v / 10000;
  if GetStr('BASSNetAgent',dir) then BASSNetAgent := dir;
  if GetDW('BASSNetUseProxy',v) then
   BASSNetUseProxy := v <> 0;
  if GetStr('BASSNetProxy',dir) then BASSNetProxy := dir;

  if GetDW('VolLinear',v) then VolLinear := v <> 0;
  if not GetStr('mixerctlPath1',s1) then s1 := '';
  if not GetStr('mixerctlPath2',s2) then s2 := '';
  if not GetStr('mixerctlPath3',s3) then s3 := '';
  FrmMixer.OpenMixer(s1,s2,s3);
  if AutoSaveVolumePos then
   begin
    if GetDW('Volume',v) then
     if v < VolumeCtrlMax then
      begin
       VolumeCtrl := v;
       SetSysVolume;
      end
   end;
  {$IFDEF Windows}
  if GetDW('Priority',v) then SetPriority2(v);
  {$ENDIF Windows}
  DefaultDirectory := '';
  if GetStr('DefaultDirectory',dir) then DefaultDirectory := dir;
 end
else
 FrmMixer.OpenMixer('','','');
finally
 FrmMixer.SetMixerParams;
 if not LangSet then
  Set_Language2('');
end;
LastTimeComLine := GetTickCount - CLFast;
try
 if ParamCount <> 0 then
  CommandLineInterpreter('"' + GetCurrentDir + '" ' + GetCommandLine,True);
 for i := 0 to Length(AfterScan) - 1 do
  CommandLineInterpreter(AfterScan[i],True);
except
 ShowException(ExceptObject, ExceptAddr);
end;
AfterScan := nil;
if LocateAndTryLoadDefaultPL then
 if CanReadOptions then
  if GetDW('ListItem',v) then
   if (v >= 0) and (v < Length(PlayListItems)) then
    PlayingItem := v;
CreatePlayOrder;
CalculateTotalTime(False);
dir := ExtractFileDir(GetProcessFileName);
if DefaultDirectory = '' then DefaultDirectory := dir;
if SetCurrentDir(DefaultDirectory) then FrmMain.OpenDialog1.InitialDir := DefaultDirectory;
if CanReadOptions then
 begin
  if AutoSaveWindowsPos then
   begin
    Position := poDesigned;
    if GetDW('MainX',v) then Left := v;
    if GetDW('MainY',v) then Top := v;
    AdjustFormOnDesktop(FrmMain);
    FrmPLst.Position := poDesigned;
    if GetDW('ListX',v) then FrmPLst.Left := v;
    if GetDW('ListY',v) then FrmPLst.Top := v;
    if GetDW('ListW',v) then FrmPLst.Width := v;
    if GetDW('ListH',v) then FrmPLst.Height := v;
    AdjustFormOnDesktop(FrmPLst);
    if GetDW('ListVis',v) then if v <> 0 then
     begin
      ButList.Switch_On;
      FrmPLst.Visible := True;
     end;
    FrmMixer.Position := poDesigned;
    if GetDW('MixerX',v) then FrmMixer.Left := v;
    if GetDW('MixerY',v) then FrmMixer.Top := v;
    AdjustFormOnDesktop(FrmMixer);
    if GetDW('ToolsX',v) then ToolsX := v;
    if GetDW('ToolsY',v) then ToolsY := v;
   end;
  if GetDW('AppIcon',v) then SelectAppIcon(v);
  if GetDW('TrayIcon',v) then SelectTrayIcon(v);
  if GetDW('MenuIcon',v) then MenuIconNumber := v;
  if GetDW('MusIcon',v) then MusIconNumber := v;
  if GetDW('SkinIcon',v) then SkinIconNumber := v;
  if GetDW('ListIcon',v) then ListIconNumber := v;
  if GetDW('BASSIcon',v) then BASSIconNumber := v;
  if GetDW('TrayMode',v) then Set_TrayMode2(v);
 end;
finally
 if CanReadOptions then OptionsDone;
end;
FIDO_SaveStatus(FIDO_Nothing);
if FileAvailable then
 PlayCurrent
else
 PlayItem(PlayingOrderItem,-1);
InitialScan := True;
end;

procedure TFrmMain.SetBuffers(len,num:integer);
begin
if digsoundthread_active then exit;
if (num < 2) or (num > 10) then exit;
if (len < 5) or (len > 2000) then exit;
BufLen_ms := len;
NumberOfBuffers := num;
BufferLength := round(BufLen_ms * SampleRate / 1000);
VisPosMax := round(BufferLength * NumberOfBuffers / VisStep) + 1;
VisTickMax := VisStep * VisPosMax;
SetLength(VisPoints,VisPosMax);
end;

procedure TFrmMain.Set_WODevice2(WOD:integer;NM:string);
var
 l,j:integer;
begin
if digsoundthread_active or (WOD < 0) then exit;
l := FrmMixer.cbWODevice.Items.Count; if WOD >= l then exit;
if (NM <> '') and (FrmMixer.cbWODevice.Items[WOD] <> NM) then
 begin
  j := 1;
  while (j < l) and (FrmMixer.cbWODevice.Items[j] <> NM) do inc(j);
  if j < l then
   WOD := j
  else
   WOD := 0;
 end;
if digsoundDevice <> WOD then
 begin
  digsoundDevice := WOD;
  FrmMixer.cbWODevice.ItemIndex := WOD;
 end;
end;

{$IFDEF Windows}
procedure TFrmMain.Set_MIDIDevice2(MD:integer;NM:string);
var
 l,j:integer;
begin
if midithread_active or (MD < -1) then exit;
l := FrmMixer.cbMODevice.Items.Count; if MD >= l - 1 then exit;
if (NM <> '') and (FrmMixer.cbMODevice.Items[MD + 1] <> NM) then
 begin
  j := 0;
  while (j < l) and (FrmMixer.cbMODevice.Items[j] <> NM) do inc(j);
  if j < l then
   MD := j - 1
  else
   MD := -1;
 end;
if MIDIDevice <> DWORD(MD)  then
 begin
  MIDIDevice := MD;
  FrmMixer.cbMODevice.ItemIndex := MD + 1;
 end;
end;
{$ENDIF Windows}

procedure TFrmMain.Set_BufLen_ms2(BL:integer);
begin
 if BL <> BufLen_ms then
  begin
   SetBuffers(BL,NumberOfBuffers);
   FrmMixer.UpdateBuffLables;
  end;
end;

procedure TFrmMain.Set_NumberOfBuffers2(NB:integer);
begin
if NB <> NumberOfBuffers then
 begin
  SetBuffers(BufLen_ms,NB);
  FrmMixer.UpdateBuffLables;
 end;
end;

procedure TFrmMain.Set_Chip2(Ch:ChTypes);
begin
if (Ch <> ChType) and (Ch in [AY_Chip,YM_Chip]) then
 begin
  ChType := Ch;
  Calculate_Level_Tables2;
  FrmMixer.CheckBox5.Checked := False;
  FrmMixer.CheckBox4.Checked := False;
  case Ch of
  AY_Chip:
   begin
    FrmMixer.RadioButton1.Checked := True;
    Led_AY.State := False;
    Led_YM.State := True;
    Led_AY.Redraw(False);
    Led_YM.Redraw(False);
    if IsPlaying then
     FrmMixer.CheckBox4.Checked := True;
   end;
  YM_Chip:
   begin
    FrmMixer.RadioButton2.Checked := True;
    Led_AY.State := True;
    Led_YM.State := False;
    Led_AY.Redraw(False);
    Led_YM.Redraw(False);
    if IsPlaying then
     FrmMixer.CheckBox5.Checked := True;
   end;
  end;
 end;
end;

procedure TFrmMain.Set_IntOffset2(InO:integer);
begin
if (InO <> IntOffset) and (InO >= 0) and (InO < MaxTStates) then
 begin
  IntOffset := InO;
  FrmMixer.FTact.Text := IntToStr(InO);
 end;
end;

function TFrmMain.Get_Language:string;
begin
if Lang = '' then
 Result := GetDefaultLang
else
 Result := Lang;
end;

procedure TFrmMain.Set_Language2(const aLang:string);
begin
if Lang = aLang then exit;
Lang := aLang;
SetDefaultLang(aLang);
if ButTools.Is_On then
 begin
  if aLang = '' then
   FrmTools.LangCB.ItemIndex := 0
  else
   FrmTools.LangCB.Text := aLang;
  FrmTools.UpdateTranslation;
 end;
end;

procedure TFrmMain.Set_Loop2(Lp:boolean);
begin
if Do_Loop = Lp then exit;
Do_Loop := Lp;
case Lp of
True:ButLoop.Switch_On;
else ButLoop.Switch_Off;
end;
end;

procedure TFrmMain.Set_TrayMode2(TM:integer);
begin
if (TrayMode = TM) or (DWORD(TM) > 2) then exit;
TrayMode := TM;
if TM = 2 then
 if WindowState <> wsMinimized then TM := 0 else TM := 1;
case TM of
0:
 begin
  RemoveTrayIcon;
  AddTaskbarButton;
 end;
1:
 begin
  AddTrayIcon;
  RemoveTaskbarButton;
 end;
end;
if ButTools.Is_On then
 case TrayMode of
 0:FrmTools.RadioButton8.Checked := True;
 1:FrmTools.RadioButton9.Checked := True;
 2:FrmTools.RadioButton10.Checked := True;
end;
end;

procedure TFrmMain.Set_MFP_Frq2(Md, Fr: integer);
begin
if (Md = MFPTimerMode) and (Fr = MFPTimerFrq) then exit;
Set_MFP_Frq(Md,Fr);
FrmMixer.FrqMFPTemp := MFPTimerFrq;
FrmMixer.Set_MFPFrqs
end;

procedure TFrmMain.SetAutoSaveDefDir2(ASD:boolean);
begin
AutoSaveDefDir := ASD;
if ButTools.Is_On then FrmTools.CheckBox38.Checked := ASD
end;

procedure TFrmMain.SetAutoSaveWindowsPos2(ASW:boolean);
begin
AutoSaveWindowsPos := ASW;
if ButTools.Is_On then FrmTools.CheckBox40.Checked := ASW
end;

procedure TFrmMain.SetAutoSaveVolumePos2(ASV:boolean);
begin
AutoSaveVolumePos := ASV;
FrmMixer.CheckBox39.Checked := ASV;
end;

{$IFDEF Windows}
procedure TFrmMain.SetPriority2(NP:DWORD);
begin
if not (NP in
    [IDLE_PRIORITY_CLASS,NORMAL_PRIORITY_CLASS,HIGH_PRIORITY_CLASS]) then exit;
SetPriority(NP);
if ButTools.Is_On then
 case Priority of
 IDLE_PRIORITY_CLASS:   FrmTools.RadioButton3.Checked := True;
 NORMAL_PRIORITY_CLASS: FrmTools.RadioButton4.Checked := True;
 HIGH_PRIORITY_CLASS:   FrmTools.RadioButton5.Checked := True;
 end;
end;
{$ENDIF Windows}

procedure TFrmMain.SetChan2(u,i:integer);
begin
if DWORD(u) > 255 then exit;
with FrmMixer do
 case i of
 0:Change_Show(TrackBar1,Edit1,Edit12,u,Index_AL);
 1:Change_Show(TrackBar2,Edit2,Edit13,u,Index_AR);
 2:Change_Show(TrackBar3,Edit3,Edit14,u,Index_BL);
 3:Change_Show(TrackBar4,Edit4,Edit15,u,Index_BR);
 4:Change_Show(TrackBar5,Edit5,Edit16,u,Index_CL);
 5:Change_Show(TrackBar6,Edit6,Edit17,u,Index_CR);
 6:Change_Show2(TrackBar7,Edit20,u,BeeperMax);
 7:Change_Show2(TrackBar10,Edit34,u,Atari_DMAMax);
 -1:Change_Show2(TrackBar13,Edit30,u,PreAmp);
 end;
end;

procedure TFrmMain.CalcFiltKoefs;
const
 MaxF = 9200;
var
 i:integer;
 K,F,C,i2,Filt_M2:double;
 FKt:array of double;
 s:string;
begin
//Work range [0..MaxF)
//Range [MaxF..SampleRate / 2) is easy cut-off from 0 to -53 dB
//Cut-off range is [SampleRate / 2.. AY_Freq div 8 / 2] (-53 dB)
//for Ay_Freq = 1773400 Hz:
(*
Полезная область - 0..11083,75 Гц (10)
221675->44100 - 67 (коэффициентов)
221675->48000 - 57
221675->96000 - 20
221675->110000 - 17

Полезная область - 0..10076,14 (11)
221675->22050 - 771

Полезная область - 0..9236,46 (12)
221675->22050 - 409

Полезная область - 0..8525,96 (13)
221675->22050 - 293
*)
IsFilt := 0;
C := 22050; if SampleRate >= 44100 then
 begin
  C := SampleRate / 2;
  inc(IsFilt);
 end;
Filt_M := round(3.3/(C - MaxF) * (AY_Freq div 8));
if AY_Freq * Filt_M > 3500000 * 50 then //90% of usage for my Celeron 850 MHz
 begin
  Filt_M := round(3500000 * 50 / AY_Freq);
  IsFilt := 0;
 end;
C := Pi * (MaxF + C) / (AY_Freq div 8);
SetLength(FKt,Filt_M);
Filt_M2 := (Filt_M - 1) / 2;
K := 0;
for i := 0 to Filt_M - 1 do
 begin
  i2 := i - Filt_M2;
  if i2 = 0 then
   F := C
  else
   F := sin(C * i2) / i2 * (0.54 + 0.46 * cos(2 * Pi / Filt_M * i2));
  FKt[i] := F;
  K := K + F;
 end;
SetLength(Filt_K,Filt_M);
for i := 0 to Filt_M - 1 do
 Filt_K[i] := round(FKt[i] / K * $1000000);
s := Mes_FIR + ' (' + IntToStr(Filt_M) + ' '+Mes_PTS+')';
if IsFilt = 0 then s := s + ' + ' + LowerCase(Mes_Averager);
FrmMixer.Label13.Caption := s;
dec(Filt_M);
end;

procedure TFrmMain.SetFilter(FQ: integer);
begin
digsoundloop_catch;
try
  FilterQuality := FQ;
  if (FQ = 0) or (SampleRate >= AY_Freq div 8) then
   begin
    IsFilt := -1;
    Filt_K := nil;
    Filt_XL := nil;
    Filt_XR := nil;
    FrmMixer.Label13.Caption := Mes_Averager;
    exit;
   end;
  CalcFiltKoefs;
  SetLength(Filt_XL,Filt_M + 1);
  SetLength(Filt_XR,Filt_M + 1);
  FillChar(Filt_XL[0],(Filt_M + 1) * 4,0);
  FillChar(Filt_XR[0],(Filt_M + 1) * 4,0);
  Filt_I := 0;
finally
  digsoundloop_release;
end;
end;

procedure TFrmMain.SetFilter2(FQ: integer);
begin
if (FilterQuality = FQ) or (FQ > 6) then exit;
SetFilter(FQ);
end;

procedure TFrmMain.SaveAllParams;
var
 Tmp:boolean;
begin
try
 Tmp := FIDO_Descriptor_Enabled;
 FIDO_Descriptor_Enabled := False;
 StopAndFreeAll;
 FIDO_Descriptor_Enabled := Tmp;
 FIDO_SaveStatus(FIDO_Exit);
 FreePlayingResourses;
 SaveParams;
except
 ShowException(ExceptObject, ExceptAddr);
end;
end;

procedure TFrmMain.DoCloseActions;
var
 p,p1:PSensZone;
 pp,pp1:PMoveZone;
begin
if CloseActionsDone then exit;
IPCServer.OnMessage := nil;
CloseActionsDone := True;
SaveAllParams;
TrySaveDefaultPL;
mixerctl_close;
RemoveTrayIcon;
BmpFree;

if SensZoneRoot <> nil then
 begin
  p := SensZoneRoot;
  SensZoneRoot := nil;
  repeat
   p1 := p^.Next;
   p^.Free;
   p := p1;
  until p = nil;
 end;
if MoveZoneRoot <> nil then
 begin
  pp := MoveZoneRoot;
  MoveZoneRoot := nil;
  repeat
   pp1 := pp^.Next;
   pp^.Free;
   pp := pp1;
  until pp = nil;
 end;

DeleteObject(RgnProgr);
DeleteObject(RgnVol);
DeleteObject(RgnClose);
DeleteObject(RgnMin);
DeleteObject(RgnTools);
DeleteObject(RgnPList);
DeleteObject(RgnMixer);
DeleteObject(RgnOpen);
DeleteObject(RgnNext);
DeleteObject(RgnStop);
DeleteObject(RgnPause);
DeleteObject(RgnPlay);
DeleteObject(RgnBack);
DeleteObject(RgnLoop);
DeleteObject(MyFormRgn);

VisTimer.Free;

BMP_Scroll.Free;
BMP_VScroll.Free;
BMP_Vis.Free;
BMP_Time.Free;
BMP_Sources.Free;
BMP_DBuffer.Free;
{$IFDEF Windows}
SetPriority(NORMAL_PRIORITY_CLASS);
{$ENDIF Windows}
end;

procedure TFrmMain.HideMinimize(var Msg: TMsg);
begin
DoMinimize;
end;

procedure TFrmMain.SelectAppIcon(n:integer);
begin
if AppIconNumber = n then exit;
AppIconNumber := n;
Application.Icon.LoadFromResourceName(hInstance,Format('ICON%.2u',[n]));
end;

procedure TFrmMain.SelectTrayIcon(n:integer);
begin
if TrayIconNumber = n then exit;
TrayIconNumber := n;
TrayIcon1.Icon.LoadFromResourceName(hInstance,Format('ICON%.2u',[n]));
end;

Procedure Ay_Emul_ShowException (Msg : ShortString);
begin
ShowMessage({$IFDEF Windows}IfAnsiToUTF8({$ENDIF  Windows}Msg{$IFDEF Windows}){$ENDIF  Windows});
end;

procedure TFrmMain.Ay_Emul_ShowExceptionA(Sender : TObject; E : Exception);
begin
ShowMessage({$IFDEF Windows}IfAnsiToUTF8({$ENDIF  Windows}E.Message{$IFDEF Windows}){$ENDIF  Windows});
end;

procedure TFrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
DoCloseActions;
end;

procedure TFrmMain.AppEndSession(Sender: TObject);
begin
DoCloseActions;
end;

procedure AYVisualisation(smp:DWORD);
var
 CurVisPos:DWORD;
 T,E,A,i:integer;
 TE:boolean;
begin
VProgrPos := BaseSample + smp;
CurrTime_Rasch := trunc(VProgrPos / SampleRate * 1000);
CurVisPos := smp mod VisTickMax div VisStep;

if SpectrumChecked or IndicatorChecked then
 with VisPoints[CurVisPos] do
  begin
   if Calc = 0 then
    begin
     Calc := 1;
     for i := 0 to 1 do
      with VisPoints[CurVisPos].R[i] do
       begin
        case EnvT of
        8,12 : E := 28;
        10,14: E := 26;
        else
         begin
          E := AmpE - 1;
          if E < 0 then E := 0
         end
        end;
        T := TnA;
        if AmpA and 16 = 0 then
         AmpA := AmpA * 2
        else if not (EnvT in [8,10,12,14]) then
         AmpA := E
        else
         begin
          A := E;
          TE := Mix and 1 = 0;
          if (T <= 3) and TE then
           Dec(A,6)
          else if TE then
           A := 30;
          AmpA := A;
          if (T <= 3) or not TE then
           if EnvT in [8,12] then
            T := EnvP * 16
           else
            T := EnvP * 32;
         end;
        TnA := T;
        T := TnB;
        if AmpB and 16 = 0 then
         AmpB := AmpB * 2
        else if not (EnvT in [8,10,12,14]) then
         AmpB := E
        else
         begin
          A := E;
          TE := Mix and 2 = 0;
          if (T <= 3) and TE then
           Dec(A,6)
          else if TE then
           A := 30;
          AmpB := A;
          if (T <= 3) or not TE then
           if EnvT in [8,12] then
            T := EnvP * 16
           else
            T := EnvP * 32;
         end;
        TnB := T;
        T := TnC;
        if AmpC and 16 = 0 then
         AmpC := AmpC * 2
        else if not (EnvT in [8,10,12,14]) then
         AmpC := E
        else
         begin
          A := E;
          TE := Mix and 4 = 0;
          if (T <= 3) and TE then
           Dec(A,6)
          else if TE then
           A := 30;
          AmpC := A;
          if (T <= 3) or not TE then
           if EnvT in [8,12] then
            T := EnvP * 16
           else
            T := EnvP * 32;
         end;
        TnC := T;
        if not TSMode then break;
       end;
    end;
   T := R[0].AmpA; E := R[0].AmpB; A := R[0].AmpC;
   if TSMode then
    begin
     if R[1].AmpA > T then T := R[1].AmpA;
     if R[1].AmpB > E then E := R[1].AmpB;
     if R[1].AmpC > A then A := R[1].AmpC;
    end;
   RedrawVisChannels(T,E,A,30);
   RedrawVisSpectrum(@VisPoints[CurVisPos],31);
  end;
  ShowProgress(VProgrPos);
end;

procedure TFrmMain.WMVOLUMECHANGED(var Msg: TMsg);
begin
GetSysVolume;
end;

end.
