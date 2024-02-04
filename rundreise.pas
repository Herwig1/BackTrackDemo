unit rundReise;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Weg des Handlungsreisenden; alternativ zum Backtracking werden noch zwei
            andere Verfahren angeboten, die nicht unbedingt die beste Lösung liefern,
            dafür aber wesentlich schneller eine akzeptable Lösung finden
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

{ siehe c't Jannuar 1994

Algorithmen abgeleitet aus Verhalten einer Schmelze beim Erstarren.

SA - Simulated-Annealing-Algorithmus
     Simuliertes Erstarren (1983; IBM)

  SA zur Minimierung
    wähle eine Ausgangskonfiguration;
    wähle eine Anfangstemperatur T>0;
    WIEDERHOLE
      WIEDERHOLE
        wähle eine neue Konfiguration, die eine kleine Änderung der
        alten Konfiguration ist;
        berechne die Qualitätsfunktion Q der neuen Konfiguration;
        DE:=Q(neu)-Q(alt);
        WENN DE<0
          DANN alte Konfiguration:=neue Konfiguration
          SONST WENN Zufallszahl<exp(-DE/(kT))
                  DANN alte Konfiguration:=neue Konfiguration
      BIS lange keine Erniedrigung der Qualität;
      verringere T;
    BIS überhaupt keine Verringerung der Qualitätsfunktion mehr;
  ENDE.

TA - Threshold-Accepting-Algoritmus
     Schwellenakzeptanz (1990; IBM, Dueck, Scheuer)

  TA zur Minimierung
    wähle eine Ausgangskonfiguration;
    wähle eine Anfangstemperatur T>0;
    WIEDERHOLE
      WIEDERHOLE
        wähle eine neue Konfiguration, die eine kleine Änderung der
        alten Konfiguration ist;
        berechne die Qualitätsfunktion Q der neuen Konfiguration;
        DE:=Q(neu)-Q(alt);
        WENN DE<T
          DANN alte Konfiguration:=neue Konfiguration
      BIS lange keine Erniedrigung der Qualität;
      verringere T;
    BIS überhaupt keine Verringerung der Qualitätsfunktion mehr;
  ENDE.

GDA - Great-Deluge-Algorithmus
      Sinflut-Algorithmus (1993?; IBM, Dueck)
  GDA zur Minimierung
    wähle eine Ausgangskonfiguration;
    wähle eine Regenmenge Regen>0;
    wähle einen Wasserstand W>0;
    WIEDERHOLE
      wähle eine neue Konfiguration, die eine kleine Änderung der
      alten Konfiguration ist;
      berechne die Qualitätsfunktion Q der neuen Konfiguration;
      WENN Q(neu)>W
        DANN alte Konfiguration:=neue Konfiguration
      W:=W + Regen;
    BIS lange keine Erniedrigung der Qualität;
  ENDE.

wähle eine neue Konfiguration, die eine kleine Änderung der
alten Konfiguration ist;

alt:        0  1  2  3  4  5| 6  7  8  9 10| 11 12 13 14 15
2 Schnitte:                 |cut1          |cut2
neu:        0  1  2  3  4  5|10  9  8  7  6| 11 12 13 14 15

  oder

alt:        0  1  2  3  4  5| 6  7  8  9 10| 11 12 13 14 15
2 Schnitte:                 |cut2          |cut1
neu:        0 15 14 13 12 11| 6  7  8  9 10|  5  4  3  2  1
}

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Grids, Buttons, ExtCtrls,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

CONST maxCities = 50;
      maxTime   = 200;

      maxPXorg     = 300;
      maxPYorg     = 400;

      startWert = 557864;    { Für Zufallsgenerator1 }
      start2    = 1236;      { für Zufallsgererator2 }
      tempfaktor= 0.9;

      offset    = 20;

      SA_mode   = 1;
      TA_mode   = 2;
      voll_mode = 0;

