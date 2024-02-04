unit Labyrinth;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Weg aus dem Labyrinth suchen; alternativ mit dem Lee-Verfahren
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, Buttons, StdCtrls, Spin,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

const maxX = 40;
      maxY = 40;

      hindernis = -3;
      besucht   = -2;
      aktWeg    = -1;
      frei      = 0;
      LeeNr1    = 1;
      leeNr2    = 2;
      leeNr3    = 3;
      startFeld = 63;
      wegEnde   = 64;

type TBeispiel = array[0..maxY] of string[maxX+1];
     TFeld     = Array[0..maxX,0..maxY] of shortInt;

const
      bsp0 : TBeispiel =
            ( '00000000000000000000000000000000000000000',
              '0  0                                    0',
              '0 00 0000000000000000000000000000000000 0',
              '0 0                                     0',
              '0 0 000000000000000 000000000000000000000',
              '0 0 0                 0000000000000000000',
              '0 0 0 000000000000000A                  0',
              '0 0 0 000000000000000000000000000000000 0',
              '0 0 0                                   0',
              '0   0000000000000000000000000000000000000',
              '0 0 0 0                                 0',
              '0 0 0 0 0000000000000000000000000000000 0',
              '0 0 0 0 0                             0 0',
              '0 0 0 0 0  00000000000000000000000000 0 0',
              '0 0 0 0 0                           0 0 0',
              '0 0 0 0 00000000000000000000000000000 0 0',
              '0 0 0                                 0 0',
              '0 0 0 000000000000000000000000000000000 0',
              '0 0 0 0                                 0',
              '0 0 0 0 000000000000 000000000000 0000000',
              '0 0 0 0                        0        E',
              '0     0 0000000000000000000000 000000 000',
              '0 0 0 0 0                           0 0 0',
              '0 0 0 0 0 0000000000000000000000000 0 0 0',
              '0 0 0     00                      0 0 0 0',
              '0 0 0 0 0    00000000000000000000 0 0 0 0',
              '0 0 0 0 0 00 00000000000000000000 0 0 0 0',
              '0 0 0 0 0 00                      0 0 0 0',
              '0 0 0 0 0 0000000000000000000000000 0 0 0',
              '0 0 0 0 0                           0 0 0',
              '0 0 0 0  0000000000000000000000000000 0 0',
              '0 0   00                              0 0',
              '0 0000 00000000000000000000000000000000 0',
              '0 0    0                                0',
              '0 0 0000 000000000000000000000000000000 0',
              '0 0    0                              0 0',
              '0 0 000000000000000000000000000000000 0 0',
              '0 0                                   0 0',
              '0 0000000000000000000000000000000000000 0',
              '0                                       0',
              '00000000000000000000000000000000000000000' );

type

  { TLabyForm }

  TLabyForm = class(TForm)
    BitBtnBeenden: TBitBtn;
    ButtonNeuStart: TBitBtn;
    ButtonStart: TBitBtn;
    CheckBoxZwischenSchritt: TCheckBox;
    FramePausenStrg1: TFramePausenStrg;
    Panelcommand: TPanel;
    PanelLab: TPanel;
    PanelInit: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpinEditStartX: TSpinEdit;
    SpinEditStartY: TSpinEdit;
    RadioGroup1: TRadioGroup;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SpinEditEndX: TSpinEdit;
    SpinEditEndY: TSpinEdit;
    PanelStart: TPanel;
    PanelInfo: TPanel;
    LabelWeg: TLabel;
    Panel5: TPanel;
    DrawGrid1: TDrawGrid;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    SpeedButtonStartEast: TSpeedButton;
    SpeedButtonStartNorth: TSpeedButton;
    SpeedButtonStartWest: TSpeedButton;
    SpeedButtonStartSouth: TSpeedButton;
    Label11: TLabel;
    CheckBoxBestLsg: TCheckBox;
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DrawGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGrid1DblClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonNeuStartClick(Sender: TObject);
    procedure SpinEditStartXChange(Sender: TObject);
    procedure SpinEditStartYChange(Sender: TObject);
    procedure SpinEditEndXChange(Sender: TObject);
    procedure SpinEditEndYChange(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);
    procedure SpeedButtonStartEastClick(Sender: TObject);
  private
    { Private-Deklarationen }
    konstrukt,erfolg,eineLsg : boolean;
    lastCol,lastRow,
    minWeg,weg       : longint;
    startx,starty,
    ausgangX,ausgangY,
    startRtg    : integer;
    lab,labMin,labOrg : TFeld;
    procedure MakeBsp(const bsp:TBeispiel);
    procedure ZeichneZelle(x,y:integer; status:shortInt);
    procedure Markieren(a,b:TPoint;var nr:integer);
    procedure LoescheMarkierungen(von,bis:shortInt);
    procedure VerfolgeWegZurueck(a,b:TPoint;nr:integer);
    procedure LeeAlgorithmus;
    procedure SucheWeg(x,y,aWeg:integer;rtg:integer;var aErfolg:boolean);
    procedure SucheWegRechts(x,y,aWeg:integer;rtg:integer;var aErfolg:boolean);
    procedure SucheWegZufall(x,y,aWeg:integer;rtg:integer;var aErfolg:boolean);
  public
    { Public-Deklarationen }
  end;

