unit sudoku;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Sudoku
   Autor:   H. Niemeyer  (c) 2023
   Version: 1.0

   letzte Änderung: 20.11.2023 *)

{$mode ObjFPC}{$H+}

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls, Spin, Buttons,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

const
 minElement = 1;
 maxElement = 9;  // Achtung:  maxElement +1 <= 10  bei Bit10 !!
                  // sonst wird Zählung falsch
type
  TZiffer = minElement..maxElement;
  TNumSet  = set of TZiffer;
  TFeld   = array[0..8,0..8] of TNumSet;
  TSudo   = array[0..8,0..8] of integer;
  TZifferIn = array[0..8] of TNumSet;
  TVerteilung = array[1..9] of TNumSet;

  { TSudokuForm }

  TSudokuForm = class(TForm)
    BitBtnEndUserModus: TBitBtn;
    BitBtnBeenden: TBitBtn;
    BitBtnStart: TBitBtn;
    ButtonLeeresFeld: TButton;
    BitBtnNeuStart: TBitBtn;
    CheckBoxAlleLsgSuchen: TCheckBox;
    CheckBoxZwischenSchritt: TCheckBox;
    FramePausenStrg1: TFramePausenStrg;
    LabelAnz: TLabel;
    LabelInfo: TLabel;
    Panel1: TPanel;
    ButtonAktualisiereHilfe: TButton;
    Panel2: TPanel;
    ButtonBeispiel: TButton;
    ButtonZeigeZwang: TButton;
    ButtonVersteckeHilfe: TButton;
    ButtonZeigeHilfe: TButton;
    ButtonInit: TButton;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    PanelUserInput: TPanel;
    PanelStart: TPanel;
    RadioGroupMethode: TRadioGroup;
    SpinEditBspNr: TSpinEdit;
    StringGrid1: TStringGrid;
    procedure BitBtnEndUserModusClick(Sender: TObject);
    procedure BitBtnNeuStartClick(Sender: TObject);
    procedure ButtonAktualisiereHilfeClick(Sender: TObject);
    procedure BitBtnBeendenClick(Sender: TObject);
    procedure ButtonBeispielClick(Sender: TObject);
    procedure ButtonInitClick(Sender: TObject);
    procedure BitBtnStartClick(Sender: TObject);
    procedure ButtonLeeresFeldClick(Sender: TObject);
    procedure ButtonZeigeZwangClick(Sender: TObject);
    procedure ButtonZeigeHilfeClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGrid1EditingDone(Sender: TObject);
  private
    { Private-Deklarationen }
    Feld  : TFeld;
    reihe : array[0..8] of integer;
    anzLsg, anzAufruf                              : integer;
    lastPuzzle, aktPuzzle, nextMove, lsgPuzzle     : TSudo;
    fehler, zwangGefunden, neuesPuzzle, veraendert : boolean;
    ZifInSpalte, ZifInZeile, ZifInQuadrat          : TZifferIn;

    procedure AendereCursor(aCursor:TCursor);
    procedure AktualisiereFeld;
    procedure AutoRunModusStart(titel:string);
    procedure AutoRunModusStopp;
    procedure Backtrack(sucheAlle:boolean; modus:integer);
    function BesetzeFeld(x,y,ziffer:integer):boolean;
    procedure BefreieFeld(x,y:integer);
    function BruteForceBackTrack(x,y:integer; sucheAlle:boolean):boolean;
    function CheckSpalte(sp:integer):boolean;
    function CheckZeile(z:integer):boolean;
    function EinzigesElement(m:TNumSet):integer;
    procedure ErstelleFeldDaten;
    function GetVerteilungSpalte(sp:integer):TVerteilung;
    function GetVerteilungZeile(z:integer):TVerteilung;
    function GetVerteilungQuadrat(nr:integer):TVerteilung;
    procedure InitialisiereFeld;
    procedure LeeresFeld;
    procedure LogikTest;
    function ReduziereSpalte(sp:integer):boolean;
    function ReduziereZeile(z:integer):boolean;
    procedure SortiereReihe;
    function SucheDubletteInQuadrat(nr:integer):boolean;
    function SucheDubletteInSpalte(sp:integer):boolean;
    function SucheDubletteInZeile(z:integer):boolean;
    function SucheTriplettInQuadrat(nr:integer):boolean;
    function SucheTriplettInSpalte(sp:integer):boolean;
    function SucheTriplettInZeile(z:integer):boolean;
    function TesteFeld(x,y:integer): integer;
    procedure UebertragePuzzleAufGrid(puzzle:TSudo);
    procedure UserInput;
    procedure ZeigeGrid(zeigHilfe:boolean);
    function Zwangsbelegung(zeigeBlock:boolean):boolean;
  public
    { Public-Deklarationen }
  end;


