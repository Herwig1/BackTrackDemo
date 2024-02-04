unit solitaer_test;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Das (Kugel-Lege-)Spiel Solitär;
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.6

   letzte Änderung: 17.11.2023 *)

interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, LazFileUtils,
  StdCtrls, ExtCtrls, Buttons,
  pausensteuerung;

type
  TStatus = (frei, belegt, ungueltig);
  TSprungRtg = (rechts,oben,links,unten,keinSprung);
  TSprungArr = Array[rechts..unten] of boolean;

const
     maxgame = 12;
     gamename : array[0..maxgame-1] of string =
                 ('Kreuz',    'Plus',    'Kamin',    'Acht',
                  'Pyramide', 'Pfeil-1', 'Herkules', 'Spiegel',
                  'Pfeil-2',  'Diamant', 'Solitär',  'Solitär 2');
    gameImage : array[0..maxgame-1,1..7] of byte =
                  (($00, $08, $1c, $08, $08, $00, $08),   //cross
                   ($00, $08, $08, $3e, $08, $08, $08),   //plus
                   ($1c, $1c, $1c, $14, $00, $00, $08 ),  //kamin
                   ($00, $1c, $14, $1c, $14, $1c, $08 ),  //eight
                   ($00, $08, $1c, $3e, $7f, $00, $08 ),  //piramid
                   ($18, $1c, $3e, $08, $08, $1c, $1c ),  //arrow-1
                   ($10, $1c, $1c, $7f, $14, $14, $14 ),  //hercules
                   ($00, $14, $36, $7f, $36, $14, $00 ),  //mirror
                   ($18, $1c, $3e, $7f, $08, $1c, $1c ),  //arrow-2
                   ($08, $1c, $3e, $7f, $3e, $1c, $08 ),  //diamond
                   ($1c, $1c, $7f, $7f, $7f, $1c, $1c ),  //solitair
                   ($1c, $3e, $7f, $7f, $7f, $3e, $1c )); //solitair 2


const a = 40;  //Feldgröße
      b = 5;   //a-2b = Durchmesser

     nach_links  = '<';
     nach_rechts = '>';
     nach_oben   = '^';
     nach_unten  = 'v';
     { Anzahl der möglichen Züge von der jeweiligen Position:
           .  .  2  1  2  .  .
           .  .  2  1  2  .  .
           2  2  4  4  4  2  2
           1  1  4  4  4  1  1
           2  2  4  4  4  2  2
           .  .  2  1  2  .  .
           .  .  2  1  2  .  .    }

     // kreuz
        maxFeldAnzahl_kreuz = qSize*qSize - (qSize-3)*(qSize-3);
        maxZugZahl_kreuz = 36 {mittlere Felder} + 20 {Randfelder} + 20 {Randfelder-1} + 16*(qSize-7);

     {     .  .  2  1  2  .  .
           .  2  2  3  2  2  .
           2  2  4  4  4  2  2
           1  3  4  4  4  3  1
           2  2  4  4  4  2  2
           .  2  2  3  2  2  .
           .  .  2  1  2  .  .    }
     // raute
        maxFeldAnzahl_Raute = qSize*qSize - (qSize-3)*(qSize-3) + 4;
        maxZugZahl_Raute = 36 {mittlere Felder} + 28 {Randfelder} + 28 {Randfelder-1};

     maxFeldAnzahl = maxFeldAnzahl_Raute;
     maxZugZahl    = maxZugZahl_Raute;

type
  TLinZugFolge = array[1..maxFeldAnzahl-2] of byte;

  { TFormSolitaer }
  TFormSolitaer = class(TForm)
    BitBtnBeenden: TBitBtn;
    ButtonAutoPlay: TBitBtn;
    ButtonManuell: TButton;
    ButtonZugZurueck: TButton;
    ButtonZeigeZwischenStand: TButton;
    ButtonZeigeZugFolge: TButton;
    ButtonAbbruchUndSpeichern: TButton;
    ButtonErgebnis: TButton;
    CheckBoxAll: TCheckBox;
    CheckBoxZwischenSchritt: TCheckBox;
    ComboBoxBrettNumerierung: TComboBox;
    ComboBoxReihenfolge: TComboBox;
    ComboBoxVerfahren: TComboBox;
    ComboBoxBrettFormat: TComboBox;
    FramePausenStrg1: TFramePausenStrg;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelAnzLsg: TLabel;
    LabelAnzahlTests: TLabel;
    LabelTestet: TLabel;
    LabelMrd: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    PaintBox1: TPaintBox;
    PanelStart: TPanel;
    PanelPaintBox: TPanel;
    PanelLeftSide: TPanel;
    PanelCommand: TPanel;
    PanelOben: TPanel;
    PanelBeendenCommand: TPanel;
    PanelPlayCommand: TPanel;
    PanelVorbereiten: TPanel;
    Splitter1: TSplitter;
    procedure ButtonAbbruchUndSpeichernClick(Sender: TObject);
    procedure ButtonAutoPlayClick(Sender: TObject);
    procedure ButtonErgebnisClick(Sender: TObject);
    procedure ButtonFeldNeuClick(Sender: TObject);
    procedure ButtonManuellClick(Sender: TObject);
    procedure ButtonZeigeZwischenStandClick(Sender: TObject);
    procedure ButtonZeigeZugFolgeClick(Sender: TObject);
    procedure ButtonZugZurueckClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure ComboBoxBrettFormatChange(Sender: TObject);
    procedure ComboBoxBrettNumerierungChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure PaintBox1Click(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
  private
    { Private-Deklarationen }
    brettVorgabe     : Array[-1..qSize+2,-1..qSize+2] of TStatus;
    brettManuellPlay : Array[-1..qSize+2,-1..qSize+2] of TStatus;
    brett            : Array[1..qSize,1..qSize] of TStatus;
    brettXYtoNr      : Array[1..qSize,1..qSize] of integer;
    feldNrToXY       : Array[1..maxFeldAnzahl] of TPoint;
    linBrett : Array[1..maxFeldAnzahl] of TStatus;
    testZug  : Array[1..maxZugZahl] of record von, ueber, nach : integer end;
    zugvon   : Array[1..qSize,1..qSize] of TSprungArr;
    zug, mZug: array[1..maxFeldAnzahl] of record vx,vy,nx,ny:integer end;
    zugR     : array[1..maxFeldAnzahl] of record x,y :integer; rtg : char end;
    LinZug   : TLinZugFolge;    //array[1..maxFeldAnzahl-2] of integer;

    bm_frei, bm_belegt : TBitmap;
    maxAnzahlBrettPos, maxAnzahlErlaubteZuege,
    maxAnzahlPins, AnzahlZuegeBisLoesung, endPosX, endPosY, endPosNr,
    brettFormat, brettNumerierung, bf_verfahren, bf_startRichtung : byte; //integer;
    anzahlPinOnWinPath,anzahlPinBetweenWinPath,anzahlPinOutsideWinPath : byte;       //count of pin types 1,2,3
    mZugNr, zugNr, zugNrOnESC : integer;
    testCounter,testMrd       : longint;
    restAnzahlPins,anzLsg     : integer;

    autoPlay, pinAusgewaehlt,

    speichern, laden,

    direktZugXY : boolean;
     findAll : boolean;
    speicherListe : TStringList;
    lastx, lasty, lastFeldx, lastFeldy, sx,sy, sprung : integer;
    startTime, endTime : longint;
    procedure CheckInteraction;
    procedure InitBrett;
    procedure InitBrettFormat(brettForm:integer);
    procedure InitBrettZaehlung(art:integer);
    procedure InitStartPosition;
    procedure InitStartVars;
    procedure InitZugArray(startMove:TSprungRtg);
    procedure InitZugVon;
    procedure MoveStein(x0,y0, x1,y1:integer);
    procedure Umrechnen_ZugXY_to_LinZug;
    procedure Umrechnen_mZugXY_to_LinZug;
    procedure Umrechnen_LinZug_to_ZugXY(const aLinZug:TLinZugFolge);
    procedure Vorbereiten;
    procedure SpielZugBruteForceSimple(var erfolg:boolean);
    procedure SpielZugBruteForceSimpleLoadAndSave(var erfolg:boolean);
    procedure SpielZugBruteForceOptimiert(var erfolg:boolean);
    procedure SpielZugBruteForceIterativ(var erfolg:boolean; mitFilter, mitPinBewertung : boolean);

    procedure ZeichneBrett;
    procedure ZeichneFeld(x,y:integer;status:TStatus);
    procedure ZeichneLinBrett(nr:integer; normal:boolean);
    procedure ZeigeErgebnis(erfolg:boolean);
    procedure ZeigeLinZugFolge(aLinZug:TLinZugFolge; nr:byte);
    procedure ZeigeZwischenLoesung;
  public
    { Public-Deklarationen }
  end;

var
  FormSolitaer: TFormSolitaer;

implementation

  {$R *.lfm}

procedure TFormSolitaer.ButtonAbbruchUndSpeichernClick(Sender: TObject);
begin
  if ButtonAbbruchUndSpeichern.tag=0
    then begin
           speicherListe:=TStringList.Create;
           speicherListe.Add(comboBoxBrettFormat.Items[comboBoxBrettFormat.ItemIndex]);
           speicherListe.Add(IntToStr(comboBoxBrettFormat.ItemIndex));
           speicherListe.Add(comboBoxBrettNumerierung.Items[comboBoxBrettNumerierung.ItemIndex]);
           speicherListe.Add(IntToStr(comboBoxBrettNumerierung.ItemIndex));
           speicherListe.Add(comboBoxReihenfolge.Items[comboBoxReihenfolge.ItemIndex]);
           speicherListe.Add(IntToStr(comboBoxReihenfolge.ItemIndex));
           speicherListe.Add(IntToStr(testCounter));
           speicherListe.Add(IntToStr(testMrd));
           speicherListe.Add(IntToStr(restAnzahlPins));
           speichern:=true;
           FramePausenStrg1.BitBtnBreakClick(nil);
         end
    else begin
           laden:=true;
           ButtonAbbruchUndSpeichern.Caption:='Abbruch+Speichern';
           ButtonAbbruchUndSpeichern.tag:=0;
           ButtonFeldNeuClick(Sender);
           ButtonAutoPlayClick(nil);
         end;
end;

procedure TFormSolitaer.ButtonErgebnisClick(Sender: TObject);
var k : integer;
    s : string;
begin
  if listbox1.Visible
    then begin
           listbox1.visible:=false;
           ZeichneBrett
         end
    else begin
           listbox1.Items.Clear;
           for k:=1 to zugNr do with zug[k] do
             begin
               s:='('+inttostr(vx)+'/'+ inttostr(vy)+') '+ zugR[k].rtg +'     ('+inttostr(nx)+'/'+ inttostr(ny)+')';
               listbox1.Items.Add(s);
             end;
           listbox1.Visible:=true;
         end;
end;

procedure TFormSolitaer.ButtonFeldNeuClick(Sender: TObject);
begin
  initBrett;
  InitStartVars;
  zeichneBrett;
  Memo1.Clear;
  ButtonZugZurueck.Visible:=false;
end;

procedure TFormSolitaer.ButtonManuellClick(Sender: TObject);
begin
  if buttonManuell.Tag=0
    then begin
           InitBrett;
           InitZugArray(TSprungRtg(bf_StartRichtung));
           autoPlay:=false;
           mZugNr:=0;
           fillChar(mZug,sizeOf(mZug),0);
           buttonManuell.Tag:=1;
           buttonManuell.Caption:='Spiel beenden';
           buttonAutoPlay.Visible:=false;
           bitbtnBeenden.Enabled:=false;
         end
    else begin
           ButtonZugZurueck.Visible:=false;;
           buttonManuell.Tag:=0;
           buttonManuell.Caption:='Manuell';
           abbruch:=true;
           InitBrett;
           autoPlay:=true;
           ZeigeErgebnis(false);
           buttonAutoPlay.Visible:=true;
           bitbtnBeenden.Enabled:=true;
         end;
end;


procedure TFormSolitaer.ButtonZeigeZugFolgeClick(Sender: TObject);
var nr : byte;
begin
  nr:=zugNr;
  if direktZugXY then Umrechnen_ZugXY_to_LinZug;
  if not autoPlay then begin nr:=mZugNr; Umrechnen_mZugXY_to_LinZug; end;
  ZeigeLinZugFolge(linZug,nr);
end;

procedure TFormSolitaer.ButtonZugZurueckClick(Sender: TObject);
var x0,y0, x1,y1, x2,y2 : integer;
begin
  with mZug[mZugNr] do begin x0:=vx; y0:=vy; x2:=nx;  y2:=ny; x1:=(x0+x2) div 2; y1:=(y0+y2) div 2; end;
  brettManuellPlay[x0,y0]:=belegt; ZeichneFeld(x0,y0,belegt);
  brettManuellPlay[x1,y1]:=belegt; ZeichneFeld(x1,y1,belegt);
  brettManuellPlay[x2,y2]:=frei;   ZeichneFeld(x2,y2,frei);
  dec(mZugNr);
  if mZugNr=0 then ButtonZugZurueck.Visible:=false;
end;

procedure TFormSolitaer.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked);
  if zeigen
    then ZeichneBrett;
