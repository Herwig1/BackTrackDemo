unit pausensteuerung;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Steuerung der Geschwindigkeiten im Demo-Modus
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.1

   letzte Änderung: 15.12.2023 *)

{$mode Delphi}

interface

uses
  SysUtils, Forms, Controls, Buttons, StdCtrls,
  BackTrackDemo_Sprache;

type

  { TFramePausenStrg }

  TFramePausenStrg = class(TFrame)
    BitBtnBreak: TBitBtn;
    BitBtnContinueShow: TBitBtn;
    BitBtnPauseDefault: TBitBtn;
    BitBtnPauseDouble: TBitBtn;
    BitBtnPauseHalf: TBitBtn;
    BitBtnPauseNone: TBitBtn;
    BitBtnPauseShow: TBitBtn;
    BitBtnZwischenSchritt: TBitBtn;
    ImageListSteuerung: TImageList;
    LabelPausenLaenge: TLabel;
    procedure BitBtnBreakClick(Sender: TObject);
    procedure BitBtnContinueShowClick(Sender: TObject);
    procedure BitBtnPauseDefaultClick(Sender: TObject);
    procedure BitBtnPauseDoubleClick(Sender: TObject);
    procedure BitBtnPauseHalfClick(Sender: TObject);
    procedure BitBtnPauseNoneClick(Sender: TObject);
    procedure BitBtnPauseShowClick(Sender: TObject);
    procedure BitBtnZwischenSchrittClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private

    CheckBoxZwischenSchritt : TCheckbox;
    procedure InfoPausenLaenge;
  public
    procedure Init(aCheckBox:TCheckBox;quick:boolean);
    procedure NormalStart;
    procedure SetCheckBoxZwischenSchritt(aCheckBox:TCheckBox);
    procedure SetModusPause(aModus : boolean);
    procedure SetPause(aPause:integer);
    procedure SetZwischenSchritt(b:boolean);

  end;

  { globale Variablen }
  var pause, miniPause : integer;
    abbruch, neuePause, keinePause, showSteps, zeigen : boolean;

procedure CheckPause;
procedure Delay(zeit:Longint);
procedure KurzePause(k:integer);

implementation

{$R *.lfm}

var zeigMiniPause : boolean;

{ TFramePausenStrg }

procedure TFramePausenStrg.BitBtnContinueShowClick(Sender: TObject);
begin
  BitBtnPauseShow.Enabled:= true;
  BitBtnContinueShow.Enabled:=False;
  showSteps := true;
end;

procedure TFramePausenStrg.BitBtnBreakClick(Sender: TObject);
begin
  abbruch:=true; keinePause:=true;  neuePause:=true;
end;

procedure TFramePausenStrg.BitBtnPauseDefaultClick(Sender: TObject);
begin
  miniPause:=10;
  pause:=256;
  InfoPausenLaenge;
end;

procedure TFramePausenStrg.BitBtnPauseDoubleClick(Sender: TObject);
begin
  miniPause:=miniPause+2;
  if pause>0 then pause:=pause*2 else pause:=2;
  InfoPausenLaenge;
end;

procedure TFramePausenStrg.BitBtnPauseHalfClick(Sender: TObject);
begin
  if miniPause>0 then miniPause:=miniPause-2;
  if pause>1 then pause:=pause DIV 2;
  InfoPausenLaenge;
end;

procedure TFramePausenStrg.BitBtnPauseNoneClick(Sender: TObject);
begin
  miniPause:=0;
  pause:=0;
  neuePause:=true; keinePause:=true;
  LabelPausenLaenge.caption:=RSArr[rsKeinePause];
  LabelPausenLaenge.Repaint;
end;

procedure TFramePausenStrg.BitBtnPauseShowClick(Sender: TObject);
begin
  BitBtnPauseShow.Enabled:=False;
  BitBtnContinueShow.Enabled:= true;
  showSteps := false;
end;

procedure TFramePausenStrg.BitBtnZwischenSchrittClick(Sender: TObject);
begin
  zeigen:=not zeigen;
  if zeigen
    then BitBtnZwischenSchritt.ImageIndex:=1
    else BitBtnZwischenSchritt.ImageIndex:=0;
  if (sender<>nil) and assigned(CheckBoxZwischenSchritt) then CheckBoxZwischenSchritt.checked:=zeigen;
end;