const alleZiffern : TNumSet = [1,2,3,4,5,6,7,8,9];
      bspMax= 5;
      bsp0  : TSudo = ((0,0,0, 0,0,0, 0,0,0),
                       (0,0,0, 0,0,0, 0,0,0),
                       (0,0,0, 0,0,0, 0,0,0),

                       (0,0,0, 0,0,0, 0,0,0),
                       (0,0,0, 0,0,0, 0,0,0),
                       (0,0,0, 0,0,0, 0,0,0),

                       (0,0,0, 0,0,0, 0,0,0),
                       (0,0,0, 0,0,0, 0,0,0),
                       (0,0,0, 0,0,0, 0,0,0));

      bsp1  : TSudo = ((0,0,0, 0,0,0, 4,0,0),
                       (0,9,0, 0,0,1, 0,8,2),
                       (0,0,0, 4,2,0, 0,5,0),

                       (0,7,0, 0,0,0, 0,2,6),
                       (0,4,0, 0,6,0, 1,0,0),
                       (5,0,8, 0,0,0, 0,9,0),

                       (0,1,5, 0,0,7, 0,0,3),
                       (0,0,0, 2,0,0, 6,1,9),
                       (0,0,0, 0,3,6, 0,0,8));

      bsp2  : TSudo = ((0,0,7, 0,0,0, 5,9,0),
                       (8,0,0, 0,0,0, 0,0,6),
                       (5,0,0, 9,0,1, 0,0,8),

                       (0,0,6, 0,0,8, 2,0,0),
                       (0,0,0, 0,0,0, 0,0,0),
                       (0,0,2, 5,0,0, 1,0,0),

                       (4,0,0, 2,0,3, 0,0,9),
                       (3,0,0, 0,0,0, 0,0,1),
                       (0,5,8, 0,0,0, 6,3,0));

     bsp3   : TSudo = ((0,0,0, 0,2,0, 0,7,0),
                       (4,0,0, 0,1,8, 0,0,5),
                       (0,7,3, 0,0,0, 0,0,9),

                       (0,0,0, 0,0,0, 7,0,0),
                       (0,0,0, 0,8,0, 0,1,0),
                       (0,0,0, 0,0,9, 0,0,3),

                       (0,9,0, 0,0,5, 0,0,0),
                       (8,0,0, 6,0,1, 0,3,0),
                       (0,0,2, 0,0,0, 4,0,0));

     bsp4   : TSudo = ((0,0,0, 1,0,6, 0,0,5),
                       (0,4,0, 0,0,0, 0,0,6),
                       (0,0,0, 2,0,5, 1,0,0),

                       (0,5,8, 0,0,9, 0,7,3),
                       (0,0,0, 0,0,0, 0,0,0),
                       (9,2,0, 4,0,0, 6,8,0),

                       (0,0,5, 7,0,4, 0,0,0),
                       (2,0,0, 0,0,0, 0,4,0),
                       (8,0,0, 5,0,3, 0,0,0));

     bsp5   : TSudo = ((0,0,1, 0,0,0, 0,0,0),
                       (0,6,0, 0,0,9, 0,0,0),
                       (0,0,8, 0,7,0, 6,0,2),

                       (6,0,0, 0,5,0, 0,7,0),
                       (0,3,0, 1,0,2, 0,9,0),
                       (0,1,0, 0,9,0, 0,0,5),

                       (2,0,6, 0,8,0, 7,0,0),
                       (0,0,0, 4,0,0, 0,3,0),
                       (0,0,0, 0,0,0, 5,0,0));

var
  SudokuForm: TSudokuForm;

implementation

{$R *.lfm}

//gültig für Zahlmengen mit maxElement<10 und minElenent>=0;  z.B: [1..9]
// gilt aber nicht für [11..19]
function AnzahlImSet(aSet: TNumSet): Integer;
const
  anzahlArr: array[0..31] of Byte =
    ( 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,      //  0..15
      1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5 );   // 16..31
var num : word;
begin
  if aSet=[] then exit(0);
  num:=0;
  move(aSet,num,Sizeof(word));
  num:=num shr minElement;
  result := anzahlArr[num and $1F] + anzahlArr[(num shr 5) and $1F];
end;

function FirstInSet(aSet: TNumSet): Integer;
var k : integer;
begin
  result:=-1;
  for k:=minElement to maxElement do
    if k in aSet then exit(k)
end;

procedure TSudokuForm.AendereCursor(aCursor:TCursor);
begin
  stringGrid1.cursor:=aCursor;
  panel1.cursor:=aCursor;
  Cursor:=aCursor;
end;

procedure TSudokuForm.AktualisiereFeld;
var sp, z, n : integer;
    s        : string;
    m        : TNumSet;
begin
  if veraendert then
    begin
      for sp:=0 to 8 do
        for z:=0 to 8 do
          begin
            s := stringGrid1.Cells[sp,z];
            case Length(s) of
                  0 : begin end;
                  1 : begin
                        n:=Pos(s[1],'123456789');
                        if n>0 then
                          begin
                            feld[sp,z]:=[n];
                          //  aktPuzzle[sp,z]:=n;
                            fehler := not BesetzeFeld(sp,z,n);
                          end;
                      end;
                 else begin
                        m:=[];
                        repeat
                          n:=Pos(s[1],'123456789');
                          if n>0 then m:=m+[n];
                          delete(s,1,2);
                        until s='';
                        feld[sp,z]:=m;
                      end;
               end;
             veraendert:=false;
          end;
    end;

  ButtonZeigeZwang.Enabled:=false;
  ButtonZeigeHilfe.Enabled:=true;
  ButtonVersteckeHilfe.Enabled:=false;
end;

procedure TSudokuForm.AutoRunModusStart(titel:string);
begin
  if neuesPuzzle then
    begin
      veraendert:=true;
      InitialisiereFeld;
      neuesPuzzle:=false;
    end;
  LabelInfo.Caption:=titel;
  LabelAnz.Caption:='';
  BitBtnBeenden.Enabled:=false;
  PanelUserInput.Visible:=false;
  PanelStart.Hide;
  FramePausenStrg1.NormalStart;
  AendereCursor(crHourGlass);
  fehler:=false;
end;

procedure TSudokuForm.AutoRunModusStopp;
begin
  AendereCursor(crDefault);
  BitBtnBeenden.Enabled:=true;
  FramePausenStrg1.Hide;
  PanelStart.show;
  PanelStart.repaint;
end;

procedure TSudokuForm.Backtrack(sucheAlle:boolean; modus:integer);
var fertig : Boolean;
    k      : integer;
