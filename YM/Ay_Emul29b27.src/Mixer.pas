{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit Mixer;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons;

type

  { TFrmMixer }

  TFrmMixer = class(TForm)
   AtariMonoChk: TCheckBox;
   AtariYMMonoChk: TCheckBox;
   GroupBox16: TGroupBox;
   STRB: TRadioButton;
   STeRB: TRadioButton;
   SpeedButton3: TSpeedButton;
   TSOverflowLbl: TLabel;
    CheckBox13: TCheckBox;
    Edit34: TEdit;
    Edit35: TEdit;
    Edit36: TEdit;
    GroupBox15: TGroupBox;
    Label29: TLabel;
    AYOverflowLbl: TLabel;
    ProxyChk: TCheckBox;
    ProxyE: TEdit;
    Label28: TLabel;
    NetAgentCB: TComboBox;
    GroupBox14: TGroupBox;
    Label12: TLabel;
    MixerTabSheet: TPageControl;
    AYEmuSheet: TTabSheet;
    KUsil: TGroupBox;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel2: TBevel;
    Bevel18: TBevel;
    Bevel19: TBevel;
    Bevel20: TBevel;
    Bevel17: TBevel;
    Bevel21: TBevel;
    Bevel23: TBevel;
    Bevel24: TBevel;
    Bevel22: TBevel;
    RadioButton30: TRadioButton;
    RadioButton31: TRadioButton;
    TrackBar1: TTrackBar;
    TrackBar10: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit6: TEdit;
    Edit5: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    CheckBox1: TCheckBox;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit14: TEdit;
    TrackBar7: TTrackBar;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    CheckBox2: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    CheckBox3: TCheckBox;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    Edit20: TEdit;
    GroupBox7: TGroupBox;
    RadioButton15: TRadioButton;
    Edit21: TEdit;
    RadioButton16: TRadioButton;
    Edit22: TEdit;
    CheckBox9: TCheckBox;
    Edit23: TEdit;
    RadioButton17: TRadioButton;
    Edit24: TEdit;
    GroupBox8: TGroupBox;
    RadioButton18: TRadioButton;
    RadioButton19: TRadioButton;
    RadioButton20: TRadioButton;
    Edit25: TEdit;
    Edit26: TEdit;
    Edit27: TEdit;
    GroupBox9: TGroupBox;
    RadioButton21: TRadioButton;
    RadioButton22: TRadioButton;
    RadioButton25: TRadioButton;
    Edit28: TEdit;
    Edit29: TEdit;
    Edit32: TEdit;
    DMAOverflowLbl: TLabel;
    WOSheet: TTabSheet;
    GroupBox3: TGroupBox;
    RadioButton23: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    GroupBox5: TGroupBox;
    RadioButton13: TRadioButton;
    RadioButton14: TRadioButton;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    GroupBox4: TGroupBox;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    Button1: TButton;
    RadioButton24: TRadioButton;
    RadioButton27: TRadioButton;
    Edit31: TEdit;
    SpeedButton1: TSpeedButton;
    Button2: TButton;
    SpeedButton2: TSpeedButton;
    Buff: TGroupBox;
    LbLen: TLabel;
    LbNum: TLabel;
    Label4: TLabel;
    LBTot: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TrackBar8: TTrackBar;
    TrackBar9: TTrackBar;
    GroupBox10: TGroupBox;
    cbWODevice: TComboBox;
    BASSSheet: TTabSheet;
    GroupBox11: TGroupBox;
    FFTTyp: TLabel;
    Label10: TLabel;
    TrackBar11: TTrackBar;
    TrackBar12: TTrackBar;
    Label2: TLabel;
    aminmax: TLabel;
    TrackBar13: TTrackBar;
    Edit30: TEdit;
    VolumeSheet: TTabSheet;
    Button3: TButton;
    Button4: TButton;
    Label3: TLabel;
    Edit33: TEdit;
    CheckBox10: TCheckBox;
    GroupBox12: TGroupBox;
    Label13: TLabel;
    RadioButton26: TRadioButton;
    RadioButton28: TRadioButton;
    FTact: TEdit;
    Label7: TLabel;
    CheckBox39: TCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    MOSheet: TTabSheet;
    GroupBox13: TGroupBox;
    cbMODevice: TComboBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    RadioButton29: TRadioButton;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    procedure CheckBox9Change(Sender: TObject);
    procedure Edit34EditingDone(Sender: TObject);
    procedure Edit36EditingDone(Sender: TObject);
    function OpenMixer(const Path1,Path2,Path3:string):boolean;
    procedure CheckBox13Change(Sender: TObject);
    procedure Edit11EditingDone(Sender: TObject);
    procedure Edit19EditingDone(Sender: TObject);
    procedure Edit1EditingDone(Sender: TObject);
    procedure Edit20EditingDone(Sender: TObject);
    procedure Edit22EditingDone(Sender: TObject);
    procedure Edit25EditingDone(Sender: TObject);
    procedure Edit2EditingDone(Sender: TObject);
    procedure Edit30EditingDone(Sender: TObject);
    procedure Edit31EditingDone(Sender: TObject);
    procedure Edit32EditingDone(Sender: TObject);
    procedure Edit3EditingDone(Sender: TObject);
    procedure Edit4EditingDone(Sender: TObject);
    procedure Edit5EditingDone(Sender: TObject);
    procedure Edit6EditingDone(Sender: TObject);
    procedure FTactEditingDone(Sender: TObject);
    procedure NetAgentCBChange(Sender: TObject);
    procedure ProxyChkChange(Sender: TObject);
    procedure ProxyEChange(Sender: TObject);
    procedure RadioButton30Click(Sender: TObject);
    procedure RadioButton31Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure TrackBar10Change(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure TrackBar5Change(Sender: TObject);
    procedure TrackBar6Change(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure RadioButton7Click(Sender: TObject);
    procedure Set_Frqs;
    procedure Set_Z80Frqs;
    procedure Set_MC68KFrqs;
    procedure FormHide(Sender: TObject);
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure RadioButton11Click(Sender: TObject);
    procedure RadioButton12Click(Sender: TObject);
    procedure RadioButton13Click(Sender: TObject);
    procedure RadioButton14Click(Sender: TObject);
    procedure Change_Show(TB:TTrackBar;E1,E2:TEdit;NewVal:Byte;var Ind:Byte);
    procedure RadioButton15Click(Sender: TObject);
    procedure RadioButton16Click(Sender: TObject);
    procedure Set_Pl_Frqs;
    procedure Button1Click(Sender: TObject);
    procedure SetMixerParams;
    procedure FormCreate(Sender: TObject);
    procedure RadioButton17Click(Sender: TObject);
    procedure RadioButton20Click(Sender: TObject);
    procedure Set_MFPFrqs;
    procedure RadioButton18Click(Sender: TObject);
    procedure RadioButton19Click(Sender: TObject);
    procedure RadioButton25Click(Sender: TObject);
    procedure RadioButton22Click(Sender: TObject);
    procedure RadioButton21Click(Sender: TObject);
    procedure Change_Show2(TB:TTrackBar;E1:TEdit;NewVal:byte;var Ind:byte);
    procedure TrackBar7Change(Sender: TObject);
    procedure RadioButton23Click(Sender: TObject);
    procedure RadioButton24Click(Sender: TObject);
    procedure RadioButton29Click(Sender: TObject);
    procedure SetSRs;
    procedure RadioButton27Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure UpdateBuffLables;
    procedure TrackBar8Change(Sender: TObject);
    procedure TrackBar9Change(Sender: TObject);
    procedure cbWODeviceChange(Sender: TObject);
    procedure TrackBar11Change(Sender: TObject);
    procedure TrackBar12Change(Sender: TObject);
    procedure TrackBar13Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox10Click(Sender: TObject);
    procedure RadioButton28Click(Sender: TObject);
    procedure RadioButton26Click(Sender: TObject);
    procedure CheckBox39Click(Sender: TObject);
    procedure cbMODeviceChange(Sender: TObject);
    procedure CheckBox11Click(Sender: TObject);
    procedure CheckBox12Click(Sender: TObject);
    procedure UpdateAmplFields;
  private
    { Private declarations }
  public
    { Public declarations }
    FrqAYTemp,FrqPlTemp,FrqMFPTemp:longword;
  end;

var
  FrmMixer: TFrmMixer;

implementation

uses
  MainWin, Tools, AY, Z80, basslight, basscode, digsound, digsoundcode,
  mixerctl, SelVolCtrl{$IFDEF Windows}, Midi{$ENDIF Windows}, settings, atari,
  mxhelper, Languages;

{$R *.lfm}

function TFrmMixer.OpenMixer(const Path1,Path2,Path3:string):boolean;
var
 s:string;
begin
Result := mixerctl_open(Path1,Path2,Path3,FrmMain.Handle,WM_VOLUMECHANGED) = 0;
if not Result then exit;
GetSysVolume;
mixerctl_title(s);
Edit33.Text := s;
end;

procedure TFrmMixer.Edit34EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit34.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Change_Show2(TrackBar10,Edit34,A,Atari_DMAMax)
else
 Edit34.Text := IntToStr(TrackBar10.Position);
end;

procedure TFrmMixer.CheckBox9Change(Sender: TObject);
begin
{RedrawPlaylist(ShownFrom,False); //todo intfreq from list влияет
CalculateTotalTime(False);}
end;

procedure TFrmMixer.Edit36EditingDone(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit36.Text,Fr,Err);
if Err = 0 then
 FrmMain.Set_MC68K_Frq(Fr);
Set_MC68KFrqs;
end;

procedure TFrmMixer.TrackBar1Change(Sender: TObject);
begin
FrmMain.SetChan2(TrackBar1.Position,0);
end;

procedure TFrmMixer.Edit1EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit1.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 FrmMain.SetChan2(A,0)
else
 Edit1.Text := IntToStr(TrackBar1.Position);
end;

procedure TFrmMixer.Edit19EditingDone(Sender: TObject);
begin
FrmMain.Set_N_TactS(Edit19.Text);
end;

procedure TFrmMixer.Edit11EditingDone(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit11.Text,Fr,Err);
if Err = 0 then
 begin
  FrmMain.Set_Chip_Frq(Fr);
  FrqAYTemp := AY_Freq
 end;
Set_Frqs;
end;

procedure TFrmMixer.Edit20EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit20.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Change_Show2(TrackBar7,Edit20,A,BeeperMax)
else
 Edit20.Text := IntToStr(TrackBar7.Position);
end;

procedure TFrmMixer.Edit22EditingDone(Sender: TObject);
var
 Fr:integer;
 FrReal:real;
begin
try
 FrReal:=StrToFloat(Edit22.Text);
 Fr:=round(FrReal*1000);
 FrmMain.Set_Player_Frq2(Fr);
except
 Set_Pl_Frqs;
end;
end;

procedure TFrmMixer.Edit25EditingDone(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit25.Text,Fr,Err);
if Err=0 then
 begin
  FrmMain.Set_MFP_Frq(1,Fr);
  FrqMFPTemp:=MFPTimerFrq;
 end;
Set_MFPFrqs;
end;

procedure TFrmMixer.Edit2EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit2.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 FrmMain.SetChan2(A,1)
else
 Edit2.Text := IntToStr(TrackBar2.Position);
end;

procedure TFrmMixer.Edit30EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit30.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 Change_Show2(TrackBar13,Edit30,A,PreAmp)
else
 Edit30.Text := IntToStr(TrackBar13.Position);
end;

procedure TFrmMixer.Edit31EditingDone(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit31.Text,Fr,Err);
if Err = 0 then FrmMain.Set_Sample_Rate2(Fr);
end;

procedure TFrmMixer.Edit32EditingDone(Sender: TObject);
var
 Err,Fr:integer;
begin
Val(Edit32.Text,Fr,Err);
if Err = 0 then
 FrmMain.Set_Z80_Frq(Fr);
Set_Z80Frqs;
end;

procedure TFrmMixer.Edit3EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit3.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 FrmMain.SetChan2(A,2)
else
 Edit3.Text := IntToStr(TrackBar3.Position);
end;

procedure TFrmMixer.Edit4EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit4.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 FrmMain.SetChan2(A,3)
else
 Edit4.Text := IntToStr(TrackBar4.Position);
end;

procedure TFrmMixer.Edit5EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit5.Text,A,Cde);
if (Cde = 0) and (A in [0..255]) then
 FrmMain.SetChan2(A,4)
else
 Edit5.Text := IntToStr(TrackBar5.Position);
end;

procedure TFrmMixer.Edit6EditingDone(Sender: TObject);
var
 A,Cde:integer;
begin
Val(Edit6.Text,A,Cde);
if (Cde=0)and(A in [0..255]) then
 FrmMain.SetChan2(A,5)
else
 Edit6.Text := IntToStr(TrackBar6.Position);
end;

procedure TFrmMixer.FTactEditingDone(Sender: TObject);
var
 Temp1,Temp2:integer;
begin
Val(FTact.Text,Temp1,Temp2);
if (Temp2 = 0) and (Temp1 >= 0) and (Temp1 < integer(MaxTStates)) then
 IntOffset := Temp1;
FTact.Text := IntToStr(IntOffset);
end;

procedure TFrmMixer.NetAgentCBChange(Sender: TObject);
begin
BASSNetAgent := NetAgentCB.Text;
end;

procedure TFrmMixer.ProxyChkChange(Sender: TObject);
begin
BASSNetUseProxy := ProxyChk.Checked;
FrmMixer.ProxyE.Enabled := BASSNetUseProxy;
end;

procedure TFrmMixer.ProxyEChange(Sender: TObject);
begin
BASSNetProxy := ProxyE.Text;
end;

procedure TFrmMixer.RadioButton30Click(Sender: TObject);
begin
if not RadioButton30.Checked then exit;
FrmMain.Set_MC68K_Frq(8000000);
end;

procedure TFrmMixer.RadioButton31Click(Sender: TObject);
var
 Err,Fr:integer;
begin
if not RadioButton31.Checked then exit;
Val(Edit36.Text,Fr,Err);
if Err = 0 then
 begin
  FrmMain.Set_MC68K_Frq(Fr);
  Set_MC68KFrqs;
 end;
if Visible then Edit36.SetFocus;
end;

procedure TFrmMixer.SpeedButton3Click(Sender: TObject);
var
 APoint:TPoint;
 EmChip:ChTypes;
 i:integer;
begin
APoint.x:=SpeedButton3.Width; APoint.y:=SpeedButton3.Height;
APoint := SpeedButton3.ClientToScreen(APoint);
FrmMxHlp.Left:=APoint.x; FrmMxHlp.Top:=APoint.y;
if FrmMxHlp.ShowModal = mrOk then
 begin
  i := FrmMxHlp.ChansRG.ItemIndex + 1;
  if i > 6 then
   begin
    dec(i,6);
    if i = 7 then
     i := 0;
    EmChip:=YM_Chip;
   end
  else
   EmChip:=AY_Chip;
  FrmMain.CalcModeCoefs(i,EmChip,FrmMxHlp.TSDMAChG.Checked[0],FrmMxHlp.TSDMAChG.Checked[1],
           Index_AL,Index_AR,Index_BL,Index_BR,Index_CL,Index_CR,
           BeeperMax,Atari_DMAMax);
  PreAmp := 0; //byte!
  repeat //нет смысла заранее просчитывать, проще перебирать все варианты, пока не найдем подходящий
    dec(PreAmp);
    Calculate_Level_Tables2;
    if not (AYOverflowLbl.Visible or
       (FrmMxHlp.TSDMAChG.Checked[1] and DMAOverflowLbl.Visible) or
       (FrmMxHlp.TSDMAChG.Checked[0] and TSOverflowLbl.Visible)) then
     break;
  until Preamp = 0;
  UpdateAmplFields;
 end;
end;

procedure TFrmMixer.TrackBar10Change(Sender: TObject);
begin
Change_Show2(TrackBar10,Edit34,TrackBar10.Position,Atari_DMAMax);
end;

procedure TFrmMixer.TrackBar2Change(Sender: TObject);
begin
FrmMain.SetChan2(TrackBar2.Position,1);
end;

procedure TFrmMixer.TrackBar3Change(Sender: TObject);
begin
FrmMain.SetChan2(TrackBar3.Position,2);
end;

procedure TFrmMixer.TrackBar4Change(Sender: TObject);
begin
FrmMain.SetChan2(TrackBar4.Position,3);
end;

procedure TFrmMixer.TrackBar5Change(Sender: TObject);
begin
FrmMain.SetChan2(TrackBar5.Position,4);
end;

procedure TFrmMixer.TrackBar6Change(Sender: TObject);
begin
FrmMain.SetChan2(TrackBar6.Position,5);
end;

procedure TFrmMixer.RadioButton1Click(Sender: TObject);
begin
if not RadioButton1.Checked then exit;
FrmMain.Set_Chip2(AY_Chip);
end;

procedure TFrmMixer.RadioButton2Click(Sender: TObject);
begin
if not RadioButton2.Checked then exit;
FrmMain.Set_Chip2(YM_Chip)
end;

procedure TFrmMixer.RadioButton3Click(Sender: TObject);
begin
if not RadioButton3.Checked then exit;
FrmMain.Set_Chip_Frq(1773400);
FrqAYTemp := 1773400;
end;

procedure TFrmMixer.RadioButton4Click(Sender: TObject);
begin
if not RadioButton4.Checked then exit;
FrmMain.Set_Chip_Frq(1750000);
FrqAYTemp := 1750000;
end;

procedure TFrmMixer.RadioButton5Click(Sender: TObject);
begin
if not RadioButton5.Checked then exit;
FrmMain.Set_Chip_Frq(2000000);
FrqAYTemp := 2000000;
end;

procedure TFrmMixer.RadioButton6Click(Sender: TObject);
begin
if not RadioButton6.Checked then exit;
FrmMain.Set_Chip_Frq(1000000);
FrqAYTemp := 1000000;
end;

procedure TFrmMixer.RadioButton7Click(Sender: TObject);
var
 Err,Fr:integer;
begin
if not RadioButton7.Checked then exit;
Val(Edit11.Text,Fr,Err);
if Err = 0 then
 begin
  FrmMain.Set_Chip_Frq(Fr);
  FrqAYTemp := AY_Freq;
  Set_Frqs;
 end;
if Visible then Edit11.SetFocus;
end;

procedure TFrmMixer.Set_MFPFrqs;
begin
if MFPTimerMode = 0 then
 RadioButton18.Checked := True
else 
 case FrqMFPTemp of
 2457600:RadioButton19.Checked := True;
 else begin
       Edit25.Text := IntToStr(FrqMFPTemp);
       RadioButton20.Checked := True;
      end;
 end;
end;

procedure TFrmMixer.Set_Z80Frqs;
begin
 case FrqZ80 of
 3494400:RadioButton21.Checked := True;
 3500000:RadioButton22.Checked := True;
 else begin
       Edit32.Text := IntToStr(FrqZ80);
       RadioButton25.Checked := True;
      end;
 end;
end;

procedure TFrmMixer.Set_MC68KFrqs;
begin
 if MC68000Freq = 8000000 then
  RadioButton30.Checked := True
 else
  begin
   Edit36.Text := FloatToStr(MC68000Freq);
   RadioButton31.Checked := True;
  end;
end;

procedure TFrmMixer.Set_Frqs;
begin
 case FrqAYTemp of
 1773400:RadioButton3.Checked:=true;
 1750000:RadioButton4.Checked:=true;
 2000000:RadioButton5.Checked:=true;
 1000000:RadioButton6.Checked:=true;
 else begin
       Edit11.Text:=IntToStr(FrqAYTemp);
       RadioButton7.Checked:=true;
      end;
 end;
end;

procedure TFrmMixer.Set_Pl_Frqs;
begin
 case FrqPlTemp of
 50000:RadioButton15.Checked := True;
 48828:RadioButton17.Checked := True;
 else begin
       Edit22.Text := FloatToStrF(FrqPlTemp/1000,ffFixed,7,3);
       RadioButton16.Checked := True;
      end;
 end;
end;

procedure TFrmMixer.FormHide(Sender: TObject);
begin
if ButtZoneRoot<>nil then
 if ButMixer.Is_On then
  ButMixer.Switch_Off
end;

procedure TFrmMixer.RadioButton29Click(Sender: TObject);
begin
if not RadioButton29.Checked then exit;
Set_Sample_Rate(192000);
end;

procedure TFrmMixer.RadioButton24Click(Sender: TObject);
begin
if not RadioButton24.Checked then exit;
Set_Sample_Rate(96000);
end;

procedure TFrmMixer.RadioButton23Click(Sender: TObject);
begin
if not RadioButton23.Checked then exit;
Set_Sample_Rate(48000);
end;

procedure TFrmMixer.RadioButton8Click(Sender: TObject);
begin
if not RadioButton8.Checked then exit;
Set_Sample_Rate(44100);
end;

procedure TFrmMixer.RadioButton9Click(Sender: TObject);
begin
if not RadioButton9.Checked then exit;
Set_Sample_Rate(22050);
end;

procedure TFrmMixer.RadioButton10Click(Sender: TObject);
begin
if not RadioButton10.Checked then exit;
Set_Sample_Rate(11025);
end;

procedure TFrmMixer.RadioButton11Click(Sender: TObject);
begin
if not RadioButton11.Checked then exit;
Set_Sample_Bit(16);
end;

procedure TFrmMixer.RadioButton12Click(Sender: TObject);
begin
if not RadioButton12.Checked then exit;
Set_Sample_Bit(8);
end;

procedure TFrmMixer.RadioButton13Click(Sender: TObject);
begin
if not RadioButton13.Checked then exit;
Set_Stereo(2);
end;

procedure TFrmMixer.RadioButton14Click(Sender: TObject);
begin
if not RadioButton14.Checked then exit;
Set_Stereo(1);
end;

procedure TFrmMixer.UpdateAmplFields;
begin
FrmMain.SetChan2(PreAmp,-1);
FrmMain.SetChan2(Index_AL,0);
FrmMain.SetChan2(Index_AR,1);
FrmMain.SetChan2(Index_BL,2);
FrmMain.SetChan2(Index_BR,3);
FrmMain.SetChan2(Index_CL,4);
FrmMain.SetChan2(Index_CR,5);
FrmMain.SetChan2(BeeperMax,6);
FrmMain.SetChan2(Atari_DMAMax,7);
end;

procedure TFrmMixer.Change_Show(TB:TTrackBar;E1,E2:TEdit;NewVal:byte;var Ind:byte);
begin
TB.Position:=NewVal;
E1.Text:=IntToStr(NewVal);
if IsPlaying then E2.Text:=E1.Text;
Ind := NewVal;
Calculate_Level_Tables2;
end;

procedure TFrmMixer.RadioButton15Click(Sender: TObject);
begin
if not RadioButton15.Checked then exit;
FrmMain.Set_Player_Frq2(50000);
end;

procedure TFrmMixer.RadioButton16Click(Sender: TObject);
var
 Fr:integer;
 FrReal:real;
begin
if not RadioButton16.Checked then exit;
try
 FrReal:=StrToFloat(Edit22.Text);
 Fr:=round(FrReal*1000);
 FrmMain.Set_Player_Frq2(Fr);
 if Visible then Edit22.SetFocus;
except
 Set_Pl_Frqs;
 if Visible then Edit22.SetFocus;
end;
end;

procedure TFrmMixer.Button1Click(Sender: TObject);
begin
FrmMain.SetDefault;
CheckBox1.Checked := True;
CheckBox2.Checked := True;
CheckBox3.Checked := True;
CheckBox9.Checked := True;
CheckBox8.Checked := True;
SetMixerParams;
end;

procedure TFrmMixer.SetSRs;
begin
case SampleRate of
192000:
 RadioButton29.Checked := True;
96000:
 RadioButton24.Checked := True;
48000:
 RadioButton23.Checked := True;
44100:
 RadioButton8.Checked := True;
22050:
 RadioButton9.Checked := True;
11025:
 RadioButton10.Checked := True;
else
 begin
  RadioButton27.Checked := True;
  Edit31.Text := IntToStr(SampleRate);
 end;
end;
end;

procedure TFrmMixer.SetMixerParams;
begin
FrqAYTemp := AY_Freq;
FrqPlTemp := Interrupt_Freq;
FrqMFPTemp := MFPTimerFrq;
TrackBar1.Position := Index_AL;
TrackBar2.Position := Index_AR;
TrackBar3.Position := Index_BL;
TrackBar4.Position := Index_BR;
TrackBar5.Position := Index_CL;
TrackBar6.Position := Index_CR;
TrackBar7.Position := BeeperMax;
TrackBar10.Position := Atari_DMAMax;
TrackBar13.Position := PreAmp;
Edit1.Text := IntToStr(Index_AL);
Edit2.Text := IntToStr(Index_AR);
Edit3.Text := IntToStr(Index_BL);
Edit4.Text := IntToStr(Index_BR);
Edit5.Text := IntToStr(Index_CL);
Edit6.Text := IntToStr(Index_CR);
Edit20.Text := IntToStr(BeeperMax);
Edit30.Text := IntToStr(PreAmp);
Edit19.Text := IntToStr(MaxTStates);
if ChType = AY_Chip then
 RadioButton1.Checked := True
else
 RadioButton2.Checked := True;
Set_Z80Frqs;
Set_Frqs;
Set_Pl_Frqs;
Set_MFPFrqs;
SetSRs;
case SampleBit of
16:
 RadioButton11.Checked := True;
8:
 RadioButton12.Checked := True;
end;
if NumberOfChannels = 2 then
 RadioButton13.Checked := True
else
 RadioButton14.Checked := True;
UpdateBuffLables;
cbWODevice.ItemIndex := digsoundDevice;
{$IFDEF Windows}
cbMODevice.ItemIndex := Integer(MIDIDevice) + 1;
{$ENDIF Windows}

if FilterQuality = 0 then
 RadioButton28.Checked := True
else
 RadioButton26.Checked := True;

FTact.Text := IntToStr(IntOffset);
TrackBar11.Position := BASSFFTType - BASS_DATA_FFT256;
TrackBar12.Position := round(BASSAmpMin * 10000);
CheckBox11.Checked := BASSFFTNoWin = 0;
{$IFDEF Windows}
CheckBox12.Checked := MIDISeekToFirstNote;
{$ENDIF Windows}
CheckBox13.Checked := BASSFFTRemDC = BASS_DATA_FFT_REMOVEDC;
NetAgentCB.Text := BASSNetAgent;
ProxyChk.Checked := BASSNetUseProxy;
ProxyE.Text := BASSNetProxy;
CheckBox10.Checked := VolLinear;
CheckBox39.Checked := AutoSaveVolumePos;
if IsPlaying then
 FrmMain.ShowAllParams;
end;

procedure TFrmMixer.FormCreate(Sender: TObject);
begin
Edit21.Text := FloatToStrF(50,ffFixed,7,3);
Edit24.Text := FloatToStrF(48.828,ffFixed,7,3);
digsound_getdevices(cbWODevice.Items);
{$IFDEF Windows}
MIDIEnumDevices(cbMODevice);
{$ENDIF Windows}
CheckBox10.Checked := VolLinear;
end;

procedure TFrmMixer.RadioButton17Click(Sender: TObject);
begin
if not RadioButton17.Checked then exit;
FrmMain.Set_Player_Frq2(48828);
end;

procedure TFrmMixer.RadioButton20Click(Sender: TObject);
var
 Err,Fr:integer;
begin
if not RadioButton20.Checked then exit;
Val(Edit25.Text,Fr,Err);
if Err=0 then
 begin
  FrmMain.Set_MFP_Frq(1,Fr);
  FrqMFPTemp:=MFPTimerFrq;
  Set_MFPFrqs;
 end;
if Visible then Edit25.SetFocus;
end;

procedure TFrmMixer.RadioButton18Click(Sender: TObject);
begin
if not RadioButton18.Checked then exit;
FrmMain.Set_MFP_Frq(0,0{round(AY_Freq * 16 / 13)}); //anyway recalculated in Set_MFP_Frq
FrqMFPTemp := MFPTimerFrq;
end;

procedure TFrmMixer.RadioButton19Click(Sender: TObject);
begin
if not RadioButton19.Checked then exit;
FrmMain.Set_MFP_Frq(1,2457600);
FrqMFPTemp := 2457600;
end;

procedure TFrmMixer.RadioButton25Click(Sender: TObject);
var
 Err,Fr:integer;
begin
if not RadioButton25.Checked then exit;
Val(Edit32.Text,Fr,Err);
if Err = 0 then
 begin
  FrmMain.Set_Z80_Frq(Fr);
  Set_Z80Frqs
 end;
if Visible then Edit32.SetFocus;
end;

procedure TFrmMixer.RadioButton22Click(Sender: TObject);
begin
if not RadioButton22.Checked then exit;
FrmMain.Set_Z80_Frq(3500000);
end;

procedure TFrmMixer.RadioButton21Click(Sender: TObject);
begin
if not RadioButton21.Checked then exit;
FrmMain.Set_Z80_Frq(3494400);
end;

procedure TFrmMixer.Change_Show2(TB:TTrackBar;E1:TEdit;NewVal:byte;var Ind:byte);
begin
TB.Position := NewVal;
E1.Text := IntToStr(NewVal);
Ind := NewVal;
Calculate_Level_Tables2;
end;

procedure TFrmMixer.TrackBar7Change(Sender: TObject);
begin
Change_Show2(TrackBar7,Edit20,TrackBar7.Position,BeeperMax)
end;

procedure TFrmMixer.RadioButton27Click(Sender: TObject);
var
 Err,Fr:integer;
begin
if not RadioButton27.Checked then exit;
Val(Edit31.Text,Fr,Err);
if Err = 0 then
 begin
  Set_Sample_Rate(Fr);
  SetSRs
 end;
if Visible then Edit31.SetFocus
end;

procedure TFrmMixer.SpeedButton1Click(Sender: TObject);
begin
Set_Sample_Rate(round(FrqAYTemp / 8));
SetSRs
end;

procedure TFrmMixer.Button2Click(Sender: TObject);
begin
Visible := False;
end;

procedure TFrmMixer.SpeedButton2Click(Sender: TObject);
begin
StopAndFreeAll;
end;

procedure TFrmMixer.UpdateBuffLables;
begin
FrmMixer.TrackBar8.Position := BufLen_ms;
FrmMixer.TrackBar9.Position := NumberOfBuffers;
LbNum.Caption := IntToStr(NumberOfBuffers);
LbLen.Caption := IntToStr(BufLen_ms) + ' ' + Mes_MiliSec;
LBTot.Caption := IntToStr(BufLen_ms * NumberOfBuffers) + ' ' + Mes_MiliSec;
end;

procedure TFrmMixer.TrackBar8Change(Sender: TObject);
begin
FrmMain.SetBuffers(TrackBar8.Position,NumberOfBuffers);
UpdateBuffLables;
end;

procedure TFrmMixer.TrackBar9Change(Sender: TObject);
begin
FrmMain.SetBuffers(BufLen_ms,TrackBar9.Position);
UpdateBuffLables;
end;

procedure TFrmMixer.TrackBar11Change(Sender: TObject);
begin
case TrackBar11.Position of
0:
 begin
  FFTTyp.Caption := '128';
  BASSFFTType := BASS_DATA_FFT256;
 end;
1:
 begin
  FFTTyp.Caption := '256';
  BASSFFTType := BASS_DATA_FFT512;
 end;
2:
 begin
  FFTTyp.Caption := '512';
  BASSFFTType := BASS_DATA_FFT1024;
 end;
3:
 begin
  FFTTyp.Caption := '1024';
  BASSFFTType := BASS_DATA_FFT2048;
 end;
4:
 begin
  FFTTyp.Caption := '2048';
  BASSFFTType := BASS_DATA_FFT4096;
 end;
5:
 begin
  FFTTyp.Caption := '4096';
  BASSFFTType := BASS_DATA_FFT8192;
 end;
6:
 begin
  FFTTyp.Caption := '8192';
  BASSFFTType := BASS_DATA_FFT16384;
 end;
7:
 begin
  FFTTyp.Caption := '16384';
  BASSFFTType := BASS_DATA_FFT32768;
 end;
end;
end;

procedure TFrmMixer.TrackBar12Change(Sender: TObject);
begin
BASSAmpMin := TrackBar12.Position / 10000;
aminmax.Caption := FloatToStr(BASSAmpMin);
end;

procedure TFrmMixer.TrackBar13Change(Sender: TObject);
begin
Change_Show2(TrackBar13,Edit30,TrackBar13.Position,PreAmp);
end;

procedure TFrmMixer.Button3Click(Sender: TObject);
var
 Lst:Tmixerctl_list;
 i,j,k:integer;
begin
if mixerctl_enumerate(Lst) <> 0 then exit; //todo errors
with TFrmSelVolCtrl.Create(Self) do
 try
  Caption := Mes_SelectMixerDivice;
  for i := 0 to Length(Lst) - 1 do
   ListBox1.Items.Add(Lst[i].Name);
  if ShowModal <> mrOk then exit;
  i := ListBox1.ItemIndex;
  if Length(Lst[i].SubDevice) = 0 then
   begin
    ShowMessage(Mes_NoValidDestForMixer);
    exit;
   end;
  ListBox1.Clear;
  Caption := Mes_SelectDestination;
  for j := 0 to Length(Lst[i].SubDevice) - 1 do
   ListBox1.Items.Add(Lst[i].SubDevice[j].Name);
  if ShowModal <> mrOk then exit;
  j := ListBox1.ItemIndex;
  if Length(Lst[i].SubDevice[j].SubDevice) = 0 then
   begin
    ShowMessage(Mes_NoVolumeControlsFound);
    exit;
   end;
  ListBox1.Clear;
  Caption := Mes_SelectControl;
  for k := 0 to Length(Lst[i].SubDevice[j].SubDevice) - 1 do
   ListBox1.Items.Add(Lst[i].SubDevice[j].SubDevice[k]);
  if ShowModal <> mrOk then exit;
  OpenMixer(Lst[i].Name,Lst[i].SubDevice[j].Name,
                Lst[i].SubDevice[j].SubDevice[ListBox1.ItemIndex]);
 finally
  Free;
 end;
end;

procedure TFrmMixer.Button4Click(Sender: TObject);
begin
if not OpenMixer('','','') then
 ShowMessage(Mes_SystemVolCtrlsNotDetected);
end;

procedure TFrmMixer.CheckBox10Click(Sender: TObject);
begin
VolLinear := CheckBox10.Checked;
GetSysVolume;
end;

procedure TFrmMixer.RadioButton28Click(Sender: TObject);
begin
if not RadioButton28.Checked then exit;
FrmMain.SetFilter(0);
end;

procedure TFrmMixer.RadioButton26Click(Sender: TObject);
begin
if not RadioButton26.Checked then exit;
FrmMain.SetFilter(1);
end;

procedure TFrmMixer.CheckBox39Click(Sender: TObject);
begin
AutoSaveVolumePos := CheckBox39.Checked;
end;

procedure TFrmMixer.cbWODeviceChange(Sender: TObject);
begin
digsoundDevice := cbWODevice.ItemIndex;
end;

procedure TFrmMixer.cbMODeviceChange(Sender: TObject);
begin
{$IFDEF Windows}
MIDIDevice := cbMODevice.ItemIndex - 1;
{$ENDIF Windows}
end;

procedure TFrmMixer.CheckBox11Click(Sender: TObject);
begin
if CheckBox11.Checked then
 BASSFFTNoWin := 0
else
 BASSFFTNoWin := BASS_DATA_FFT_NOWINDOW;
end;

procedure TFrmMixer.CheckBox12Click(Sender: TObject);
begin
{$IFDEF Windows}
MIDISeekToFirstNote := CheckBox12.Checked;
{$ENDIF Windows}
end;

procedure TFrmMixer.CheckBox13Change(Sender: TObject);
begin
if not CheckBox13.Checked then
 BASSFFTRemDC := 0
else
 BASSFFTRemDC := BASS_DATA_FFT_REMOVEDC;
end;

end.
