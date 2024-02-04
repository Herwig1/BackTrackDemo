unit rundweg;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Weg des Handlungsreisenden; Wahl der Srädte und Entfernungen sind möglich
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, Grids, Buttons,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

CONST maxStaedte = 16;
      ersteStadt = 1;

      twoWays = clBlack;
      selWay  = clRed;
      oneWay1 = clYellow;
      oneWay2 = clAqua;
      xxxWay  = clWhite;

      zwischenErgebnis : BOOLEAN  = TRUE;
      einbahnStrasse   : BOOLEAN  = FALSE;
      ordStadt0        : BYTE     = Ord('A')-1;

      maxPXorg        = 400;
      maxPYorg        = 400;

      dist0  : array[1..8,1..8] of integer =
             ((  0, 10,  0,  0, 40,  0, 30,  0),
              ( 10,  0, 12, 20,  0,  0,  0,  0),
              (  0, 12,  0, 15, 66,  0,  0, 25),
              (  0, 20, 15,  0,  0, 50,  0,  0),
              ( 40,  0,  0,  0,  0,  0,  0, 60),
              (  0,  0,  0, 50,  0,  0, 10,  0),
              ( 30,  0,  0,  0,  0, 10,  0,  0),
              (  0,  0, 25,  0,  0,  0,  0,  0));


type  stadt_Nr      = ersteStadt..maxStaedte;
      stadt_Nr_plus = ersteStadt..maxStaedte+1;
      city          = record
                         x,y : Integer;
                      end;

type

  { TRundwegForm }

  TRundwegForm = class(TForm)
    ButtonStart: TBitBtn;
    FramePausenStrg1: TFramePausenStrg;
    Memo1: TMemo;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    PanelBrett: TPanel;
    PanelEdit: TPanel;
    edit1: TEdit;
    PaintBox1: TPaintBox;
    Splitter1: TSplitter;
    StringGrid2: TStringGrid;
    PanelRechts: TPanel;
    PanelStart: TPanel;
    SpeedButtonInputCities: TSpeedButton;
    SpeedButtonDistances: TSpeedButton;
    StaticText1: TStaticText;
    SpinEdit1: TSpinEdit;
    CheckBoxZwischenSchritt: TCheckBox;
    procedure BitBtnZwischenSchrittClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure SpeedButtonInputCitiesClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    anzahlStaedte,maxZahl, lsgNr : integer;
    stadtEingabe,
    naechsteStadt: BOOLEAN;
    cities       : array[stadt_Nr] of city;
    gefahren     : array[stadt_Nr,stadt_Nr] of BOOLEAN;
    dist         : array[stadt_Nr,stadt_Nr] of integer;
    wayColor     : array[stadt_Nr,stadt_Nr] of TColor;
    besucht      : array[stadt_Nr] of integer;
    weg,min_Weg  : STRING;
    min_Weg_Len,
    weg_Len       : WORD;

    { Private-Deklarationen }
    Function Ausgabe(Const aWeg:STRING;laenge:WORD):string;
    procedure Fahre_Weiter_nach(ort:stadt_Nr);
    procedure gLine(nr1,nr2:stadt_Nr; f:integer);
    procedure Init;
    procedure InitCities;
    procedure InitDistGrid(k:stadt_Nr;neu : Boolean);
    procedure InitVars;
    function  Runde_fertig:BOOLEAN;
    procedure ZeigeCities(mitVerbindung:Boolean);
    procedure ZeigeCityName(x, y, nr:integer);
    procedure ZeigeRundweg;
  public
    { Public-Deklarationen }
  end;

var
  RundwegForm: TRundwegForm;

implementation

 {$R *.lfm}

function TRundwegForm.Ausgabe(const aWeg: STRING; laenge: WORD): string;
var i : BYTE;
begin
  result:='';
  for i:=1 TO Length(aWeg)-1 do result:=result+aWeg[i]+'_';
  result:=result+aWeg[length(aWeg)]+' :  '+IntToStr(laenge);
  edit1.text:=result;
end;

procedure TRundwegForm.BitBtnZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.BitBtnZwischenSchrittClick(sender);
end;