begin
  anzLsg:=0;
  anzAufruf:=0;
  for k:=0 to 8 do reihe[k]:=k;
  case modus of
    0 : begin
           AutoRunModusStart(RSArr[rsBacktrackingbruteForce]);
           fertig:=BruteForceBackTrack(0,0, sucheAlle);
         end;
    1 : begin
           SortiereReihe;
           AutoRunModusStart(RSArr[rsBacktrackingBFOptimiert]);
           fertig:=BruteForceBackTrack(0,0, sucheAlle);
        end;
    2 : begin
           AutoRunModusStart(RSArr[rsBacktrackingErstZwangsbelegung]);
           fertig:=Zwangsbelegung(false);
           if fertig
             then begin
                    anzLsg:=1;
                    lsgPuzzle:=aktPuzzle;
                  end
             else begin
                    SortiereReihe;
                    fertig:=BruteForceBackTrack(0,0, sucheAlle);
                  end;
        end;
    end;
   if abbruch then LabelInfo.caption:=RSArr[rsAbgebrochen] else
   if anzLsg=0
     then LabelInfo.caption:=RSArr[rsKeineLoesung]
     else begin
            if anzLsg=1
              then LabelInfo.caption:=RSArr[rsGeloest]
              else LabelInfo.caption:=IntToStr(anzLsg)+RSArr[rsLoesungenGefunden2];
           aktPuzzle:=lsgPuzzle;
           ZeigeGrid(false);
         end;
  AutoRunModusStopp;
  LabelAnz.Caption:=IntToStr(anzAufruf);
end;

function TSudokuForm.BesetzeFeld(x,y,ziffer:integer):boolean;
var sp, z, sp0, z0 : integer;
begin
  // prüfe, ob Eingabe zulaessig ist
   for sp:=0 to 8 do if sp<>x then         //Zeile
     if feld[sp,y]-[ziffer]=[]
       then exit(false);

  for z:=0 to 8 do if z<>y then         //Spalte
    if feld[x,z]-[ziffer]=[]
        then exit(false);

  sp0:=(x div 3)*3;
  z0 :=(y div 3)*3;
  for sp:=sp0 to sp0+2 do                  //in 3x3_Matrix ändern
    for z:=z0 to z0+2 do
      if (sp<>x) or (z<>y) then
        if feld[sp,z]-[ziffer]=[] then exit(false);

  for sp:=0 to 8 do if sp<>x then         //Zeile
    begin
      feld[sp,y]:=feld[sp,y]-[ziffer];
    end;
  for z:=0 to 8 do if z<>y then         //Spalte
    begin
      feld[x,z]:=feld[x,z]-[ziffer];
    end;

  for sp:=sp0 to sp0+2 do                  //in 3x3_Matrix ändern
    for z:=z0 to z0+2 do
      if (sp<>x) or (z<>y) then
        begin
          feld[sp,z]:=feld[sp,z]-[ziffer];
        end;

  feld[x,y]:=[ziffer];
  aktPuzzle[x,y]:=ziffer;
  if zeigen then stringGrid1.Cells[x,y]:=IntToStr(ziffer);

  ZifInSpalte[x]:=ZifInSpalte[x]+[ziffer];
  ZifInZeile[y]:=ZifInZeile[y]+[ziffer];
  sp0:=(x div 3) + (y div 3)*3;
  ZifInQuadrat[sp0]:= ZifInQuadrat[sp0]+[ziffer];
  result:=true;
end;

procedure TSudokuForm.BefreieFeld(x,y:integer);
begin
  feld[x,y]:=[];
  aktPuzzle[x,y]:=0;
  if zeigen then stringGrid1.Cells[x,y]:='';
  ErstelleFeldDaten
end;

procedure TSudokuForm.BitBtnBeendenClick(Sender: TObject);
begin
  abbruch:=true;
  close;
end;

procedure TSudokuForm.BitBtnEndUserModusClick(Sender: TObject);
begin
  ButtonZeigeZwangClick(nil);
  panelUserInput.Visible:=false;
  panelStart.Visible:=true;
end;

procedure TSudokuForm.BitBtnNeuStartClick(Sender: TObject);
begin
  UebertragePuzzleAufGrid(lastPuzzle);
  BitBtnStartClick(nil);
end;

procedure TSudokuForm.BitBtnStartClick(Sender: TObject);
var b : boolean;
begin
  b:=CheckBoxAlleLsgSuchen.Checked;
  case RadioGroupMethode.ItemIndex of
        0 : BackTrack(b,0);
        1 : BackTrack(b,1);
        2 : BackTrack(b,2);
        3 : LogikTest;
        4 : UserInput;
  end;
end;

procedure TSudokuForm.ButtonLeeresFeldClick(Sender: TObject);
begin
  LeeresFeld;
  ButtonInit.Enabled:=true;
end;

function TSudokuForm.BruteForceBackTrack(x,y:integer; sucheAlle:boolean):boolean;
var qn      : integer;
    ziffer  : byte;
    erfolg  : boolean;
    vergeben: TNumSet;

    procedure SetzeZiffer(sp,z, zif:integer);
    const fix = $1F;
    begin
      aktPuzzle[sp,z]:=zif;
      ZifInSpalte[sp]:=ZifInSpalte[sp]+[zif];
      ZifInZeile[z]:=ZifInZeile[z]+[zif];
      ZifInQuadrat[qn]:= ZifInQuadrat[qn]+[zif];
      if zeigen
        then stringGrid1.Cells[sp,z]:=IntToStr(zif)
        else if anzAufruf and fix = fix then LabelAnz.Caption:=IntToStr(anzAufruf);
    end;

    procedure EntferneZiffer(sp,z, zif:integer);
    begin
      aktPuzzle[sp,z]:=0;
      ZifInSpalte[sp]:=ZifInSpalte[sp]-[zif];
      ZifInZeile[z]:=ZifInZeile[z]-[zif];
      ZifInQuadrat[qn]:= ZifInQuadrat[qn]-[zif];
      if zeigen then stringGrid1.Cells[sp,z]:='';
    end;

