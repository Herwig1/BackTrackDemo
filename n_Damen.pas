unit n_Damen;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   das n-Damen-Problem; findet alle Lösungen
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Spin, ExtCtrls, Grids,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

CONST maxFeld =  16;
      maxLsg  = 32000;

TYPE  h_diagonale = 2..2*maxFeld;
      n_diagonale = 1-maxFeld..maxFeld-1;
      position    = 1..maxFeld;
      loesung     = array[position] of position;

type

  { TNDameForm }

  TNDameForm = class(TForm)
    ButtonStart: TBitBtn;
    CheckBoxZwischenSchritt: TCheckBox;
    edit1: TEdit;
    FramePausenStrg1: TFramePausenStrg;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    Panel5: TPanel;
    PanelBrett: TPanel;
    PaintBox1: TPaintBox;
    Panel8: TPanel;
    PanelEdit: TPanel;
    Splitter1: TSplitter;
    StringGrid1: TStringGrid;
    PanelWeiter: TPanel;
    ButtonUndependent: TButton;
    ButtonNewTest: TButton;
    PanelStart: TPanel;
    StaticText1: TStaticText;
    SpinEdit1: TSpinEdit;
    CheckBoxAlleLsgSuchen: TCheckBox;
    procedure ButtonNewTestClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonUndependentClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure PanelBrettResize(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    feldSize : integer;
    haupt_diagonale_frei : array[h_diagonale] of BOOLEAN;
    neben_diagonale_frei : array[n_diagonale] of BOOLEAN;
    zeile_frei           : array[1..maxFeld] of BOOLEAN;
    loes                 : loesung;
    f                    : BYTE;
    all                  : array[1..maxLsg] of loesung;
    lsg_Nr, max          : WORD;
    erfolgreich,einzel   : BOOLEAN;
    aktfeld              : array[1..maxFeld,1..maxFeld] of 0..2;
    Function  Ausgabe(aLoesung:loesung):String;
    procedure Belege(x,y:integer;status:Word);
    procedure CalculateBrettSize;
    procedure InitFeld;
    procedure Setze_Dame(nr:position;var aErfolg:BOOLEAN);    { *Haupt* }
    procedure Teste_Symmetrie(symArt:BYTE);
    procedure ZeichneBrett;
    procedure Zeig_Dame(nr,z:position;status:Word);
    procedure Zeige_Loesung(nr:integer);
    procedure ZwischenAusgabe(aLsg_Nr:integer;aLoesung:loesung);
  public
    { Public-Deklarationen }
  end;

var
  NDameForm: TNDameForm;

implementation

 {$R *.lfm}

const mark_frei       = 0;
      mark_Test       = 1;
      mark_KeinErfolg = 2;

      ofs = 5;

Function TNDameForm.Ausgabe(aLoesung:loesung):String;
var nr : 1..maxFeld;
begin
  result:='';
  for nr:=1 to max do result:=result+'  D'+IntToStr(nr)+'_'+IntToStr(aLoesung[nr]);
end;

procedure TNDameForm.Belege(x,y:integer;status:Word);
var col : TColor;
    mitte,r : integer;
begin
  aktFeld[x,y] := status;
  if status=mark_test
    then begin
           PaintBox1.Canvas.Brush.Color:=clRed;
           paintBox1.Canvas.Ellipse(ofs+(x-1)*feldSize+2,ofs+(y-1)*feldSize+2,ofs+x*feldSize-2,ofs+y*feldSize-2);
         end
    else begin
           if odd(x+y)
             then col:=clWhite
             else col:=clBlack;
           paintBox1.Canvas.Brush.Color:=col;
           PaintBox1.Canvas.Rectangle(ofs+(x-1)*feldSize+1,ofs+(y-1)*feldSize+1, ofs+x*feldSize-1,ofs+y*feldSize-1);
           if status=mark_keinErfolg then
             begin
               PaintBox1.Canvas.Brush.Color:=clred;
               mitte:=(feldSize DIV 2) - ofs;
               r:= 1+(feldSize Div 4);
               paintBox1.Canvas.Ellipse(x*feldSize-mitte-r,y*feldSize-mitte-r,x*feldSize-mitte+r,y*feldSize-mitte+r);
             end
         end;
end;

procedure TNDameForm.ButtonNewTestClick(Sender: TObject);
begin
  abbruch:=true;
  PanelWeiter.Hide;
  PanelStart.show;
  PanelStart.Repaint;
end;

procedure TNDameForm.ButtonStartClick(Sender: TObject);
var z : integer;
begin
  BitBtnBeenden.Enabled:=false;
  PanelStart.hide;
  edit1.text:='';
  stringGrid1.RowCount:=16+1;
  stringGrid1.Cells[0,0]:=RSArr[rsLoesungenZu]+ IntToStr(max)+'x'+IntToStr(max);
  for z:=1 to 16 do stringGrid1.Cells[0,z]:='';
  stringGrid1.repaint;

  InitFeld;
  PaintBox1.Repaint;
  if max<10 then f:=1
            else if max<100 then f:=2;
  lsg_Nr:=0;
  erfolgreich:=FALSE;
  einzel:=not CheckBoxAlleLsgSuchen.checked;
  if zeigen <> checkBoxZwischenSchritt.Checked
     then zeigen:=checkBoxZwischenSchritt.Checked;
  FramePausenStrg1.NormalStart;
  Setze_Dame(1, erfolgreich);
  BitBtnBeenden.Enabled:=true;
  FramePausenStrg1.hide;
  if not einzel and (lsg_Nr>1)
    then begin
           PanelWeiter.Show;
           PanelWeiter.Repaint;
         end
    else begin
           PanelStart.show;
           PanelStart.Repaint;
         end;
  if lsg_Nr=0
    then Edit1.text:=RSArr[rsKeineLoesung]
    else begin
           zeige_Loesung(stringGrid1.row);
           if lsg_Nr>1 then edit1.text:=InttoStr(lsg_Nr)+ RSArr[rsLoesungenErmittelt];
         end;
end;

procedure TNDameForm.ButtonUndependentClick(Sender: TObject);
var nr : integer;
begin
  if not(einzel) then
    begin
      abbruch:=false;
      nr:=0;
      PanelWeiter.Hide;
      PanelStart.Hide;
      FramePausenStrg1.BitBtnContinueShowClick(nil);
      FramePausenStrg1.show;
      FramePausenStrg1.Repaint;
      BitBtnBeenden.Enabled:=false;
      zeigen:=checkBoxZwischenSchritt.Checked;
      while (nr<=6) and (lsg_Nr>1) and Not abbruch do
        begin nr:=nr+1;Teste_Symmetrie(nr) end;
      FramePausenStrg1.Hide;
      if not abbruch
        then edit1.text:=RSArr[rsEsGibt]+IntToStr(lsg_Nr)+RSArr[rsUnabhLoesungen]
        else begin
               edit1.text:=RSArr[rsEsWurden]+IntToStr(lsg_Nr)+RSArr[rsLoesungenErmittelt];
               PanelWeiter.Show;
             end;
      StringGrid1.RowCount:=lsg_Nr+1;
      zeige_Loesung(stringGrid1.row);
      stringGrid1.Visible:=true;
      buttonNewTestClick(sender)
    end;
  PanelStart.Show;
  BitBtnBeenden.Enabled:=true;
end;

procedure TNDameForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked);
end;