TYPE city = record
              x,y : REAL;
            end;

     cityArr4   = array[1..4] of city;
     TTourArray = array[0..maxCities] of integer;

type

  { TTravelForm }

  TTravelForm = class(TForm)
    ButtonStart: TBitBtn;
    FramePausenStrg1: TFramePausenStrg;
    Memo1: TMemo;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    PanelPaintBox: TPanel;
    PaintBox1: TPaintBox;
    PanelEdit: TPanel;
    edit1: TEdit;
    PanelCommandCenter: TPanel;
    PanelStart: TPanel;
    SpeedButtonDistances: TSpeedButton;
    SpeedButtonInputCities: TSpeedButton;
    Splitter1: TSplitter;
    StaticText1: TStaticText;
    SpinEditAnz: TSpinEdit;
    RadioGroup1: TRadioGroup;
    StringGrid2: TStringGrid;
    procedure ButtonStartClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure SpeedButtonInputCitiesClick(Sender: TObject);
    procedure SpinEditAnzChange(Sender: TObject);
    procedure SpinEditAnzExit(Sender: TObject);
  private
    cities   : array[0..maxCities-1] of city;
    cityDist : array[0..maxCities-1,0..maxCities-1] of real;
    index  : TTourArray;
    time   : Integer;
    result : array[0..maxTime] of Integer;
    heat   : array[0..maxTime] of Integer;
    maxCity,
    calcMode  : integer;
    dummy,
    dummy2 : LONGINT;
    maxLang,
    laenge,
    temp,
    faktor,
    scale  : REAL;
    stadtEingabe, naechsteStadt : boolean;
    { Private-Deklarationen }
    procedure gLine(x1,y1,x2,y2:REAL;f:integer);
    procedure gDraw(x,k:integer);
    procedure InitCities;
    procedure InitCityDist;
    procedure InitDistGrid(k:integer);
    procedure InitVars;
    function MyRandom(var aDummy:LONGINT):REAL;
    function NameToNumber(ch:char):integer;
    procedure NewDraw(CONST Ncuts : cityArr4);
    function NumberToName(nr:integer):char;
    procedure Start;
    procedure VollStart;
    procedure ZeigeAktLoesung(const tour:TTourArray;aLaenge:real);
    procedure ZeigeCities(mitVerbindung:Boolean);
    procedure ZeigeCityName(x, y, nr:integer);
    procedure ZeigeGraph;
   public
    { Public-Deklarationen }
  end;

var
  TravelForm: TTravelForm;

implementation

  {$R *.lfm}

procedure TTravelForm.ButtonStartClick(Sender: TObject);
var altePause : integer;
begin
  PanelStart.Hide;
  BitBtnBeenden.Enabled:=false;
  FramePausenStrg1.NormalStart;
  memo1.Clear;
  edit1.Text:='';
  zeigeCities(true);
  screen.cursor:=crHourGlass;
  if calcMode<>voll_mode
    then begin
           altePause := pause;
           FramePausenStrg1.SetPause(512);
           start;
           FramePausenStrg1.SetPause(altePause);
         end
    else VollStart;
  screen.cursor:=crDefault;
  FramePausenStrg1.Hide;
  PanelStart.show;
  PanelStart.repaint;
  BitBtnBeenden.Enabled:=true;
  if not abbruch then Memo1Click(nil);
end;

procedure TTravelForm.FormActivate(Sender: TObject);
begin
  initvars;
  initCities;
  RadioGroup1Click(self);
  paintbox1.refresh;
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(nil,false);
  TranslationsFor_rundreise
end;

procedure TTravelForm.FormCreate(Sender: TObject);
var fs : integer;
begin
  SkaliereForm(self);
  fs:=edit1.Font.Size;
  repeat
    fs:=fs-1;
    edit1.Font.size:=fs;
  until edit1.Font.size<font.size;
end;