begin
  erfolg:=false;
  if abbruch then exit(false);
  inc( anzAufruf );
  while aktPuzzle[x,reihe[y]]<>0 do
    begin
      inc(x);
      if x>8 then
         begin
           x:=0; inc(y);
           if y>8 then
             begin
               inc(anzLsg);
               if anzLsg=1 then move(aktPuzzle, LsgPuzzle, SizeOf(aktPuzzle));
               erfolg:=not sucheAlle;
               exit(erfolg);
             end;
         end;
    end;
  qn:=(x div 3) + (reihe[y] div 3)*3;
  vergeben :=  ZifInZeile[reihe[y]]+ZifInSpalte[x]+ZifInQuadrat[qn];
  for ziffer:=1 to 9 do
    if not (ziffer in vergeben)
      then begin
             SetzeZiffer(x,reihe[y], ziffer);
             CheckPause;
             erfolg:=BruteForceBackTrack(x,y,sucheAlle);
             if not erfolg
               then begin
                      EntferneZiffer(x,reihe[y],ziffer);
                      CheckPause;
                    end
               else break;
             if abbruch then break;
           end;
  result:=erfolg;
end;

procedure TSudokuForm.ButtonAktualisiereHilfeClick(Sender: TObject);
begin
  neuesPuzzle:=false; veraendert:=true;
  ButtonZeigeZwangClick(Sender);
  veraendert:=true;
  AktualisiereFeld;
  ButtonZeigeHilfeClick(sender);
  ButtonAktualisiereHilfe.Enabled:=false;
end;

procedure TSudokuForm.ButtonBeispielClick(Sender: TObject);
begin
  case SpinEditBspNr.Value of
        1 : UebertragePuzzleAufGrid(bsp1);
        2 : UebertragePuzzleAufGrid(bsp2);
        3 : UebertragePuzzleAufGrid(bsp3);
        4 : UebertragePuzzleAufGrid(bsp4);
        5 : UebertragePuzzleAufGrid(bsp5);
       end;
end;

procedure TSudokuForm.ButtonInitClick(Sender: TObject);
begin
  neuesPuzzle:=true; veraendert:=true;
  ButtonZeigeZwangClick(ButtonZeigeZwang);
  InitialisiereFeld;
  ButtonAktualisiereHilfe.Enabled:=true;
end;

procedure TSudokuForm.ButtonZeigeZwangClick(Sender: TObject);
var sp, z, n : integer;
begin
  if Sender=ButtonZeigeZwang then n:=2 else n:=1;
  for sp:=0 to 8 do
    for z:=0 to 8 do
      if Length(stringGrid1.Cells[sp,z])>n
        then stringGrid1.Cells[sp,z]:='';

  ButtonZeigeHilfe.Enabled:=true;
  ButtonVersteckeHilfe.Enabled:=false;
end;

procedure TSudokuForm.ButtonZeigeHilfeClick(Sender: TObject);
begin
  ZeigeGrid(true);
  ButtonZeigeHilfe.Enabled:=false;
  ButtonVersteckeHilfe.Enabled:=true;
  ButtonZeigeZwang.Enabled:=true;
end;

procedure TSudokuForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked);
end;

function TSudokuForm.CheckSpalte(sp:integer):boolean;
var m,m1,m2,m3, c1,c2,c3 : TNumSet;
    z,sp1  : integer;

    procedure Bereinige( cSet:TNumSet; k:integer);
    var j, z1 : integer;
    begin
      for j:=sp1 to sp1+2 do
        if j<>sp then
          for z1:=k to k+2 do
            if (feld[j,z1]*cSet)<>[] then
              begin
                feld[j,z1]:=feld[j,z1]-cSet;
                result:=true
              end;
    end;

begin
  result:=false;
  m:=[];
  for z:=0 to 8 do if AnzahlImSet(feld[sp,z])=1 then m:=m+feld[sp,z];
  m1:=m + feld[sp,0] + feld[sp,1] + feld[sp,2];
  m2:=m + feld[sp,3] + feld[sp,4] + feld[sp,5];
  m3:=m + feld[sp,6] + feld[sp,7] + feld[sp,8];
  c1:=alleZiffern-m1;
  c2:=alleZiffern-m2;
  c3:=alleZiffern-m3;
  sp1:= (sp div 3 ) * 3;
  if c1*c2<>[] then Bereinige(c1*c2,6);
  if c1*c3<>[] then Bereinige(c1*c3,3);
  if c2*c3<>[] then Bereinige(c2*c3,0);
end;

function TSudokuForm.CheckZeile(z:integer):boolean;
var m,m1,m2,m3, c1,c2,c3 : TNumSet;
    sp,z1  : integer;

    procedure Bereinige( cSet:TNumSet; k:integer);
    var j, sp1 : integer;
    begin
      for j:=z1 to z1+2 do
        if j<>z then
          for sp1:=k to k+2 do
            if (feld[sp1,j]*cSet)<>[] then
              begin
                feld[sp1,j]:=feld[sp1,j]-cSet;
                result:=true
              end;
    end;

begin
  result:=false;
  m:=[];
  for sp:=0 to 8 do if AnzahlImSet(feld[sp,z])=1 then m:=m+feld[sp,z];
  m1:=m + feld[0,z] + feld[1,z] + feld[2,z];
  m2:=m + feld[3,z] + feld[4,z] + feld[5,z];
  m3:=m + feld[6,z] + feld[7,z] + feld[8,z];
  c1:=alleZiffern-m1;
  c2:=alleZiffern-m2;
  c3:=alleZiffern-m3;
  z1:= (z div 3 ) * 3;
  if c1*c2<>[] then Bereinige(c1*c2,6);
  if c1*c3<>[] then Bereinige(c1*c3,3);
  if c2*c3<>[] then Bereinige(c2*c3,0);
