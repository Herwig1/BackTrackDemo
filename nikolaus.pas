unit nikolaus;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   das Haus vom Nikolaus
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Buttons,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

const maxPkt   = 5;
      maxLines = 8;

type
      verbindeTyp = array[0..maxLines] of 0..maxPkt;
      lineArray   = array[1..maxPkt,1..maxPkt] of BOOLEAN;

const abstOrg     = 100; x0org = 200; y0org = 50;
      orglinie : lineArray
               = ( (FALSE,TRUE, TRUE, FALSE,FALSE),
                   (TRUE, FALSE,TRUE, TRUE, TRUE ),
                   (TRUE, TRUE, FALSE,TRUE, TRUE ),
                   (FALSE,TRUE, TRUE, FALSE,TRUE ),
                   (FALSE,TRUE, TRUE, TRUE, FALSE) );

type

  { TNikolausForm }

  TNikolausForm = class(TForm)
    ButtonStart: TBitBtn;
    CheckBoxZwischenSchritt: TCheckBox;
    FramePausenStrg1: TFramePausenStrg;
    Memo1: TMemo;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    Panel4: TPanel;
    Panel5: TPanel;
    PanelStart: TPanel;
    Label2: TLabel;
    CheckBoxAlleLsgSuchen: TCheckBox;
    SpinEditStartPos: TSpinEdit;
    CheckBoxLinieNachfahren: TCheckBox;
    Panel6: TPanel;
    paintbox1: TPaintBox;
    Panel7: TPanel;
    edit1: TEdit;
    Splitter1: TSplitter;
    procedure ButtonStartClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure paintbox1Paint(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure SpinEditStartPosChange(Sender: TObject);
  private
    { Private-Deklarationen }
    abst, x0, y0 : integer;
    linie        : lineArray;
    verbinde     : verbindeTyp;
    punkt        : array[1..maxPkt] of TPoint;
    speicher     : array[1..100] of verbindeTyp;
    lgsNr        : integer;
    ganzeLinie,
    erfolgreich,
    einzel       : BOOLEAN;
    procedure NextLine(lastPkt,eintrag:integer;var aErfolg:BOOLEAN);  { *Haupt* }
    procedure SchreibLoesung;
    procedure StarteRunModus;
    procedure VerlasseRunModus;
    procedure Zeichne(a,b:TPoint;col:TColor);
    procedure ZeichneHaus;
    procedure ZeigeLoesung(nr:integer);
  public
    { Public-Deklarationen }
  end;

var
  NikolausForm: TNikolausForm;

implementation

{$R *.lfm}

procedure TNikolausForm.ButtonStartClick(Sender: TObject);
begin
  lgsNr:=0;
  erfolgreich:=FALSE;
  einzel:=not CheckBoxAlleLsgSuchen.checked;
  FillChar(verbinde,SizeOf(verbinde),#0);
  linie:=orgLinie;
  memo1.clear;
  StarteRunModus;
  if einzel
    then edit1.text:=RSArr[rsLoesungSuchen]
    else edit1.text:=RSArr[rsLoesungenSuchen];
  verbinde[0]:=SpinEditStartPos.value;
  NextLine(SpinEditStartPos.value,1,erfolgreich);
  if lgsNr=0 then edit1.text:=RSArr[rsKeineLoesung]
             else if einzel then edit1.text:=RSArr[rsEineLoesungGefunden1]
                            else edit1.text:=IntToStr(lgsNr)+RSArr[rsLoesungenErmittelt];
  CheckBoxLinieNachfahren.Enabled:=zeigen;
  VerlasseRunModus;
end;

procedure TNikolausForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.checked);
  CheckBoxLinieNachfahren.Enabled:=zeigen;
end;

procedure TNikolausForm.FormActivate(Sender: TObject);
begin
  abst:=ScaleX(abstOrg, orgDPI);
  x0:=ScaleY(abstOrg, orgDPI);
  if x0<abst then abst:=x0;
  x0:=ScaleX(X0org, orgDPI);
  y0:=ScaleY(Y0org, orgDPI);
  punkt[1]:=Point(x0,y0);
  punkt[2]:=Point(x0-abst,y0+abst);
  punkt[3]:=Point(x0+abst,y0+abst);
  punkt[4]:=Point(x0-abst,y0+2*abst);
  punkt[5]:=Point(x0+abst,y0+2*abst);
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(CheckBoxZwischenSchritt,true);
  linie:=orgLinie;
//  ZeichneHaus;
   TranslationsFor_nikolaus
end;

procedure TNikolausForm.FormCreate(Sender: TObject);
var fs : integer;
begin
  linie:=orgLinie;
  SkaliereForm(self);
  fs:=memo1.Font.Size;
  repeat
    fs:=fs-1;
    memo1.Font.Size:=fs;
    edit1.Font.size:=fs;
  until memo1.Font.size<font.size;
end;

procedure TNikolausForm.Memo1Click(Sender: TObject);
var n : integer;
    s : string;
begin
   n:=memo1.CaretPos.y;
   if n<memo1.Lines.Count
    then s:=memo1.Lines[n]
    else s:='';
  if s='' then exit;
  memo1.SelStart:=Pos(s,memo1.Text)-1;
  memo1.SelLength:=Length(s);
  zeigeLoesung(n+1);
end;

{ ****************** Hauptprocedure ************** }
procedure  TNikolausForm.NextLine(lastPkt,eintrag:integer;var aErfolg:BOOLEAN);
var nextPkt : integer;
begin
  nextPkt:=0; aErfolg:=false;
  Application.ProcessMessages;
  if abbruch then exit;
  repeat
    nextPkt:=nextPkt+1;
    if linie[lastPkt,nextPkt] then
      begin
        Application.ProcessMessages;
        verbinde[eintrag]:=nextPkt;
        Zeichne(punkt[lastPkt],punkt[nextPkt],clRed);
        if eintrag=maxLines
          then begin
                 lgsNr:=lgsNr+1;
                 SchreibLoesung;
                 speicher[lgsNr]:=verbinde;
                 aErfolg:=einzel
               end
          else begin
                 linie[lastPkt,nextPkt]:=FALSE;
                 linie[nextPkt,lastPkt]:=FALSE;
                 NextLine(nextPkt,eintrag+1,erfolgreich)
              end;
        if not aErfolg and not abbruch then
          begin
            linie[lastPkt,nextPkt]:=TRUE;
            linie[nextPkt,lastPkt]:=TRUE;
            verbinde[eintrag]:=0;
            Zeichne(punkt[nextPkt],punkt[lastpkt],clWhite);
          end
      end
  until (nextPkt=maxPkt) OR aErfolg or abbruch;
end;

procedure TNikolausForm.paintbox1Paint(Sender: TObject);
begin
  ZeichneHaus;
end;

procedure TNikolausForm.PanelBeendenCommandResize(Sender: TObject);
begin
   BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;

procedure TNikolausForm.SpinEditStartPosChange(Sender: TObject);
begin
  if (SpinEditStartPos.text<>'') then
    if (SpinEditStartPos.value>=1)
     then if (SpinEditStartPos.value<=maxPkt)
            then ZeichneHaus
            else SpinEditStartPos.value:=maxPkt
     else SpinEditStartPos.value:=1
end;

procedure TNikolausForm.SchreibLoesung;
var i : integer;
    s : string;
begin
  s:=IntToStr(verbinde[0]);
  for i:=1 TO maxLines do s:=s+' --> '+IntToStr(verbinde[i]);
  memo1.Lines.Add(s);
end;

procedure TNikolausForm.StarteRunModus;
begin
  ganzeLinie:= not CheckBoxLinieNachfahren.checked;
  FramePausenStrg1.SetModusPause(not ganzeLinie);
  BitBtnBeenden.Enabled:=false;
  PanelStart.Hide;
  FramePausenStrg1.NormalStart;
  PaintBox1.refresh;
end;

procedure TNikolausForm.VerlasseRunModus;
begin
  BitBtnBeenden.Enabled:=true;
  FramePausenStrg1.Hide;
  PanelStart.visible:=true;
end;

procedure TNikolausForm.ZeichneHaus;
var k,j,oldP,r : integer;
    a          : TPoint;
    oldL,oldS  : boolean;
begin
  paintBox1.Canvas.Brush.Color:=clBtnFace;
  paintBox1.Canvas.Pen.Color:=clBtnFace;
  paintBox1.Canvas.Rectangle(0,0,paintBox1.width,paintBox1.Height);

  oldP:=pause; pause:=0;
  oldL:=ganzeLinie; ganzeLinie:=true;
  oldS:=showSteps; showSteps:=true;
  for k:=1 to maxPkt do
    for j:=k+1 to maxPkt do
      if linie[k,j] then Zeichne(punkt[k],punkt[j],clWhite);
  pause:=oldP;
  ganzeLinie:=oldL;
  showSteps:=oldS;
  for k:=1 to maxPkt do
    begin
      a:=punkt[k];
      paintBox1.Canvas.Brush.Color:=clRed;
      paintBox1.Canvas.Pen.Color:=clRed;
      if k=SpinEditStartPos.value then r:=4 else r:=2;
      paintBox1.Canvas.ellipse(a.x-r,a.y-r,a.x+r,a.y+r);
      paintBox1.Canvas.Brush.Color:=clBtnFace;
      if a.x<x0 then j:=-12 else j:=4;
      paintBox1.canvas.TextOut(a.x+j,a.y-8,IntToStr(k));
    end;
end;

procedure TNikolausForm.Zeichne(a,b:TPoint;col:TColor);
var i,dx,dy: integer;
begin
  if zeigen then
  if ganzeLinie
    then begin
           PaintBox1.canvas.pen.color:=col;
           PaintBox1.canvas.MoveTo(a.x,a.y);
           PaintBox1.canvas.LineTo(b.x,b.y);
           CheckPause;
         end
    else begin
           dx:=b.x-a.x; dy:=b.y-a.y;
           for i:=1 TO abst do
             begin
               PaintBox1.canvas.Pixels[a.x+i*dx DIV abst,a.y+i*dy DIV abst]:=col;
               Delay(miniPause);
               if not showSteps then
                 repeat
                   Application.ProcessMessages;
                 until showSteps or abbruch;
               if not zeigen then break;
             end;
         end

end;

procedure TNikolausForm.ZeigeLoesung(nr:integer);
var i,oldP1,oldP2 : integer;
    oldZ          : Boolean;
begin
  if (nr>0) and (nr<=lgsNr) then
    begin
      StarteRunModus;
      oldP1:=miniPause; oldP2:=pause; oldZ:=zeigen;
      verbinde:=speicher[nr];
      zeigen:=true;
      for i:=1 TO maxLines do
        Zeichne(punkt[verbinde[i-1]],punkt[verbinde[i]],clRed);
      miniPause:=oldP1; pause:=oldP2;
      if miniPause=0 then keinePause:=true;
      zeigen:=oldZ;
      VerlasseRunModus;
    end
end;

end.
