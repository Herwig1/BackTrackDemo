unit Rucksack;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   das Rucksack-Problem
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons, ExtCtrls, Grids,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

const maxTeile = 20;
      waageX0org  = 180;
      waageX1org  = 380;
      waageY0org  = 300;

type einzelTeil = record
                    gewicht,
                    wert      :word
                  end;
     waagePos = record xA,xE : integer end;

     teileArray = Array[1..maxTeile] of einzelTeil;
     eingepackt = set of Byte;

const anzahlBeispiel = 18;
      masseBeispiel  = 200;
      teileBeispiel : teileArray =
           ( (gewicht:10;wert:18), (gewicht:11;wert:20),  (gewicht:12;wert:17),
             (gewicht:13;wert:19), (gewicht:14;wert:25),  (gewicht:15;wert:21),
             (gewicht:16;wert:27), (gewicht:17;wert:23),  (gewicht:18;wert:25),
             (gewicht:19;wert:24), (gewicht:20;wert:28),  (gewicht:21;wert:22),
             (gewicht:22;wert:29), (gewicht:23;wert:27),  (gewicht:24;wert:31),
             (gewicht:25;wert:29), (gewicht:26;wert:28),  (gewicht:27;wert:30),
             (gewicht:28;wert:32), (gewicht:29;wert:40) );