procedure TTravelForm.gDraw(x,k:integer);
var y,y1,x0,y0 : integer;
begin
  if time<(maxTime DIV 4) then x0:=maxTime DIV 2-10 else x0:=maxtime;
  x0:=paintbox1.width-x0; y0:=(paintBox1.height DIV 2);
  paintbox1.canvas.pen.color:=clGreen;
  if k = 1
    then begin y:=heat[x-1];y1:=heat[x]; {y0:=y0} end
    else begin y:=result[x-1];y1:=result[x]; y0 := 2*y0; end;
  x:=2*x+x0;
  paintbox1.canvas.MoveTo(x-2,y0-y);
  paintbox1.canvas.LineTo(x,y0-y1);
end;

procedure TTravelForm.gLine(x1,y1,x2,y2:REAL;f:integer);
begin
  if f=0 then paintbox1.canvas.pen.color:=clBtnFace
         else paintbox1.canvas.pen.color:=clRed;
  paintbox1.canvas.MoveTo(Trunc(x1*faktor),Trunc(y1*faktor));
  paintbox1.canvas.LineTo(Trunc(x2*faktor),Trunc(y2*faktor));
end;


procedure TTravelForm.InitCities;
var i, maxPX, maxPY : integer;
begin
  Randomize;
  maxPX:=ScaleX(maxPXorg, orgDPI);
  maxPY:=ScaleY(maxPYorg, orgDPI);
  for i:=0 TO maxCity-1 do
    begin
      cities[i].x:=Random(maxPX-3)+2;
      cities[i].y:=Random(maxPY-3)+2;
      index[i]:=i
    end;
  InitCityDist;
  time:=-1;
end;

procedure TTravelForm.InitCityDist;
var j, k : integer;
    dist : real;
begin
  for k:=0 to maxCity-2 do
    for j:=k+1 to maxCity-1 do
      begin
        dist:=Sqrt(Sqr(cities[k].x-cities[j].x)+Sqr(cities[k].y-cities[j].y));
        cityDist[k,j] := dist;
        cityDist[j,k] := dist;
      end;
  for k:=0 to maxCity-1 do cityDist[k,k] := 0;
  InitDistGrid(maxCity);
end;

procedure TTravelForm.InitDistGrid(k:integer);
var j, n : integer;
    d    : real;
begin
  stringGrid2.colCount:=k+1;
  stringGrid2.rowCount:=k+1;
  stringGrid2.Height:=(k+2)*stringGrid2.DefaultRowHeight;
  stringGrid2.ColWidths[0]:=32;
  for j:=1 to k do
    begin
      stringGrid2.Cells[j,0]:=' '+NumberToName(j-1);
      stringGrid2.Cells[0,j]:=' '+NumberToName(j-1);
      stringGrid2.Cells[j,j]:='   --';
      for n:=j+1 to k do
        begin
          d:=cityDist[j-1,n-1];
          stringGrid2.Cells[j,n]:=format('%7.2f',[d]);
          stringGrid2.Cells[n,j]:=stringGrid2.Cells[j,n];
        end
    end;
end;

procedure TTravelForm.InitVars;
begin
  maxCity:=SpinEditAnz.value;
  scale:=Sqrt(maxCity);
  faktor:=1;{(paintBox1.width-40)/Sqrt(maxCity);  }
  temp:={maxCities;}Sqrt(maxCity);
  dummy:=startWert;
  dummy2:=start2;
  randSeed:=0;
  RadioGroup1Click(Self);
end;

procedure TTravelForm.Memo1Click(Sender: TObject);
var s     : string;
    k,n,j,l : integer;