procedure TRundwegForm.ButtonStartClick(Sender: TObject);
begin
  if stringGrid2.Visible then
    begin
      InitVars;
      SpeedButtonDistances.down:=false;
      stringGrid2.Visible:=false;
    end;
  BitBtnBeenden.Enabled:=false;
  PanelStart.Hide;
  FramePausenStrg1.NormalStart;
  zeigeCities(true);
  Init;
  Fahre_Weiter_nach(ersteStadt);
  if abbruch
    then edit1.text:=RSArr[rsSucheAbgebrochen]
    else if (min_Weg<>'')
           then begin
                  edit1.text:=RSArr[rsRundwegKleinsteLaenge]+Ausgabe(min_Weg,min_Weg_Len);
                  ZeigeRundweg
                end
           else edit1.text:=RSArr[rsKeinenRundwegGefunden];
  FramePausenStrg1.Hide;
  PanelStart.show;
  PanelStart.repaint;
  BitBtnBeenden.Enabled:=true;
end;

procedure TRundwegForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked );
end;


procedure TRundwegForm.Fahre_Weiter_nach(ort:stadt_Nr);
var stadt : stadt_Nr_plus;
    s     : string;
begin
  stadt:=ersteStadt;
  repeat
    if not gefahren[ort,stadt] then
      begin
        weg_Len:=weg_Len+dist[ort,stadt];
        if zeigen then gLine(ort,stadt,1);
        if weg_Len<min_Weg_Len then
          begin
            weg:=weg+Chr(ordStadt0+stadt);
            CheckPause;
            gefahren[ort,stadt]:=TRUE;
            Inc(besucht[stadt]);
            if (stadt=ersteStadt) and Runde_fertig
              then begin
                     inc(lsgNr);
                     min_Weg_Len:=weg_Len; min_Weg:=weg;
                     s:=Ausgabe(weg,weg_Len);
                     memo1.Lines.Add(s);
                   end
              else Fahre_Weiter_nach(stadt);
           { Dec(lastOrt);}
            system.Delete(weg,Length(weg),1);
            gefahren[ort,stadt]:=FALSE;
            Dec(besucht[stadt])
          end;
        weg_Len:=weg_Len-dist[ort,stadt];
        if zeigen then gLine(ort,stadt,0);
      end;
      Inc(stadt);
   Until (stadt>anzahlStaedte) or abbruch;
end;

procedure TRundwegForm.FormActivate(Sender: TObject);
begin
  stadtEingabe:=false;
  naechsteStadt:=false;
  anzahlStaedte:=StrToInt(spinedit1.text);
  maxZahl:=0;
  initCities;
  InitDistGrid(anzahlStaedte,true);
  paintbox1.refresh;
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  TranslationsFor_rundweg
end;

procedure TRundwegForm.FormCreate(Sender: TObject);
var fs : integer;
begin
  SkaliereForm(self);
  fs:=stringGrid2.Font.Size;
  repeat
    fs:=fs-1;
    stringGrid2.Font.Size:=fs;
    edit1.Font.size:=fs;
  until stringGrid2.Font.size<font.size
end;

procedure TRundwegForm.gLine(nr1,nr2:stadt_Nr; f:integer);
begin
  with paintBox1.canvas do
    begin
      case f of
        0 : pen.color:=wayColor[nr1,nr2];
        1 : pen.color:=clRed;
        2 : pen.color:=clWhite;
        end;
      MoveTo(cities[nr1].x,cities[nr1].y);
      LineTo(cities[nr2].x,cities[nr2].y);
    end;
end;


procedure TRundwegForm.Init;
var i,k : BYTE;
begin
  for i:=ersteStadt TO anzahlStaedte do
    begin
      for k:=ersteStadt TO anzahlStaedte do gefahren[i,k]:=(dist[i,k]=0);
      besucht[i]:=0
    end;
  min_Weg:='';  weg:=Chr(ordStadt0+ersteStadt);
  min_Weg_Len:=$7FFF;  weg_Len:=0;
  besucht[ersteStadt]:=1;
  lsgNr:=-1;
  memo1.Clear;
end;

procedure TRundwegForm.InitCities;
var i            : stadt_Nr_plus;
    maxPX, maxPY : integer;
