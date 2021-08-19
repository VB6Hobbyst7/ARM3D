unit mxhelper;

{$mode objfpc}{$H+}

interface

uses
 Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
 StdCtrls;

type

 { TFrmMxHlp }

 TFrmMxHlp = class(TForm)
  Button1: TButton;
  Button2: TButton;
  TSDMAChG: TCheckGroup;
  ChansRG: TRadioGroup;
 private
  { private declarations }
 public
  { public declarations }
 end;

var
 FrmMxHlp: TFrmMxHlp;

implementation

{$R *.lfm}

end.