begin
  if sender = nil
    then n := memo1.Lines.Count-1
    else n:=memo1.CaretPos.y;
  if n<memo1.Lines.Count
    then s:=memo1.Lines[n]
    else s:='';
  if s='' then exit;
  memo1.SelStart:=Pos(s,memo1.Text)-1;
  memo1.SelLength:=Length(s);
  if not PanelStart.Visible then exit;

  k:=pos('|',s);
  s:=copy(s,1,k-1);
  while s[length(s)]=' ' do delete(s,Length(s),1);
  if (s<>'') then
    begin
      ZeigeCities(false);
      j:=0;k:=3;s:=s+' ';
      while k<=Length(s) do
        begin
          l:=NameToNumber(s[k]);
          gLine(cities[j].x,cities[j].y,cities[l].x,cities[l].y,1);
          j:=l;
          k:=k+2;
          Delay(200);
        end;
    end;
end;

function TTravelForm.MyRandom(var aDummy:LONGINT):real;
CONST modul = 714025;
      mult  = 1366;
      add   = 150889;
      rm    = 1.400512e-6;
begin
  aDummy:=(mult*aDummy+add) MOD modul;
  result:=aDummy*rm
end;

function TTravelForm.NameToNumber(ch:char):integer;
begin
  if ch < 'a'
    then result:=ord(ch)-ord('A')
    else result:=26+ord(ch)-ord('a')
end;

procedure TTravelForm.NewDraw(CONST Ncuts : cityArr4);
begin
  gLine(Ncuts[1].x,Ncuts[1].y,Ncuts[2].x,Ncuts[2].y,0);
  gLine(Ncuts[3].x,Ncuts[3].y,Ncuts[4].x,Ncuts[4].y,0);
  gLine(Ncuts[4].x,Ncuts[4].y,Ncuts[2].x,Ncuts[2].y,1);
  gLine(Ncuts[1].x,Ncuts[1].y,Ncuts[3].x,Ncuts[3].y,1);
end;

function TTravelForm.NumberToName(nr:integer):char;
var j : integer;
begin
  if nr<=25
    then j:= nr+ord('A')
    else j:=(nr-26)+ord('a');
  result:=char(j);
end;

procedure TTravelForm.RadioGroup1Click(Sender: TObject);
var oldCalcMode : integer;
begin
  oldCalcMode :=calcMode;
  case radioGroup1.itemindex of
       0 : calcMode := TA_mode;
       1 : calcMode := SA_mode;
       2 : calcMode := voll_mode;
     end;
  if (oldCalcMode <> calcMode) and
     ( (oldCalcMode = voll_mode) or (calcMode = voll_mode) )
      then ZeigeGraph;
end;

procedure TTravelForm.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var r : integer;
begin
  if stadtEingabe and naechsteStadt and (maxCity<StrToInt(SpinEditAnz.text))
    then begin
           Inc(maxCity);
           cities[maxCity].x:=x;
           cities[maxCity].y:=y;
           PaintBox1.canvas.pen.color:=clRed;
           paintBox1.Canvas.Brush.Color:=clRed;
           if maxCity=0 then r:=3 else r:=2;
           paintBox1.Canvas.ellipse(x-r,y-r,x+r,y+r);
           ZeigeCityName(x,y,maxCity);
           naechsteStadt:=false;
           stadteingabe:=maxCity<StrToInt(SpinEditAnz.text)-1;
           if not stadteingabe then
             begin
               edit1.text:='';
               SpeedButtonInputCities.down:=false;
               Inc(maxCity);
               InitCityDist;
             end;
         end;
end;

procedure TTravelForm.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if stadtEingabe then naechsteStadt:=true;
end;

procedure TTravelForm.PaintBox1Paint(Sender: TObject);
begin
  ZeigeGraph;
end;

procedure TTravelForm.PanelBeendenCommandResize(Sender: TObject);
begin
  BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;

