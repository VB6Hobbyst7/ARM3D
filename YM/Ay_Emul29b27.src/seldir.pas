{
This is part of AY Emulator project
AY-3-8910/12 Emulator
Version 2.9 for Windows and Linux
Author Sergey Vladimirovich Bulba
(c)1999-2021 S.V.Bulba
}

unit seldir;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  EditBtn, StdCtrls, ExtCtrls;

type

  { TSelDirDlg }

  TSelDirDlg = class(TForm)
    Button1: TButton;
    Button2: TButton;
    PlaylistGB: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RecurseChk: TCheckBox;
    DoDetect: TCheckBox;
    DirEdit: TDirectoryEdit;
  private
    { private declarations }
  public
    { public declarations }
  end;

function ChooseDirectory(var Dir:string;const Capt:string;Extra:boolean;const s1,s2:string):boolean;

var
  SelDirDlg: TSelDirDlg;

implementation

uses
  MainWin;

{$R *.lfm}

function ChooseDirectory(var Dir:string;const Capt:string;Extra:boolean;const s1,s2:string):boolean;
begin
Result := False;
SelDirDlg.DirEdit.Directory:=Dir;
SelDirDlg.DirEdit.DialogTitle:=Capt;
SelDirDlg.Caption:=Capt;
SelDirDlg.RecurseChk.Visible:=Extra;
SelDirDlg.DoDetect.Visible:=Extra;
SelDirDlg.PlaylistGB.Visible:=Extra;
if Extra then
 begin
  SelDirDlg.RecurseChk.Checked := AddFolderRecurseDirs;
  SelDirDlg.DoDetect.Checked := AddFolderDoDetect;
  SelDirDlg.RadioButton1.Checked := AddFolderPlaylists = 0;
  SelDirDlg.RadioButton2.Checked := AddFolderPlaylists = 1;
  SelDirDlg.RadioButton3.Checked := AddFolderPlaylists = 2;
  SelDirDlg.RecurseChk.Caption := s1;
  SelDirDlg.DoDetect.Caption := s2;
 end;
if SelDirDlg.ShowModal = mrOk then
 begin
  if Extra then
   begin
    AddFolderRecurseDirs := SelDirDlg.RecurseChk.Checked;
    AddFolderDoDetect := SelDirDlg.DoDetect.Checked;
    if SelDirDlg.RadioButton1.Checked then
     AddFolderPlaylists := 0
    else if SelDirDlg.RadioButton2.Checked then
     AddFolderPlaylists := 1
    else if SelDirDlg.RadioButton3.Checked then
     AddFolderPlaylists := 2;
   end;
  Dir := SelDirDlg.DirEdit.Directory;
  Result := True;
 end;
end;

end.