begin
  Randomize;
  maxPX:=ScaleX(maxPXorg, orgDPI);
  maxPY:=ScaleY(maxPYorg, orgDPI);
  for i:=maxZahl+1 TO anzahlStaedte do
    begin
      cities[i].x:=Random(maxPX-3)+2;
      cities[i].y:=Random(maxPY-3)+2;
    end;
end;

procedure TRundwegForm.InitDistGrid(k:stadt_Nr;neu : Boolean);
var j, n : stadt_Nr;
    d    : word;
begin
  stringGrid2.colCount:=k+1;
  stringGrid2.rowCount:=k+1;
  stringGrid2.Height:=(k+2)*stringGrid2.DefaultRowHeight;
  for j:=1 to k do
    begin
      stringGrid2.Cells[j,0]:=Char(ordStadt0+j);
      stringGrid2.Cells[0,j]:=Char(ordStadt0+j);
      stringGrid2.Cells[j,j]:='--';
      for n:=1 to k do if n<>j then
        if neu or (n>maxZahl) or (j>maxZahl)
        then begin
               d:=trunc(Sqrt(Sqr(cities[j].x-cities[n].x)+Sqr(cities[j].y-cities[n].y) ) );
               stringGrid2.Cells[j,n]:=IntToStr(d);
             end
        else begin
               stringGrid2.Cells[j,n]:=IntToStr(dist[j,n]);
             end;
    end;
  if k>maxZahl then begin maxZahl:=k; InitVars end
               else if neu then InitVars;
end;

procedure TRundwegForm.InitVars;
var j,n : stadt_Nr;
    d   : word;
    s   : string[20];
    f   : TColor;
begin
  for j:=1 to anzahlStaedte do
    for n:=1 to anzahlStaedte  do
       begin
         s:=stringGrid2.Cells[j,n];
         if (s<>'') and (Pos(s[1],'1234567890')>0)
         then
          try
            d:=StrToInt(s);
          except
            d:=0;
          end
          else d:=0;
          dist[j,n]:=d;
        end;
  for j:=ersteStadt to anzahlStaedte-1 do
      for n:=j+1 to anzahlStaedte do
         begin
           if dist[j,n]<>0
             then if dist[n,j]<>0 then f:=twoWays
                                  else f:=oneway1
             else if dist[n,j]<>0 then f:=oneway2;
           wayColor[j,n]:=f;
           wayColor[n,j]:=f;
         end;
end;

procedure TRundwegForm.Memo1Click(Sender: TObject);
var s     : string;
    k,n,j : integer;
begin
  n:=memo1.CaretPos.y;
  if n<memo1.Lines.Count
    then s:=memo1.Lines[n]
    else s:='';
  if s='' then exit;
  memo1.SelStart:=Pos(s,memo1.Text)-1;
  memo1.SelLength:=Length(s);
  s:=copy(s,1,Pos(' :  ', s)-1);
  if s<>'' then ZeigeCities(true);
  n:=3; k:=ersteStadt;
  while n<=Length(s) do
    begin
      j:=Ord(s[n])-ordStadt0;
      gLine(k,j,1);
      k:=j;
      n:=n+2;
      Delay(200);
    end;
end;

procedure TRundwegForm.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var r : integer;
begin
  if stadtEingabe and naechsteStadt and (anzahlStaedte<StrToInt(spinEdit1.text))
    then begin
           Inc(anzahlStaedte);
           cities[anzahlStaedte].x:=x;
           cities[anzahlStaedte].y:=y;
           PaintBox1.canvas.pen.color:=clRed;
           paintBox1.Canvas.Brush.Color:=clRed;
           if anzahlStaedte=1 then r:=3 else r:=2;
           paintBox1.Canvas.ellipse(x-r,y-r,x+r,y+r);
           ZeigeCityName(x,y,anzahlStaedte);
           naechsteStadt:=false;
           stadteingabe:=anzahlStaedte<StrToInt(spinEdit1.text);
           if not stadteingabe then
             begin
               edit1.text:='';
               SpeedButtonInputCities.down:=false;
               InitDistGrid(anzahlStaedte,true);
             end;
         end;
end;

procedure TRundwegForm.PaintBox1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if stadtEingabe then naechsteStadt:=true;
end;