procedure TTravelForm.SpeedButtonInputCitiesClick(Sender: TObject);
begin
   case TSpeedButton(sender).tag of
    1 : begin
          if SpeedButtonInputCities.down
            then begin
                    maxCity:=-1;
                    stadtEingabe:=true;
                    naechsteStadt:=true;
                    ZeigeCities(true);
                    edit1.text:=RSArr[rsPunkteEingeben];
                 end;
            stringGrid2.visible:=false;
        end;
    2 : begin
          if SpeedButtonDistances.Down
            then begin
                   stringGrid2.visible:=true;
                   maxCity:=StrToInt(SpinEditAnz.text);
                   InitDistGrid(maxCity);
                 end
            else begin
                   InitVars;
                   if stringGrid2.visible then stringGrid2.visible:=false;
                   ZeigeCities(true);
                 end;
        end;
    end;
end;

procedure TTravelForm.SpinEditAnzChange(Sender: TObject);
begin
   if (SpinEditAnz.text<>'') then
    if (SpinEditAnz.value>=4) and (SpinEditAnz.value<=maxcities)
      then begin
             maxCity:=SpinEditAnz.value;
             InitCities;
             time := 0;
             ZeigeGraph;
             Memo1.Clear;
             edit1.Text:='';
           end
end;

procedure TTravelForm.SpinEditAnzExit(Sender: TObject);
begin
  if (SpinEditAnz.text<>'') then
    if (SpinEditAnz.value>=4)
     then if (SpinEditAnz.value<=maxcities)
            then begin
                   exit
                 end
            else SpinEditAnz.value:=maxCities
     else SpinEditAnz.value:=4;
  SpinEditAnz.setfocus;
end;

procedure TTravelForm.Start;
var cuts        : cityArr4;
    profit, tmp : REAL;

  procedure Totallaenge;
  var i : integer;
  begin
    laenge:=CityDist[index[maxCity-1],index[0]];
    for i:=0 TO maxCity-2
      do laenge:=laenge+CityDist[ index[i],index[i+1] ];
  end;

  procedure ReConnect(cut1,cut2:integer);
  var k : integer;
  begin
    if cut1>cut2 then begin k:=cut1; cut1:=cut2; cut2:=k; end;
    cut1:=cut1+1;
    while cut1<cut2 do
      begin
        k:=index[cut1];
        index[cut1]:=index[cut2];
        index[cut2]:=k;
        cut1:=cut1+1;
        cut2:=cut2-1;
      end;
    if zeigen then NewDraw(cuts);
  end;

  function Accept:BOOLEAN;
  begin
    Case CalcMode of
      SA_mode : begin
                  Accept:=(profit<0) or (MyRandom(dummy2)<exp(-profit/tmp));
                end;
      TA_mode : Accept:=profit<tmp;
      else Accept:=false;
     end;
end;

var cut1, cut2                  : integer;
    moves, succmoves, y0        : integer;
    tempScale,langScale,aktlang : REAL;
begin
  time:=0;
  for y0:=0 TO maxCity-1 do index[y0]:=y0;
  index[maxCity]:=0;
  tmp:=50; //Sqrt(maxCity);
  y0:=paintBox1.height DIV 2;
  tempScale:=y0/tmp;
  Totallaenge;
  maxLang:=laenge;
  aktLang:=laenge;
  langScale:= (y0-10)/maxLang;
  result[0]:= y0-10; //  Trunc(laenge*langScale) = y0-10;
  heat[0]  := y0; //  Trunc(tmp*tempScale) = y0;
  ZeigeGraph;
  ZeigeAktLoesung(index,laenge);
  repeat
    moves:=0;
    succmoves:=0;
    index[maxCity]:=index[0];
    repeat
      moves:=moves+1;
      repeat
        cut1:=Random(maxCity);
        cut2:=Random(maxCity);
      until Abs(cut2-cut1)>1;

      profit:= - cityDist[index[cut1],index[cut1+1] ]
               - cityDist[index[cut2],index[cut2+1] ]
             + cityDist[index[cut1],index[cut2] ]
             + cityDist[index[cut1+1],index[cut2+1] ];

      if Accept then
        begin
          succmoves:=succmoves+1;
          cuts[1]:=cities[index[cut1]];
          cuts[2]:=cities[index[cut1+1]];
          cuts[3]:=cities[index[cut2]];
          cuts[4]:=cities[index[cut2+1]];
          ReConnect(cut1,cut2);
          CheckPause;

          TotalLaenge;
          if laenge<aktlang then
            begin
              aktlang:=laenge;
              ZeigeAktLoesung(index,laenge);
            end;
        end;
    until (moves=maxCity*200) OR (succmoves=maxCity*10) or abbruch;
    tmp:=tmp*tempfaktor;

    time:=time+1;
    Totallaenge;
    if laenge<aktlang then
      begin
        aktlang:=laenge;
        ZeigeAktLoesung(index,laenge);
      end;
    result[time]:= Trunc(laenge*langScale);
    heat[time]  := Trunc(tmp*tempScale);
    gDraw(time,1);
    gDraw(time,2);
  until (succmoves=0) OR (time=maxTime) or abbruch;
  ZeigeGraph;
