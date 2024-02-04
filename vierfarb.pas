unit vierfarb;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   das (inzwischen gelöste) Vierfarben-Problem
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons, ExtCtrls, Grids,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

const maxAnzahl   = 20;
      maxCol      = 15;
      maxFarbe    = 4;
      maxBeispiel = 5;
      _blank = ' ';
      _dot   = '.';
      colArray    : Array[0..maxCol] of TColor =
                      (clRed,   clBlue,   clYellow,  clGreen,
                       clAqua,  clMaroon, clTeal,    clPurple,
                       clOlive, clGray,   clLime,    clNavy,
                       clWhite, clBlack,  clFuchsia, clSilver);

     rectBeispiel : Array[1..5] of TRect =
           ( (left:1;   top:1;  right:200; bottom:130),
             (left:10;  top:10; right:90;  bottom:150),
             (left:100; top:80; right:210; bottom:100),
             (left:190; top:40; right:250; bottom:160),
             (left:150; top:30; right:220; bottom:60) );

type  rectArray  = Array[1..maxAnzahl] of TRect;
      TByteSet   = Set of Byte;
      TUmrandung = Array[1..100] of TPoint;
      TEinLand   = record
                    r       : TRect;
                    farbe   : TColor;
                    nachbar : TByteSet;
                    anzP    : Integer;
                    grenze  : ^TUmrandung;
                  end;
      TLand      = Array[1..maxAnzahl] of TEinLand;

