{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit Tools;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, {$IFDEF Windows}Windows, ShlObj, ComObj, ActiveX, {$ENDIF Windows}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, WinVersion, LConvEncoding, FileTypes;

const
 NOfIcons = 16;
 IconAuthors:array[0..NOfIcons] of string =
 ('Sergey Bulba','X-agon','X-agon','X-agon','X-agon','David Willis',
  'Graham Goring','Graham Goring','Graham Goring','Graham Goring',
  'bcass','bcass','Exocet','Exocet','Roman Morozov','Ivan Reshetnikov',
  'Ivan Reshetnikov');

type
    TSelIconProc = procedure(n:integer) of object;
    TIconSelector = class
    IcGrp:TGroupBox;
    IcImg:TImage;
    IconUpDown:TUpDown;
    TitLB,AuthLB,AuthName:TLabel;
    constructor Create(AOwner:TWinControl);
    destructor Destroy; override;
    procedure ShowIcon;
    procedure IconUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure UpdateTranslation(const Cap:string);
    public
    DoSelectIcon:TSelIconProc;
    end;

    { TFrmTools }

    TFrmTools = class(TForm)
    CBDefCP: TComboBox;
    CBDescCP: TComboBox;
    AllUsersChk: TCheckBox;
    CheckBox12: TCheckBox;
    LangCB: TComboBox;
    Edit9: TEdit;
    FontDialog1: TFontDialog;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    Label20: TLabel;
    PageControl1: TPageControl;
    GenTools: TTabSheet;
    GroupBox1: TGroupBox;
    CheckBox40: TCheckBox;
    GroupBox5: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    GroupBox10: TGroupBox;
    Button10: TButton;
    Button11: TButton;
    GroupBox11: TGroupBox;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    GroupBox12: TGroupBox;
    Label8: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Edit3: TEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Button12: TButton;
    Button13: TButton;
    GroupBox13: TGroupBox;
    Edit4: TEdit;
    CheckBox38: TCheckBox;
    Button14: TButton;
    FTypTools: TTabSheet;
    SearchTool: TTabSheet;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    Button2: TButton;
    DName: TEdit;
    GroupBox3: TGroupBox;
    CheckBox9: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox33: TCheckBox;
    Protokol: TMemo;
    ProgressBar1: TProgressBar;
    Button3: TButton;
    Memo1: TMemo;
    Button8: TButton;
    Button9: TButton;
    FIDOTools: TTabSheet;
    Label2: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    CheckBox29: TCheckBox;
    CheckBox41: TCheckBox;
    CheckBox42: TCheckBox;
    Button16: TButton;
    Button4: TButton;
    Button7: TButton;
    CheckBox57: TCheckBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    ColorDialog1: TColorDialog;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    ListBox4: TListBox;
    Button5: TButton;
    Button6: TButton;
    Button15: TButton;
    Button17: TButton;
    GroupBox4: TGroupBox;
    EditVTPath: TEdit;
    SpeedButton1: TSpeedButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure AllEnable;
    procedure CBDefCPChange(Sender: TObject);
    function CloseQuery:boolean;override;
    procedure Button4Click(Sender: TObject);
    procedure Edit4EditingDone(Sender: TObject);
    procedure Edit9EditingDone(Sender: TObject);
    procedure LangCBExit(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure CheckBox38Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure CheckRegistration;
    procedure FormCreate(Sender: TObject);
    procedure CheckBox40Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure SelectMenuIcon(n:integer);
    procedure SelectMusIcon(n:integer);
    procedure SelectSkinIcon(n:integer);
    procedure SelectListIcon(n:integer);
    procedure SelectBASSIcon(n:integer);
    procedure Label1Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label13Click(Sender: TObject);
    procedure Label14Click(Sender: TObject);
    procedure Label15Click(Sender: TObject);
    procedure Label16Click(Sender: TObject);
    procedure Label18Click(Sender: TObject);
    procedure Label19Click(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    function ChangePLColor(var WantedColor:TColor):boolean;
    procedure CreateIcSel(var IcSel:TIconSelector;AOwner:TWinControl;SelIconProc:TSelIconProc;x,y:integer;const IcName:string;IcNum:integer);
    procedure Button5Click(Sender: TObject);
    procedure EditVTPathChange(Sender: TObject);
    procedure UpdateTranslation;
    {$ifdef Windows}
    procedure RegisterGroup(t:TFTCategory;lb:TListBox);
    {$endif Windows}
    procedure SpeedButton1Click(Sender: TObject);
    procedure LoadLanguages;
  private
    { Private declarations }
  public
    { Public declarations }
    AppIcSel,TrayIcSel,StartIcSel,
    MusIcSel,SkinIcSel,ListIcSel,BASSIcSel:TIconSelector;
  end;

{$IFDEF Windows}
procedure SetPriority(Pr:DWORD);
{$ENDIF Windows}

var
  FrmTools: TFrmTools;
  {$IFDEF Windows}
  Priority:dword = NORMAL_PRIORITY_CLASS;
  {$ENDIF Windows}

implementation

uses
  MainWin, {Mixer, }Players, PlayList, Options, seldir, Languages
  {$IFDEF Windows}, assoc{$ENDIF Windows}, settings;

{$R *.lfm}

{$IFDEF Windows}
procedure SetPriority(Pr:DWORD);
var
 HMyProcess:HANDLE;
begin
HMyProcess := GetCurrentProcess;
SetPriorityClass(HMyProcess,Pr);
CloseHandle(HMyProcess);
Priority := Pr;
end;
{$ENDIF Windows}

procedure TFrmTools.Button2Click(Sender: TObject);
var
 s1,s2:string;
begin
s1 := Mes_SelectFolder;
if DirectoryExists(DName.Text) then
 s2 := DName.Text
else
 s2 := FrmMain.OpenDialog1.InitialDir;
if ChooseDirectory(s2,s1,False,'','') then
 DName.Text := s2;
end;

procedure TFrmTools.Button1Click(Sender: TObject);
begin
FrmMain.OpenDialog1.Filter := T_AllFiles + '|*';
FrmMain.OpenDialog1.Filter := FrmMain.OpenDialog1.Filter +
 '|SNA|*.sna|TRD, TD0, FDI, SCL|*.trd;*.scl;*.fdi;*.td0|BIN|*.bin|TAP, TZX|' +
 '*.tap;*.tzx';
if FrmMain.OpenDialog1.Execute then
 begin
  Memo1.Lines := FrmMain.OpenDialog1.Files;
  FrmMain.OpenDialog1.FileName := '';
 end;
end;

procedure TFrmTools.Button3Click(Sender: TObject);
begin
if FinderWorksNow then
 begin
  May_Quit := True;
  AllEnable;
 end
else
 begin
  Button3.Caption := Mes_Stop;
  Memo1.ReadOnly := True;
  DName.ReadOnly := True;
  Button1.Enabled := False;
  Button2.Enabled := False;
  Button4.Enabled := False;
  GroupBox1.Enabled := False;
  GroupBox3.Enabled := False;
  GroupBox5.Enabled := False;
  GroupBox6.Enabled := False;
  GroupBox10.Enabled := False;
  Protokol.Clear;
  FindModules;
 end;
end;

procedure TFrmTools.AllEnable;
begin
FinderWorksNow := False;
Button3.Caption := Mes_Begin;
Memo1.ReadOnly := False;
DName.ReadOnly := False;
Button1.Enabled := True;
Button2.Enabled := True;
Button4.Enabled := True;
GroupBox1.Enabled := True;
GroupBox3.Enabled := True;
GroupBox5.Enabled := True;
GroupBox6.Enabled := True;
GroupBox10.Enabled := True
end;

procedure TFrmTools.CBDefCPChange(Sender: TObject);
begin
CodePageDef := CBDefCP.Text;
end;

procedure TFrmTools.Button4Click(Sender: TObject);
begin
{$IFDEF Windows}
PostMessage(Handle,WM_CLOSE,0,0);
{$ELSE Windows}
Close;
{$ENDIF Windows}
end;

procedure TFrmTools.Edit4EditingDone(Sender: TObject);
var
 s:string;
begin
s := Trim(Edit4.Text);
if DirectoryExists(s) then
 FrmMain.DefaultDirectory := s;
end;

procedure TFrmTools.Edit9EditingDone(Sender: TObject);
 var
 i:integer;
begin
try
 try
  i := StrToInt(Trim(Edit9.Text));
 except
  exit;
 end;
 FrmMain.SetVisTimerPeriod(i);
finally
 Edit9.Text := IntToStr(VisTimerPeriod);
end;

end;

procedure TFrmTools.LangCBExit(Sender: TObject);
begin
if LangCB.Text = LangCB.Items[0] then
 FrmMain.Set_Language2('')
else
 FrmMain.Set_Language2(LangCB.Text);
end;

function TFrmTools.CloseQuery:boolean;
begin
Result := not FinderWorksNow;
if Result then
 begin
  if ButTools.Is_On then ButTools.Switch_Off;
  ToolsY := Top;
  ToolsX := Left;
 end;
end;

procedure TFrmTools.RadioButton3Click(Sender: TObject);
begin
if not RadioButton3.Checked then exit;
{$IFDEF Windows}
SetPriority(IDLE_PRIORITY_CLASS);
{$ELSE Windows}
NonWin;
{$ENDIF Windows}
end;

procedure TFrmTools.RadioButton4Click(Sender: TObject);
begin
if not RadioButton4.Checked then exit;
{$IFDEF Windows}
SetPriority(NORMAL_PRIORITY_CLASS);
{$ELSE Windows}
NonWin;
{$ENDIF Windows}
end;

procedure TFrmTools.RadioButton5Click(Sender: TObject);
begin
if not RadioButton5.Checked then exit;
{$IFDEF Windows}
SetPriority(HIGH_PRIORITY_CLASS);
{$ELSE Windows}
NonWin;
{$ENDIF Windows}
end;

procedure TFrmTools.Button7Click(Sender: TObject);
var
 s:string;
begin
Uninstall := True;
DeleteOptions;
DeleteDefaultPL; //todo: remove config folder
s := '';
try
 UnregisterApp(not AllUsersChk.Checked);
except
 s := ' ' + Mes_ExcRegAdm;
end;
ShowMessage(Mes_AyEmulRemoved+s+'. '+Mes_CloseBye);
end;

{$IFDEF Windows}
procedure StartMenuLink(ChangeIcon:boolean); //todo: посмотреть, есть ли что-то кроссплатформенное
var
 AnObj:IUnknown;
 ShLink:IShellLinkW;
 PFile:IPersistFile;
 StartMenuDir,MyProgramPath,ShCutPath:WideString;
 Pidl:PItemIDList;
begin
SetLength(StartMenuDir, MAX_PATH + 1);
if (SHGetSpecialFolderLocation(FrmMain.Handle, CSIDL_PROGRAMS,Pidl)
    = NOERROR) and SHGetPathFromIDListW(Pidl, PWideChar(StartMenuDir)) then
 begin
  StartMenuDir := PWideChar(StartMenuDir);
  ShCutPath := StartMenuDir + '\AY Emulator.lnk';
  if not FileExists(ShCutPath) then
   begin
    if ChangeIcon then exit;
   end
  else
   DeleteFile(ShCutPath);
  MyProgramPath := UTF8Decode(GetProcessFileName);
  AnObj := CreateComObject(CLSID_ShellLink);
  ShLink := AnObj as IShellLinkW;
  PFile := AnObj as IPersistFile;
  ShLink.SetPath(PWideChar(MyProgramPath));
  ShLink.SetWorkingDirectory(PWideChar(ExtractFileDir(MyProgramPath)));
  ShLink.SetIconLocation(PWideChar(MyProgramPath),MenuIconNumber);
  PFile.Save(PWideChar(ShCutPath), False);
 end;
end;
{$ENDIF Windows}

procedure TFrmTools.SelectMenuIcon(n:integer);
begin
if MenuIconNumber = n then exit;
MenuIconNumber := n;
{$IFDEF Windows}
StartMenuLink(True);
{$ENDIF Windows}
end;

procedure TFrmTools.Button10Click(Sender: TObject);
begin
{$IFDEF Windows}
StartMenuLink(False);
{$ELSE Windows}
NonWin;
{$ENDIF Windows}
end;

procedure TFrmTools.Button11Click(Sender: TObject);
{$IFDEF Windows}
var
 Pidl:PItemIDList;
 StartMenuDir:WideString;
begin
SetLength(StartMenuDir, MAX_PATH + 1);
if (SHGetSpecialFolderLocation(FrmMain.Handle, CSIDL_PROGRAMS,Pidl)
    = NOERROR) and SHGetPathFromIDListW(Pidl, PWideChar(StartMenuDir)) then
 begin
  StartMenuDir := PWideChar(StartMenuDir) + '\AY Emulator.lnk';
  if FileExists(StartMenuDir) then
   DeleteFile(StartMenuDir);
 end;
{$ELSE Windows}
begin
NonWin;
{$ENDIF Windows}
end;

procedure TFrmTools.RadioButton8Click(Sender: TObject);
begin
if not RadioButton8.Checked then exit;
FrmMain.Set_TrayMode2(0);
end;

procedure TFrmTools.RadioButton9Click(Sender: TObject);
begin
if not RadioButton9.Checked then exit;
FrmMain.Set_TrayMode2(1);
end;

procedure TFrmTools.RadioButton10Click(Sender: TObject);
begin
if not RadioButton10.Checked then exit;
FrmMain.Set_TrayMode2(2);
end;

procedure TFrmTools.Button12Click(Sender: TObject);
var
 tmp:integer;
 s,s1,s2:string;
begin
s := FrmMain.OpenDialog1.FileName;
s1 := FrmMain.OpenDialog1.InitialDir;
FrmMain.OpenDialog1.FileName := '';
tmp := FrmMain.OpenDialog1.FilterIndex;
FrmMain.OpenDialog1.FilterIndex := 1;
FrmMain.OpenDialog1.Options := [OfHideReadOnly,OfEnableSizing];
FrmMain.OpenDialog1.Filter := GetFilterString(GetFileType('AYS'));
if FrmMain.SkinDirectory <> '' then
 FrmMain.OpenDialog1.InitialDir := FrmMain.SkinDirectory;
if FrmMain.OpenDialog1.Execute then
 begin
  s2 := FrmMain.OpenDialog1.FileName;
  if FrmMain.LoadSkin(s2,False) then
   FrmMain.SkinDirectory := ExtractFileDir(s2);
 end;
FrmMain.OpenDialog1.InitialDir := s1;
FrmMain.OpenDialog1.FilterIndex := tmp;
FrmMain.OpenDialog1.FileName := s;
FrmMain.OpenDialog1.Options := [OfHideReadOnly,OfEnableSizing,OfAllowMultiSelect];
end;

procedure TFrmTools.Button13Click(Sender: TObject);
begin
if FrmMain.SkinFileName <> '' then
 FrmMain.LoadSkin('',False);
end;

procedure TFrmTools.CheckBox38Click(Sender: TObject);
begin
AutoSaveDefDir := CheckBox38.Checked;
end;

procedure TFrmTools.Button14Click(Sender: TObject);
begin
SaveDefaultDir3;
end;

procedure TFrmTools.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
CloseAction := caFree;
AppIcSel.Free;
TrayIcSel.Free;
StartIcSel.Free;
MusIcSel.Free;
SkinIcSel.Free;
ListIcSel.Free;
BASSIcSel.Free;
end;

procedure TFrmTools.CreateIcSel(var IcSel:TIconSelector;AOwner:TWinControl;SelIconProc:TSelIconProc;x,y:integer;const IcName:string;IcNum:integer);
begin
IcSel := TIconSelector.Create(AOwner);
with IcSel do
 begin
  DoSelectIcon := SelIconProc;
  IcGrp.Top := y;
  IcGrp.Left := x;
  UpdateTranslation(IcName);
  IconUpDown.Position := IcNum;
  ShowIcon;
 end;
end;

procedure TFrmTools.CheckRegistration;
var
 AppRegistered:boolean;
 ProgIdRegistered:array[TFTCategory]of boolean;

 function IsFileExtAndProgID(const s:string;t:TFTCategory):boolean;
 begin
 Result := False;
 if not AppRegistered then exit;
 if not ProgIdRegistered[t] then exit;
 Result := IsFileExtAssoc(s,t);
 end;

 procedure Chk(t:TFTCategory;lb:TListBox);
 var
  i:integer;
 begin
 for i := 0 to lb.Count-1 do
  lb.Selected[i] := IsFileExtAndProgID(lb.Items[i],t);
 end;

var
 fti:TFTCategory;
begin
{$IFDEF Windows}
AppRegistered := IsRegApp(GetProcessFileName);
{$ELSE Windows}
AppRegistered := False; //todo
{$ENDIF Windows}
if AppRegistered then
 for fti := Low(TFTCategory) to High(TFTCategory) do
  ProgIdRegistered[fti] := IsFileTypeReg(fti);
Chk(TFTCAudio,ListBox1);
Chk(TFTCBASS,ListBox2);
Chk(TFTCPlaylist,ListBox3);
Chk(TFTCSkin,ListBox4);
end;

procedure TFrmTools.FormCreate(Sender: TObject);
begin
if ToolsX <> MaxInt then
 begin
  Top := ToolsY;
  Left := ToolsX;
  AdjustFormOnDesktop(Self);
 end
else
 Position := poScreenCenter;

CreateIcSel(AppIcSel,GenTools,@FrmMain.SelectAppIcon,213,247,Tit_AppIcon,AppIconNumber);
CreateIcSel(TrayIcSel,GenTools,@FrmMain.SelectTrayIcon,111,247,Tit_TrayIcon,TrayIconNumber);
CreateIcSel(StartIcSel,GenTools,@SelectMenuIcon,9,247,Tit_StartMenuIcon,MenuIconNumber);
CreateIcSel(MusIcSel,FTypTools,@SelectMusIcon,ListBox1.Left-104,ListBox1.Top,Tit_MusicIcon,MusIconNumber);
CreateIcSel(SkinIcSel,FTypTools,@SelectSkinIcon,ListBox4.Left-104,ListBox4.Top,Tit_SkinIcon,SkinIconNumber);
CreateIcSel(ListIcSel,FTypTools,@SelectListIcon,ListBox3.Left-104,ListBox3.Top,Tit_PlaylistIcon,ListIconNumber);
CreateIcSel(BASSIcSel,FTypTools,@SelectBASSIcon,ListBox2.Left-104,ListBox2.Top,Tit_BASSIcon,BASSIconNumber);

ListBox1.ControlStyle := ListBox1.ControlStyle - [csDoubleClicks];
ListBox2.ControlStyle := ListBox2.ControlStyle - [csDoubleClicks];
ListBox3.ControlStyle := ListBox3.ControlStyle - [csDoubleClicks];
ListBox4.ControlStyle := ListBox4.ControlStyle - [csDoubleClicks];

GetFNExtsCat(ListBox1.Items,ListBox2.Items,ListBox3.Items,ListBox4.Items);

try
 CheckRegistration;
except
end;

EditVTPath.Text := VTPath;
Edit1.Text := FrmMain.SkinAuthor;
Edit2.Text := FrmMain.SkinComment;
Edit3.Text := FrmMain.SkinFileName;
Edit4.Text := FrmMain.DefaultDirectory;
CheckBox38.Checked := AutoSaveDefDir;
CheckBox40.Checked := AutoSaveWindowsPos;
DName.Text := IncludeTrailingPathDelimiter(FrmMain.OpenDialog1.InitialDir) + 'AYFinderTmp';
{$IFDEF Windows}
case Priority of
IDLE_PRIORITY_CLASS:RadioButton3.Checked:=True;
NORMAL_PRIORITY_CLASS:RadioButton4.Checked:=True;
HIGH_PRIORITY_CLASS:RadioButton5.Checked:=True;
end;
{$ENDIF Windows}
case TrayMode of
0:RadioButton8.Checked:=True;
1:RadioButton9.Checked:=True;
2:RadioButton10.Checked:=True;
end;
CheckBox29.Checked := FIDO_Descriptor_Enabled;
CheckBox42.Checked := FIDO_Descriptor_KillOnNothing;
CheckBox41.Checked := FIDO_Descriptor_KillOnExit;
Edit6.Text := FIDO_Descriptor_Prefix;
Edit7.Text := FIDO_Descriptor_Suffix;
Edit8.Text := FIDO_Descriptor_Nothing;
Edit5.Text := FIDO_Descriptor_Filename;
Label1.Color := PLColorBk;
Label1.Font.Color := PLColor;
Label12.Color := PLColorBk;
Label12.Font.Color := PLColor;
Label13.Color := PLColorBkSel;
Label13.Font.Color := PLColorSel;
Label14.Color := PLColorBkSel;
Label14.Font.Color := PLColorSel;
Label15.Color := PLColorBkPl;
Label15.Font.Color := PLColorPl;
Label16.Color := PLColorBkPl;
Label16.Font.Color := PLColorPl;
Label17.Color := PLColorBkSel;
Label17.Font.Color := PLColorPlSel;
Label18.Color := PLColorBk;
Label18.Font.Color := PLColorErr;
Label19.Color := PLColorBkSel;
Label19.Font.Color := PLColorErrSel;

Edit9.Text:=IntToStr(VisTimerPeriod);

GetSupportedEncodings(CBDefCP.Items);
CBDefCP.Text:=CodePageDef;

GetSupportedEncodings(CBDescCP.Items);
CBDescCP.Text:=FIDO_Descriptor_Enc;

LoadLanguages;
end;

procedure TFrmTools.CheckBox40Click(Sender: TObject);
begin
AutoSaveWindowsPos := CheckBox40.Checked;
end;

procedure TFrmTools.Button16Click(Sender: TObject);
begin
with FrmMain do
 begin
  FIDO_Descriptor_Enabled := CheckBox29.Checked;
  FIDO_Descriptor_KillOnNothing := CheckBox42.Checked;
  FIDO_Descriptor_KillOnExit := CheckBox41.Checked;
  FIDO_Descriptor_Enc := CBDescCP.Text;
  FIDO_Descriptor_Prefix := Edit6.Text;
  FIDO_Descriptor_Suffix := Edit7.Text;
  FIDO_Descriptor_Nothing := Edit8.Text;
  FIDO_Descriptor_Filename := Edit5.Text;
  FIDO_Descriptor_String := '';
  if IsPlaying and not Paused then
   FIDO_SaveStatus(FIDO_Playing)
  else
   FIDO_SaveStatus(FIDO_Nothing);
 end;
end;

procedure TIconSelector.ShowIcon;
var
  icon:TIcon;
begin
icon := TIcon.Create;
icon.LoadFromResourceName(hInstance,Format('ICON%.2u',[IconUpDown.Position]));

IcImg.Canvas.FillRect(IcImg.ClientRect);
IcImg.Canvas.Draw(0,0,icon);

AuthName.Caption := IconAuthors[IconUpDown.Position];

icon.Free;
end;

procedure TIconSelector.IconUpDownClick(Sender: TObject; Button: TUDBtnType);
begin
ShowIcon;
DoSelectIcon(IconUpDown.Position);
end;

procedure TIconSelector.UpdateTranslation(const Cap:string);
begin
IcGrp.Caption := Tit_Icon;
AuthLB.Caption := Tit_Author;
TitLB.Caption := Cap;
end;

constructor TIconSelector.Create(AOwner:TWinControl);
begin
inherited Create;
IcGrp := TGroupBox.Create(AOwner);
IcGrp.Width := 97;
IcGrp.Height := 81+16;
IcImg := TImage.Create(IcGrp);
IcImg.Parent := IcGrp;
IcImg.Width := 32;
IcImg.Height := 32;
IcImg.Top := 1+16;
IcImg.Left := 24;
IconUpDown := TUpDown.Create(IcGrp);
IconUpDown.Parent := IcGrp;
IconUpDown.Height := 32;
IconUpDown.Top := 1+16;
IconUpDown.Left := 56;
IconUpDown.Max := NOfIcons;
IconUpDown.OnClick := @IconUpDownClick;
TitLB := TLabel.Create(IcGrp);
TitLB.Parent := IcGrp;
TitLB.AutoSize:=False;
TitLB.Alignment:=taCenter;
TitLB.Left := 1;
TitLB.Top := 1;
TitLB.Width:=IcGrp.Width-5;
AuthLB := TLabel.Create(IcGrp);
AuthLB.Parent := IcGrp;
AuthLB.AutoSize:=False;
AuthLB.Alignment:=taCenter;
AuthLB.Left := 1;
AuthLB.Top := 33+16;
AuthLB.Width:=IcGrp.Width-5;
AuthName := TLabel.Create(IcGrp);
AuthName.Parent := IcGrp;
AuthName.Alignment := taCenter;
AuthName.AutoSize := False;
AuthName.Left := 1;
AuthName.Top := 49+16;
AuthName.Width := IcGrp.Width-5;
IcGrp.Parent := AOwner;
end;

destructor TIconSelector.Destroy;
begin
try
 TitLB.Free;
 AuthName.Free;
 AuthLB.Free;
 IconUpDown.Free;
 IcImg.Free;
 IcGrp.Free;
finally
 inherited;
end;
end;

procedure TFrmTools.UpdateTranslation;
begin
AppIcSel.UpdateTranslation(Tit_AppIcon);
TrayIcSel.UpdateTranslation(Tit_TrayIcon);
StartIcSel.UpdateTranslation(Tit_StartMenuIcon);
MusIcSel.UpdateTranslation(Tit_MusicIcon);
SkinIcSel.UpdateTranslation(Tit_SkinIcon);
ListIcSel.UpdateTranslation(Tit_PlaylistIcon);
BASSIcSel.UpdateTranslation(Tit_BASSIcon);
end;

{$ifdef Windows}
procedure TFrmTools.RegisterGroup(t:TFTCategory;lb:TListBox);
var
 i:integer;
begin
FileTypeReg(not AllUsersChk.Checked,t);
for i := 0 to lb.Count - 1 do
 FileExtAssoc(not AllUsersChk.Checked,lb.Items[i],t,lb.Selected[i]);
end;
{$endif Windows}

procedure TFrmTools.Button8Click(Sender: TObject);
begin
Screen.Cursor := crHourGlass;
try
  {$ifndef Windows}
  WriteIconsAsPNG(not AllUsersChk.Checked);
  MimeTypesReg(not AllUsersChk.Checked);
  {$endif Windows}
  AppReg(not AllUsersChk.Checked);
  {$ifdef Windows}
  RegisterGroup(TFTCAudio,ListBox1);
  RegisterGroup(TFTCBASS,ListBox2);
  RegisterGroup(TFTCPlaylist,ListBox3);
  RegisterGroup(TFTCSkin,ListBox4);
  AssocChanged;
  {$endif Windows}
finally
  Screen.Cursor := crDefault;
end;
CheckRegistration;
end;

procedure TFrmTools.Button9Click(Sender: TObject);
begin
Screen.Cursor := crHourGlass;
try
  UnregisterApp(not AllUsersChk.Checked);
  {$ifndef Windows}
  DeleteMimeTypes(not AllUsersChk.Checked);
  DeleteIcons(not AllUsersChk.Checked);
  {$endif Windows}
finally
  Screen.Cursor := crDefault;
end;
CheckRegistration;
end;

procedure TFrmTools.SelectMusIcon(n:integer);
begin
if MusIconNumber <> n then
 MusIconNumber := n;
end;

procedure TFrmTools.SelectSkinIcon(n:integer);
begin
if SkinIconNumber <> n then
 SkinIconNumber := n;
end;

procedure TFrmTools.SelectListIcon(n:integer);
begin
if ListIconNumber <> n then
 ListIconNumber := n;
end;

procedure TFrmTools.SelectBASSIcon(n:integer);
begin
if BASSIconNumber <> n then
 BASSIconNumber := n;
end;

function TFrmTools.ChangePLColor(var WantedColor:TColor):boolean;
begin
ColorDialog1.Color := WantedColor;
Result := ColorDialog1.Execute;
if Result then
 begin
  WantedColor := ColorDialog1.Color;
  RedrawPlaylist(ShownFrom,False);
 end;
end;

procedure TFrmTools.Label1Click(Sender: TObject);
begin
if ChangePLColor(PLColor) then
 begin
  Label1.Font.Color := PLColor;
  Label12.Font.Color := PLColor
 end
end;

procedure TFrmTools.Label12Click(Sender: TObject);
begin
if ChangePLColor(PLColorBk) then
 begin
  Label1.Color := PLColorBk;
  Label12.Color := PLColorBk;
  Label18.Color := PLColorBk
 end
end;

procedure TFrmTools.Label13Click(Sender: TObject);
begin
if ChangePLColor(PLColorSel) then
 begin
  Label13.Font.Color := PLColorSel;
  Label14.Font.Color := PLColorSel
 end
end;

procedure TFrmTools.Label14Click(Sender: TObject);
begin
if ChangePLColor(PLColorBkSel) then
 begin
  Label13.Color := PLColorBkSel;
  Label14.Color := PLColorBkSel;
  Label17.Color := PLColorBkSel;
  Label19.Color := PLColorBkSel;
 end;
end;

procedure TFrmTools.Label15Click(Sender: TObject);
begin
if ChangePLColor(PLColorPl) then
 begin
  Label15.Font.Color := PLColorPl;
  Label16.Font.Color := PLColorPl;
 end;
end;

procedure TFrmTools.Label16Click(Sender: TObject);
begin
if ChangePLColor(PLColorBkPl) then
 begin
  Label15.Color := PLColorBkPl;
  Label16.Color := PLColorBkPl;
 end;
end;

procedure TFrmTools.Label17Click(Sender: TObject);
begin
if ChangePLColor(PLColorPlSel) then Label17.Font.Color := PLColorPlSel;
end;

procedure TFrmTools.Label18Click(Sender: TObject);
begin
if ChangePLColor(PLColorErr) then Label18.Font.Color := PLColorErr;
end;

procedure TFrmTools.Label19Click(Sender: TObject);
begin
if ChangePLColor(PLColorErrSel) then Label19.Font.Color := PLColorErrSel;
end;

procedure TFrmTools.Button5Click(Sender: TObject);
var
 lb:TListBox;
 i:integer;
begin
case (Sender as TButton).Tag of
0:lb := ListBox1;
1:lb := ListBox2;
2:lb := ListBox3;
3:lb := ListBox4;
else exit;
end;
if lb.SelCount < lb.Count then
 lb.SelectAll
else
 for i := 0 to lb.Count - 1 do
  lb.Selected[i] := False;
end;

procedure TFrmTools.EditVTPathChange(Sender: TObject);
begin
VTPath := EditVTPath.Text;
end;

procedure TFrmTools.SpeedButton1Click(Sender: TObject);
begin
FontDialog1.Font := PLArea.Font;
if FontDialog1.Execute then
 begin
  PLArea.Font := FontDialog1.Font;
  ListLineHeight := PLArea.Canvas.TextHeight('0');
 end;
end;

procedure TFrmTools.LoadLanguages;
var
 SearchRec: TSearchRec;
 i,j:integer;
 Dir,s:string;
 unique:boolean;
begin
LangCB.Clear;
LangCB.Items.Append('auto/en');
LangCB.Items.Append('en');
Dir := IncludeTrailingBackslash(ExtractFilePath(GetProcessFileName)) +
        'languages' + DirectorySeparator;
if not DirectoryExists(Dir,False{todo: fpc bug: FP can't expand relative links}) then exit;
i := FindFirst(Dir + '*.po',faAnyFile,SearchRec);
while i = 0 do
 begin
   if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    if SearchRec.Attr and faDirectory = 0 then
     if SearchRec.Size > 0 then
      begin
       i := Length(SearchRec.Name)-3;
       s := Copy(SearchRec.Name,1,i);
       while (i > 0) and (s[i] <> '.') do
        dec(i);
       if i > 0 then
        begin
         s := Copy(s,i+1,Length(s));
         unique := True;
         for j := 1 to LangCB.Items.Count-1 do
          if LangCB.Items[j] = s then
           begin
            unique := False;
            break;
           end;
         if unique then
          LangCB.Items.Append(s);
        end;
      end;
  i := FindNext(SearchRec);
 end;
FindClose(SearchRec);
if Lang = '' then
 LangCB.ItemIndex := 0
else
 LangCB.Text := Lang;
end;

end.