procedure TFramePausenStrg.FrameResize(Sender: TObject);
const abstand = 2;
var mitte, breit, w : integer;
begin
  w:=Self.ClientWidth;
  mitte:=w div 2;
  breit:=mitte - 2*abstand;
  BitBtnPauseHalf.Left:=abstand;
  BitBtnPauseHalf.Width:=breit;
  BitBtnPauseDefault.Left:=abstand;
  BitBtnPauseDefault.Width:=breit;
  BitBtnPauseDouble.Left:=mitte+abstand;
  BitBtnPauseDouble.Width:=breit;
  BitBtnPauseNone.Left:=mitte+abstand;
  BitBtnPauseNone.Width:=breit;
  BitBtnPauseShow.Left:=abstand;
  BitBtnContinueShow.Left:=BitBtnPauseShow.Width+3*Abstand;
  BitBtnZwischenSchritt.Left:=mitte - 2*abstand - BitBtnZwischenSchritt.Width;
  BitBtnBreak.Left:=w-abstand-BitBtnBreak.Width;
end;

procedure TFramePausenStrg.InfoPausenLaenge;
begin
  neuePause:=true; keinePause:=false;
  if zeigMiniPause
    then LabelPausenLaenge.caption:=RSArr[rsVerzoegerung]+IntToStr(miniPause)+RSArr[rsMs]
    else LabelPausenLaenge.caption:=RSArr[rsPausenlaenge]+IntToStr(pause)+RSArr[rsMs];;
  LabelPausenLaenge.Repaint;
end;

procedure TFramePausenStrg.Init(aCheckBox:TCheckBox;quick:boolean);
begin
  SetCheckBoxZwischenSchritt(aCheckBox);
  zeigen:=false;
  SetZwischenSchritt(true);
  abbruch:=false;
  BitBtnPauseDefaultClick(nil);
  BitBtnContinueShowClick(nil);
  SetModusPause(quick);
  TranslationsFor_TFramePausenStrg(self);
end;

procedure TFramePausenStrg.NormalStart;
begin
  abbruch:=false;
  keinePause:=false;
  if not zeigen then BitBtnPauseNoneClick(nil)
                else if pause=0 then BitBtnPauseDefaultClick(nil);
  BitBtnContinueShowClick(nil);
  visible:=true;
end;

procedure TFramePausenStrg.SetCheckBoxZwischenSchritt(aCheckBox: TCheckBox);
begin
  CheckBoxZwischenSchritt:=aCheckBox;
end;

procedure TFramePausenStrg.SetPause(aPause: integer);
begin
  if zeigMiniPause
    then miniPause:=aPause
    else pause:=aPause;
  InfoPausenLaenge;
end;

procedure TFramePausenStrg.SetModusPause(aModus : boolean);
begin
  if aModus <> zeigMiniPause then
    begin
      zeigMiniPause:=aModus;
      if zeigMiniPause
        then begin
               BitBtnPauseHalf.Caption:=RSArr[rsVerkleinern];
               BitBtnPauseDouble.caption:=RSArr[rsVergroessern];
             end
        else begin
               BitBtnPauseHalf.caption:=RSArr[rsHalbieren];
               BitBtnPauseDouble.caption:=RSArr[rsVerdoppeln];
             end;
      InfoPausenLaenge
    end;
end;

procedure TFramePausenStrg.SetZwischenSchritt(b:boolean);
begin
  if zeigen<>b
    then BitBtnZwischenSchrittClick(self);
end;

procedure Delay(zeit:Longint);
var zeit1 : longint;
begin
  if zeit=0 then exit;
  neuePause:=false;
  zeit1:=GetTickCount64;
  repeat
    Application.ProcessMessages
  until (GetTickCount64-zeit1>zeit) or neuePause;
end;

procedure CheckPause;
begin
  if keinePause then Application.ProcessMessages
                else if zeigMiniPause
                       then Delay(miniPause)
                       else Delay(pause);
 if not showSteps then
   repeat
      Application.ProcessMessages;
   until showSteps or abbruch;
end;

procedure KurzePause(k:integer);
begin
  if k<1 then k:=1;
  if keinePause then Application.ProcessMessages
                else if zeigMiniPause
                       then Delay(miniPause div k)
                       else Delay(pause div k);
 if not showSteps then
   repeat
      Application.ProcessMessages;
   until showSteps or abbruch;
end;

end.