var
  LabyForm: TLabyForm;

implementation

  {$R *.lfm}

procedure TLabyForm.ButtonNeuStartClick(Sender: TObject);
var old : boolean;
begin
  showSteps:=true;
  old:=keinePause;
  keinePause:=true;
  LoescheMarkierungen(besucht,leeNr3);
  keinePause:=old;
  lab[startX,startY]:=startfeld;
  drawGrid1.repaint;
  ButtonStartClick(Sender);
end;

procedure TLabyForm.ButtonStartClick(Sender: TObject);
begin
  drawGrid1.Enabled:=false;
  PanelInit.enabled:=false;
  PanelStart.visible:=false;
  FramePausenStrg1.FrameResize(Panelcommand);
  FramePausenStrg1.NormalStart;
  if lab[SpinEditStartX.value,SpinEditStartY.value]=wegEnde
    then erfolg:=true
    else begin
           if radioGroup1.itemIndex=3
             then begin
                    FramePausenStrg1.SetPause(20);
                    LeeAlgorithmus;
                  end
             else begin
                    erfolg:=false; minWeg:=$7FFFFFFF;
                    weg:=0;
                    eineLsg:=not checkBoxBestLsg.Checked;
                    if keinePause and eineLsg then FramePausenStrg1.BitBtnPauseDoubleClick(nil);
                    labMin:=lab;
                    case radioGroup1.itemIndex of
                      0 : SucheWeg(startX,startY,weg,startRtg,erfolg);
                      1 : SucheWegRechts(startX,startY,weg,startRtg,erfolg);
                      2 : SucheWegZufall(startX,startY,weg,startRtg,erfolg);
                      end;
                    lab:=labMin;
                    drawGrid1.refresh;
                  end;
         end;
  FramePausenStrg1.Visible:=false;
  PanelStart.visible:=true;
  PanelInit.Enabled:=true;
  drawGrid1.Enabled:=true;
end;

procedure TLabyForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked);
end;

procedure TLabyForm.DrawGrid1DblClick(Sender: TObject);
var x,y : integer;
begin
  x:=drawGrid1.Col;
  y:=drawGrid1.row;
  if (x>=0) and (y>=0) then
  if lab[x,y]=frei
    then begin
           ZeichneZelle(startX,startY,frei);
           startX:=x;
           startY:=y;
           ZeichneZelle(startX,startY,startFeld);
           SpinEditStartX.value:=x;
           SpinEditStartY.value:=y;
           drawGrid1.repaint;
         end
    else if (lab[x,y]=hindernis) then
         begin
           ZeichneZelle(ausgangX,ausgangY,hindernis);
           ausgangX:=x;
           ausgangY:=y;
           ZeichneZelle(ausgangX,ausgangY,wegEnde);
           SpinEditEndX.value:=x;
           SpinEditEndY.value:=y;
           drawGrid1.repaint;
         end;