end;

function TSudokuForm.EinzigesElement(m:TNumSet):integer;
var anz : integer;
begin
  if m=[] then exit(0);
  anz:=AnzahlImSet(m);
  if anz=1
    then result:=FirstInSet(m)
    else result:=-anz;
end;

procedure TSudokuForm.ErstelleFeldDaten;
var sp, z, n : integer;
    s        : string;
    tmp      : TSudo;
begin
  tmp:=Default(TSudo);
  for sp:=0 to 8 do
    for z:=0 to 8 do
      begin
        s:=stringGrid1.Cells[sp,z];
        if (s='') or (s='0')
          then feld[sp,z]:=alleZiffern
          else if (Length(s)=1) and (Pos(s,'123456789')>0)
                 then begin
                        n:=StrToInt(s);
                        tmp[sp,z]:=n;
                        feld[sp,z]:=[n];
                      end
                 else feld[sp,z]:=[];
      end;
  ZifInSpalte:=Default(TZifferIn);
  ZifInZeile:=Default(TZifferIn);
  ZifInQuadrat:=Default(TZifferIn);
  aktPuzzle:=Default(TSudo);
  for sp:=0 to 8 do
    for z:=0 to 8 do
      begin
        n:=tmp[sp,z];
        if n>0 then
          BesetzeFeld(sp,z,n);
      end;
end;

procedure TSudokuForm.FormActivate(Sender: TObject);
begin
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(self.CheckBoxZwischenSchritt,false);
  TranslationsFor_sudoku;
  ButtonBeispielClick(nil);
end;

procedure TSudokuForm.FormCreate(Sender: TObject);
begin
  SkaliereForm(self);
  SpinEditBspNr.MaxValue:=bspMax;
  ButtonZeigeHilfe.Enabled:=false;
  ButtonAktualisiereHilfe.Enabled:=false;
end;

function TSudokuForm.GetVerteilungSpalte(sp: integer): TVerteilung;
var k, z : integer;
    m    : TNumSet;
begin
  for k:=1 to 9 do
    begin
      m:=[];
      for z:=0 to 8 do
        if (k in feld[sp,z]) and (aktPuzzle[sp,z]<>k) then m:=m+[z+1];
      result[k]:=m;
      if AnzahlImSet(m)=1 then
        begin
          nextMove[sp,FirstInSet(m)-1]:=k;
          zwangGefunden:=true;
        end;
    end;
end;

function TSudokuForm.GetVerteilungZeile(z: integer): TVerteilung;
var k, sp : integer;
    m     : TNumSet;
begin
  for k:=1 to 9 do
    begin
      m:=[];
      for sp:=0 to 8 do
       if (k in feld[sp,z]) and (aktPuzzle[sp,z]<>k) then m:=m+[sp+1];
      result[k]:=m;
      if AnzahlImSet(m)=1 then
        begin
          nextMove[FirstInSet(m)-1,z]:=k;
          zwangGefunden:=true
        end;
    end;
end;

function TSudokuForm.GetVerteilungQuadrat(nr: integer): TVerteilung;
var k, j, n,
    sp, z, stelle : integer;
    m             : TNumSet;
begin
   j:=(nr mod 3)*3;
   n:=(nr div 3)*3;
   for k:=1 to 9 do
    begin
      m:=[];
      for sp:=j to j+2 do
       for z:=n to n+2 do
        if (k in feld[sp,z]) and (aktPuzzle[sp,z]<>k) then m:=m+[(sp-j)+(z-n)*3+1];
      result[k]:=m;
      if AnzahlImSet(m)=1 then
        begin
          stelle:=FirstInSet(m)-1;
          nextMove[j+(stelle mod 3),n+(stelle div 3)]:=k;
          zwangGefunden:=true;
        end;
    end;
end;

procedure TSudokuForm.InitialisiereFeld;
begin
  if neuesPuzzle and veraendert then
    begin
      ErstelleFeldDaten;
      Move(aktPuzzle,LastPuzzle,SizeOf(aktPuzzle));
      veraendert:=false;
      labelInfo.Caption:='';
      BitBtnNeuStart.Enabled:=true;
    end;
  LabelAnz.Caption:='';
  ButtonZeigeZwang.Enabled:=false;
  ButtonZeigeHilfe.Enabled:=true;
  ButtonVersteckeHilfe.Enabled:=false;
  buttonInit.Visible:=false;
end;

procedure TSudokuForm.LeeresFeld;
begin
  FillChar(bsp0,SizeOf(bsp0),0);
  UebertragePuzzleAufGrid(bsp0);
end;

procedure TSudokuForm.LogikTest;
var sp, z, n          : integer;
    fertig, geaendert : boolean;
