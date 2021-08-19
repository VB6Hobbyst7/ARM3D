{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit About;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, {$IFDEF Windows}Windows,{$ENDIF Windows}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, LH5;

type

  { TAboutBox }

  TAboutBox = class(TForm)
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    {$IFNDEF Windows}
    procedure DoSetRgn(Sender: TObject);
    {$ENDIF Windows}
    procedure FormShow(Sender: TObject);
    procedure Push(Bt:integer;DoPush:boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
//{$IFNDEF Windows}
//    function PtOnBut(Bt,X,Y:integer):boolean;
//{$ENDIF Windows}
  private
    { Private declarations }
  public
    { Public declarations }
    AbFormRgn:HRGN;
    AbDBuffer:TBitmap;
    OKClicked,HlpClicked:boolean;
    But:array[0..1] of record
      Pushed:boolean;
      PushedBmp,UnPushedBmp:TBitmap;
      x1,y1,x2,y2:integer;
     end;
  end;

implementation

uses
  MainWin, UniReader;

{$R *.lfm}

var
{$IFDEF Windows}
  PrevWndProc: WNDPROC;
{$ENDIF Windows}
  AbOkRgn,AbHlpRgn:HRGN;

{$IFDEF Windows}
function WndCallback(Ahwnd: HWND; uMsg: UINT; wParam: WParam; lParam: LParam):LRESULT; stdcall;
var
 r:_RECT;
begin
 case uMsg of
 WM_NCHITTEST:
  begin
   if GetWindowRect(Ahwnd,r) and not PtInRegion(AbOkRgn,GET_X_LPARAM(lParam) - r.Left,GET_Y_LPARAM(lParam) - r.Top)
      and not PtInRegion(AbHlpRgn,smallint(LOWORD(lParam)) - r.Left,smallint(HIWORD(lParam)) - r.Top) then
    Result := HTCAPTION
   else
    Result := DefWindowProc(Ahwnd,uMsg,wParam,lParam);
   exit;
  end;
 end;
 Result:=CallWindowProc(PrevWndProc,Ahwnd, uMsg, WParam, LParam);
end;
{$ENDIF Windows}

procedure TAboutBox.FormCreate(Sender: TObject);

 procedure AddRoundRectRgn(a,b,c,d,e,f,op:integer);
 var
  r:HRGN;
 begin
  r := CreateRoundRectRgn(a,b,c,d,e,f);
  CombineRgn(AbFormRgn,AbFormRgn,r,op);
  DeleteObject(r)
 end;

 procedure AddRectRgn(a,b,c,d,op:integer);
 var
  r:HRGN;
 begin
  r := CreateRectRgn(a,b,c,d);
  CombineRgn(AbFormRgn,AbFormRgn,r,op);
  DeleteObject(r)
 end;

 procedure AddRoundRectRgnH(a,b,c,d,e,f,op:integer);
 var
  r:HRGN;
 begin
  r := CreateRoundRectRgn(a,b,c,d,e,f);
  CombineRgn(AbHlpRgn,AbHlpRgn,r,op);
  DeleteObject(r);
 end;

 procedure AddRectRgnH(a,b,c,d,op:integer);
 var
  r:HRGN;
 begin
  r := CreateRectRgn(a,b,c,d);
  CombineRgn(AbHlpRgn,AbHlpRgn,r,op);
  DeleteObject(r);
 end;

var
 Bitmap:TBitmap;
 URHandle:integer;
 Stream:TStream;
 pic:pointer;
 rs:TResourceStream;
begin
AbFormRgn := CreateRectRgn(18,12,315,347);
AddRoundRectRgn(40-1,285+5,183+3,344+2,183+4-40,344-285-3,RGN_DIFF);
AddRectRgn(293,340,320,347,RGN_DIFF);
AddRoundRectRgn(287,314,320,347,33,33,RGN_OR);
AddRoundRectRgn(216,329-2,300,355-2,300-216,355-329,RGN_DIFF);
AddRectRgn(180,303,233,347,RGN_DIFF);
AddRectRgn(18,315,180,347,RGN_DIFF);
AddRoundRectRgn(-3,206,38,281,38+3,281-206,RGN_DIFF);
AddRoundRectRgn(-1,167,30,191,30+1,191-167,RGN_DIFF);
AddRoundRectRgn(-3,128,28,152,30+1,191-167,RGN_DIFF);
AddRoundRectRgn(-4-11,54,50-11,114,50+4,114-54,RGN_DIFF);
AddRectRgn(18,12,23,14,RGN_DIFF);
AddRoundRectRgn(1,12,64,58,64-1,58-12,RGN_OR);
AddRoundRectRgn(12,112,30,130,30-12,132-114,RGN_OR);
AddRoundRectRgn(12,151,30,169,30-12,132-114,RGN_OR);
AddRoundRectRgn(12,189,30,207,30-12,132-114,RGN_OR);
AddRectRgn(18,280,45,315,RGN_DIFF);
AddRoundRectRgn(16,274,52,310,52-16,311-275,RGN_OR);
AddRoundRectRgn(293+4,243,342+4,320,346-293,320-242,RGN_DIFF);
AddRoundRectRgn(306,205,336,229,336-306,229-205,RGN_DIFF);
AddRoundRectRgn(308,166,338,190,336-306,229-205,RGN_DIFF);
AddRoundRectRgn(306,150,324,168,30-12,168-150,RGN_OR);
AddRoundRectRgn(306,189,324,206,30-12,206-189,RGN_OR);
AddRoundRectRgn(306,228,324,245,30-12,245-228,RGN_OR);
AddRoundRectRgn(295,29,344,150,344-295,150-29,RGN_DIFF);
AddRectRgn(294,81,300,97,RGN_DIFF);
AbHlpRgn := CreateRoundRectRgn(243,0,343,70,344-244,70-0);
AddRectRgnH(243,43,343,71,RGN_DIFF);
AddRoundRectRgnH(243,3,343,66,343-243,66-3,RGN_OR);
AddRoundRectRgnH(280,27,297,45,17,17,RGN_DIFF);
AddRoundRectRgnH(277,38,292,54,15,16,RGN_DIFF);
AddRoundRectRgnH(270,50,286,66,15,16,RGN_DIFF);
AddRoundRectRgnH(280,54,308,82,28,28,RGN_OR);
AddRectRgnH(306,62,314,70,RGN_OR);
AddRoundRectRgnH(309,64,319,73,314-306,74-65,RGN_DIFF);
AddRectRgnH(262,150,291,307,RGN_OR);
AddRoundRectRgnH(269,95,316,143,317-270,143-95,RGN_OR);
AbOkRgn := CreateRoundRectRgn(176,250,259,332,260-177,334-252);
CombineRgn(AbFormRgn,AbFormRgn,AbOkRgn,RGN_OR);
CombineRgn(AbFormRgn,AbFormRgn,AbHlpRgn,RGN_OR);

Bitmap:=TBitmap.Create;
rs := TResourceStream.Create(HInstance,'ABOUTSCREEN',RT_RCDATA);
UniReadInit(URHandle,URMemory,'',rs.Memory,rs.Size);
Compressed_Size := rs.Size - 4;
pic := nil;
try
  try
   UniRead(URHandle,@Original_Size,4);
   UniAddDepacker(URHandle,UDLZH);
   GetMem(pic,Original_Size);
   UniRead(URHandle,pic,Original_Size)
  finally
   UniReadClose(URHandle);
  end;
  Stream := TMemoryStream.Create;
  Stream.Write(pic^,Original_Size);
  Stream.Position := 0;
  Bitmap.LoadFromStream(Stream);
  Stream.Free;
  AbDBuffer := TBitmap.Create;
  AbDBuffer.Width := 343;
  AbDBuffer.Height := 348;
  AbDBuffer.Canvas.CopyRect(Rect(0,0,343,347),Bitmap.Canvas,Rect(1,2,344,349));
  AbDBuffer.Canvas.Font := Font;
  But[0].UnPushedBmp := TBitmap.Create;
  But[0].UnPushedBmp.Width:=83;
  But[0].UnPushedBmp.Height:=82;
  But[0].UnPushedBmp.Canvas.
          CopyRect(Rect(0,0,83,82),Bitmap.Canvas,Rect(177,252,260,334));
  But[0].PushedBmp := TBitmap.Create;
  But[0].PushedBmp.Width:=83;
  But[0].PushedBmp.Height:=82;
  But[0].PushedBmp.Canvas.
          CopyRect(Rect(0,0,83,82),Bitmap.Canvas,Rect(323,252,406,334));
  But[0].x1 := 176;
  But[0].y1 := 250;
  But[0].x2 := 259;
  But[0].y2 := 332;
  But[1].UnPushedBmp := TBitmap.Create;
  But[1].UnPushedBmp.Width:=100;
  But[1].UnPushedBmp.Height:=142;
  But[1].UnPushedBmp.Canvas.
          CopyRect(Rect(0,0,100,142),Bitmap.Canvas,Rect(244,2,344,144));
  But[1].PushedBmp := TBitmap.Create;
  But[1].PushedBmp.Width:=100;
  But[1].PushedBmp.Height:=142;
  But[1].PushedBmp.Canvas.
          CopyRect(Rect(0,0,100,142),Bitmap.Canvas,Rect(345,2,445,144));
  But[1].x1 := 243;
  But[1].y1 := 0;
  But[1].x2 := 343;
  But[1].y2 := 142;
  Bitmap.Free;
  But[0].Pushed:=False;
  But[1].Pushed:=False;
  OKClicked := False;
  HlpClicked := False;
finally
  if pic <> nil then FreeMem(pic);
  rs.Free;
end;
end;

procedure TAboutBox.FormDestroy(Sender: TObject);
begin
DeleteObject(AbFormRgn);
DeleteObject(AbOkRgn);
DeleteObject(AbHlpRgn);
But[0].PushedBmp.Free;
But[0].UnPushedBmp.Free;
But[1].PushedBmp.Free;
But[1].UnPushedBmp.Free;
AbDBuffer.Free;
end;

procedure TAboutBox.FormPaint(Sender: TObject);
begin
Canvas.CopyMode:=cmSrcCopy;
Canvas.CopyRect(Rect(0,0,AbDBuffer.Width,AbDBuffer.Height),AbDBuffer.Canvas,Rect(0,0,AbDBuffer.Width,AbDBuffer.Height));
end;

procedure TAboutBox.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Shift <> [ssLeft] then exit;
//{$IFDEF Windows}
if PtInRegion(AbOkRgn,X,Y) then
//{$ELSE Windows}
//if PtOnBut(0,X,Y) then
//{$ENDIF Windows}
 begin
  Push(0,True);
  OKClicked := True;
  HlpClicked := False;
 end
//{$IFDEF Windows}
else if PtInRegion(AbHlpRgn,X,Y) then
//{$ELSE Windows}
//else if PtOnBut(1,X,Y) then
//{$ENDIF Windows}
 begin
  Push(1,True);
  OKClicked := False;
  HlpClicked := True;
 end
else
 begin
{$IFNDEF Windows}
//  BeginAutoDrag;
  BeginDrag(False);
{$ENDIF Windows}
  OKClicked := False;
  HlpClicked := False;
 end;
end;

procedure TAboutBox.Push(Bt:integer;DoPush:boolean);
begin
with But[Bt] do
 begin
  if DoPush = Pushed then exit;
  if DoPush then
   AbDBuffer.Canvas.CopyRect(Rect(x1,y1,x2,y2),PushedBmp.Canvas,Rect(0,0,x2-x1,y2-y1))
  else
   AbDBuffer.Canvas.CopyRect(Rect(x1,y1,x2,y2),UnPushedBmp.Canvas,Rect(0,0,x2-x1,y2-y1));
  Pushed := DoPush;
  Canvas.CopyRect(Rect(x1,y1,x2,y2),AbDBuffer.Canvas,Rect(x1,y1,x2,y2));
 end;
end;

procedure TAboutBox.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if Shift <> [ssLeft] then exit;
if OKClicked then
 begin
//{$IFDEF Windows}
  if PtInRegion(AbOkRgn,X,Y) then
//{$ELSE Windows}
//  if PtOnBut(0,X,Y) then
//{$ENDIF Windows}
   Push(0,True)
  else
   Push(0,False);
 end
else if HlpClicked then
 begin
//{$IFDEF Windows}
  if PtInRegion(AbHlpRgn,X,Y) then
//{$ELSE Windows}
//  if PtOnBut(1,X,Y) then
//{$ENDIF Windows}
   Push(1,True)
  else
   Push(1,False);
 end;
end;

procedure TAboutBox.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if OKClicked and
//{$IFDEF Windows}
 PtInRegion(AbOkRgn,X,Y) then
//{$ELSE Windows}
// PtOnBut(0,X,Y) then
//{$ENDIF Windows}
  Close
else if HlpClicked and
//{$IFDEF Windows}
 PtInRegion(AbHlpRgn,X,Y) then
//{$ELSE Windows}
// PtOnBut(1,X,Y) then
//{$ENDIF Windows}
 begin
  Push(1,False);
  FrmMain.CallHelp;
 end;
OKClicked := False;
HlpClicked := False;
end;

{$IFNDEF Windows} //GTK can set region after OnShow only :(
procedure TAboutBox.DoSetRgn(Sender: TObject);
begin
  Timer1.Enabled := False;
  SetWindowRgn(Handle, AbFormRgn, True);
end;
{$ENDIF Windows}

procedure TAboutBox.FormShow(Sender: TObject);
begin
{$IFDEF Windows}
//starting Lazarus 1.6.1 Handle is recreated on ShowModal (after FormCreate) :(
SetWindowRgn(Handle, AbFormRgn, True);
PrevWndProc:={%H-}Windows.WNDPROC(SetWindowLongPtr(Handle,GWL_WNDPROC,{%H-}PtrInt(@WndCallback)));
{$ELSE Windows}
Timer1.OnTimer:=@DoSetRgn;
Timer1.Enabled:=True;
{$ENDIF Windows}
end;

procedure TAboutBox.FormDeactivate(Sender: TObject);
begin
Push(0,False);
Push(1,False);
OKClicked := False;
HlpClicked := False;
end;

procedure TAboutBox.FormKeyPress(Sender: TObject; var Key: Char);
begin
if Key = #27 then Close;
end;

//{$IFNDEF Windows}
//function TAboutBox.PtOnBut(Bt,X,Y:integer):boolean;
//begin
//with But[Bt] do
// Result := (X >= x1) and (X <= x2) and (Y >= y1) and (Y <= y2);
//end;
//{$ENDIF Windows}

end.