procedure TNDameForm.CalculateBrettSize;
var k, s : integer;
begin
  max:=spinEdit1.value;
  s:=panelBrett.Width-30;
  k:=panelEdit.top-30;
  if k<s then s:=k;
  feldSize:=(s-10) DIV max;
  k:=feldSize*max+10;
  PaintBox1.SetBounds(5, 5, 10+k, 10+k);
  PaintBox1.Repaint;
end;

procedure TNDameForm.FormActivate(Sender: TObject);
begin
  CalculateBrettSize;
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  TranslationsFor_n_Damen;
end;

procedure TNDameForm.FormCreate(Sender: TObject);
var fs : integer;
begin
  SkaliereForm(self);
  fs:=stringGrid1.Font.Size;
  repeat
    fs:=fs-1;
    stringGrid1.Font.Size:=fs;
    edit1.Font.size:=fs;
  until stringGrid1.Font.size<font.size;
  CheckBoxAlleLsgSuchen.Caption:=CheckBoxAlleLsgSuchen.Caption + RSArr[rsMax]+IntToStr(maxLsg)+')';
  InitFeld;
end;

procedure TNDameForm.InitFeld;
var sp,z : integer;
begin
  for sp:=1 to max do
    for z:=1 to max do aktFeld[sp,z]:=0;
  for z := 2 to 2*maxFeld do haupt_diagonale_frei[z] := true;
  for z := 1-maxFeld to maxFeld-1 do neben_diagonale_frei[z] := true;
  for z := 1 to maxFeld do zeile_frei[z] := true;