end;

procedure TLabyForm.DrawGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
var farbe : TColor;
    weiter: boolean;
begin
  weiter:=false;
  case lab[col,row] of
     hindernis : farbe:=clsilver;
     aktWeg    : farbe:=clRed;
     frei      : farbe:=clWhite;
     startfeld : farbe:=clRed;
     WegEnde   : farbe:=clGreen;
        else begin farbe:=clWhite; weiter:=true end;
     end;
  drawGrid1.Canvas.Brush.color:=farbe;
  drawGrid1.Canvas.pen.color:=farbe;
  drawGrid1.canvas.Rectangle(rect.left,rect.top,rect.right,rect.bottom);
  if weiter then
    begin
      case lab[col,row] of
          besucht : farbe:=clblue;
          leeNr1  : farbe:=clYellow;
          leeNr2  : farbe:=clLime;
          leeNr3  : farbe:=clFuchsia;
             else farbe:=clFuchsia;
          end;
      drawGrid1.Canvas.Brush.color:=farbe;
      drawGrid1.canvas.Rectangle(rect.left+1,rect.top+1,rect.right-1,rect.bottom-1);
    end;
end;

procedure TLabyForm.DrawGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not konstrukt then
    begin
      konstrukt:=true;
      lastCol:=-1; lastRow:=-1;
    end;
end;

procedure TLabyForm.DrawGrid1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var aktCol,aktRow : integer;
begin
  if konstrukt then
    begin
      drawGrid1.mouseToCell(x,y,aktCol,aktRow);
      if (aktCol>=0) and (aktRow>=0) and ((aktCol<>lastCol) or (aktRow<>lastRow)) then
        begin
          lastRow:=aktRow;
          lastCol:=aktCol;
          if ssLeft in shift
            then ZeichneZelle(lastCol,lastRow,hindernis)
            else if ssRight in shift
                   then ZeichneZelle(lastCol,lastRow,frei);
        end;
    end;
end;

procedure TLabyForm.DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  konstrukt:=false;
end;

procedure TLabyForm.FormActivate(Sender: TObject);
begin
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,true);
  TranslationsFor_Labyrinth
end;

procedure TLabyForm.FormCreate(Sender: TObject);
begin
  SkaliereForm(self);
  drawgrid1.ColCount:=maxX+1;
  drawgrid1.rowCount:=maxY+1;
  makeBsp(bsp0);
  SpinEditStartX.maxValue:=maxX;
  SpinEditStartX.value:=startX;
  SpinEditStartY.maxValue:=maxY;
  SpinEditStartY.value:=startY;
  SpinEditEndX.maxValue:=maxX;
  SpinEditEndX.value:=ausgangX;
  SpinEditEndY.maxValue:=maxY;
  SpinEditEndY.value:=ausgangY;
  startRtg:=0;
  SpeedButtonStartEast.Down:=true;
end;

procedure TLabyForm.LeeAlgorithmus;
var a,b : TPoint;
    nr  : integer;
begin
  a.x:=SpinEditStartX.Value; a.y:=SpinEditStartY.Value;
  b.x:=SpinEditEndX.Value; b.y:=SpinEditEndY.Value;
  nr:=leeNr1;
  Markieren(a,b,nr);
  VerfolgeWegZurueck(a,b,nr);
end;

procedure TLabyForm.LoescheMarkierungen(von,bis : shortInt);
  var i,k : Integer;
  begin
    for i:= 0 TO maxX do
      for k:= 0 TO maxY do
        if (von<=lab[i,k]) and (lab[i,k]<=bis) then
          begin
            lab[i,k]:=frei;
            if zeigen then
            begin
            DrawGrid1DrawCell(nil, i, k, drawGrid1.CellRect(i,k),[]);
            CheckPause;
            end;
          end;
    drawGrid1.repaint;
    Delay(pause);
  end;


procedure TLabyForm.MakeBsp(const bsp:TBeispiel);
var x,y : integer;
    s   : string;