end;

procedure TFormSolitaer.ComboBoxBrettFormatChange(Sender: TObject);
begin
  initBrett;
  InitStartVars;
  ButtonZugZurueck.Visible:=false;
  ComboBoxBrettNumerierungChange(Sender);
end;

procedure TFormSolitaer.ComboBoxBrettNumerierungChange(Sender: TObject);
var x, y  : integer;
    s, s1 : string;
begin
  initBrett;
  zeichneBrett;
  Memo1.Clear;
  for y:=1 to qSize do
    begin
      s :='';
      for x:=1 to qSize do
        begin
          if brettVorgabe[x,y]<>ungueltig
            then s1 := IntToStr(BrettXYToNr[x,y])+' '
            else s1 := '   ';
          if Length(s1)<3 then s1:=' '+s1;
          s:=s+s1;
        end;
      memo1.Lines.Add(s);
    end;
end;

procedure TFormSolitaer.ButtonZeigeZwischenStandClick(Sender: TObject);
begin
  if direktZugXY then Umrechnen_ZugXY_to_LinZug;
  if not autoPlay then Umrechnen_mZugXY_to_LinZug;
  ZeigeZwischenLoesung;
end;

procedure TFormSolitaer.ButtonAutoPlayClick(Sender: TObject);
var erfolg   : boolean;
    x,y,n,j  : integer;
    k        : TSprungRtg;
begin
  if buttonManuell.Tag=1 then ButtonManuellClick(nil);
  if sender=nil
    then bf_verfahren := 1
    else bf_verfahren := ComboBoxVerfahren.ItemIndex+1;
  erfolg:=false;
  autoPlay:=true;
  labelAnzLsg.Caption:='';
  Vorbereiten;
  startTime:=GetTickCount64;
  case bf_verfahren of
      1 : begin     // BrutForce rekursiv
              ButtonAbbruchUndSpeichern.Caption:='Abbruch+Speichern';
              ButtonAbbruchUndSpeichern.tag:=0;
              ButtonAbbruchUndSpeichern.visible:=true;
              direktZugXY:=true;
              zugNrOnEsc := 0;
              if laden
                then begin
                       speicherListe:=TStringList.Create;
                       speicherListe.LoadFromFile('solitaer.txt');
                       comboBoxBrettFormat.ItemIndex:=StrToInt(speicherListe.strings[1]);
                       comboBoxBrettNumerierung.ItemIndex:=StrToInt(speicherListe.strings[3]);
                       comboBoxReihenfolge.ItemIndex:=StrToInt(speicherListe.strings[5]);

                       Vorbereiten;
                       testCounter:=StrToInt(speicherListe.strings[6]);
                       testMrd:=StrToInt(speicherListe.strings[7]);
                       LabelAnzahlTests.Caption:=speicherListe.strings[6];
                       if testMrd<>0 then LabelMrd.Caption:=speicherListe.strings[7];
                        {n:=StrToInt(speicherListe.strings[8]); }  // dummy restAnzahlPins
                       for n:=8 downTo 0 do speicherListe.delete(n);
                       SpielZugBruteForceSimpleLoadAndSave(erfolg);
                     end
                else SpielZugBruteForceSimple(erfolg);

              if speichern then
                begin
                  j:=1;
                  while j<=zugNrOnESC do
                    begin
                      with zug[j] do begin x:=vx; y:=vy; end;
                      n:=brettXYToNr[x,y];
                      speicherListe.Add(IntTostr(n));
                      if x=zug[j].nx
                        then if y+2=zug[j].ny
                               then k:=unten
                               else k:=oben
                        else if x+2=zug[j].nx
                               then k:=rechts
                               else k:=links;
                      speicherListe.Add(IntToStr(ord(k)));
                      j:=j+1;
                    end;
                  speicherListe.SaveToFile('solitaer.txt');
                  if FileExistsUTF8('solitaer.txt') { *Converted from FileExists* }
                    then begin
                           ButtonAbbruchUndSpeichern.Caption:='Fortsetzen';
                           ButtonAbbruchUndSpeichern.tag:=1;
                         end
                    else ButtonAbbruchUndSpeichern.visible:=false;
                end;
          end;
       2 : SpielZugBruteForceOptimiert(erfolg);            // BrutForce rekursiv optimiert

       3 : SpielZugBruteForceIterativ(erfolg,false,false); // BrutForce iterativ

       4 : SpielZugBruteForceIterativ(erfolg,true,false);  // BrutForce iterativ plus stack

       5 : SpielZugBruteForceIterativ(erfolg,false,true);  // BrutForce iterativ plus Pin-Bewertung

       6 : SpielZugBruteForceIterativ(erfolg,true,true);   // BrutForce iterativ plus stack plus Pin-Bewertung
  end;
  endTime:=GetTickCount64;
  if erfolg then
    if bf_verfahren <= 2
      then Umrechnen_ZugXY_to_LinZug
      else Umrechnen_LinZug_to_ZugXY(linZug);
  ZeigeErgebnis(erfolg);
  memo1.Lines.Add('Zeit: '+intToStr(endTime-startTime)+' ms');