end;

procedure TTravelForm.VollStart;
var nichtBesucht : array[0..maxCities] of boolean;
    tour,mintour : TTourArray;
    n            : Integer;
    myMaxLang,
    myLaenge     : real;

  procedure Suchen(nr:integer);

    procedure TotalLaenge;
    var i : integer;
    begin
      myLaenge:=cityDist[tour[maxCity-1],tour[0]];
      for i:=0 TO maxCity-2
        do myLaenge:=myLaenge+cityDist[tour[i],tour[i+1]];
    end;

  var n        : integer;
      lastCity : city;
  begin
    if nr>=maxCity then
      begin
        TotalLaenge;
        if myLaenge<myMaxLang then
          begin
            myMaxLang:=myLaenge;
            ZeigeAktLoesung(tour,myLaenge);
            minTour:=tour;
          end;
        exit;
      end;
    for n:=0 to maxCity-1 do
      begin
        if nichtBesucht[n] then
          begin
            nichtBesucht[n]:=false;
            tour[nr]:=n;
            lastCity:=cities[tour[nr-1]];
            if zeigen and not keinePause
              then gLine(lastCity.x,lastCity.y,cities[n].x,cities[n].y,1);
            CheckPause;
            if abbruch then exit;
            suchen(nr+1);
            if zeigen and not keinePause
              then gLine(lastCity.x,lastCity.y,cities[n].x,cities[n].y,1);
            CheckPause;
            if abbruch then exit;
            nichtBesucht[n]:=true;
          end;
      end;
  end;

begin
  for n:=1 to maxCities do nichtBesucht[n]:=true;
  nichtBesucht[0]:=false;
  tour[0]:=0;
  mintour := Default(TTourArray);
  myMaxLang:=1.e20;
  suchen(1);
  ZeigeCities(false);
  if not abbruch then
    begin
      for n:=0 to maxCity-2 do
        gLine(cities[mintour[n]].x,cities[mintour[n]].y,cities[mintour[n+1]].x,cities[mintour[n+1]].y,1);
      gLine(cities[mintour[maxCity-1]].x,cities[mintour[maxCity-1]].y,cities[0].x,cities[0].y,1);
    end;
end;

procedure TTravelForm.ZeigeAktLoesung(const tour:TTourArray;aLaenge:real);
var s : string;
    n, x,y, x1,y1 : integer;
begin
   edit1.Text:=format(RSArr[rsAktuellKleinsteLaenge],[aLaenge]);
   s:='';
   for n:=0 to maxCity-1 Do s:=s+NumberToName(tour[n])+' ';
   s:=s+'A    |   '+format('%7.4f',[laenge]);
   memo1.Lines.Add(s);
   if not zeigen then exit;
   PaintBox1.canvas.pen.color:=clBlack;
   x:= Trunc(cities[tour[0]].x*faktor);
   y:= Trunc(cities[tour[0]].y*faktor);
   PaintBox1.canvas.MoveTo(x,y);
   for n:=1 to maxCity-1 do
     begin
       x1:= Trunc(cities[tour[n]].x*faktor);
       y1:= Trunc(cities[tour[n]].y*faktor);
       PaintBox1.canvas.LineTo(x1,y1);
     end;
  PaintBox1.canvas.LineTo(x,y);