begin
  for y:=0 to maxY do
    begin
      s:=bsp[y];
      for x:=0 to maxX do
        case s[x+1] of
           '0' : lab[x,y]:=hindernis;
           'A' : begin lab[x,y]:=startFeld; startx:=x; starty:=y; end;
           'E' : begin lab[x,y]:=wegEnde; ausgangX:=x; ausgangY:=y; end;
           else lab[x,y]:=0;
         end;
    end;
  startRtg:=0;
  SpeedButtonStartEast.Down:=true;
  labOrg:=lab;
  drawGrid1.refresh;
end;

procedure TLabyForm.Markieren(a,b:TPoint;var nr:integer);
  TYPE lifo   = ^liste;
       liste  = RECORD
                  x,y : WORD;
                  no  : Byte;
                  vor,nach : lifo
                end;
  var hilf,speicher,ende:lifo;
      i,x,y        : WORD;
      ok,gefunden : BOOLEAN;
  begin
    x:=a.x; y:=a.y;
    gefunden:=FALSE;
    New(speicher);speicher^.vor:=NIL;speicher^.nach:=NIL;
    speicher^.x:=a.x; speicher^.y:=a.y; speicher^.no:=startFeld;
    ende:=speicher;
    repeat
      a.x:=ende^.x;a.y:=ende^.y;
      if ende^.no>=leeNr3 then nr:=leeNr1 else nr:=ende^.no+1;
      for i:=1 TO 4 do
        begin
          ok:=FALSE;
          case i of
              1 : if a.x<MaxX then begin x:=a.x+1; y:=a.y; ok:=TRUE end;
              2 : if a.y>0 then begin y:=a.y-1; x:=a.x; ok:=TRUE end;
              3 : if a.x>0 then begin x:=a.x-1; y:=a.y; ok:=TRUE end;
              4 : if a.y<MaxY then begin y:=a.y+1; x:=a.x; ok:=TRUE end
             end;
          if ok and (lab[x,y]=frei)
            then begin
                   New(hilf); hilf^.vor:=NIL; hilf^.nach:=speicher;
                   hilf^.x:=x; hilf^.y:=y; hilf^.no:=nr;
                   speicher^.vor:=hilf; speicher:=hilf; lab[x,y]:=nr;
                   if zeigen then DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
                   CheckPause;
                 end
            else if (x=b.x) and (y=b.y) then gefunden:=TRUE
         end;
       hilf:=ende^.vor;DisPose(ende);ende:=hilf;
    until (ende = NIL) OR gefunden or abbruch;
    while ende<>NIL do begin hilf:=ende^.vor;DisPose(ende);ende:=hilf end;
    if not gefunden then nr:=0 else erfolg:=true;
  end;

procedure TLabyForm.Panel5Resize(Sender: TObject);
var x,y:integer;
begin
  x:=(panel5.Width-4) div (maxX+1);
  y:=(panel5.Height-4) div (maxY+1);
  if y<x then x:=y;
  drawgrid1.DefaultColWidth:=x-1;
  drawgrid1.DefaultRowHeight:=x-1;
  drawgrid1.repaint;
end;


procedure TLabyForm.SpeedButtonStartEastClick(Sender: TObject);
begin
  startRtg:=(sender as TSpeedButton).tag
end;

procedure TLabyForm.SpinEditStartXChange(Sender: TObject);
begin
  try
    if (SpinEditStartX.value>=0) and (SpinEditStartX.value<=maxX) and (startx<>SpinEditStartX.value) then
      begin
        ZeichneZelle(startx,startY,frei);
        startx:=SpinEditStartX.value;
        ZeichneZelle(startx,startY,startFeld);
        DrawGrid1.repaint;
      end;
  finally
  end;
end;

procedure TLabyForm.SpinEditStartYChange(Sender: TObject);
begin
  try
    if (SpinEditStartY.value>=0) and (SpinEditStartY.value<=maxY) and (startY<>SpinEditStartY.value) then
      begin
        ZeichneZelle(startx,startY,frei);
        starty:=SpinEditStartY.value;
        ZeichneZelle(startx,startY,startFeld);
        DrawGrid1.repaint;
      end;
  finally
  end;
