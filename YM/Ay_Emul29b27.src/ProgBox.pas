{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit ProgBox;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type

  { TFrmPrBox }

  TFrmPrBox = class(TForm)
    Button2: TButton;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrBox: TFrmPrBox;
  PrgBox:boolean = False;

implementation

uses
  MainWin;

{$R *.lfm}

procedure TFrmPrBox.Button1Click(Sender: TObject);
begin
May_Quit := True;
end;

procedure TFrmPrBox.Button2Click(Sender: TObject);
begin
May_Quit := True;
May_Quit2 := True;
end;

end.