end;

procedure TFormSolitaer.CheckInteraction;
begin
  CheckPause;
  testCounter:=testCounter+1;
  if testCounter and $1FF = $1FF then
    begin
      if testCounter>=1000000000 then
        begin
          testMrd:=testMrd+1;
          LabelMrd.caption:=intToStr(testMrd);
          testCounter:=testCounter-1000000000
        end;
      LabelAnzahlTests.caption:=intToStr(testCounter);
    end;
end;


procedure TFormSolitaer.FormActivate(Sender: TObject);
begin
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  ZeichneBrett;
end;

procedure TFormSolitaer.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  bm_frei.Free;
  bm_belegt.Free;
end;

procedure TFormSolitaer.FormCreate(Sender: TObject);

  procedure MakeBitMap(var bm: TBitMap; kugel: boolean);
  var bm1    : TBitmap;
      r0, r1 : TRect;
      farbe  : Tcolor;
      j,k,n  : integer;
  begin
    bm := TBitmap.create;
    bm.Width:=a;
    bm.Height:=a;
    bm.Canvas.Brush.Color:=clBtnFace;
    bm.Canvas.Pen.Color:=clBtnFace;
    bm.Canvas.Rectangle(0,0,a,a);
    if not kugel
      then begin
             bm.Canvas.Brush.Color:=clWhite;
             bm.Canvas.Pen.Color:=clBlack;
             bm.Canvas.ellipse(b,b,a-b,a-b);
           end
      else begin
             bm1:=TBitMap.Create;
             bm1.Width:=200;
             bm1.Height:=200;
             with bm1.Canvas do
               begin
                 brush.Color:=clBtnFace;
                 Pen.Color:=clBtnFace;
                 rectangle(0, 0, 200, 200);
                 k:=0;
                 repeat
                   if k<75
                     then farbe:=k*$030303 + $101010
                     else Farbe:=$FFFFFF;
                   Pen.Color:=farbe;
                   brush.Color:=farbe;
                   n:=175-round(0.9*k);
                   j:= 25+round(1.1*k);
                   ellipse(j,j,n,n);
                   k:=k+1;
                until j+1>=n;
              end;
             r1:=rect(0, 0, a, a);
             r0:=rect(0, 0, 200, 200);
             bm.Canvas.CopyRect(r1,bm1.Canvas,r0);
             bm1.free;
           end;
  end;

var k : integer;
begin
  MakeBitMap(bm_frei,false);
  MakeBitMap(bm_belegt,true);
  autoPlay:=true;
  brettNumerierung:=255;
  ComboBoxBrettFormat.Items.Clear;
  for k:=0 to maxGame-1 do
    ComboBoxBrettFormat.Items.Add(gameName[k]);
  brettFormat:=_Solitaer;
  ComboBoxBrettFormat.itemIndex:=_Solitaer;
  InitBrettFormat(_Solitaer);
  ButtonFeldNeuClick(Sender);
  if FileExistsUTF8('solitaer.txt') { *Converted from FileExists* }
    then begin
           ButtonAbbruchUndSpeichern.Caption:='Fortsetzen';
           ButtonAbbruchUndSpeichern.tag:=1;
         end
    else ButtonAbbruchUndSpeichern.visible:=false;

end;


procedure TFormSolitaer.InitBrett;
var x,y, k : integer;
begin
  if brettFormat<>ComboBoxBrettFormat.ItemIndex then
    begin
       brettFormat:=ComboBoxBrettFormat.ItemIndex;
       initBrettFormat(brettFormat);
       brettNumerierung:=255;
       Paintbox1.Repaint;
    end;
  if brettNumerierung<>ComboBoxBrettNumerierung.ItemIndex then
    begin
      brettNumerierung:=ComboBoxBrettNumerierung.ItemIndex;
      InitBrettZaehlung(brettNumerierung);
    end;

  Move(brettVorgabe, brettManuellPlay, sizeOf(brettVorgabe));

  for y:=1 to qSize do
    for x:=1 to qSize do
      brett[x,y]:=brettVorgabe[x,y];
  restAnzahlPins:=maxAnzahlPins;

//  fillChar(linBrett,SizeOf(linBrett), char(ungueltig));
  for k:=1 to maxFeldAnzahl do linBrett[k]:=ungueltig;
  for k := 1 to maxAnzahlBrettPos do linBrett[k]:=brett[feldNrToXY[k].x,feldNrToXY[k].y];

  InitStartPosition;
end;

procedure TFormSolitaer.InitBrettFormat(brettForm:integer);
var x, y       : integer;
    im, im2, k : byte;
begin
  maxAnzahlBrettPos:=0;
  maxAnzahlPins:=0;
//  fillChar(brettVorgabe,SizeOf(brettVorgabe),char(ungueltig));   //führt bei einigen Compilereinst. zu Fehlern
  for y:=-1 to qSize+2 do
    for x:=-1 to qSize+2 do  brettVorgabe[x,y]:= ungueltig;
  for y:=1 to qSize do
    begin
      im := gameImage[brettForm,y];
      im2 := gameImage[_Solitaer,y];
      k := $80;
      for x:=1 to qSize do
        begin
          k := k shr 1;
          if (im and k) = k
            then begin brettVorgabe[x,y]:=belegt; inc(maxAnzahlPins); inc(maxAnzahlBrettPos); end
            else if (im2 and k) = k
                  then begin brettVorgabe[x,y]:=frei; inc(maxAnzahlBrettPos); end
        end;
    end;
  AnzahlZuegeBisLoesung:=maxAnzahlPins-2;
end;