end;

procedure TLabyForm.SpinEditEndXChange(Sender: TObject);
begin
  try
    if (SpinEditEndX.value>=0) and (SpinEditEndX.value<=maxX) and (ausgangX<>SpinEditEndX.value) then
      begin
        ZeichneZelle(ausgangX,ausgangY,hindernis);
        ausgangX:=SpinEditEndX.value;
        ZeichneZelle(ausgangX,ausgangY,wegEnde);
        DrawGrid1.repaint;
      end;
  finally
  end;
end;

procedure TLabyForm.SpinEditEndYChange(Sender: TObject);
begin
  try
    if (SpinEditEndY.value>=0) and (SpinEditEndY.value<=maxY) and (ausgangY<>SpinEditEndY.value) then
      begin
        ZeichneZelle(ausgangX,ausgangY,hindernis);
        ausgangY:=SpinEditEndY.value;
        ZeichneZelle(ausgangX,ausgangY,wegEnde);
        DrawGrid1.repaint;
      end;
  finally
  end;
end;


procedure TLabyForm.SucheWeg(x,y,aWeg:integer;rtg:integer;var aErfolg:boolean);
const rtgTest : Array[0..3,0..2] of byte = ((0,1,3),(1,2,0),(2,3,1),(3,0,2));
var k,neuRtg,neuX,neuY : integer;
begin
  lab[x,y]:=aktweg;
  if zeigen then DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
  CheckPause;

  k:=-1;
  if abbruch then exit;
  repeat
    k:=k+1;
    neuRtg:=rtgTest[rtg,k];
    neuX:=x; neuY:=y;
    case neuRtg of
       0 : neuX:=x+1;
       1 : neuY:=y+1;
       2 : neuX:=x-1;
       3 : neuY:=y-1;
      end;
    if (0<=neuX) and (neuX<=maxX) and (0<=neuY) and (neuY<=maxY)
      then if (lab[neuX,neuY]=wegEnde)
             then begin
                    if minWeg>aWeg then
                      begin
                        minWeg:=aWeg;
                        labMin:=lab;
                        labelWeg.caption:=RSArr[rsWeglaenge]+IntToStr(aWeg);
                      end;
                    aErfolg:=eineLsg;
                  end
             else if not abbruch and (aWeg<minWeg) then
                    if (lab[neuX,neuY]=frei)
                      then SucheWeg(neuX,neuY,aWeg+1,neuRtg,aErfolg);

    if abbruch then exit;
  until (k=2) or (aErfolg and eineLsg);
  if not aErfolg then
    begin
      if eineLsg then lab[x,y]:=besucht
                 else lab[x,y]:=frei;
      if zeigen then DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
      CheckPause;
    end;
end;

procedure TLabyForm.SucheWegRechts(x,y,aWeg:integer;rtg:integer;var aErfolg:boolean);
const rtgTest : Array[0..3,0..2] of byte = ((1,0,3),(2,1,0),(3,2,1),(0,3,2));
var k,neuRtg,neuX,neuY : integer;
begin
  lab[x,y]:=aktweg;
  if zeigen then DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
  CheckPause;
  k:=-1;
  if abbruch then exit;
  repeat
    k:=k+1;
    neuRtg:=rtgTest[rtg,k];
    neuX:=x; neuY:=y;
    case neuRtg of
        0 : neuX:=x+1;
        1 : neuY:=y+1;
        2 : neuX:=x-1;
        3 : neuY:=y-1;
      end;
    if (0<=neuX) and (neuX<=maxX) and (0<=neuY) and (neuY<=maxY)
      then if (lab[neuX,neuY]=wegEnde)
             then begin
                    if minWeg>aWeg then
                        begin
                          minWeg:=aWeg;
                          labMin:=lab;
                          labelWeg.caption:=RSArr[rsWeglaenge]+IntToStr(aWeg);
                        end;
                    aErfolg:=eineLsg;
                  end
             else if not abbruch and (aWeg<minWeg) then
                      if (lab[neuX,neuY]=frei)
                        then SucheWegRechts(neuX,neuY,aWeg+1,neuRtg,aErfolg);

    if abbruch then exit;
  until (k=2) or (aErfolg and eineLsg);
  if not aErfolg then
    begin
      if eineLsg then lab[x,y]:=besucht
                 else lab[x,y]:=frei;
      if zeigen then DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
      CheckPause;
    end;