procedure TRundwegForm.PaintBox1Paint(Sender: TObject);
begin
  zeigeCities(true)
end;

procedure TRundwegForm.PanelBeendenCommandResize(Sender: TObject);
begin
  BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;

function TRundwegForm.Runde_fertig:BOOLEAN;
var i : stadt_Nr;
begin
  for i:=1 TO anzahlStaedte do
    if besucht[i]=0 then begin Runde_fertig:=FALSE; EXIT end;
  Runde_fertig:=TRUE
end;

procedure TRundwegForm.SpeedButtonInputCitiesClick(Sender: TObject);
begin
  case TSpeedButton(sender).tag of
    1 : begin
          if SpeedButtonInputCities.down
            then begin
                    anzahlStaedte:=0;
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
                   anzahlStaedte:=StrToInt(spinedit1.text);
                   InitDistGrid(anzahlStaedte,false);
                 end
            else begin
                   InitVars;
                   if stringGrid2.visible then stringGrid2.visible:=false;
                   ZeigeCities(true);
                 end;
        end;
    end;
end;

procedure TRundwegForm.SpinEdit1Change(Sender: TObject);
begin
if (spinEdit1.text='') or
   (spinEdit1.value<3)  or  (spinEdit1.value>maxStaedte)
  then begin
         SpeedButtonInputCities.enabled:=false;
         SpeedButtonDistances.enabled:=false;
         ButtonStart.enabled:=false;
         edit1.text:=RSArr[rsUngueltigerWertAnzahlStaedte];
       end
  else begin
         SpeedButtonInputCities.enabled:=true;
         SpeedButtonDistances.enabled:=true;
         ButtonStart.enabled:=true;
         if anzahlStaedte<spinEdit1.value
           then begin
                  anzahlStaedte:=spinEdit1.value;
                  InitCities;
                  InitDistGrid(anzahlStaedte,false);
                 end
           else anzahlStaedte:=spinEdit1.value;
         ZeigeCities(true);
         edit1.text:='';
       end;
end;

procedure TRundwegForm.ZeigeCities(mitVerbindung:Boolean);
var k,i,r :integer;
    x,y   : integer;
begin
  PaintBox1.canvas.brush.color:=clBtnFace;
  PaintBox1.canvas.pen.color:=clWhite;
  PaintBox1.canvas.rectangle(0,0,paintbox1.width,paintbox1.height);
  { Stadtverbindungen zeichnen }
  if mitVerbindung then
    for k:=ersteStadt to anzahlStaedte-1 do
      for i:=k+1 to anzahlStaedte do gLine(k,i,0);
  r:=3;
  PaintBox1.canvas.pen.color:=clRed;
  paintBox1.Canvas.Brush.Color:=clRed;
  for i:=ersteStadt TO anzahlStaedte do
    begin
      x:=cities[i].x;
      y:=cities[i].y;
      paintBox1.Canvas.ellipse(x-r,y-r,x+r,y+r);
      ZeigeCityName(x,y,i);
      r:=2;
    end;
end;

procedure TRundwegForm.ZeigeCityName(x,y,nr: integer);
var s : string;
    n,j : integer;
begin
   if nr<=26
     then j:=(nr-1)+ord('A')
     else j:=(nr-26)+ord('a');
   s:=char(j);
   paintBox1.Canvas.Brush.Color:=clBtnFace;
   n:=paintBox1.Canvas.TextHeight(s);
   paintBox1.Canvas.TextOut(x+3,y-3-n,s);
end;

procedure TRundwegForm.ZeigeRundweg;
var k, stadt0, stadt1, stadt2 : integer;
    c : char;
begin
  stadt2:=0;
  ZeigeCities(false);
  c:=min_Weg[1];
  if c<='Z' then stadt1:=ord(c)-ordStadt0
            else stadt1:=ord(c)-ord('a')+27;
  stadt0:=stadt1;
  for k:=2 to Length(min_Weg) do
    begin
      c:=min_Weg[k];
      if c<='Z' then stadt2:=ord(c)-ordStadt0
                else stadt2:=ord(c)-ord('a')+27;
      gLine(stadt1,stadt2,1);
      stadt1:=stadt2;
    end;
  gLine(stadt2,stadt0,1);
end;

end.

