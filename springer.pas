unit springer;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   das Springer-Problem
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Grids, Buttons,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

const brett_Laenge   = 16;
      max_anz_Felder = brett_Laenge*brett_Laenge;
      max_Zug        = 8;  { von einem Feld sind max. 8 Springerzüge möglich }
      orgBrettWeite  = 400;

type  index        = 1..brett_Laenge;
      opt_Index    = 0..max_Zug-1;
      offset       = array[0..max_Zug-1] of -2..2;
      Stri10       = STRING[10];
      test         = array[index,opt_Index] of BYTE;

const x_offset : offset = (2,1,-1,-2,-2,-1, 1, 2);  { rel. Bewegung in x  }
      y_offset : offset = (1,2, 2, 1,-1,-2,-2,-1);  { bzw. in y Richtung  }

type

  { TSpringerForm }

  TSpringerForm = class(TForm)
    ButtonStart: TBitBtn;
    FramePausenStrg1: TFramePausenStrg;
    LabelShowSolution: TLabel;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    PanelBrett: TPanel;
    PaintBox1: TPaintBox;
    PanelEdit: TPanel;
    edit1: TEdit;
    PanelOptionen: TPanel;
    StringGrid1: TStringGrid;
    PanelStart: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    StaticText1: TStaticText;
    SpinEditN: TSpinEdit;
    CheckBoxAlleLsgSuchen: TCheckBox;
    SpinEditX: TSpinEdit;
    SpinEditY: TSpinEdit;
    CheckBoxZwischenSchritt: TCheckBox;
    Splitter1: TSplitter;
    procedure ButtonStartClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure PanelBrettResize(Sender: TObject);
    procedure SpinEditNChange(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
  private
    a, max, anz_Felder : integer;
    lsg_Nr, cWidth     : integer;
    z, sp, nr          : BYTE;
    feld, lastF        : array[0..brett_Laenge,index] of BYTE;
    tx, ty             : test;
    erfolg, einzel     : boolean;
    zugNr              : LongInt;
    { Private-Deklarationen }
    procedure Ausgabe(ok:BOOLEAN);
    procedure Belege(x,y:integer;status:Word);
    procedure CalculateBrettSize;
    procedure InitFeld;
    procedure Naechster_Zug(x,y:integer);            { *Haupt* }
    procedure StarteRunModus;
    procedure VerlasseRunModus;
    procedure Zeige_Loesung(aLsgNr:Integer);
  public
    { Public-Deklarationen }
  end;

var
  SpringerForm: TSpringerForm;

implementation

{$R *.lfm}

procedure TSpringerForm.Ausgabe(ok:BOOLEAN);
var x,y : integer;
begin
  if ok
    then begin
           lsg_Nr:=lsg_Nr+1;
           if stringGrid1.colCount<lsg_Nr+1 then stringGrid1.colCount:=lsg_Nr+1;
           x:=(stringGrid1.width-10);
           if lsg_Nr>0 then x:=x DIV (lsg_Nr+1);
           if x>cWidth
             then stringGrid1.defaultColWidth:=x
             else stringGrid1.defaultColWidth:=cWidth;
           stringGrid1.Cells[lsg_Nr,0]:=IntToStr(lsg_Nr+1)+RSArr[rsLsg];
           for y:=1 TO max do
             for x:=1 TO max do
               stringGrid1.cells[lsg_Nr,feld[x,y]]:=IntToStr(x)+'/'+IntToStr(y);
           stringGrid1.repaint;
           if not zeigen then
             for y:=1 TO max do
               for x:=1 TO max do Belege(x,y,feld[x,y]);
           LabelShowSolution.Caption:=IntToStr(lsg_Nr+1)+RSArr[rsLsg];
         end
    else if lsg_Nr=-1
           then edit1.text:=RSArr[rsKeineLoesung]
           else if lsg_Nr=0
                  then edit1.text:=RSArr[rsEineLoesungGefunden]
                  else edit1.text:=IntToStr(lsg_Nr+1)+RSArr[rsLoesungenGefunden];
end;

procedure TSpringerForm.Belege(x,y:integer;status:Word);
var col   : TColor;
    mitte, offx, offy : integer;
    s     : string;
begin
  if status>0
    then begin
           mitte:=-10 + (a DIV 2);
           with PaintBox1.Canvas do
            begin
              Brush.Color:=clRed;
              Ellipse(10+(x-1)*a+2,10+(y-1)*a+2,10+x*a-2,10+y*a-2);
              s := IntToStr(status);
              offx:= GetTextWidth(s) div 2;
              offy:= GetTextHeight(s) div 2;
              TextOut(x*a-mitte-offx,y*a-mitte-offy,s);
            end;
         end
    else begin
           if odd(x+y)
             then col:=clWhite
             else col:=clBlack;
           paintBox1.Canvas.Brush.Color:=col;
           PaintBox1.Canvas.Rectangle(10+(x-1)*a+1,10+(y-1)*a+1, 10+x*a-1,10+y*a-1);
         end;
end;

procedure TSpringerForm.ButtonStartClick(Sender: TObject);
var sp1,k,j : integer;
begin
  LabelShowSolution.Caption:='';
  Edit1.Text:='';
  zugNr:=0;
  cWidth:=stringGrid1.canvas.textWidth(' '+IntToStr(max)+'/'+IntToStr(max)+' ');
  stringGrid1.defaultColWidth:=stringGrid1.width-10;
  stringGrid1.colCount:=1;
  stringGrid1.Cols[0].Clear;
  stringGrid1.rowCount:=anz_Felder+1;
  for sp1:=1 TO brett_Laenge do
    for k:=0 TO max_Zug-1 do
      begin
        j:=sp1+x_offset[k];
        if (j>0) and (j<=max) then tx[sp1,k]:=j else tx[sp1,k]:=0
      end;
  for sp1:=1 TO brett_Laenge do
    for k:=0 TO max_Zug-1 do
      begin
        j:=sp1+y_offset[k];
        if (j>0) and (j<=max) then ty[sp1,k]:=j else ty[sp1,k]:=0
      end;
  einzel:=not CheckBoxAlleLsgSuchen.checked;
  sp:=SpinEditX.value;
  z:=SpinEditY.value;
  FillChar(feld,SizeOf(feld),#0);
  for j:=0 TO brett_Laenge do
    begin
      if j>0 then feld[0,j]:=100;
      for k:=max+1 to brett_laenge do feld[j,k]:=100;
    end;
  feld[sp,z]:=1;
  nr:=2; erfolg:=FALSE;
  application.ProcessMessages;
  lsg_Nr:=-1;
  StarteRunModus;
  Naechster_Zug(sp,z);
  if (lsg_Nr>=0) or erfolg then feld:=lastF;
  if einzel
    then begin
           lsg_Nr:=-1;
           Ausgabe(erfolg);
           lsg_Nr:=0;
         end
    else begin
           Ausgabe(lsg_Nr>=0);
           Ausgabe(false);
         end;
  VerlasseRunModus;
end;

procedure TSpringerForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
   FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked);
end;

procedure TSpringerForm.CalculateBrettSize;
var k, s, h, fh : integer;
begin
  max:=SpinEditN.value;
  anz_felder:=max*max;
  s := panelBrett.Width-30;
  h := LabelShowSolution.Height;
  k:=panelEdit.top-10-h*2;
  if k<s then s:=k;
  a:=s DIV max;
  k:=a*max;
  fh := 49; s := a div 3;
  repeat
   dec(fh);
   paintbox1.font.height:=fh;
  until (PaintBox1.Canvas.GetTextHeight('12') < s) or (fh=2);
  PaintBox1.SetBounds(10, 10, 10+k, 10+k);
  LabelShowSolution.Top:=PaintBox1.Top + PaintBox1.Height + h
end;

procedure TSpringerForm.FormActivate(Sender: TObject);
begin
  CalculateBrettSize;
  InitFeld;
  PaintBox1.refresh;
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  TranslationsFor_springer;
end;

procedure TSpringerForm.FormCreate(Sender: TObject);
var fs : integer;
begin
  LabelShowSolution.Caption:='';
  SkaliereForm(self);
  fs := stringGrid1.Font.Size;
  repeat
    fs := fs-1;
    stringGrid1.Font.Size := fs;
    edit1.Font.size := fs;
  until stringGrid1.Font.size<font.size;
end;

procedure TSpringerForm.InitFeld;
var j, k : integer;
begin
  for j:=1 to max do
    for k:=1 to max do feld[j,k] := 0;
  j:=SpinEditX.value;
  k:=SpinEditY.value;
  feld[j,k] := 1;
  zugNr:=0;
end;

  { ****************** Hauptprocedure ************** }
procedure TSpringerForm.Naechster_Zug(x,y:integer);
var test_Nr    : BYTE;
    neuX,neuY  : integer;
begin
  test_Nr:=0;
  While (test_nr<=max_Zug-1) and not abbruch do
    begin
      neuY:=ty[y,test_Nr];
      if (0<neuY) then
        begin
          neuX:=tx[x,test_Nr];
          if (feld[neuX,neuY]=0) then
            begin
              feld[neuX,neuY]:=nr;
              if zeigen then belege(neuX,neuY,nr);
              zugNr:=zugNr+1;
              if zugNr and 256 = 256 then edit1.text:=IntToStr(zugNr);
              if nr=anz_Felder
                then begin
                       lastF:=feld;
                       if einzel
                         then begin erfolg:=true; lsg_Nr:=0; exit end
                         else begin
                                Ausgabe(true);
                                feld[neuX,neuY]:=0;
                                if zeigen then belege(neuX,neuY,0);
                              end;
                     end
                else begin
                       if zeigen
                         then CheckPause
                         else Application.ProcessMessages;
                       Inc(nr);
                       Naechster_Zug(neuX,neuY);
                       if erfolg then EXIT;
                       Dec(nr);
                       feld[neuX,neuY]:=0;
                       if zeigen then
                         begin
                           belege(neuX,neuY,0);
                           CheckPause;
                         end
                     end
            end
        end;
      Inc(test_Nr);
    end
end;

procedure TSpringerForm.PanelBeendenCommandResize(Sender: TObject);
begin
  BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;

procedure TSpringerForm.PanelBrettResize(Sender: TObject);
begin
  if panelBrett.Width<50 then panelBrett.Width := 50;
  edit1.Width := panelBrett.Width-20;
  CalculateBrettSize;
  PaintBox1.refresh;
end;

procedure TSpringerForm.PaintBox1Paint(Sender: TObject);
var j, k : integer;
begin
  paintBox1.Canvas.Brush.Color:=clBtnFace;
  PaintBox1.Canvas.Rectangle(10,10, PaintBox1.Width+10,PaintBox1.Height+10);
  for j:=1 to max do
    for k:=1 to max do
      begin
        belege(j,k,0);
        if feld[j,k]<>0 then belege(j,k,feld[j,k]);
      end;
end;

procedure TSpringerForm.SpinEditNChange(Sender: TObject);
var groesse : integer;
begin
  if (SpinEditN.text='') then exit;

  groesse:=SpinEditN.value;
  if (groesse>=3)
   then if (SpinEditN.value<=Brett_Laenge)
        then begin
               if SpinEditX.maxValue<>groesse then SpinEditX.maxValue:=groesse;
               if SpinEditX.Value>groesse then SpinEditX.Value:=groesse;
               if SpinEditY.maxValue<>groesse then SpinEditY.maxValue:=groesse;
               if SpinEditY.Value>groesse then SpinEditY.Value:=groesse;
               CalculateBrettSize;
               InitFeld;
               PaintBox1.refresh;
               edit1.Text:='';
             end
        else SpinEditN.value:=Brett_Laenge
   else SpinEditN.value:=3
end;

procedure TSpringerForm.StarteRunModus;
begin
  BitBtnBeenden.Enabled:=false;
  PanelStart.Hide;
  FramePausenStrg1.NormalStart;
  PaintBox1.refresh;
end;

procedure TSpringerForm.StringGrid1Click(Sender: TObject);
var aktLsg_Nr : integer;
begin
  if lsg_Nr>=0 then
    begin
      aktLsg_Nr := StringGrid1.col;
      LabelShowSolution.Caption:=RSArr[rsLoesungNr]+IntToStr(aktLsg_Nr+1);
      FramePausenStrg1.Visible:=true;
      FramePausenStrg1.BitBtnContinueShowClick(nil);
      Zeige_Loesung(aktLsg_Nr);
      FramePausenStrg1.Visible:=false;
    end;
end;

procedure TSpringerForm.VerlasseRunModus;
begin
  BitBtnBeenden.Enabled:=true;
  FramePausenStrg1.Hide;
  PanelStart.show;
  PanelStart.repaint;
end;

procedure TSpringerForm.Zeige_Loesung(aLsgNr:Integer);
var k, x, y : integer;
    s, sx   : string[20];
begin
  InitFeld;
  StarteRunModus;
  pause:=512;
  FramePausenStrg1.BitBtnPauseDoubleClick(self);
  for k:=1 to anz_Felder do
    begin
      s:=stringGrid1.cells[aLsgNr,k];
      sx:=Copy(s,1,system.Pos('/',s)-1);
      system.Delete(s,1,Length(sx)+1);
      x:=StrToInt(sx);
      y:=strToInt(s);
      Belege(x,y,k);
      feld[x,y]:=k;
      CheckPause;
    end;
  VerlasseRunModus
end;

end.