type

  { TRucksackForm }

  TRucksackForm = class(TForm)
    ButtonStart: TBitBtn;
    edit1: TEdit;
    FramePausenStrg1: TFramePausenStrg;
    Memo1: TMemo;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    Panelbrett: TPanel;
    PaintBox1: TPaintBox;
    PanelEdit: TPanel;
    Splitter1: TSplitter;
    StringGrid2: TStringGrid;
    PanelRechts: TPanel;
    PanelStart: TPanel;
    SpeedButtonInputParts: TSpeedButton;
    StaticText1: TStaticText;
    SpinEdit1: TSpinEdit;
    CheckBoxZwischenSchritt: TCheckBox;
    StaticText2: TStaticText;
    SpinEdit2: TSpinEdit;
    procedure ButtonStartClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure SpeedButtonInputPartsClick(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
  private
    { Private-Deklarationen }
    gesamtGewicht           : word;
    gewicht, maxGewicht     : integer;
    anzahlteile, wert,
    maxWert                 : integer;
    waageX0,waageX1,waageY0 : integer;
    y0, y1, wPosX, wPosY,
    lage, xTab              : integer;

    unsortedTeile,teile     : teileArray;
    index                   : Array[1..maxTeile] of integer;
    waage                   : Array[0..15] of waagePos;
    rucksack, bestSack      : eingepackt;
    lsgNr                   : integer;
    loesungen               : array of eingepackt;
    function Ausgabe:string;
    procedure Einpacken(Var nr:integer; teileNr:integer);   { *Haupt* }
    procedure EntferneVonWaage(k:integer);
    procedure LiesTeile;
    procedure PackeAufWaage(k:integer);
    procedure StringGrid2Anpassen(nr:integer);
    procedure SortTeile;
    procedure StarteRunModus;
    procedure VerlasseRunModus;
    procedure ZeigeLoesung;
    procedure ZeigeTeile(mitWaage:boolean);
  public
    { Public-Deklarationen }
  end;

var
  RucksackForm: TRucksackForm;

implementation

  {$R *.lfm}

function TRucksackForm.Ausgabe:string;
  var k : integer;
  begin
    result:=RSArr[rsWert1]+IntToStr(maxWert)+RSArr[rsGewicht]+IntToStr(maxGewicht)+'  |';
    for k:=1 to anzahlTeile do
      if k in bestsack then result:=result+'  '+IntToStr(k);
  end;

procedure TRucksackForm.ButtonStartClick(Sender: TObject);
var k,n:integer;
begin
  fillChar(index,SizeOf(index),#0);
  rucksack:=[]; bestsack:=[];
  lsgNr:=0;
  SetLength(Loesungen,1);
  maxWert:=0;
  maxGewicht:=$7FFF;
  k:=0; n:=1;
  memo1.clear;
  StarteRunModus;
  ZeigeLoesung;
  repeat
    k:=k+1;
    edit1.text:=IntToStr(k);
    Einpacken(n,k);
  until (k=anzahlTeile) or abbruch;
  if abbruch
    then edit1.text:=RSArr[rsSucheAbgebrochen]
    else if (maxWert<>0)
           then begin
                  if lsgNr=1
                    then edit1.text:=RSArr[rsBesteLoesung]+Ausgabe
                    else edit1.text:=RSArr[rsEsGibt]+IntToStr(lsgNr)+RSArr[rsLoesungenerste]+Ausgabe;
                  ZeigeLoesung;
                end
           else edit1.text:=RSArr[rsKeineLoesung];
  VerlasseRunModus
end;

procedure TRucksackForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt( CheckBoxZwischenSchritt.Checked )
end;

{ ****************** Hauptprocedure ************** }
procedure TRucksackForm.Einpacken(var nr: integer; teileNr: integer);
var k : byte;
    s : string;
begin
  if gewicht+teile[teileNr].gewicht<=gesamtGewicht then
    begin
      index[nr]:=teileNr;
      wert:=wert+teile[teileNr].wert;
      gewicht:=gewicht+teile[teileNr].gewicht;
      rucksack:=rucksack+[teileNr];
      if (wert>maxWert) or ( (wert=maxWert) and (gewicht<=maxGewicht) ) then
        begin
          if (wert=maxWert) and (gewicht=maxGewicht)
            then begin
                   lsgNr:=lsgNr+1;
                 end
            else begin
                   maxWert:=wert;
                   maxGewicht:=gewicht;
                   bestSack:=rucksack;
                   lsgNr:=1;
                 end;
          SetLength(loesungen,lsgNr);
          loesungen[lsgNr-1]:=rucksack;
          s:=ausgabe;
          memo1.Lines.Add(s);
        end;
      if nr = anzahlTeile then exit;
      if zeigen Then PackeAufWaage(teileNr);
      nr:=nr+1;
      k:=anzahlTeile+1;
      while not ( (k-1) in rucksack) do k:=k-1;
      if k<=anzahlTeile then
      repeat
        if not (k in rucksack)
          then Einpacken(nr,k);
        k:=k+1;
      until (k>=anzahlTeile) or abbruch or (gewicht+teile[k].gewicht>gesamtGewicht );
      nr:=nr-1;
      rucksack:=rucksack-[teileNr];
      wert:=wert-teile[teileNr].wert;
      gewicht:=gewicht-teile[teileNr].gewicht;
      if zeigen then EntferneVonWaage(teileNr);
    end;
end;

procedure TRucksackForm.EntferneVonWaage(k:integer);
begin
  with paintbox1.canvas do
    begin
      pen.color:=clBtnFace;
      brush.color:=clBtnFace;
      wPosX:=wPosX-teile[k].gewicht-2;
      rectangle(wPosX, wPosY-y0,wPosX+teile[k].gewicht,wPosY);
      if (wPosX=waage[lage].xA) and (lage>1) then
        begin
          lage:=lage-1; wPosY:=wPosY+y1; wPosX:=waage[lage].xE;
        end;
      TextOut(waageX0+50,waageY0+40,IntToStr(gewicht)+'           ');
      TextOut(waageX1-50,waageY0+40,IntToStr(wert)+'          ');
      pen.color:=clWhite;
      brush.color:=clRed;
      rectangle(xTab, k*y1, xTab+teile[k].gewicht, k*y1+y0);
    end;
  CheckPause;
end;

procedure TRucksackForm.FormActivate(Sender: TObject);
begin
  liesTeile;
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  TranslationsFor_Rucksack;
end;

procedure TRucksackForm.FormCreate(Sender: TObject);
var fs,k : integer;
begin
  SkaliereForm(self);
  fs:=stringGrid2.Font.Size;
  repeat
    fs:=fs-1;
    stringGrid2.Font.Size:=fs;
    edit1.Font.size:=fs;
  until stringGrid2.Font.size<font.size;
  fs:=paintBox1.Font.Size;
  while paintbox1.Canvas.TextHeight('12')*(maxTeile+2)>paintBox1.Height do
    begin
      fs:=fs-1;
      paintBox1.Font.Size:=fs;
    end;
  anzahlTeile:=anzahlBeispiel;
  gesamtgewicht:=masseBeispiel;
  with stringGrid2 do
     begin
       rowCount:=maxTeile+1;
       cells[0,0]:=RSArr[rsNr];
       cells[1,0]:=RSArr[rsGewicht1];
       cells[2,0]:=RSArr[rsWert];
       for k:=1 to maxTeile do
         begin
           cells[0,k]:=IntToStr(k);
           cells[1,k]:=IntToStr(teileBeispiel[k].gewicht);
           cells[2,k]:=IntToStr(teileBeispiel[k].wert);
         end;
    end;
  teile:=teileBeispiel;
  unsortedTeile:=teileBeispiel;
  lage:=1;
  waageX0:=ScaleX(waageX0org, orgDPI);
  waageX1:=ScaleX(waageX1org, orgDPI);
  waageY0:=ScaleY(waageY0org, orgDPI);
  waage[0].xA:=waageX0; waage[0].xE:=waageX1;
  waage[1].xA:=waageX0+5;
  spinEdit1.value:=anzahlTeile;
  spinEdit2.value:=gesamtgewicht;
end;

procedure TRucksackForm.LiesTeile;
var k: integer;
begin
  with stringGrid2 do
  for k:=1 to anzahlTeile do
    begin
      try
        unsortedTeile[k].gewicht:=StrToInt(cells[1,k]);
        unsortedTeile[k].wert:=StrToInt(cells[2,k]);
        if k=anzahlTeile then SortTeile;
      except
        stringGrid2.setfocus;
        exit;
      end;
    end;
end;

procedure TRucksackForm.Memo1Click(Sender: TObject);
var s       : string;
    k, n, l : integer;
begin
  n:=memo1.CaretPos.y;
  if n<memo1.Lines.Count
    then s:=memo1.Lines[n]
    else s:='';
  if s='' then exit;
  memo1.SelStart:=Pos(s,memo1.Text)-1;
  memo1.SelLength:=Length(s);
  Delete(s,1,pos('|',s)+1);
  l:=length(s);
  zeigeTeile(false);
  StarteRunModus;
  n:=1;
  repeat
    while (n<=l) and (s[n]=' ') do inc(n);
    k:=0;
    while (n<=l) and (s[n]>='0') and (s[n]<='9') do
      begin
        k:=k*10+ord(s[n])-ord('0');
        n:=n+1;
      end;
    if k>0 then
      begin
        gewicht:=gewicht+teile[k].gewicht;
        wert:=wert+teile[k].wert;
        packeAufWaage(k);
        CheckPause;
      end;
  until n>length(s);
 VerlasseRunModus;
end;

procedure TRucksackForm.PanelBeendenCommandResize(Sender: TObject);
begin
   BitBtnBeenden.Left:=PanelBeendenCommand.ClientWidth-BitBtnBeenden.Width-40;
   panelEdit.Width:=BitBtnBeenden.Left-40;
end;

procedure TRucksackForm.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.canvas.brush.color:=clBtnFace;
  PaintBox1.canvas.pen.color:=clWhite;
  PaintBox1.canvas.rectangle(0,0,paintbox1.width,paintbox1.height);
  ZeigeTeile(true);
end;

procedure TRucksackForm.PackeAufWaage(k:integer);
begin
  with paintbox1.canvas do
    begin
      pen.color:=clWhite;
      brush.color:=clGray;
      rectangle(xTab, k*y1, xTab+teile[k].gewicht,k*y1+y0);
      brush.color:=clRed;
      if wPosX+teile[k].gewicht+2>waage[lage-1].xE-5
        then begin
               waage[lage].xE:=wPosX; waage[lage+1].xA:=waage[lage].xA+5;
               lage:=lage+1; wPosY:=wPosY-y1; wPosX:=waage[lage].xA;
             end;
      rectangle(wPosX, wPosY-y0,wPosX+teile[k].gewicht,wPosY);
      wPosX:=wPosX+teile[k].gewicht+2;
      pen.color:=clBlack;
      brush.color:=clBtnFace;
      TextOut(waageX0+50,waageY0+40,IntToStr(gewicht)+'      ');
      TextOut(waageX1-50,waageY0+40,IntToStr(wert)+'     ');
    end;
  CheckPause;
end;

procedure TRucksackForm.SpeedButtonInputPartsClick(Sender: TObject);
begin
  if SpeedButtonInputParts.down
    then begin
           if paintbox1.visible then
             begin
               paintbox1.visible:=false;
               stringGrid2.visible:=true;
               StringGrid2Anpassen(SpinEdit1.Value);
             end;
           edit1.text:=RSArr[rsTeileEingeben];
           buttonStart.Enabled:=false;
         end
    else begin
           liesTeile;
           if not paintbox1.visible then
            begin
              stringGrid2.visible:=false;
              paintbox1.visible:=true;
            end;
            edit1.text:='';
            buttonStart.Enabled:=true;
          end;
end;

procedure TRucksackForm.SpinEdit1Change(Sender: TObject);
begin
 if spinedit1.text<>'' then
   if spinedit1.value<=maxTeile then
     begin
       anzahlTeile:=spinedit1.value;
       StringGrid2Anpassen(anzahlTeile);
     end;
 paintBox1.repaint;
end;

procedure TRucksackForm.SpinEdit2Change(Sender: TObject);
begin
  if spinedit2.text<>'' then
    gesamtGewicht:=spinEdit2.Value;
end;

procedure TRucksackForm.SortTeile;
var k,j : integer;
    neu : einzelTeil;
begin
  for k:=1 to anzahlTeile do
    begin
      neu:=unsortedTeile[k];
      j:=k;
      while (j>1) and (neu.gewicht<teile[j-1].gewicht) do
          begin
            teile[j]:=teile[j-1];
            j:=j-1;
          end;
        teile[j]:=neu;
    end;
end;

procedure TRucksackForm.StarteRunModus;
begin
  wert:=0;
  gewicht:=0;
  PaintBox1.refresh;
  BitBtnBeenden.Enabled:=false;
  PanelStart.Hide;
  FramePausenStrg1.NormalStart;
end;

procedure TRucksackForm.VerlasseRunModus;
begin
  BitBtnBeenden.Enabled:=true;
  FramePausenStrg1.Hide;
  PanelStart.visible:=true;
end;

procedure TRucksackForm.StringGrid2Anpassen(nr: integer);
var k, n :integer;
begin
  k:=stringGrid2.RowCount;
  stringGrid2.RowCount:=nr+1;
  for n:=k to nr do stringGrid2.Cells[0,n]:=IntToStr(nr);
end;

procedure TRucksackForm.ZeigeLoesung;
var k : integer;
begin
  paintBox1.repaint;
  zeigeTeile(false);
  gewicht:=0; wert:=0;
  for k:=1 to anzahlTeile do
    if k in bestSack then
      begin
        gewicht:=gewicht+teile[k].gewicht;
        wert:=wert+teile[k].wert;
        packeAufWaage(k);
      end;
end;

procedure TRucksackForm.ZeigeTeile(mitWaage:boolean);
var k,n,p : integer;
    r     : TRect;
begin
  p:=pause;
  pause:=0;
  y1:=(paintbox1.height DIV (maxTeile+1));
  y0:=y1-2;
  wPosY:=waageY0-2; wPosX:=waage[1].xA; lage:=1;
  n:=50;
  for k:=1 to AnzahlTeile do if teile[k].wert>n then n:=teile[k].wert;
  xTab:=n+8;
  r.right:=xTab-3;
  with paintBox1.canvas do
    begin
      for k:=1 to anzahlTeile do
        begin
          if k in rucksack
            then begin
                   if mitWaage then PackeAufWaage(k);
                   brush.color:=clGray;
                 end
            else brush.color:=clRed;
          pen.color:=clWhite;
          rectangle(xTab, k*y1,xTab+teile[k].gewicht,k*y1+y0);
          pen.color:=clBlack;
          brush.color:=clBtnFace;
          textOut(xTab+teile[k].gewicht+5,k*y1,IntToStr(teile[k].gewicht) );
          brush.color:=clyellow;
          r.left:= r.right-teile[k].wert;
          r.top:=k*y1+1;
          r.bottom:=r.top+y0-1;
          rectangle(r.left-1, r.top-1, r.right+1, r.bottom+1);

          textRect(r,r.left+1,r.top+2,IntToStr(teile[k].wert));
        end;
     pen.color:=clBlack;
     brush.color:=clBlack;
     rectangle(waage[0].xA, waageY0, waage[0].xE,waageY0+10);
     brush.color:=clBtnFace;
     TextOut(waageX0+30,waageY0+20,RSArr[rsGewicht1]);
     TextOut(waageX0+50,waageY0+40,IntToStr(gewicht));
     TextOut(waageX1-70,waageY0+20,RSArr[rsWert]);
     TextOut(waageX1-50,waageY0+40,IntToStr(wert));
   end;
  pause:=p;
end;


end.