end;

procedure TNDameForm.PaintBox1Paint(Sender: TObject);
var k, j : integer;
begin
  feldSize:=(Paintbox1.Width-10) DIV max;
  paintBox1.Canvas.Brush.Color:=clBtnFace;
  PaintBox1.Canvas.Rectangle(0,0, Paintbox1.Width, PaintBox1.Height);
  for j:=1 to max do
    for k:=1 to max do belege(j,k,aktFeld[j,k]);
end;

procedure TNDameForm.PanelBeendenCommandResize(Sender: TObject);
begin
  BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;

procedure TNDameForm.PanelBrettResize(Sender: TObject);
begin
  if panelBrett.Width<30 then panelBrett.Width := 30;
  edit1.Width := panelEdit.Width-20;
  CalculateBrettSize;
  PaintBox1.refresh;
end;


{ ****************** Hauptprocedure ************** }
procedure TNDameForm.Setze_Dame(nr:position;var aErfolg:BOOLEAN);
var z, p : 0..maxFeld;
begin
  z:=0;
  repeat
    Inc(z);
    Application.ProcessMessages;
    if not showSteps then
        repeat
          Application.ProcessMessages;
        until abbruch or showSteps;
    if haupt_diagonale_frei[nr+z] and neben_diagonale_frei[nr-z]
       and zeile_frei[z] then
      begin
        Zeig_Dame(nr,z,mark_test);
        loes[nr]:=z;
        if nr<max
          then Setze_Dame(nr+1,aErfolg)
          else begin
                 Inc(lsg_Nr); all[lsg_Nr]:=loes;
                 aErfolg:=einzel or (lsg_Nr=maxLsg);
                 ZwischenAusgabe(lsg_Nr,loes);
               end;
        if abbruch then exit;
        if not aErfolg then Zeig_Dame(nr,z,mark_frei);
      end;
    if einzel and not aErfolg then
     begin
      if (z<max)
        then begin Belege(nr,z,mark_keinErfolg) end
        else for p:=1 to max do Belege(nr,p,mark_frei);
      Delay(pause);
     end;
    Application.ProcessMessages;
  until (z=max) OR aErfolg or abbruch;
end;

procedure TNDameForm.SpinEdit1Change(Sender: TObject);
begin
if (spinEdit1.text<>'') then
  begin
    if (spinEdit1.value<1)
      then spinEdit1.value:=1
      else if (spinEdit1.value>maxFeld)
            then spinEdit1.value:=maxFeld;
    if spinEdit1.value<>max then
      begin
        InitFeld;
        CalculateBrettSize;
      end;
    edit1.Caption:='';
    stringGrid1.Clear;
  end;
end;

procedure TNDameForm.StringGrid1Click(Sender: TObject);
begin
  if stringGrid1.row>0 then zeige_Loesung(StringGrid1.row);
end;

procedure TNDameForm.Teste_Symmetrie(symArt:BYTE);
var nr1,nr2 : integer;
    s       : string;

  procedure Loesche(nr:integer);
  var n : integer;
  begin
    if nr<>lsg_Nr then
      for n:=nr to lsg_Nr-1 do
        begin
          all[n]:=all[n+1];
          stringGrid1.Rows[n]:=stringGrid1.Rows[n+1]
        end;
    StringGrid1.Cells[0,lsg_Nr]:='';
    lsg_Nr:=lsg_Nr-1;
  end;

  function Vergleich(symArt:BYTE):BOOLEAN;
  var k      : integer;
      symPkt : BOOLEAN;
  begin
    k:=1; sympkt:=false;
    while (k<=max) do
      begin
        case symArt of
    { Klapp-Symmetrie }
             1 : symPkt:=all[nr1,k]=max+1-all[nr2,k];       {  W-O  }
             2 : symPkt:=max+1-k=all[nr2,max+1-all[nr1,k]]; { NW-SO }
             3 : symPkt:=all[nr1,k]=all[nr2,max+1-k];       {  N-S  }
             4 : symPkt:=k=all[nr2,all[nr1,k]];             { SW-NO }
    { Dreh-Symmetrie }
             5 : symPkt:=k=all[nr2,max+1-all[nr1,k]];       { +90ø  }
             6 : symPkt:=all[nr1,k]=max+1-all[nr2,max+1-k]; { +180ø }
             7 : symPkt:=k=max+1-all[nr2,all[nr1,k]];       { -90ø  }
            end;
        if symPkt
          then k:=k+1
          else begin Vergleich:=FALSE;EXIT end;
      end;
    Vergleich:=TRUE
  end;