end;

procedure TTravelForm.ZeigeCityName(x,y,nr: integer);
var s : string;
    n : integer;
begin
   s:=NumberToName(nr);
   paintBox1.Canvas.Brush.Color:=clBtnFace;
   n:=paintBox1.Canvas.TextHeight(s);
   paintBox1.Canvas.TextOut(x+3,y-3-n,s);
end;

procedure TTravelForm.ZeigeCities(mitVerbindung:Boolean);
var i, k, r, x,y, x1,y1 : integer;
begin
  PaintBox1.canvas.brush.color:=clBtnFace;
  PaintBox1.canvas.pen.color:=clWhite;
  PaintBox1.canvas.rectangle(0,0,paintbox1.width,paintbox1.height);
  if mitVerbindung then
    begin
      PaintBox1.canvas.pen.color:=clBlack;
      { Stadtverbindungen zeichnen }
      for k:=0 to maxCity-2 do
        begin
          x:=Trunc(cities[index[k]].x*faktor);
          y:=Trunc(cities[index[k]].y*faktor);
          for i:=k+1 TO maxCity-1 do
            begin
              x1:=Trunc(cities[index[i]].x*faktor);
              y1:=Trunc(cities[index[i]].y*faktor);
              PaintBox1.canvas.MoveTo(x,y);
              PaintBox1.canvas.LineTo(x1,y1);
            end;
        end;
   end;
  PaintBox1.canvas.pen.color:=clRed;
  paintBox1.Canvas.Brush.Color:=clRed;
  { Städte zeichnen }
  r:=3;
  for i:=0 TO maxCity-1 do
    begin
      x:=Trunc(cities[i].x*faktor);
      y:=Trunc(cities[i].y*faktor);
      paintBox1.Canvas.ellipse(x-r,y-r,x+r,y+r);
      r:=2;
      ZeigeCityName(x,y,i);
    end;
end;

procedure TTravelForm.ZeigeGraph;
var i,x,y : integer;
    s     : String[80];
begin
  ZeigeCities(false);
  if calcMode <> voll_mode then
    begin
      PaintBox1.canvas.Pen.Color:=clBlack;
     { Verlauf der Grenzen nach der Zeit }
      if time<(maxTime DIV 4) then x:=maxTime DIV 2-10 else x:=maxtime;
      x:=paintbox1.width-x{-offset}; y:=(paintBox1.height DIV 2);
      PaintBox1.canvas.TextOut(x,offset-10,RSArr[rsGrenze]);
      PaintBox1.canvas.MoveTo(x+maxTime,y);
      PaintBox1.canvas.LineTo(x,y);
      PaintBox1.canvas.LineTo(x,offset);
      PaintBox1.canvas.Pen.Color:=clBlue;
      for i:=0 TO time do PaintBox1.canvas.LineTo(x+i*2,y-heat[i]);
      { Verlauf der Streckenlänge nach der Zeit }
      PaintBox1.canvas.Pen.Color:=clBlack;
      PaintBox1.canvas.TextOut(x,y+offset-10,RSArr[rsLaenge]);
      PaintBox1.canvas.MoveTo(x+maxTime,2*y);
      PaintBox1.canvas.LineTo(x,2*y);
      PaintBox1.canvas.LineTo(x,y+offset);
      y:=2*y;
      PaintBox1.canvas.Pen.Color:=clBlue;
      for i:=0 TO time do PaintBox1.canvas.LineTo(x+i*2,y-result[i]);
      if time>0 then
        begin
          s:=format(RSArr[rsAnfangsUndEndlaenge],[maxLang,laenge]);
          edit1.Text:=s;
        end;
    end;
end;

end.