type

  { TVierFarbForm }

  TVierFarbForm = class(TForm)
    ButtonStart: TBitBtn;
    FramePausenStrg1: TFramePausenStrg;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    PanelBrett: TPanel;
    PanelEdit: TPanel;
    edit1: TEdit;
    PaintBox1: TPaintBox;
    Bevel1: TBevel;
    PanelRechts: TPanel;
    StringGrid1: TStringGrid;
    PanelStartVorbereiten: TPanel;
    SpeedButtonNewInput: TSpeedButton;
    StaticText1: TStaticText;
    SpinEdit1: TSpinEdit;
    CheckBoxZwischenSchritt: TCheckBox;
    ButtonAddCountry: TButton;
    ButtonRemoveCountry: TButton;
    SpeedButton4NewCountries: TSpeedButton;
    PaintBox2: TPaintBox;
    procedure ButtonAddCountryClick(Sender: TObject);
    procedure ButtonRemoveCountryClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox2Paint(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure SpeedButtonNewInputClick(Sender: TObject);
    procedure SpeedButton4NewCountriesClick(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
  private
    anzahl, lsgNr      : integer;
    erfolg, eingabe4,
    eingabe,mausAktive : BOOLEAN;
    land               : TLand;
    { Private-Deklarationen }
    procedure CheckHalt;
    procedure Einfaerben(landNr:integer; Var aErfolg:boolean);   { *Haupt* }
    procedure LoescheLand;
    procedure MakeUmrandungen(aAnzahl:Integer);
    function TempFarbe(nr:integer):TColor;
    procedure ZeigeRechtecke;
  public
    { Public-Deklarationen }
  end;

var
  VierFarbForm: TVierFarbForm;

implementation

 {$R *.lfm}

procedure TVierFarbForm.ButtonAddCountryClick(Sender: TObject);
begin
  if anzahl<maxAnzahl then
    begin
      spinedit1.value:=spinEdit1.value+1;
      edit1.text:=RSArr[rsLaenderMarkieren];
    end;
end;

procedure TVierFarbForm.ButtonRemoveCountryClick(Sender: TObject);
begin
  if anzahl>spinedit1.minValue then
    begin
      land[anzahl].r.bottom:=0;
      spinedit1.value:=spinEdit1.value-1;
    end;
end;

procedure TVierFarbForm.ButtonStartClick(Sender: TObject);
var n : integer;
begin
  PanelStartVorbereiten.Hide;
  FramePausenStrg1.NormalStart;
  for n:=1 to anzahl do land[n].farbe:=TempFarbe(n);
  MakeUmrandungen(anzahl);
  if abbruch then exit;
  stringGrid1.rowcount:=anzahl+1;
  paintBox1.repaint;
  erfolg:=false;
  edit1.Text:=RSArr[rsEinfaerben];
  Einfaerben(1,erfolg);
  if abbruch
    then edit1.text:=RSArr[rsSucheAbgebrochen]
    else if erfolg then edit1.text:=RSArr[rsFaerbungGefunden]
                   else edit1.text:=RSArr[rsKeineFaerbungGefunden];
  FramePausenStrg1.Hide;
  PanelStartVorbereiten.show;
  PanelStartVorbereiten.repaint;
end;

procedure TVierFarbForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked);
end;

procedure TVierFarbForm.CheckHalt;
begin
 Application.ProcessMessages;
 if not showSteps then
   repeat
      Application.ProcessMessages;
   until showSteps or abbruch;
end;

{ ****************** Hauptprocedure ************** }
procedure TVierFarbForm.Einfaerben(landNr:integer; Var aErfolg:boolean);
var k,j   : integer;
    col   : TColor;
    nachBar : TByteSet;
    besetzt : boolean;
    r       : TRect;
begin
  k:=1;
  nachBar:=land[landNr].nachbar;
  repeat
    col:=tempFarbe(k);
    k:=k+1;
    besetzt:=false;
    for j:=1 to landNr-1 do
      if (j in Nachbar) and (land[j].farbe=col) then besetzt:=true;
    if not besetzt then
      begin
        land[landNr].farbe:=col;
        if zeigen
           then with paintbox1.canvas do
                begin
                  brush.color:=col;
                  Polygon( Slice(land[landNr].grenze^,land[landNr].anzP) );
                  CheckPause
                end
           else CheckHalt;
        if landNr=anzahl
          then begin
                 aErfolg:=true;
                 for j:=1 to Anzahl do
                   begin
                     stringGrid1.cells[0,j]:=RSArr[rsLand]+inttoStr(j);
                     r:=stringGrid1.CellRect(lsgNr, j);
                     with stringGrid1.Canvas do
                       begin
                         brush.color:=land[j].farbe;
                         rectangle(r.left+2,r.top+2,r.right-2,r.bottom-2);
                       end;
                   end;
               end
          else if not Abbruch then Einfaerben(landNr+1,aErfolg);
        if not aErfolg then
          begin
            land[landNr].farbe:=clSilver;
            if zeigen then with paintbox1.canvas do
              begin
                brush.color:=clSilver;
                Polygon( Slice(land[landNr].grenze^,land[landNr].anzP) );
                checkPause;
              end
          end;
       end;
   until aErfolg or (k>maxFarbe) or abbruch or (landNr=1);
end;

procedure TVierFarbForm.FormActivate(Sender: TObject);
begin
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  TranslationsFor_vierfarb;
end;

procedure TVierFarbForm.FormCreate(Sender: TObject);
var k : integer;
begin
  SkaliereForm(self);
  FillChar(land,SizeOf(land),#0);
  eingabe:=false; showSteps:=true;
  mausAktive:=false;
  spinEdit1.maxValue:=maxAnzahl;
  anzahl:=maxBeispiel;
  lsgNr:=1;
  for k:=1 to anzahl do
    begin
      land[k].r:=rectBeispiel[k];
      land[k].farbe:=tempFarbe(k);
    end;
  stringGrid1.cells[0,0]:=_blank+RSArr[rsLand];
  stringGrid1.Cells[1,0]:=RSArr[rsFarbe];
  spinEdit1.value:=anzahl;
end;

procedure TVierFarbForm.FormDestroy(Sender: TObject);
begin
  LoescheLand;
end;

procedure TVierFarbForm.LoescheLand;
var k : integer;
begin
  for k:=1 to maxAnzahl do
    if land[k].anzP>0 then
      begin
        FreeMem(land[k].grenze,land[k].anzP*SizeOf(TPoint));
        land[k].grenze:=NIL;
        land[k].nachbar:=[];
        land[k].anzP:=0;
      end;
end;

procedure TVierFarbForm.MakeUmrandungen(aAnzahl:Integer);
const maxEintrag = 6*maxAnzahl;
type tArr    = Array[1..maxEintrag] of integer;
     graf    = Array[0..maxEintrag+1,0..maxEintrag+1] of TByteSet;
var z,sp  : integer;
    r     : TRect;
    z1,s1 : tArr;
    m     : graf;

   procedure ZeichneGraf(const m:graf);
   const fak = 6;
   var x,y,k,yOffset : integer;
   begin
     yOffset:=bevel1.top+bevel1.height-paintbox1.Top;
     for x:=0 to maxEintrag+1 do
       for y:=0 to maxEintrag+1 do
         if m[y,x]<>[] then
           begin
             k:=aAnzahl;
             while (k>1) and not(k in m[y,x]) do dec(k);
             if k>0 then
               begin
                 paintbox1.Canvas.brush.Color:=tempFarbe(k);
                 paintbox1.Canvas.rectangle(fak*x,fak*y+yOffset,fak*(x+1)-1,fak*(y+1)-1+yOffset);
               end;
           end else
           begin
             paintbox1.Canvas.brush.Color:=clSilver;
             paintbox1.Canvas.rectangle(fak*x,fak*y+yOffset,fak*(x+1)-1,fak*(y+1)-1+yOffset);
           end;
    end;

   procedure Verdopple(var m:TArr);
   var n   : integer;
       neu : TArr;
   begin
     neu:=Default(TArr);
     for n:=1 to 2*aAnzahl do
       begin
         neu[3*n-2]:=m[n]-1;
         neu[3*n-1]:=m[n];
         neu[3*n]:=m[n]+1;
       end;
     m:=neu;
   end;

   procedure Testen(x,y:integer);
   var k,j,n : integer;
       s     : string;
     begin
       stringGrid1.colCount:=x+1; stringGrid1.defaultColWidth:=30;
       stringGrid1.rowCount:=y+1;
       for k:=0 to x do stringGrid1.Cols[k].clear;
       for k:=1 to x do stringGrid1.cells[k,0]:=IntToStr(s1[k]);
       for j:=1 to y do stringGrid1.cells[0,j]:=IntToStr(z1[j]);
       for k:=1 to x do
         for j:=1 to y do
           if m[j,k]=[] then stringGrid1.cells[k,j]:=''
            else begin
                   s:='';
                   for n:=1 to aAnzahl do if n in m[j,k] then s:=s+IntToStr(n);
                   stringGrid1.cells[k,j]:=s;
                 end;
       Delay(1000)
     end;

   procedure BestimmeGrenzen(k:integer;out x1,x2,y1,y2:integer);
   var r : TRect;
   begin
     r:=land[k].r;
     x1:=1;  while s1[x1]<r.Left   do x1:=x1+1;
     x2:=x1; while s1[x2]<r.right  do x2:=x2+1;
     y1:=1;  while z1[y1]<r.top    do y1:=y1+1;
     y2:=y1; while z1[y2]<r.bottom do y2:=y2+1;
   end;

   procedure Ordnen;
   var k,j,i, x1,x2,y1,y2 : integer;

       procedure einSort(var b:Tarr;n,neu:integer);
       var j : integer;
       begin
         j:=n+1;
         while (j>1) and (b[j-1]>neu) do
           begin b[j]:=b[j-1]; j:=j-1; end;
         b[j]:=neu
       end;

   begin  {Ordnen}
     z:=0; sp:=0;
     for k:=1 to aAnzahl do
       begin
         r:=land[k].r;
         einSort(s1,sp,r.Left);  sp:=sp+1;
         einSort(s1,sp,r.right); sp:=sp+1;
         einSort(z1,z,r.top);    z:=z+1;
         einsort(z1,z,r.bottom); z:=z+1;
       end;
     fillChar(m,SizeOf(m),#0);
     Verdopple(s1);
     Verdopple(z1);
     for k:=1 to aAnzahl do
       begin
         BestimmeGrenzen(k,x1,x2,y1,y2);
         for j:=x1 to x2 do begin InClude(m[y1,j],k); Include(m[y2,j],k) end;
         for i:=y1 to y2 do begin Include(m[i,x1],k); Include(m[i,x2],k) end;
         for j:=x1+1 to x2-1 do
           for i:=y1+1 to y2-1 do m[i,j]:=[k];
       end;

     for k:=1 to aAnzahl do
       begin
         BestimmeGrenzen(k,x1,x2,y1,y2);
         for j:=x1+1 to x2-1 do
           begin
             if m[y1-1,j]<>[] then land[k].nachbar:=land[k].nachbar+m[y1-1,j];
             if m[y2+1,j]<>[] then land[k].nachbar:=land[k].nachbar+m[y2+1,j];
           end;
          for i:=y1+1 to y2-1 do
            begin
              if m[i,x1-1]<>[] then land[k].nachbar:=land[k].nachbar+m[i,x1-1];
              if m[i,x2+2]<>[] then land[k].nachbar:=land[k].nachbar+m[i,x2+1];
            end;
         exclude(land[k].nachbar,k);

       end;
      for k:=1 to aAnzahl do
       begin
         BestimmeGrenzen(k,x1,x2,y1,y2);
         for j:=x1+1 to x2-1 do
          for i:=y1+1 to y2-1 do
            if m[i,j]=[k] then m[i,j]:=[];
       end;

   end;

   procedure WegeSuchen;
   var m1          : graf;
       h           : TByteSet;
       k,j,i,n,rtg,
       x1,x2,y1,y2,
       versuch     : integer;
       suche,fehler: boolean;
       p,p0        : TPoint;
       aktGrenze   : TUmrandung;

    function NeuRichtung(drehung:integer):integer;
    begin
      result:=rtg+drehung;
      if result>4 then result:=result-4
                  else if result<1 then result:=result+4;
    end;

    procedure RichtungsWechsel(drehung:integer);
    begin
      if (n=1) or (aktGrenze[n-1].x<>p.x) or (aktGrenze[n-1].y<>p.y)
        then begin aktGrenze[n]:=p; n:=n+1; versuch:=0; end
        else versuch:=versuch+1;
      rtg:=NeuRichtung(drehung);
    end;

    procedure GeheWeiter(hAlt:TByteSet);
    type TByteSetArr = Array[1..4] of TByteSet;
    var pNeu : TPoint;
        hNeu : TByteSet;
        h    : TByteSetArr;

      function NurEineRichtung:Boolean;
      var j,r : integer;
      begin
        r:=0;
        for j:=1 to 4 do
          if h[j]<>[] then
            if r=0 then r:=j
                   else r:=5;
        if (0<r) and (r<5)
          then begin rtg:=r; result:=true end
          else begin
                 result:=false;
                 if (r=0) and ((p.x<>p0.x) OR (p.y<>p0.y)) then fehler:=true;
               end;
      end;

      procedure MerkePosAndSet;
      begin
        p:=pNeu;
        hAlt:=hNeu;
        h[1]:=m[p.y,p.x+1];
        h[2]:=m[p.y+1,p.x];
        h[3]:=m[p.y,p.x-1];
        h[4]:=m[p.y-1,p.x];
      end;

      procedure GeheZurNaechstenEcke(rtg:integer;out pNeu : TPoint; out h : TByteSetArr);
      var gefunden : boolean;
      begin
        pNeu:=p; gefunden:=False;
        repeat
          if (p.x<>p0.x) OR (p.y<>p0.y) then m[p.y,p.x]:=[]
                                        else gefunden:=n>3;
          case rtg of
                1 : Inc(pNeu.x);
                2 : Inc(pNeu.y);
                3 : Dec(pNeu.x);
                4 : Dec(pNeu.y);
              end;
          hNeu:=m[pNeu.y,pNeu.x];
          if hAlt=hNeu then p:=pNeu
                       else gefunden:=true;
        until gefunden;
        h[1]:=m[p.y,p.x+1];
        h[2]:=m[p.y+1,p.x];
        h[3]:=m[p.y,p.x-1];
        h[4]:=m[p.y-1,p.x];
     end;

    begin
      hNeu:=[];
      repeat
        GeheZurNaechstenEcke(rtg,pNeu,h);
        If (hAlt<=hNeu) or
           ( (hNeu<>[]) and (hAlt>=hNeu) and
              not( (hNeu=[k])  and ( (hAlt=h[NeuRichtung(3)]) or (hAlt=h[NeuRichtung(1)]) ) ) )
          then begin
                 MerkePosAndSet;
                 If NurEineRichtung
                   then RichtungsWechsel(0)
                   else RichtungsWechsel(1);
               end
          else If hAlt=h[NeuRichtung(3)]
                 then RichtungsWechsel(3)
                 else If hAlt=h[NeuRichtung(1)]
                        then RichtungsWechsel(1)
                        else begin
                               if (h[NeuRichtung(3)]<>[]) and ( (hAlt<=h[NeuRichtung(3)]) or (hAlt>=h[NeuRichtung(3)]) )
                                 then RichtungsWechsel(3)
                                 else if (h[NeuRichtung(1)]<>[]) and ((hAlt<=h[NeuRichtung(1)]) or (hAlt>=h[NeuRichtung(1)]) )
                                        then RichtungsWechsel(1)
                                        else begin
                                               if hAlt*h[rtg]-[k]<>[]
                                                 then begin
                                                        hNeu:=h[rtg]-hAlt+[k];
                                                        p:=pNeu;
                                                        m[p.y,p.x]:=hNeu;
                                                        MerkePosAndSet;
                                                      end;
                                               If NurEineRichtung
                                               then begin
                                                      RichtungsWechsel(0);
                                                      if versuch=1 then
                                                        begin hAlt:=h[rtg]; versuch:=0 end
                                                    end
                                               else if (h[NeuRichtung(1)]<>[])
                                                      then RichtungsWechsel(1)
                                                      else RichtungsWechsel(3)
                                             end;
                             end;
      until (n>3) and (p.x=p0.x) and (p.y=p0.y) or fehler;
    end;

   begin
     m1:=m;
     h:=[]; fehler:=false;
     for k:=1 to aAnzahl do h:=h+[k];
     for k:=aAnzahl downTo 1 do
       begin
         edit1.text:=RSArr[rsSucheUmrandungFuerLand]+IntToStr(k);
         Delay(100);
         FillChar(m,SizeOf(m),#0);
         h:=h-[k];
         BestimmeGrenzen(k,x1,x2,y1,y2);
         for j:=x1 to x2 do
           for i:=y1 to y2 do
             if k in m1[i,j] then m[i,j]:=m1[i,j]-h;

         j:=x1; i:=y1; suche := true;
         while suche and not( [k]=m[i,j]) do
           if j<x2 then j:=j+1
                   else if i<y2 then begin j:=x1;i:=i+1 end
                                else suche:=false;
         if suche then
           begin
             p.x:=j; p.y:=i; p0:=p; n:=1; rtg:=1;
             aktGrenze   := Default(TUmrandung);
            // FillChar(aktGrenze,SizeOf(aktGrenze),#0);
             RichtungsWechsel(0); versuch:=0;

             GeheWeiter(m[i,j]);
             if fehler then
               begin
                 edit1.text:=RSArr[rsKannFuerLand]+IntToStr(k)+RSArr[rsKeineGrenzeErstellen];
                 abbruch:=True;
                 exit;
               end;
            land[k].anzP:=n-1;
            getMem(land[k].grenze,(n-1)*SizeOf(TPoint));
            for j:=1 to n-1 do
              begin
                p.x:=s1[aktGrenze[j].x];
                p.y:=z1[aktGrenze[j].y]+bevel1.top+bevel1.height-paintbox1.Top;
                land[k].grenze^[j]:=p;
              end;
           paintbox1.canvas.brush.color:=land[k].farbe;
           paintbox1.Canvas.Polygon( Slice(land[k].grenze^,land[k].anzP) );
           CheckPause;
           end;
       end;
     m:=m1;
     paintbox1.canvas.brush.color:=clBtnFace;
     paintbox1.canvas.Pen.color:=clBtnFace;
     paintbox1.canvas.Rectangle(0,bevel1.top+bevel1.Height,paintbox1.Width,paintbox1.Height);
     edit1.text:=RSArr[rsSucheNachUmrandungenBeendet];
     for k:=1 to aAnzahl do
      begin
       paintbox1.canvas.brush.color:=land[k].farbe;
       paintbox1.Canvas.Polygon( Slice(land[k].grenze^,land[k].anzP) );
       delay(100);
      end;
   end;

begin
  LoescheLand;
  edit1.text:=RSArr[rsSucheGrenzenUndNachbarn];
  ordnen;
  WegeSuchen;
  if not abbruch then edit1.text:='';
end;

procedure TVierFarbForm.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if eingabe then
   if button=mbLeft
    then begin
           if anzahl<maxAnzahl then
             begin
               paintBox1.canvas.Pen.color:=clBlack;
               paintBox1.canvas.Pen.mode:=pmNotXor;
               paintBox1.canvas.Brush.style:=bsClear;
               anzahl:=anzahl+1;
               with land[anzahl].r do
                 begin
                   left:=x; right:=x;
                   top:=y; bottom:=y;
                   paintBox1.canvas.Rectangle(left,top,right,bottom);
                 end;
               mausaktive:=true;
             end;
        end
   else if button=mbRight then
          begin
            if anzahl>0 then anzahl:=anzahl-1;
            paintBox1.repaint;
          end;
end;

procedure TVierFarbForm.PaintBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if mausAktive then
      with land[anzahl] do
        begin
          paintbox1.canvas.Rectangle(r.left,r.top,r.right,r.bottom);
          r.right:=x;
          r.bottom:=y;
          paintbox1.canvas.Rectangle(r.left,r.top,r.right,r.bottom);
        end;
end;

procedure TVierFarbForm.PaintBox1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var r : TRect;
    w,h : integer;
begin
  If mausAktive then with Paintbox1.canvas do
    begin
      Pen.mode:=pmCopy;
      Brush.style:=bsSolid;
      if eingabe and (not eingabe4 or (anzahl=maxAnzahl)) then
      begin
      land[anzahl].farbe:=tempFarbe(anzahl);
      Brush.color:=land[anzahl].farbe;
      with land[anzahl].r do
        begin
          if (left=right) or (top=bottom)
            then anzahl:=anzahl-1
            else Rectangle(left,top,right,bottom);
        end;
      if anzahl=spinedit1.value then
        begin
          SpeedButtonNewInput.down:=false;
          edit1.text:='';
          eingabe:=false;
          eingabe4:=false;
        end;
      end else
      if  eingabe4 then
      begin
        r:=land[anzahl].r;
        h:=(r.bottom-r.top) div 2;
        w:=(r.right-r.left) div 2;
        if (h<2) or (w<2) then  dec(anzahl)
        else begin
        land[anzahl].r:=Rect(r.left,r.top,r.left+w,r.top+h);
        land[anzahl].farbe:=tempFarbe(anzahl);
        land[anzahl+1].r:=Rect(r.left+w,r.top,r.right,r.top+h);
        land[anzahl+1].farbe:=tempFarbe(anzahl+1);
        land[anzahl+2].r:=Rect(r.left+w,r.top+h,r.right,r.bottom);
        land[anzahl+2].farbe:=tempFarbe(anzahl+2);
        land[anzahl+3].r:=Rect(r.left,r.top+h,r.left+w,r.bottom);
        land[anzahl+3].farbe:=tempFarbe(anzahl+3);
        anzahl:=anzahl+3;
        if spinEdit1.value<anzahl then spinEdit1.Value:=anzahl;
        end;
        eingabe4:=anzahl+4<=spinEdit1.value;
        SpeedButton4NewCountries.down:=eingabe4;
        eingabe:=anzahl<spinedit1.value;
        SpeedButtonNewInput.down:=eingabe;
        if not eingabe then edit1.text:='';
      end;
      mausAktive:=false;
      paintbox1.repaint;
    end;
end;

procedure TVierFarbForm.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.canvas.brush.color:=clBtnFace;
  PaintBox1.canvas.pen.color:=clWhite;
  PaintBox1.canvas.rectangle(0,0,paintbox1.width,paintbox1.height);
  ZeigeRechtecke;
end;

procedure TVierFarbForm.PaintBox2Paint(Sender: TObject);
var h, k : integer;
begin
  with paintbox2.Canvas do
    begin
      brush.color:=clBtnFace;
      pen.color:=clWhite;
      rectangle(0,0,paintbox2.width,paintbox2.height);
      h:=TextHeight('L')+1;
      for k:=1 to anzahl do
        begin
          brush.color:=land[k].farbe;
          textOut(2,paintbox2.height-20-(anzahl+1-k)*h,' '+IntToStr(k)+_dot+_blank+RSArr[rsLand]);
        end;
    end;
end;

procedure TVierFarbForm.PanelBeendenCommandResize(Sender: TObject);
begin
  BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;

procedure TVierFarbForm.SpeedButtonNewInputClick(Sender: TObject);
begin
  if SpeedButtonNewInput.down then
    begin
      anzahl:=0;
      edit1.text:=RSArr[rsLaenderMarkieren];
      eingabe:=true;
      paintBox1.repaint;
    end
    else begin
           edit1.text:='';
           eingabe:=false
         end;

end;

procedure TVierFarbForm.SpeedButton4NewCountriesClick(Sender: TObject);
begin
  if SpeedButton4NewCountries.down then
    begin
      if anzahl+4<=maxAnzahl then
      begin
      edit1.text:=RSArr[rsLaenderMarkieren];
      eingabe4:=true;
      eingabe:=true;
      end;
    end
    else begin
           edit1.text:='';
           eingabe:=false;
           eingabe4:=false
         end;
end;

procedure TVierFarbForm.SpinEdit1Change(Sender: TObject);
var neu : integer;
begin
  if spinedit1.text<>'' then
    begin
      neu:=StrToInt(spinedit1.Text);
      if neu<anzahl
        then begin
               anzahl:=neu;
               paintbox1.repaint
             end
        else if (neu>anzahl) and (neu<=maxAnzahl)
               then begin
                      while (anzahl<neu) and (land[anzahl+1].r.bottom<>0)
                        do anzahl:=anzahl+1;
                      if anzahl<neu then
                        begin
                          SpeedButtonNewInput.down:=true;
                          edit1.text:=RSArr[rsLaenderMarkieren];
                          eingabe:=true;
                        end;
                      paintBox1.repaint;
                    end;
    end;
end;

procedure TVierFarbForm.StringGrid1DrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
begin
  if (aCol<>1) or (aRow=0) or (aRow>anzahl) then
    begin
      with stringGrid1.Canvas do
                       begin
                         if aRow=0 then brush.color:=clSilver
                                   else Brush.Color:=clWhite;
                         rectangle(aRect.left,aRect.top,aRect.right,aRect.bottom);
                         TextRect(aRect,4,4,stringGrid1.Cells[aCol,aRow]);
                       end;
    end
    else begin if erfolg then
             with stringGrid1.Canvas do
                       begin
                         brush.color:=land[aRow].farbe;
                         rectangle(aRect.left+1,aRect.top+1,aRect.right-1,aRect.bottom-1);
                       end;
      end
end;

function TVierFarbForm.TempFarbe(nr:integer):TColor;
begin
  tempFarbe:=ColArray[(nr-1) Mod maxCol];
end;

procedure TVierFarbForm.ZeigeRechtecke;
var k : integer;
begin
  for k:=1 to anzahl do with PaintBox1.canvas do
    begin
     brush.color:=land[k].farbe;
     rectangle(land[k].r.left, land[k].r.top, land[k].r.right, land[k].r.bottom);
    end;
  PaintBox2Paint(nil);
end;

end.