begin
  s:=RSArr[rsEntfernSymLoesung];
  case symArt of
    1 : s:=s+RSArr[rsAchseWO];
    2 : s:=s+RSArr[rsAchseNWSO];
    3 : s:=s+RSArr[rsAchseNS];
    4 : s:=s+RSArr[rsAchseSWNO];
    5 : s:=s+RSArr[rsDrehungUm90];
    6 : s:=s+RSArr[rsDrehungUm180];
    7 : s:=s+RSArr[rsDrehungUm270]
    end;
  edit1.text:=s;
  edit1.repaint;
  if zeigen then Delay(1024);
  nr1:=1;
  while nr1<=lsg_Nr do
    begin
     if zeigen then
       begin
         edit1.text:=IntToStr(nr1)+'  '+Ausgabe(all[nr1]);
         edit1.Repaint;
       end;
     nr2:=lsg_Nr;
     stringGrid1.visible:=zeigen;
     while (nr2>nr1) and not abbruch do
       if Vergleich(symArt)
         then begin Loesche(nr2); nr2:=1 end
         else nr2:=nr2-1;
      nr1:=nr1+1;
      Application.ProcessMessages;
      if abbruch then break;
    end;

  if symArt<7 then
    begin
      s:=RSArr[rsNoch]+IntToStr(lsg_Nr)+RSArr[rsLoesung];
      if lsg_Nr>1 then s:=s+RSArr[rsEn];
      edit1.text:=s;
      StringGrid1.RowCount:=lsg_Nr+1;
      if zeigen then Delay(1024)
    end;
end;

procedure TNDameForm.ZeichneBrett;
begin
  CalculateBrettSize;
end;

procedure TNDameForm.Zeig_Dame(nr,z:position;status:Word);
var b : Boolean;
begin
  if zeigen and not keinePause then Belege(nr,z,status);
  b:=status<>mark_test;
  haupt_diagonale_frei[nr+z]:=b;
  neben_diagonale_frei[nr-z]:=b;
  zeile_frei[z]:=b;
end;

procedure TNDameForm.Zeige_Loesung(nr:integer);
var sp, z   : integer;
    aktloes : loesung;
begin
  paintbox1.repaint;
  if nr>0
   then aktloes:=all[nr]
   else aktLoes:=loes;
  for sp:=1 to max do
    for z:=1 to max do
      if aktloes[sp]=z
        then begin
               if odd(sp+z)
                 then paintBox1.Canvas.Brush.Color:=clWhite
                 else paintBox1.Canvas.Brush.Color:=clBlack;
               PaintBox1.Canvas.Rectangle(ofs+(sp-1)*feldSize+1,ofs+(z-1)*feldSize+1, ofs+sp*feldSize-1,ofs+z*feldSize-1);
               Belege(sp,z,mark_test)
             end
        else Belege(sp,z,mark_frei);
end;

procedure TNDameForm.ZwischenAusgabe(aLsg_Nr:integer;aLoesung:loesung);
var s    : String;
    lang : integer;
begin
  s:=Ausgabe(aLoesung);
  if aLsg_Nr>=stringGrid1.RowCount then stringGrid1.rowCount:=stringGrid1.RowCount+10;
  stringGrid1.Cells[0,lsg_Nr]:=s;
  if zeigen then
    begin
      edit1.text:=s;
      if stringGrid1.canvas.textWidth(s)+10>stringGrid1.DefaultColWidth
        then stringGrid1.DefaultColWidth:= stringGrid1.canvas.textWidth(s)+10;
      if aLsg_Nr<=16 then stringGrid1.Repaint;
    end else if aLsg_Nr and 127 = 127 then
      begin
        edit1.text:=s;
        lang:=stringGrid1.canvas.textWidth(s)+10;
        if lang>stringGrid1.ColWidths[0]
          then stringGrid1.ColWidths[0]:= lang;
      end;
end;

end.