procedure TFormSolitaer.InitBrettZaehlung(art:integer);
var x, y, i, k : integer; //byte;
begin
  k:=1;
  case art of
 {  qSize = 7
   _normale Zaehlung
   .  .  1  2  3  .  .       .  .  1  2  3  .  .
   .  .  4  5  6  .  .       .  4  5  6  7  8  .
   7  8  9  10 11 12 13      9  10 11 12 13 14 15
   14 15 16 17 18 19 20      16 17 18 19 20 21 22
   21 22 23 24 25 26 27      23 24 25 26 27 28 29
   .  .  28 29 30 .  .       .  30 31 32 33 34 .
   .  .  31 32 33 .  .       .  .  35 36 37 .  .     }

     0 : begin           // _normale Zaehlung
           for y:=1 to qSize do
             for x:=1 to qSize do
               if ( BrettVorgabe[x,y]<>ungueltig ) then
                 begin
                   feldNrToXY[k]:=Point(x,y);
                   k:=k+1;
                 end;
         end;

 { _spiralZaehlung
   .  .  1  2  3  .  .       .  .  1  2  3  .  .
   .  .  13 14 15 .  .       .  13 14 15 16 17 .
   12 24 25 26 27 16 4       12 28 29 30 31 18 4
   11 23 32 33 28 17 5       11 27 36 37 32 19 5
   10 22 31 30 29 18 6       10 26 35 34 33 20 6
   .  .  21 20 19 .  .       .  25 24 23 22 21 .
   .  .  9  8  7  .  .        .  .  9  8  7  . .     }

    1 : begin
          for i:=1 to qSize Div 2 do      // _spiralZaehlung
          begin
            for x:=i to qSize+1-i do if ( BrettVorgabe[x,i]<>ungueltig )
              then begin feldNrToXY[k]:=Point(x,i); k:=k+1; end;
            for y:=i+1 to qSize-i do if ( BrettVorgabe[qSize+1-i,y]<>ungueltig ) then
                  begin feldNrToXY[k]:=Point(qSize+1-i,y); k:=k+1; end;
            for x:=qSize+1-i downto i do if ( BrettVorgabe[x,qSize+1-i]<>ungueltig ) then
                   begin feldNrToXY[k]:=Point(x,qSize+1-i); k:=k+1; end;
            for y:=qSize-i downto i+1 do if ( BrettVorgabe[i,y]<>ungueltig ) then
                  begin feldNrToXY[k]:=Point(i,y); k:=k+1; end;
          end;
            feldNrToXY[k]:=Point(qMitte,qMitte);
        end;
       {    // Block:   oben     links   unten    rechts
                                                      .
                         * * *    * *       * *     * * *
                       . * * *    * * *   * * * .   * * *
                         * *      * * *   * * *      * *
                                    .
           .  .  3  2  1  .  .            .  .  3  2  1  .  .
           .  .  6  5  4  .  .            .  7  6  5  4  34 .
          9  12 8  7  32 30 27            10 13 9  8  36 33 30
          10 13 15 33 31 29 26            11 14 17 37 35 32 29
          11 14 16 23 24 28 25            12 15 18 26 27 31 28
          .  .  20 21 22 .  .             .  16 22 23 24 25 .
          .  .  17 18 19 .  .             .  .  19 20 21 .  .        }

    2 : begin                          //_blockweiseZaehlung
          for y:=1 to mitteO-1 do
            for x:=mitteR downto mitteL do
              begin
                feldNrToXY[k]:=Point(x,y); k:=k+1;
              end;
          if brettFormat=_Solitaer2 then
             begin feldNrToXY[k]:=Point(mitteL-1,mitteO-1); k:=k+1; end;
          feldNrToXY[k]:=Point(qMitte,mitteO); k:=k+1;
          feldNrToXY[k]:=Point(mitteL,mitteO); k:=k+1;

          for x:=1 to mitteL-1 do
            for y:=mitteO to mitteU do
              begin feldNrToXY[k]:=Point(x,y); k:=k+1; end;
          if brettFormat=_Solitaer2 then
                begin feldNrToXY[k]:=Point(mitteL-1,mitteU+1); k:=k+1; end;
          feldNrToXY[k]:=Point(mitteL,qMitte); k:=k+1;
          feldNrToXY[k]:=Point(mitteL,mitteU); k:=k+1;

          for y:=qSize downto mitteU+1 do
            for x:=mitteL to mitteR do
              begin feldNrToXY[k]:=Point(x,y);  k:=k+1; end;

          if brettFormat=_Solitaer2 then
                begin feldNrToXY[k]:=Point(mitteR+1,mitteU+1); k:=k+1; end;
          feldNrToXY[k]:=Point(qMitte,mitteU);  k:=k+1;
          feldNrToXY[k]:=Point(mitteR,mitteU);  k:=k+1;

          for x:=qSize downto mitteR+1 do
            for y:=mitteU downto mitteO do
              begin feldNrToXY[k]:=Point(x,y); k:=k+1; end;
          if brettFormat=_Solitaer2 then
             begin feldNrToXY[k]:=Point(mitteR+1,mitteO-1); k:=k+1; end;
          feldNrToXY[k]:=Point(mitteR,qMitte); k:=k+1;
          feldNrToXY[k]:=Point(mitteR,mitteO); k:=k+1;
          feldNrToXY[k]:=Point(qMitte,qMitte);
        end;
  end;
  for k:=1 to maxAnzahlBrettPos do
     brettXYtoNr[feldNrToXY[k].x,feldNrToXY[k].y]:=k;
end;

procedure TFormSolitaer.InitStartPosition;
var startPosX, startPosY : byte;
begin
 case brettFormat of
    _kreuz, _Plus, _Kamin,
    _Acht, _Pyramide       :  begin
                                startPosX:=qMitte; startPosY:=qSize;
                                endPosX := qMitte; endPosY := qMitte;
                              end;
    _Pfeil1, _Maennlein,
    _Pfeil2                :  begin
                                startPosX:=mitteL; startPosY:=1;
                                endPosX := qMitte; endPosY := qMitte;
                              end;
    _Solitaer2             : begin
                               startPosX:=mitteL; startPosY:=1;
                               endPosX := mitteR; endPosY := qSize;
                             end;
      else begin
             startPosX := qMitte; startPosY := qMitte;
             endPosX := qMitte;   endPosY := qMitte;
           end;

    end;  //case
  brett[startPosX,startPosY]:=frei; brettManuellPlay[startPosX,startPosY]:=frei;
  linBrett[BrettXYToNr[startPosX,startPosY]]:=frei;

  endPosNr := BrettXYToNr[endPosX,endPosY];
  restAnzahlPins:=maxAnzahlPins-1;
end;

procedure TFormSolitaer.InitStartVars;
begin
  abbruch:=false;
  zugNr:=0; testCounter:=0; testMrd:=0;
  buttonErgebnis.Visible:=false;
  listbox1.visible:=false;
  LabelMrd.caption:=' ';
  LabelAnzahlTests.caption:=' ';
  initZugVon;
end;

procedure TFormSolitaer.InitZugArray(startMove:TSprungRtg);
var x, y, nx, ny, mx, my , r, k, j, n : integer;
begin
  n := Ord(startMove)+1;
  j:=1;
  for k:=1 to maxAnzahlBrettPos do
    begin
      x:=feldNrToXY[k].x;
      y:=feldNrToXY[k].y;
      for r := n to n+3 do    //n=1: Reihenfolge: rechts, oben, links, unten
        begin                 //n=2: Reihenfolge: oben, links, unten, rechts
          case r of
              1 : begin nx:=x+2; ny:=y; mx:=x+1; my:=y; end;  // rechts
              2 : begin nx:=x; ny:=y-2; mx:=x; my:=y-1; end;  // oben
              3 : begin nx:=x-2; ny:=y; mx:=x-1; my:=y; end;  // links
              4 : begin nx:=x; ny:=y+2; mx:=x; my:=y+1; end;  // unten
              5 : begin nx:=x+2; ny:=y; mx:=x+1; my:=y; end;
              6 : begin nx:=x; ny:=y-2; mx:=x; my:=y-1; end;
              {7 :} else begin nx:=x-2; ny:=y; mx:=x-1; my:=y; end;
          end;
          if brettVorgabe[nx,ny]<>ungueltig then
            begin
              testZug[j].von  := k;
              testZug[j].ueber:= brettXYtoNr[mx,my];
              testZug[j].nach := brettXYtoNr[nx,ny];
              inc(j);
            end;
        end;
    end;
  maxAnzahlErlaubteZuege:=j-1;
end;

procedure TFormSolitaer.InitZugVon;
var x,y : integer;
begin
  fillChar(zugVon,SizeOf(Zugvon),0);
  for x:=1 to qSize do
    for y:=1 to qSize do
      if brettVorgabe[x,y]<>ungueltig then
        begin
          zugvon[x,y,unten] := brettVorgabe[x,y+2]<>ungueltig;
          zugvon[x,y,rechts]:= brettVorgabe[x+2,y]<>ungueltig;
          zugvon[x,y,oben]  := brettVorgabe[x,y-2]<>ungueltig;
          zugvon[x,y,links] := brettVorgabe[x-2,y]<>ungueltig;
        end;
end;

procedure TFormSolitaer.Memo1Click(Sender: TObject);
var z, p, k, zeile : integer;
    s, zStr        : string;
    aktLinZug      : TLinZugFolge;
begin
  fillChar(aktLinZug,sizeOf(aktLinZug),0);
  zeile:=Memo1.CaretPos.y;
  s:=memo1.Lines[zeile];
  z:=0; k:=1;
  While (k<length(s)) do
    begin
      zStr:=Copy(s,k,2);
      if zStr[1]=' ' then delete(zStr,1,1);
      if ( pos(zStr[1],'123456789')>0 ) and
         ( (Length(zStr)=1) or ( pos(zStr[2],'0123456789')>0 ) )
        then begin
               p:=StrToInt(zStr);
               inc(z);
               aktLinZug[z]:=p;
               k:=k+3;
            end
       else exit;
    end;
  p  := zeile*2;
  for k := 0 to zeile - 1 do p := p + Length(Memo1.Lines[k]);
  if Length(s)=3*AnzahlZuegeBisLoesung then
    begin
      listbox1.Visible := false;
      zugNr:= AnzahlZuegeBisLoesung;
      Umrechnen_LinZug_to_ZugXY(aktLinZug);
      ButtonErgebnisClick(nil);
    end;
  memo1.SelStart:=p;
  memo1.SelLength:=Length(s);
  ZeigeLinZugFolge(aktLinZug,z);
  memo1.SelLength:=0;
end;

procedure TFormSolitaer.MoveStein(x0,y0, x1,y1:integer);
var dx,dy, x,y, n,i,j,k : integer;
    quelle, ziel, org, bmRect : TRect;