begin
  AutoRunModusStart(RSArr[rsLogik]);
  repeat
    fertig:=true;  geaendert:=false;
    LabelInfo.caption:=RSArr[rsEindeutigeWerteSetzen];
    for sp:=0 to 8 do
      for z:=0 to 8 do
        if (stringGrid1.Cells[sp,z]='') and not(abbruch)
          then begin
                 application.ProcessMessages;
                 fertig:=false;
                 n:=TesteFeld(sp,z);
                 if (n>0) and not(abbruch)  then
                   begin
                     geaendert:=BesetzeFeld(sp,z,n);
                     CheckPause;
                   end
               end;
    if not(geaendert) and not(fertig) and not(abbruch)
      then begin
             LabelInfo.caption:=RSArr[rsMoeglichkeitenReduzieren];
             KurzePause(2);
             for z:=0 to 8 do
               begin
                 if reduziereZeile(z) then geaendert:=true;
                 if reduziereSpalte(z) then geaendert:=true;
                 if checkSpalte(z) then geaendert:=true;
                 if checkZeile(z) then geaendert:=true;
               end;
           end;
    if not(geaendert) and not(fertig) and not(abbruch)
      then begin
             LabelInfo.caption:=RSArr[rsDublettenBehandeln];
             KurzePause(2);
             for z:=0 to 8 do
               begin
                 if SucheDubletteInSpalte(z) then geaendert:=true;
                 if SucheDubletteInZeile(z) then geaendert:=true;
                 if SucheDubletteInQuadrat(z+1) then geaendert:=true;
               end;
           end;
  until not(geaendert) or fertig or abbruch;
  if fertig then LabelInfo.caption:=RSArr[rsGeloest]
            else LabelInfo.caption:=RSArr[rsKeineLoesung];
  AutoRunModusStopp;
end;

function TSudokuForm.ReduziereZeile(z:integer):boolean;
var m,m1,m2 : TNumSet;
    k,sp,j,ze : integer;
    geaendert : boolean;
begin
  geaendert:=false;
  k:=0; ze:= (z div 3 ) * 3;
  repeat
    m1:=feld[k,z]+feld[k+1,z]+feld[k+2,z];
    m2:=[];
    for j:=ze to ze+2 do if j<>z then m2:=m2+feld[k,j]+feld[k+1,j]+feld[k+2,j];
    m:=m1-m2;
    if m<>[] then for sp:=0 to 8 do
      if (sp div 3)*3<> k
        then begin
               m2:=feld[sp,z]-m;
               if feld[sp,z]-m2<>[] then
                 begin
                   feld[sp,z]:=m2;
                   geaendert:=true;
                 end;
             end;
    k:=k+3;
  until k>6;
  result:=geaendert;
end;

function TSudokuForm.ReduziereSpalte(sp:integer):boolean;
var m,m1,m2 : TNumSet;
    k,z,j,sp1 : integer;
    geaendert : boolean;
begin
  geaendert:=false;
  k:=0; sp1:= (sp div 3 ) * 3;
  repeat
    m1:=feld[sp,k]+feld[sp,k+1]+feld[sp,k+2];
    m2:=[];
    for j:=sp1 to sp1+2 do if j<>sp then m2:=m2+feld[j,k]+feld[j,k+1]+feld[j,k+2];
    m:=m1-m2;
    if m<>[] then for z:=0 to 8 do
      if (z div 3)*3 <> k
        then begin
               m2:=feld[sp,z]-m;
               if feld[sp,z]-m2<>[] then
                 begin
                   feld[sp,z]:=m2;
                   geaendert:=true;
                 end;
             end;
    k:=k+3;
  until k>6;
  result:=geaendert;
end;

procedure TSudokuForm.SortiereReihe;
var k, j, n : integer;
    a       : array[0..8] of integer;
begin
  for k:=0 to 8 do
    begin
      j:=0;
      for n:=0 to 8 do
        if aktPuzzle[n,k]<>0 then inc(j);
      a[k]:=j;
      reihe[k]:=k;
    end;
  for k:=1 to 8 do
    begin
      j:=k-1;
      n:=a[k];
      while (j>=0) and (a[j]<n) do
        begin
          a[j+1]:=a[j];
          a[j]:=n;
          reihe[j+1]:=reihe[j];
          reihe[j]:=k;
          dec(j)
        end;
    end;
end;

procedure TSudokuForm.StringGrid1Click(Sender: TObject);
begin
  ButtonInit.Visible:=neuesPuzzle;
  veraendert:=true;
end;

procedure TSudokuForm.StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
const big = 14;
var s : string;
begin
  s:=stringGrid1.cells[Col,row];
  stringGrid1.canvas.pen.color:=clGray;
  stringGrid1.canvas.pen.width:=1;
  stringGrid1.canvas.Rectangle(rect.left-1,rect.top-1,rect.right+1,rect.bottom+1);
  if lastPuzzle[col,row]<>0
    then begin
           stringGrid1.canvas.Font.Size:=big;
           stringGrid1.canvas.Font.Style:=[fsBold];
           stringGrid1.canvas.Font.color:=clRed
         end
    else if Length(s)=1
           then begin
                  stringGrid1.canvas.Font.Size:=big;
                  stringGrid1.canvas.Font.Style:=[];
                  stringGrid1.canvas.Font.color:=clBlack
                end
           else begin
                  stringGrid1.canvas.Font.Size:=6;
                  stringGrid1.canvas.Font.Style:=[];
                  stringGrid1.canvas.Font.color:=clBlack
                end;
  stringGrid1.canvas.TextOut((rect.left+rect.right-canvas.textWidth(s)) div 2,(rect.top+rect.bottom-canvas.textHeight(s)) div 2,s);
  if (col=0) or (col=3) or (col=6) then
    begin
      stringGrid1.canvas.pen.color:=clBlack;
      stringGrid1.canvas.pen.width:=3;
      stringGrid1.canvas.moveto(rect.left,rect.top);
      stringGrid1.canvas.lineto(rect.left,rect.bottom);
    end;
  if col=8 then
     begin
      stringGrid1.canvas.pen.color:=clBlack;
      stringGrid1.canvas.pen.width:=3;
      stringGrid1.canvas.moveto(rect.right-1,rect.top);
      stringGrid1.canvas.lineto(rect.right-1,rect.bottom);
    end;
  if (row=0) or (row=3) or (row=6) then
    begin
      stringGrid1.canvas.pen.color:=clBlack;
      stringGrid1.canvas.pen.width:=3;
      stringGrid1.canvas.moveto(rect.left,rect.top);
      stringGrid1.canvas.lineto(rect.right,rect.top);
    end;
  if row=8 then
     begin
      stringGrid1.canvas.pen.color:=clBlack;
      stringGrid1.canvas.pen.width:=3;
      stringGrid1.canvas.moveto(rect.left,rect.bottom-1);
      stringGrid1.canvas.lineto(rect.right,rect.bottom-1);
    end;