end;

procedure TLabyForm.SucheWegZufall(x,y,aWeg:integer;rtg:integer;var aErfolg:boolean);
const rtgTest : Array[0..3,0..2] of byte = ((0,1,3),(1,2,0),(2,3,1),(3,0,2));
var k,j,neuRtg,neuX,neuY : integer;
    schonGewaehlt : array[0..2] of boolean;
begin
  lab[x,y]:=aktweg;
  if zeigen then DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
  CheckPause;
  k:=-1;
  if abbruch then exit;
  fillChar(schonGewaehlt,sizeOf(schonGewaehlt),0);
  randomize;
  repeat
    k:=k+1;
    repeat
      j:=random(3);
      if schonGewaehlt[j] then j:=-1;
    until j>=0;
    schonGewaehlt[j]:=true;
    neuRtg:=rtgTest[rtg,j];
    neuX:=x; neuY:=y;
    case neuRtg of
       0 : neuX:=x+1;
       1 : neuY:=y+1;
       2 : neuX:=x-1;
       3 : neuY:=y-1;
      end;
    if (0<=neuX) and (neuX<=maxX) and (0<=neuY) and (neuY<=maxY)
      then if (lab[neuX,neuY]=wegEnde)
             then begin
                    if minWeg>aWeg then
                      begin
                        minWeg:=aWeg;
                        labMin:=lab;
                        labelWeg.caption:=RSArr[rsWeglaenge]+IntToStr(aWeg);
                      end;
                    aErfolg:=eineLsg;
                  end
             else if not abbruch and (aWeg<minWeg) then
                    if (lab[neuX,neuY]=frei)
                      then SucheWegZufall(neuX,neuY,aWeg+1,neuRtg,aErfolg);

    if abbruch then exit;
  until (k=2) or (aErfolg and eineLsg);
  if not aErfolg then
    begin
      if eineLsg then lab[x,y]:=besucht
                 else lab[x,y]:=frei;
      if zeigen then DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
      CheckPause;
    end;
end;

procedure TLabyForm.VerfolgeWegZurueck(a,b:TPoint;nr:integer);
var x,y,j,aWeg : WORD;
      ok       : BOOLEAN;
begin
    x:=b.x; y:=b.y; aWeg:=0;
    repeat
      if nr=leeNr1 then nr:=leeNr3 else Dec(nr);
      j:=0;  ok:=false;
      repeat
        j:=j+1;
        case j of
             1 : begin ok:=(x<maxX) and (lab[x+1,y]=nr); if ok then Inc(x) end;
             2 : begin ok:=(y<maxY) and (lab[x,y+1]=nr); if ok then Inc(y) end;
             3 : begin ok:=(y>0) and (lab[x,y-1]=nr); if ok then Dec(y) end;
             4 : begin ok:=(x>0) and (lab[x-1,y]=nr); if ok then Dec(x) end;
             end
      until ok OR (j=4) or ( (x=a.x) and (y=a.y) );
      if ok then
        begin
          lab[x,y]:=aktWeg;
          aWeg:=aWeg+1;
          DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
          CheckPause;
        end
    until not ok or abbruch or ( (x=a.x) and (y=a.y) );
    labelWeg.caption:=RSArr[rsWeglaenge]+IntToStr(aWeg);
    LoescheMarkierungen(leeNr1,leeNr3);
end;

procedure TLabyForm.ZeichneZelle(x,y:integer; status:shortInt);
begin
  lab[x,y]:=status;
  DrawGrid1DrawCell(nil, x, y, drawGrid1.CellRect(x,y),[]);
end;

end.