begin
   n := (x1 - x0)*a;
   k := (y1 - y0)*a;
   if n=0
     then begin dx:=0; dy:= k div 10;  end
     else begin dy:=0; dx:= n div 10;  end;
   x := (x0-1)*a;
   y := (y0-1)*a;
   quelle := rect( 0, 0, a, a);
   for i := 0 to 9 do
     begin
       ziel   := rect( x+(i+1)*dx, y+(i+1)*dy, x+a+(i+1)*dx, y+a+(i+1)*dy);
       paintBox1.canvas.CopyRect ( ziel, bm_belegt.canvas, quelle);
       if i<5 then j:=i else j:=i-5;
       if dx=0
         then begin
                if dy>0
                  then begin
                         org   :=rect( x, y+i*dy, x+a,  y+(i+1)*dy);
                         bmRect:=rect( 0,   j*dy,   a,    (j+1)*dy);
                       end
                  else begin
                         org :=  rect( x, y+a+(i+1)*dy, x+a, y+a+i*dy);
                         bmRect:=rect( 0,   a+(j+1)*dy,   a,   a+j*dy);
                       end
              end
         else begin
                if dx>0
                   then begin
                          org   :=rect( x+i*dx, y, x+(i+1)*dx, y+a);
                          bmRect:=rect(   j*dx, 0,   (j+1)*dx,   a);
                        end
                   else begin
                          org   :=rect( x+a+(i+1)*dx, y, x+a+i*dx, y+a);
                          bmRect:=rect(   a+(j+1)*dx, 0,   a+j*dx,   a);
                       end;
              end;
       paintBox1.canvas.CopyRect ( org, bm_frei.canvas, bmRect);
       Delay(pause div 8);
     end;
end;

procedure TFormSolitaer.PaintBox1Click(Sender: TObject);
var k,t,neux,neuy,mx,my : integer;

   procedure Umsetzen;
   begin
     MoveStein (sx,sy,neux,neuy);
     brettManuellPlay[neux,neuy]:=belegt;
     brettManuellPlay[sx,sy]:=frei;
     brettManuellPlay[mx,my]:=frei;
     ZeichneFeld(sx,sy,frei);
     ZeichneFeld(neux,neuy,belegt);
     ZeichneFeld(mx,my,frei);
     restAnzahlPins:=restAnzahlPins-1;
     mZugNr:=mZugNr+1;
     buttonZugZurueck.Visible:=true;
     with mZug[mZugNr] do begin vx:=sx; vy:=sy; nx:=neux;  ny:=neuy end;
     sprung:=0; sx:=0; sy:=0;
     lastFeldx:=0; lastfeldy:=0; lastx:=0; lasty:=0; pinAusgewaehlt:=false;
     testCounter:=zugNr;
     LabelAnzahlTests.caption:=intToStr(testCounter);
     if restAnzahlPins=1 then ZeigeErgebnis(true);
   end;

begin
  if (not autoPlay) and (sprung<>0) and ( (lastFeldx<>0) and (lastFeldy<>0) )
     and (sx<>0) and (sy<>0) then
    if (brettManuellPlay[lastFeldx,lastFeldy]=frei)
      then for k:=1 to 4 do
             begin
               case k of
                  1 : begin neux:=sx+2; neuy:=sy; mx:=sx+1; my:=sy; t:=1 end;
                  2 : begin neux:=sx; neuy:=sy+2; mx:=sx; my:=sy+1; t:=2 end;
                  3 : begin neux:=sx-2; neuy:=sy; mx:=sx-1; my:=sy; t:=4 end;
                 else begin neux:=sx; neuy:=sy-2; mx:=sx; my:=sy-1; t:=8 end;
               end;
               if ( (sprung and t) = t) and (neux=lastFeldx) and (neuy=lastFeldy) then
                 begin
                   Umsetzen;
                   exit
                 end;
             end
      else begin
             pinAusgewaehlt:=not pinAusgewaehlt;
             if (brettManuellPlay[lastFeldx,lastFeldy]=belegt) and (sx=lastFeldx) and (sy=lastFeldy) then
             begin
               case sprung of
                    1 : begin neux:=sx+2; neuy:=sy; mx:=sx+1; my:=sy; end;
                    2 : begin neux:=sx; neuy:=sy+2; mx:=sx; my:=sy+1; end;
                    4 : begin neux:=sx-2; neuy:=sy; mx:=sx-1; my:=sy; end;
                    8 : begin neux:=sx; neuy:=sy-2; mx:=sx; my:=sy-1; end;
                   else exit;
                 end;
               Umsetzen;
             end;
           end;
end;

procedure TFormSolitaer.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
var fx,fy,k,t : integer;
begin
  if (not autoPlay) and ( (lastx<>x) or (lasty<>y)) then
    begin
      lastx:=x; lasty:=y;
      fx:=((x-b) DIV a)+1;
      fy:=((y-b) DIV a)+1;
      if ( (fx>=1) and (fx<=qSize) and (fy>=1) and (fy<=qSize) ) and ((fx<>lastFeldx) or (fy<>lastFeldy))
         and (brettManuellPlay[fx,fy]<>ungueltig) then
        begin
          t:=0;
          if (not pinAusgewaehlt) and (brettManuellPlay[fx,fy]=belegt) then
            begin
              for k:=1 to 4 do
                case k of
                  1 : if (brettManuellPlay[fx+1,fy]=belegt) and (brettManuellPlay[fx+2,fy]=frei) then t:=1;
                  2 : if (brettManuellPlay[fx,fy+1]=belegt) and (brettManuellPlay[fx,fy+2]=frei) then t:=t+2;
                  3 : if (brettManuellPlay[fx-1,fy]=belegt) and (brettManuellPlay[fx-2,fy]=frei) then t:=t+4;
                 else if (brettManuellPlay[fx,fy-1]=belegt) and (brettManuellPlay[fx,fy-2]=frei) then t:=t+8;
                end;
              if t<>0 then
                begin
                  if brettManuellPlay[sx,sy]=belegt then ZeichneFeld(sx,sy,belegt);
                  with paintbox1.canvas do
                    begin
                      if (t=1) or (t=2) or (t=4) or (t=8)
                        then brush.color:=clGreen
                        else brush.color:=clred;
                      ellipse((fx-1)*a+b,(fy-1)*a+b,fx*a-b,fy*a-b);
                    end;
                  sx:=fx; sy:=fy; sprung:=t;
                end;
            end;
          lastFeldx:=fx; lastFeldy:=fy;
        end;
    end;
end;

procedure TFormSolitaer.PaintBox1Paint(Sender: TObject);
begin
  zeichneBrett;
end;

procedure TFormSolitaer.PanelBeendenCommandResize(Sender: TObject);
begin
  BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;


procedure TFormSolitaer.SpielZugBruteForceSimple(var erfolg:boolean);
var altx,alty,neux,neuy,mx,my, n : integer;
    richtung                     : TSprungRtg;
begin
  CheckInteraction;
  if abbruch then begin erfolg:=true; zugNrOnESC:=zugNr; exit end;

  n:=1;
  repeat
    altx:=feldNrToXY[n].x;      // nur echte Felder des Brettes berücksichtigen
    alty:=feldNrToXY[n].y;
    if (brett[altx,alty]=belegt) then
      begin
        richtung := TSprungRtg(0);  //erster Eintrag in TSprungRtg -> rechts
        repeat
          if zugvon[altx,alty,richtung] then  // nur zulässige Richtungen beachten
          begin
          case richtung of
                rechts : begin neux:=altx+2; neuy:=alty; mx:=altx+1; my:=alty;  end;
                unten  : begin neux:=altx; neuy:=alty+2; mx:=altx; my:=alty+1;  end;
                links  : begin neux:=altx-2; neuy:=alty; mx:=altx-1; my:=alty;  end;
               { oben   : } else begin neux:=altx; neuy:=alty-2; mx:=altx; my:=alty-1;  end;
              end;
          application.ProcessMessages;
          if (brett[neux,neuy]=frei) and (brett[mx,my]=belegt) then
            begin
              brett[neux,neuy]:=belegt;
              brett[altx,alty]:=frei;
              brett[mx,my]:=frei;
              if zeigen then
                begin
                  MoveStein(altx,alty,neux,neuy);
                  LabelAnzahlTests.caption:=intToStr(testCounter);
                end;
              restAnzahlPins:=restAnzahlPins-1;
              zugNr:=zugNr+1;
              with zug[zugNr] do begin vx:=altx; vy:=alty; nx:=neux; ny:=neuy end;
              if (restAnzahlPins=1) and (brett[endPosX,endPosY]=belegt)
                then begin
                       if findAll
                         then begin
                                ButtonZeigeZwischenStandClick(nil);
                                inc(anzLsg);
                                labelAnzLsg.Caption:='bisher '+IntToStr(anzLsg)+' Lösungen gefunden';
                              end
                         else begin erfolg:=true; zugNrOnESC:=zugNr; exit end
                       end
                else SpielZugBruteForceSimple(erfolg);
                       if not erfolg
                         then begin
                                brett[neux,neuy]:=frei;
                                brett[altx,alty]:=belegt;
                                brett[mx,my]:=belegt;
                                restAnzahlPins:=restAnzahlPins+1;
                                zugNr:=zugNr-1;
                                if zeigen then
                                  begin
                                    ZeichneFeld(neux,neuy,frei);
                                    ZeichneFeld(altx,alty,belegt);
                                    ZeichneFeld(mx,my,belegt);
                                    checkPause;
                                  end;
                              end
                         else begin
                                exit;  //erfolg=true
                              end;

              end;
          end;
          richtung:=Succ(richtung)
        until (richtung=keinSprung) {or erfolg};
      end;
    n:=n+1
  until (n>maxAnzahlBrettPos) {or erfolg};