end;

procedure TSudokuForm.StringGrid1EditingDone(Sender: TObject);
var s : string;
    x,y,ziffer : integer;
begin
  x:=stringGrid1.Col;
  y:=stringGrid1.row;
  s:=stringGrid1.Cells[x,y];
  if (length(s)=1) and (Pos(s,'123456789')>0)
    then begin
           ziffer:=StrToInt(s);
           if not BesetzeFeld(x,y,ziffer)
            then stringGrid1.Cells[x,y]:='';
         end
    else if (s='') or (s=' ') or (s='0')
           then BefreieFeld(x,y)
           else exit;
  ButtonAktualisiereHilfe.Enabled:=true;
end;

function TSudokuForm.SucheDubletteInQuadrat(nr:integer):boolean;
var k,sp,sp1,sp2     : integer;
    z0,sp0,z,z1,z2   : integer;
    m,m2             : TNumSet;
begin
  result:=false;
  z0:=((nr-1) Div 3) * 3;
  sp0:=((nr-1) Mod 3) * 3;
  for z:=z0 to z0+2 do
    for sp:=sp0 to sp0+2 do
      begin
        m:=feld[sp,z];
        if AnzahlImSet(m)=2 then
          begin
            for k:=(z-z0)*3+(sp-sp0)+1 to 8 do
              begin
                sp1:=sp0 + (k mod 3);
                z1:=z0 + (k div 3);
                if m = feld[sp1,z1] then
                  begin
                    for sp2:=sp0 to sp0+2 do
                      for z2:=z0 to z0+2 do
                       if ( (sp2<>sp) or (z2<>z) ) and ( (sp2<>sp1) or (z2<>z1) ) then
                         begin
                           m2:=feld[sp2,z2]-m;
                           if feld[sp2,z2]-m2<>[] then
                             begin
                               feld[sp2,z2]:=m2;
                               result:=true;
                            end;
                        end;
                  end;
              end;
          end;
      end;
end;

function TSudokuForm.SucheDubletteInSpalte(sp:integer):boolean;
var k,z,z1 : integer;
    m,m2   : TNumSet;
begin
  result:=false;
  for z:=0 to 8 do
    begin
      m:=feld[sp,z];
      if AnzahlImSet(m)=2 then
        begin
          for z1:=z+1 to 8 do
            if m=feld[sp,z1] then
              begin
                for k:=0 to 8 do if (k<>z) and (k<>z1) then
                  begin
                    m2:=feld[sp,k]-m;
                    if m2 <> feld[sp,k] then
                      begin
                        feld[sp,k]:=m2;
                        result:=true;
                      end;
                  end;
              end;
        end;
    end;
end;

function TSudokuForm.SucheDubletteInZeile(z:integer):boolean;
var k,sp,sp1 : integer;
    m,m2     : TNumSet;
begin
  result:=false;
  for sp:=0 to 8 do
    begin
      m:=feld[sp,z];
      if AnzahlImSet(m)=2 then
        begin
          for sp1:=sp+1 to 8 do
            if m=feld[sp1,z] then
              begin
                for k:=0 to 8 do if (k<>sp) and (k<>sp1) then
                  begin
                    m2:=feld[k,z]-m;
                    if m2 <> feld[k,z] then
                      begin
                        feld[k,z]:=m2;
                        result:=true;
                      end;
                  end;
              end;
        end;
    end;
end;

function TSudokuForm.SucheTriplettInQuadrat(nr: integer): boolean;
var k, n, j, i,
    sp, z       : integer;
    m, m1       : TNumSet;
begin
  result:=false;
  sp:=((nr-1) mod 3)*3;
  z :=((nr-1) div 3)*3;
  for k:=0 to 6 do    // (Pseudo-)Triple behandeln: 3 Ziffern verteilen sich auf 3 Felder des Quadrats
    begin
      m1:=feld[sp + (k mod 3), z + (k div 3)];
      if (AnzahlImSet(m1)>1) and (AnzahlImSet(m1)<=3) then
        for n:=k+1 to 7 do
          begin
            m:=feld[sp + (n mod 3),z + (n div 3)];
            if (AnzahlImSet(m)>1) and (AnzahlImSet(m1+m)<=3) then
              begin
                m1:=m1+m;
                for j:=n+1 to 8 do
                  begin
                    m:=feld[sp + (j mod 3), z + (j div 3)];
                    if (AnzahlImSet(m)>1) and (AnzahlImSet(m1+m)<=3) then
                      begin
                        m1:=m1+m;
                        m:=[k,n,j];
                        for i:=0 to 8 do
                          if not(i in m) then
                            begin
                              feld[sp + i mod 3, 1 + (i div 3)]:=feld[sp + i mod 3, z + (i div 3)] - m1;
                              result:=true;
                            end;
                      end;
                  end;
              end;
          end;
    end;
end;

function TSudokuForm.SucheTriplettInSpalte(sp: integer): boolean;
var k, n, j, z : integer;
    m, m1      : TNumSet;