end;

procedure TFormSolitaer.SpielZugBruteForceSimpleLoadAndSave(var erfolg:boolean);
var altx,alty,neux,neuy,mx,my, n : integer;
    k                            : TSprungRtg;
begin
  if laden
    then begin
           n:=StrToInt(SpeicherListe.strings[0]);
           SpeicherListe.Delete(0);
         end
    else begin
           CheckInteraction;
           if abbruch then begin zugNrOnESC:=zugNr; erfolg:=true; exit end;
           n:=1;
         end;
  repeat
    altx:=feldNrToXY[n].x;      // nur echte Felder des Brettes berücksichtigen
    alty:=feldNrToXY[n].y;
    if (brett[altx,alty]=belegt) then
      begin
        if laden
          then begin
                 k:=TSprungRTG(StrToInt(SpeicherListe.strings[0]));
                 SpeicherListe.Delete(0);
                 if SpeicherListe.Count=0 then
                   begin
                   delay(500);
                     ZeichneBrett;
                   delay(500);
                     laden:=false; speichern:=false;
                     speicherListe.Clear;
                     speicherListe.free;
                   end;
               end
          else k := TSprungRtg(0);  //erster Eintrag in TSprungRtg -> rechts
        repeat
          if zugvon[altx,alty,k] then  // nur zulässige Richtungen beachten
          begin
          case k of
                rechts : begin neux:=altx+2; neuy:=alty; mx:=altx+1; my:=alty;  end;
                oben   : begin neux:=altx; neuy:=alty-2; mx:=altx; my:=alty-1;  end;
                links  : begin neux:=altx-2; neuy:=alty; mx:=altx-1; my:=alty;  end;
               { unten  :} else begin neux:=altx; neuy:=alty+2; mx:=altx; my:=alty+1;  end;
              end;
          if (brett[neux,neuy]=frei) and (brett[mx,my]=belegt) then
            begin
              brett[neux,neuy]:=belegt;
              brett[altx,alty]:=frei;
              brett[mx,my]:=frei;
              if zeigen then
                begin
                  MoveStein(altx,alty,neux,neuy);
                  LabelAnzahlTests.caption:=intToStr(testCounter);
                end;
              restAnzahlPins:=restAnzahlPins-1;
              zugNr:=zugNr+1;
              with zug[zugNr] do begin vx:=altx; vy:=alty; nx:=neux;  ny:=neuy end;
              if restAnzahlPins=1
                then begin
                       if findAll
                         then begin
                                ButtonZeigeZwischenStandClick(nil); inc(anzLsg);
                                labelAnzLsg.Caption:='bisher '+IntToStr(anzLsg)+' Lösungen gefunden';
                              end
                         else begin erfolg:=true; exit end;
                     end
                else if laden then SpielZugBruteForceSimpleLoadAndSave(erfolg)
                              else SpielZugBruteForceSimple(erfolg);
                       if not erfolg
                         then begin
                                brett[neux,neuy]:=frei;
                                brett[altx,alty]:=belegt;
                                brett[mx,my]:=belegt;
                                restAnzahlPins:=restAnzahlPins+1;
                                zugNr:=zugNr-1;
                                if zeigen then
                                  begin
                                    ZeichneFeld(neux,neuy,frei);
                                    ZeichneFeld(altx,alty,belegt);
                                    ZeichneFeld(mx,my,belegt);
                                  end;
                              end
                         else begin
                                if speichern then
                                  begin
                                    speicherListe.Insert(9,IntTostr(n));
                                    speicherListe.Insert(10,IntToStr(ord(k)));
                                    zugNr:=zugNr-1;
                                  end;
                                exit;  //erfolg=true
                              end;

          end;
          end;
          k:=Succ(k);
        until (k=keinSprung) {or erfolg};
      end;
    n:=n+1
  until (n>maxAnzahlBrettPos) {or erfolg};
end;

procedure TFormSolitaer.SpielZugBruteForceOptimiert(var erfolg:boolean);
var n : integer;
begin
  CheckInteraction;
  if abbruch then begin zugNrOnESC := zugNr; erfolg:=true; exit end;
  n:=1;
  repeat
    with testZug[n] do
    if linBrett[von]=belegt then
      begin
         if (linBrett[nach]=frei) and (linBrett[ueber]=belegt) then
            begin
              linBrett[nach] := belegt;
              linBrett[ueber]:= frei;
              linBrett[von]  := frei;
              restAnzahlPins:=restAnzahlPins-1;
              zugNr:=zugNr+1;
              linZug[zugNr]:= n;

              if zeigen then
                begin
                  MoveStein(feldNrToXY[von].x,feldNrToXY[von].y,feldNrToXY[nach].x,feldNrToXY[nach].y);
                  LabelAnzahlTests.caption:=intToStr(testCounter);
                end else application.ProcessMessages;
              if (restAnzahlPins=1) and (linBrett[endPosNr]=belegt)
                then begin
                       if findAll
                         then begin
                                ZeigeZwischenLoesung; Inc(anzLsg);
                                labelAnzLsg.Caption:='bisher '+IntToStr(anzLsg)+' Lösungen gefunden';
                              end
                         else begin erfolg:=true; Umrechnen_LinZug_to_ZugXY(linZug); exit end
                     end
                else SpielZugBruteForceOptimiert(erfolg);
              if not erfolg
                then begin
                       linBrett[nach]  := frei;
                       linBrett[von]   := belegt;
                       linBrett[ueber] := belegt;
                       restAnzahlPins:=restAnzahlPins+1;
                       zugNr:=zugNr-1;
                       if zeigen then
                         begin
                           ZeichneLinBrett(nach, true);
                           ZeichneLinBrett(von, true);
                           ZeichneLinBrett(ueber, true);
                           checkPause;
                         end else application.ProcessMessages;
                     end
                else exit;  //erfolg=true
            end;
       end;
    n:=n+1
  until (n>maxAnzahlErlaubteZuege) {or erfolg};
end;


// ohne Rekursiom
const maxStackHeight = maxFeldAnzahl-3;

var PMStacks : array[1..qSizeQuadrat,0..maxStackHeight] of byte; // 49 stacks of linZug
    PMHeight : array[1..qSizeQuadrat] of byte;                   //entries per stack

procedure TFormSolitaer.SpielZugBruteForceIterativ(var erfolg:boolean; mitFilter, mitPinBewertung:boolean);