begin
  result:=false;
  for k:=0 to 6 do    // (Pseudo-)Triple behandeln: 3 Ziffern verteilen sich auf 3 Felder der Spalte
    if (AnzahlImSet(feld[sp,k])>1) and (AnzahlImSet(feld[sp,k])<=3) then
      for n:=k+1 to 7 do
        if (AnzahlImSet(feld[sp,n])>1) and (AnzahlImSet(feld[sp,k]+feld[sp,n])<=3) then
          for j:=n+1 to 8 do
            if (AnzahlImSet(feld[sp,j])>1) and (AnzahlImSet(feld[sp,k]+feld[sp,n]+feld[sp,j])<=3) then
               begin
                 m:=[k,n,j];
                 m1:=feld[sp,k]+feld[sp,n]+feld[sp,j];
                 for z:=0 to 8 do
                   if not(z in m) then
                     begin
                       feld[sp,z]:=feld[sp,z]-m1;
                       result:=true;
                     end;
               end;
end;

function TSudokuForm.SucheTriplettInZeile(z: integer): boolean;
var k, n, j, sp : integer;
    m, m1       : TNumSet;
begin
  result:=false;
  for k:=0 to 6 do    // (Pseudo-)Triple behandeln: 3 Ziffern verteilen sich auf 3 Felder der Zeile
    if (AnzahlImSet(feld[k,z])>1) and (AnzahlImSet(feld[k,z])<=3) then
       for n:=k+1 to 7 do
         if (AnzahlImSet(feld[n,z])>1) and (AnzahlImSet(feld[k,z]+feld[n,z])<=3) then
           for j:=n+1 to 8 do
             if (AnzahlImSet(feld[j,z])>1) and (AnzahlImSet(feld[k,z]+feld[n,z]+feld[j,z])<=3) then
               begin
                 m:=[k,n,j];
                 m1:=feld[k,z]+feld[n,z]+feld[j,z];
                 for sp:=0 to 8 do
                   if not(sp in m) then
                     begin
                       feld[sp,z]:=feld[sp,z]-m1;
                       result:=true;
                     end;
               end;
end;

function TSudokuForm.TesteFeld(x,y:integer): integer;
var k,j,n,sp,z : integer;
    m,m1,m2,m3 : TNumSet;
begin
  m1:=[];
  n:=EinzigesElement(feld[x,y]);
  if n<=0 then
    begin
      sp:=(x div 3)*3;
      z :=(y div 3)*3;
      m:=[];
      for k:=sp to sp+2 do           //in Quadrat prüfen
        for j:=z to z+2 do
          if (k<>x) or (j<>y) then m:=m+feld[k,j];
      m1:=feld[x,y]-m;
      n:=EinzigesElement(m1);
    end;
  if n<=0
   then begin
          m:=[];
          for k:=0 to 8 do if (k<>x) then m:=m+feld[k,y];
          m2:=feld[x,y]-m;
          n:=EinzigesElement(m2);
          if n<=0 then
            begin
              m:=[];
              for k:=0 to 8 do if (k<>y) then m:=m+feld[x,k];
              m3:=feld[x,y]-m;
              n:=EinzigesElement(m3);
              if n<=0 then
                begin
                  m:=feld[x,y]-(m1+m2+m3);
                  n:=EinzigesElement(m);
                end;
            end;
        end;
  result:=n;
end;

procedure TSudokuForm.UebertragePuzzleAufGrid(puzzle:TSudo);
var sp,z : integer;
begin
  neuesPuzzle:=true;
  veraendert:=true;
  ButtonZeigeZwang.Enabled:=false;
  ButtonZeigeHilfe.Enabled:=false;
  ButtonVersteckeHilfe.Enabled:=false;
  for sp:=0 to 8 do
    for z:=0 to 8 do
      begin
        if puzzle[sp,z]>0
          then StringGrid1.Cells[sp,z]:=InttoStr(puzzle[sp,z])
          else StringGrid1.Cells[sp,z]:='';
        Feld[sp,z]:=alleZiffern;
      end;
  InitialisiereFeld;
end;

procedure TSudokuForm.UserInput;
begin
  panelStart.Visible:=false;
  panelUserInput.Visible:=true;
end;

procedure TSudokuForm.ZeigeGrid(zeigHilfe:boolean);
var sp, z, x, zahl : integer;
    aktSet   : TNumSet;
    s        : string;
begin
  for sp:=0 to 8 do
    for z:=0 to 8 do
      begin
        zahl:= aktPuzzle[sp,z];
        if zahl=0
          then begin
                 s:='';
                 if zeigHilfe
                   then begin
                          aktSet:=feld[sp,z];
                          for x:=1 to 9 do
                            if (x in aktSet) then s:=s+IntToStr(x)+',';
                        end;
                 stringGrid1.Cells[sp,z]:=s;
               end
          else stringGrid1.Cells[sp,z]:=IntToStr(zahl);
      end;
   application.ProcessMessages;
end;

function TSudokuForm.Zwangsbelegung(zeigeBlock:boolean):boolean;
var sp, z, nr, ziffer, anz : integer;
begin
  anz:=0;
  repeat
    result:=true;
    zwangGefunden:=false;
    fillchar(nextMove,sizeOf(nextMove),0);
    for sp:=0 to 8 do GetVerteilungSpalte(sp);
    for z:=0 to 8 do GetVerteilungZeile(z);
    for nr:=0 to 8 do GetVerteilungQuadrat(nr);

    for sp:=0 to 8 do
      for z:=0 to 8 do
        begin
          ziffer:=nextMove[sp,z];
          application.ProcessMessages;
          if ziffer>0
            then begin
                   fehler:=not BesetzeFeld(sp,z,ziffer);
                   if abbruch or fehler then exit(false);
                   Inc(anz);
                   CheckPause;
                 end
            else if aktPuzzle[sp,z]=0 then result:=false;
        end;
  until not zwangGefunden or abbruch or fehler;
  if (anz>0) and zeigeBlock then CheckPause;
end;


end.