var useFilter, usePinType : boolean;
    pintype               : array[1..maxFeldAnzahl] of byte;

    //--- P system --- (eliminate same board positions, skip permutations)

    procedure clearPMstacks;
    var i,j : byte;
    begin
     for i := 1 to qSizeQuadrat do   //Permutation filter system
      begin
       PMheight[i] := 0;
       for j := 0 to maxStackHeight do PMstacks[i,j] := 0;
      end;
    end;

    procedure PMpush(m,nr : byte);        //push nr to stack of board position pins of move m
    var pin,h,i : byte;
    begin
      for i := 1 to 3 do
        begin
          case i of
             1 : pin := testZug[m].von;    //get pin1 of move m
             2 : pin := testZug[m].ueber;  //       2
             3 : pin := testZug[m].nach;   //       3
          end;
          h := PMheight[pin] + 1;
          PMstacks[pin,h] := nr;
          PMheight[pin] := h;
        end;
    end;

    procedure PMpop(m : byte);            //remove last entry from stack for pins of move m
    begin
      dec(PMheight[testZug[m].von]);
      dec(PMheight[testZug[m].ueber]);
      dec(PMheight[testZug[m].nach]);
    end;

    function lastPmove(m : byte) : byte;  //find latest zugNr that changed pin positions of move m
    var pin,x,i : byte;
    begin
      result := 0;
      for i := 1 to 3 do
        begin
          case i of
            1 : pin := testZug[m].von;
            2 : pin := testZug[m].ueber;
            3 : pin := testZug[m].nach;
           end;
          x := PMstacks[pin,PMheight[pin]];  //x=latest zugNr modifying von,ueber,nach
          if x <> 0 then
           if x > result then result := x;
      end;
    end;

  procedure InitPinBewertung(xEndPos,yEndPos:byte);
  var _pinType : Array[1..qSize,1..qSize] of byte;
      x, y, k  : integer;

    procedure InitPinJumpPath(x0,y0:integer);
    var pTyp     : byte;
        x, y, k  : integer;
    begin
      pTyp := _pinType[x0,y0];
      for k:=1 to 4 do
        begin
          case k of
             1 : begin x:=x0+2; y:=y0   end;
             2 : begin x:=x0;   y:=y0+2 end;
             3 : begin x:=x0-2; y:=y0   end;
            { 4 :} else begin x:=x0;   y:=y0-2 end;
            end;
           if (brettVorgabe[x,y]<>ungueltig) and(_pinType[x,y]<>pTyp)
              then begin
                     _pinType[x,y]:=pTyp;
                     InitPinJumpPath(x,y);
                   end;
        end;
    end;

 { 1: Pin on Win-Path      - :Endposition: erhält Wert 1; alle Positionen von denen auf ein 1-er Feld gesprungen werden kann
   3: Pin outside Win-Path - alle Felder, die bei Sprung von/nach einem 1-er Feld nie übersprungen werden
   2: Pin between Win-Path - alle Felder, die noch übrig bleiben

         _kreuz: Endposition in Mitte       _raute: Endposition unten rechts

              .  .  3  2  3  .  .                .  .  1  2  1  .  .
              .  .  2  1  2  .  .                .  3  2  3  2  3  .
              3  2  3  2  3  2  3                1  2  1  2  1  2  1
              2  1  2 :1: 2  1  2                2  3  2  3  2  3  2
              3  2  3  2  3  2  3                1  2  1  2  1  2  1
              .  .  2  1  2  .  .                .  3  2  3  2  3  .
              .  .  3  2  3  .  .                .  .  1  2 :1: .  .        }

  begin
 // FillChar(_pinType,sizeOf(_pinType),3);
  for y:=1 to qSize do
    for x:=1 to qSize do
      begin
       if brett[x,y]=ungueltig
          then _pinType[x,y]:=0
          else _pinType[x,y]:=3;
      end;
  _pinType[xEndPos,yEndPos]:=1;
  InitPinJumpPath(xEndPos,yEndPos);
  for k:=1 to 4 do
    begin
      case k of
           1 : begin x := xEndPos+1; y:=yEndPos; end;
           2 : begin x := xEndPos-1; y:=yEndPos; end;
           3 : begin x := xEndPos; y:=yEndPos-1; end;
           4 : begin x := xEndPos; y:=yEndPos+1; end;
          end;
      if brettVorgabe[x,y]<>ungueltig
       then begin
              _pinType[x,y]:=2;
              InitPinJumpPath(x,y);
            end
    end;

  anzahlPinOnWinPath := 0;
  anzahlPinBetweenWinPath := 0;
  anzahlPinOutsideWinPath := 0;
  fillchar(pinType,sizeOf(pinType),0);
  for k:=1 to maxAnzahlBrettPos do
   begin
     pinType[k]:= _pinType[feldNrToXY[k].x,feldNrToXY[k].y];
     if linBrett[k]=belegt then
     case pintype[k] of
           1 : inc(anzahlPinOnWinPath);
           2 : inc(anzahlPinBetweenWinPath);
           3 : inc(anzahlPinOutsideWinPath);
        end;
   end;
  k:=anzahlPinOnWinPath + anzahlPinBetweenWinPath + anzahlPinOutsideWinPath;
  if k <> restAnzahlPins
     then restAnzahlPins:= k;
  end;


  function solve : boolean;
    //solve solitaire game
    //speedup search by pin differentiation
    //testZugNr is trial move during search
    //zugNr points to next free entry in linZug table

    var m,pm,p1,p2,p3 : byte;
        testZugNr     : byte;
        tempAnzPinOnWinP,tempAnzPinBetweenWinP,tempAnzPinOutsideWinP : byte;

    label start, testmove, nextmove, moveBack;

    begin
     erfolg := false;

start :                  //(re)start with 1st move
     CheckInteraction;
     if abbruch then begin result:=false; exit end;

     testZugNr := 1;             //1st trial move

testmove :               //test move is possible

     p1 := testZug[testZugNr].von;
     if linBrett[p1] = frei then goto nextmove;
     p2 := testZug[testZugNr].ueber;
     if linBrett[p2] = frei then goto nextmove;
     p3 := testZug[testZugNr].nach;
     if linBrett[p3] = belegt then goto nextmove;

    //------- P filter -------------
     if useFilter then
       begin
         pm := lastPmove(testZugNr) + 1;
         while pm < zugNr do
           begin
             if linZug[pm] > testZugNr then goto nextmove;
             inc(pm);
           end;
       end;

    //------- pin differentiation ---
   if usePinType then
     begin
       tempAnzPinOnWinP      := anzahlPinOnWinPath;
       tempAnzPinBetweenWinP := anzahlPinBetweenWinPath;
       tempAnzPinOutsideWinP := anzahlPinOutsideWinPath;
       case pintype[p2] of
          1 : dec(tempAnzPinOnWinP);
          2 : dec(tempAnzPinBetweenWinP);
          3 : dec(tempAnzPinOutsideWinP);
         end;
       if (tempAnzPinOnWinP = 0) or (tempAnzPinBetweenWinP < tempAnzPinOutsideWinP) then goto nextmove;
    end;

    //---- record move -----
     linBrett[p1] := frei;
     linBrett[p2] := frei;
     linBrett[p3] := belegt;
     linZug[zugNr]:= testZugNr;
     PMpush(testZugNr,zugNr);
     if zeigen then
        begin
          MoveStein(feldNrToXY[p1].x,feldNrToXY[p1].y,feldNrToXY[p3].x,feldNrToXY[p3].y);
          LabelAnzahlTests.caption:=intToStr(testCounter);
          CheckPause;
        end else application.ProcessMessages;
    if usePinType then
      begin
        anzahlPinOnWinPath := tempAnzPinOnWinP;
        anzahlPinBetweenWinPath:= tempAnzPinBetweenWinP;
        anzahlPinOutsideWinPath := tempAnzPinOutsideWinP;
      end;

    //--- test solution ----
     if (zugNr = AnzahlZuegeBisLoesung) and ((linBrett[endPosNr]=belegt) )
       then begin
              if findAll then begin
                                anzLsg:=anzLsg+1;
                                ZeigeZwischenLoesung;
                                labelAnzLsg.Caption:='bisher '+IntToStr(anzLsg)+' Lösungen gefunden';
                                Goto moveBack;
                              end
                         else begin
                                restAnzahlPins:=1;
                                result := true;
                                exit;
                              end;
            end
       else begin
              inc(zugNr);
              goto start;
            end;

nextmove :

     inc(testZugNr);
     if testZugNr <= maxAnzahlErlaubteZuege then goto testmove;

     if zugNr <= 1 then
      begin
       result := false;
       restAnzahlPins := AnzahlZuegeBisLoesung-zugNr+1;
       exit;
      end;


   // Zug zurücknehmen
     LinZug[zugNr]:=0;
     dec(zugNr);
moveBack :
     testZugNr := linZug[zugNr];
     p1 := testZug[testZugNr].von;
     p2 := testZug[testZugNr].ueber;
     p3 := testZug[testZugNr].nach;
     linBrett[p1] := belegt;
     linBrett[p2] := belegt;
     linBrett[p3] := frei;
     dec(PMheight[p1]);
     dec(PMheight[p2]);
     dec(PMheight[p3]);
     if zeigen then
        begin
          ZeichneLinBrett(p3, true);
          ZeichneLinBrett(p2, true);
          ZeichneLinBrett(p1, true);
          CheckPause;
        end else application.ProcessMessages;
     if usePinType then
       begin
         m:=pintype[p2];
         case m of
          1 : inc(anzahlPinOnWinPath);
          2 : inc(anzahlPinBetweenWinPath);
          3 : inc(anzahlPinOutsideWinPath);
         end;
       end;

     goto nextmove;

    end;

begin
  clearPMstacks;
  zugNr := 1;
  useFilter := mitFilter;
  usePinType := mitPinBewertung;
  if usePinType
    then InitPinBewertung(endPosX,endPosY);
  startTime :=GetTickCount64;
  erfolg := solve;
end;


procedure TFormSolitaer.Umrechnen_ZugXY_to_LinZug;
var j, k, p1, p2 : integer;
    r : char;
begin
 if zug[1].vx=0 then begin Umrechnen_LinZug_to_ZugXY(linZug); exit end;
  for k:=1 to AnzahlZuegeBisLoesung do
     begin
       if zug[k].vx=0 then begin exit end;
       p1:=BrettXYToNr[ zug[k].vx, zug[k].vy ];
       p2:=BrettXYToNr[ zug[k].nx, zug[k].ny ];
       j:=1;
       if (p1>0) and (p2>0) then
       begin
       while (testZug[j].von<>p1) or (testZug[j].nach<>p2) do inc(j);
       linZug[k]:=j;
       if zug[k].vx=zug[k].nx
        then if zug[k].ny>zug[k].vy
               then r:=nach_unten
               else r:=nach_oben
        else if zug[k].nx>zug[k].vx
               then r:=nach_rechts
               else r:=nach_links;
       zugR[k].rtg := r;
       end;
     end;
end;

procedure TFormSolitaer.Umrechnen_mZugXY_to_LinZug;
var j, k, p1, p2 : integer;
    r : char;
begin
  for k:=1 to AnzahlZuegeBisLoesung do
     begin
       if mZug[k].vx=0 then begin exit end;
       p1:=BrettXYToNr[ mZug[k].vx, mZug[k].vy ];
       p2:=BrettXYToNr[ mZug[k].nx, mZug[k].ny ];
       j:=1;
       while (testZug[j].von<>p1) or (testZug[j].nach<>p2) do inc(j);
       linZug[k]:=j;
       if mZug[k].vx=mZug[k].nx
        then if mZug[k].ny>mZug[k].vy
               then r:=nach_unten
               else r:=nach_oben
        else if mZug[k].nx>mZug[k].vx
               then r:=nach_rechts
               else r:=nach_links;
       zugR[k].rtg := r;
     end;
end;

procedure TFormSolitaer.Umrechnen_LinZug_to_ZugXY(const aLinZug:TLinZugFolge);
var k, p : integer;
    r    : char;
begin
  for k:=1 to AnzahlZuegeBisLoesung do
    begin
      if aLinZug[k]=0 then exit;
      p:=testZug[aLinZug[k]].von;
      zug[k].vx := FeldNrToXY[p].x;
      zug[k].vy := FeldNrToXY[p].y;

      p:=testZug[aLinZug[k]].nach;
      zug[k].nx := FeldNrToXY[p].x;
      zug[k].ny := FeldNrToXY[p].y;

      zugR[k].x := zug[k].vx;
      zugR[k].y := zug[k].vy;
      if zug[k].vx=zug[k].nx
        then if zug[k].ny>zug[k].vy
               then r:=nach_unten
               else r:=nach_oben
        else if zug[k].nx>zug[k].vx
               then r:=nach_rechts
               else r:=nach_links;
       zugR[k].rtg := r;
    end;
end;

procedure TFormSolitaer.Vorbereiten;
begin
  direktZugXY := false;
  anzLsg := 0;
  ButtonAbbruchUndSpeichern.visible:=false;
  PanelVorbereiten.Visible:=false;
  PanelStart.Visible:=false;
  PanelBeendenCommand.Enabled:=false;
  bf_StartRichtung:=comboBoxReihenfolge.ItemIndex;
  findAll:=CheckBoxAll.checked;
  InitBrett;
  InitStartVars;
  InitZugArray(TSprungRtg(bf_StartRichtung));
  ZeichneBrett;
  showSteps:=true;
  PanelPlayCommand.Visible:=true;
  FramePausenStrg1.Visible:=true;
end;


procedure TFormSolitaer.ZeichneBrett;
var x ,y   : integer;
    status : TStatus;
begin
 paintbox1.Canvas.Brush.Color:=clBtnFace;
 paintbox1.Canvas.Pen.Color:=clBtnFace;
 paintbox1.Canvas.Rectangle(0,0,paintbox1.Width,paintbox1.Height);
 paintbox1.Canvas.Pen.Color:=clBlack;
  for x:=1 to qSize do
    for y:=1 to qSize do
        begin
          if autoPlay
            then status:=brett[x,y]
            else status:=brettManuellPlay[x,y];
          ZeichneFeld(x,y,status);
        end;
end;

procedure TFormSolitaer.ZeichneFeld(x,y:integer;status:TStatus);
var r0, r1 : TRect;
begin
  with paintbox1.canvas do
    begin
      r0:=rect(0,0,a,a);
      r1:=rect((x-1)*a,(y-1)*a,x*a,y*a);
      case status of
           belegt : copyRect(r1,bm_belegt.Canvas,r0);
           frei   : copyRect(r1,bm_frei.Canvas,r0);
         end;
      if (x=endPosX) and (y=endPosY) then
        begin
          brush.Style:=bsclear;
          pen.Width:=2;
          pen.color:=clRed;
          ellipse((x-1)*a+b-1,(y-1)*a+b-1,x*a-b+1,y*a-b+1);
          pen.Color:=clBlack;
          pen.Width:=1;
          brush.Style:=bssolid;
        end;

    end;
end;

procedure TFormSolitaer.ZeichneLinBrett(nr:integer; normal:boolean);
var x,y : integer;
begin
  x:=feldNrToXY[nr].x;
  y:=feldNrToXY[nr].y;
  if normal or (linBrett[nr] <> belegt)
    then ZeichneFeld(x,y,linBrett[nr])
    else with paintbox1.canvas do
           begin
             brush.color:=clred;
             ellipse((x-1)*a+b,(y-1)*a+b,x*a-b,y*a-b);
           end;
end;

procedure TFormSolitaer.ZeigeErgebnis(erfolg:boolean);
begin
  if testCounter>=1000000000 then
    begin
      testMrd:=testMrd+1;
      LabelMrd.caption:=intToStr(testMrd);
      testCounter:=testCounter-1000000000
    end;
  LabelAnzahlTests.caption:=intToStr(testCounter);
  if erfolg and (restAnzahlPins<=1) then buttonErgebnis.Visible:=true;
  FramePausenStrg1.Visible:=false;
  PanelBeendenCommand.Enabled:=true;
  PanelVorbereiten.Visible:=true;
  PanelStart.Visible:=true;
end;

procedure TFormSolitaer.ZeigeLinZugFolge(aLinZug:TLinZugFolge;nr:byte);
var k, altPause  : integer;
    panelPauseVis,stoppEnabled,altShowSteps,altAbbruch  : boolean;
    backZug      : TLinZugFolge;
    backLinBrett : Array[1..maxFeldAnzahl] of TStatus;
    backManBrett : Array[-1..qSize+2,-1..qSize+2] of TStatus;
    backBrett    : Array[1..qSize,1..qSize] of TStatus;
begin
  if autoPlay and (bf_verfahren>2) then
    begin
      for k:=1 to maxAnzahlBrettPos do
        brett[ feldNrToXY[k].x, feldNrToXY[k].y ]:= linBrett[k];
    end;
  Move(aLinZug,backZug,SizeOf(aLinZug));
  Move(linBrett,backLinBrett,SizeOf(linBrett));
  Move(Brett,backBrett,SizeOf(Brett));
  Move(brettManuellPlay,backManBrett,SizeOf(brettManuellPlay));
  stoppEnabled:=FramePausenStrg1.BitBtnPauseShow.Enabled;
  altShowSteps:=showSteps;
  altAbbruch:=abbruch;

  initBrett;
  ZeichneBrett;
  altPause:=pause;
  FramePausenStrg1.BitBtnPauseDefaultClick(nil);
  panelPauseVis:=FramePausenStrg1.Visible;
  FramePausenStrg1.Visible:=true;
  abbruch := false; showSteps:=true;

  for k:=1 to nr do  if aLinZug[k]>0 then
    begin
      with testZug[aLinZug[k]] do
        begin
          MoveStein(feldNrToXY[von].x,feldNrToXY[von].y,feldNrToXY[nach].x,feldNrToXY[nach].y);
          linBrett[von]  := frei;
          linBrett[ueber]:= frei;
          linBrett[nach] := belegt;
        end;
      CheckPause;
      if abbruch then Begin zugNrOnESC:=zugNr;break; end;
    end;

  Move(backZug,aLinZug,SizeOf(aLinZug));
  Move(backLinBrett,linBrett,SizeOf(linBrett));
  Move(backBrett,Brett,SizeOf(Brett));
  Move(backManBrett,brettManuellPlay,SizeOf(brettManuellPlay));
  ZeichneBrett;

  FramePausenStrg1.SetPause(altpause);
  showSteps:=altShowSteps;
  FramePausenStrg1.Visible:=panelPauseVis;
  abbruch:=altAbbruch;
end;

procedure TFormSolitaer.ZeigeZwischenLoesung;
var k, n, p, vx,vy, nx,ny  : integer;
    s, s1 : string;
    r     : char;
begin
  if not zeigen then
    begin
      if autoPlay and (bf_verfahren>2) then
        for k:=1 to maxAnzahlBrettPos do
          brett[ feldNrToXY[k].x, feldNrToXY[k].y ]:= linBrett[k];
      ZeichneBrett;
    end;
  if autoPlay then n:=zugNr else n:=mZugNr;
  s:='';
  for k:=1 to n do
    begin
      if LinZug[k]=0 then break;
      s1:='';
      p:=testZug[LinZug[k]].von;
      vx := FeldNrToXY[p].x;
      vy := FeldNrToXY[p].y;

      p:=testZug[LinZug[k]].nach;
      nx := FeldNrToXY[p].x;
      ny := FeldNrToXY[p].y;

      s1:=IntToStr(brettXYtoNr[vx,vy]);
      if vx=nx
        then if ny>vy
               then r:=nach_unten
               else r:=nach_oben
        else if nx>vx
               then r:=nach_rechts
               else r:=nach_links;
      s1:=s1+r;
      while Length(s1)<4 do s1:=s1+' ';
      s:=s+s1;
    end;
  memo1.lines.add(s);
end;


end.
