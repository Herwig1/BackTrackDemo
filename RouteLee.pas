unit RouteLee;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Verbindungsbahnen auf einer Platine; alternativ ein weiteres Verfahren (Lee)
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Grids, Buttons,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

CONST maxAnzahlPunkte        = 50;
      maxAnzahlVerbindungen  = 20;
      maxPX        = 100;
      maxPY        = 50;
      fakX         = 4;
      fakY         = 4;
      ax0          = 1;
      ay0          = 1;
      maxBildX     = maxPX*fakX;
      maxBildY     = maxPY*fakY;
      ordStadt0    : BYTE     = Ord('A')-1;

TYPE punkt         = RECORD
                       x,y : integer
                     end;
     pktVerbindung = RECORD
                       a,b : WORD
                     end;
     pktListe      = array[1..maxAnzahlPunkte] of punkt;
     vbListe       = array[1..maxAnzahlVerbindungen] of pktVerbindung;
     loesungsArr   = Array[1..maxAnzahlVerbindungen] of integer;

CONST tempFarbe   : Array[0..6] of TColor = (clWhite,
                                             clblue, claqua, clgreen, clFuchsia,
                                             clBlack, clred);

type

  { TRouterForm }

  TRouterForm = class(TForm)
    ButtonStart: TBitBtn;
    FramePausenStrg1: TFramePausenStrg;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    PanelBrett: TPanel;
    PanelEdit: TPanel;
    edit1: TEdit;
    PaintBox1: TPaintBox;
    PanelRechts: TPanel;
    StringGrid1: TStringGrid;
    PanelStart: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    CheckBoxAlleLsg: TCheckBox;
    CheckBoxZwischenSchritt: TCheckBox;
    ButtonRandomExample: TButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    CheckBoxUseLee: TCheckBox;
    SpeedButtonInput: TSpeedButton;
    StringGrid2: TStringGrid;
    procedure FormActivate(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonRandomExampleClick(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure SpinEdit1Exit(Sender: TObject);
    procedure SpinEdit2Exit(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure CheckBoxUseLeeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButtonInputClick(Sender: TObject);
    procedure StringGrid2Click(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
  private
    cWidth,lsgNr,saveNr : integer;
    erfolg, neu, lee,
    einzel, makeNeu,
    punktEingabe        : BOOLEAN;
    pkt                 : pktListe;
    vb                  : vbListe;
    loesung             : loesungsArr;
    maxPunkte, maxVerbind, testNr : integer;
    route    : array[1..maxAnzahlVerbindungen,1..(maxPX+2)*(maxPY+2)] of byte;
    besetzt  : array[0..maxPX+1,0..maxPY+1] of integer;
    xmin,xmax,ymin,ymax : WORD;
    anzahlPunkte,anzahlVb:integer;
    m   : array[1..maxAnzahlPunkte] of BYTE;
    { Private-Deklarationen }
    procedure AusgabeLsg(nr:integer);
    procedure CheckHalt;
    procedure InitFeld;
    procedure LoescheMarkierungen;
    procedure MakeListeAutomatisch(var p:pktListe;var v : vbListe);
    procedure MakeRoute(a,b:punkt;nr,step:integer;richtung:BYTE; var aErfolg : boolean);
    procedure MakeRouteLee(nr,routeNr:integer;var aErfolg : boolean);
    procedure Markieren(a,b:punkt;out nr:integer);
    procedure MarkPunkt(a:punkt;farbe:TColor);
    procedure MarkStartZiel(a,b:punkt;zeig:boolean);
    procedure MarkTempPunkt(x,y:Integer;farbe:TColor);
    procedure MerkeLoesung;
    procedure NeueGrenzen(var neuXMin,neuXMax,neuYMin,neuYMax:WORD;p:punkt;groesser:boolean);
    procedure NeueVerteilung;
    procedure SortListe(p : pktListe;var v : vbListe);
    procedure StarteMakeRoute(startNr:integer;neueLoesung:Boolean);
    procedure VerfolgeWegZurueck(a,b:punkt;i,nr:integer);
    procedure ZeichneWegStueck(x0,y0,x,y: integer;farbe:TColor);
    procedure ZeigePunkte(aNeu:boolean);
    procedure ZeigeVerbindungen;
  public
    { Public-Deklarationen }
  end;

var
  RouterForm: TRouterForm;

implementation

 {$R *.lfm}

procedure TRouterForm.AusgabeLsg(nr:integer);
var k,j,l, n,no : integer;
    oldZ,oldP   : Boolean;
begin
  InitFeld;
  oldZ:=zeigen; zeigen:=true;
  oldP:=keinePause; keinePause:=false;
  PanelStart.Hide;
  FramePausenStrg1.show;
  FramePausenStrg1.Repaint;
  if lee
    then for n:=1 to maxVerbind do
           begin
             Application.ProcessMessages;
             l:=StrToInt(stringGrid1.cells[nr,n]);
             k:=vb[l].a; j:=vb[l].b;
             Markieren(pkt[k],pkt[j],no);
             MarkPunkt(pkt[k],tempFarbe[6]);
             MarkPunkt(pkt[j],tempFarbe[6]);
             VerfolgeWegZurueck(pkt[k],pkt[j],n,no)
           end
   else begin
          testNr:=nr;
          l:=StrToInt(stringGrid1.cells[nr,1]);
          StarteMakeRoute(l, false);
        end;
  zeigen:=oldZ;
  keinePause:=oldP;

  FramePausenStrg1.Hide;
  PanelStart.show;
  PanelStart.repaint;
end;

procedure TRouterForm.ButtonStartClick(Sender: TObject);
begin
  cWidth:=stringGrid1.canvas.textWidth(' '+IntToStr(maxPX)+'/'+IntToStr(maxPY)+' ');
  stringGrid1.defaultColWidth:=stringGrid1.width-10;
  stringGrid1.colCount:=1;
  stringGrid1.Cols[0].Clear;
  if makeNeu then NeueVerteilung
             else InitFeld;
  makeNeu:=false;
  stringGrid1.rowCount:=maxVerbind+1;
  lsgNr:=-1;
  einzel:=not CheckBoxAlleLsg.checked;
  lee:=CheckBoxUseLee.checked;
  BitBtnBeenden.Enabled:=false;
  PanelStart.Hide;
  FramePausenStrg1.NormalStart;

  if lee then begin
                FramePausenStrg1.SetModusPause(true);
                MakeRouteLee(1,1,erfolg);
                FramePausenStrg1.SetModusPause(false);
              end
         else StarteMakeRoute(1,true);
  if lsgNr=-1
    then edit1.text:=RSArr[rsKeineLoesung]
    else edit1.text:=IntToStr(lsgNr+1)+RSArr[rsLoesungenGefunden1];

  FramePausenStrg1.Hide;
  PanelStart.show;
  PanelStart.repaint;
  BitBtnBeenden.Enabled:=true;
end;

procedure TRouterForm.ButtonRandomExampleClick(Sender: TObject);
begin
  stringgrid1.Clear;
  stringgrid1.ColCount:=2;
  stringgrid1.Cols[1].Clear;
  NeueVerteilung;
  ZeigeVerbindungen;
end;

procedure TRouterForm.CheckBoxUseLeeClick(Sender: TObject);
begin
  lee:=CheckBoxUseLee.checked;
end;


procedure TRouterForm.CheckHalt;
begin
 Application.ProcessMessages;
 if not showSteps then
   repeat
      Application.ProcessMessages;
   until showSteps or abbruch;
end;


procedure TRouterForm.FormActivate(Sender: TObject);
begin
  NeueVerteilung;
  stringGrid2.Visible:=false;
  ZeigeVerbindungen;
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  TranslationsFor_RouteLee
end;

procedure TRouterForm.FormCreate(Sender: TObject);
var fs : integer;
begin
  makeNeu:=true;
  SkaliereForm(self);
  fs:=stringGrid1.Font.Size;
  repeat
    fs:=fs-1;
    stringGrid1.Font.Size:=fs;
    stringGrid2.Font.Size:=fs;
    edit1.Font.size:=fs;
  until stringGrid1.Font.size<font.size;
end;


procedure TRouterForm.InitFeld;
var i : integer;
begin
  FillChar(besetzt,SizeOf(besetzt),#0);
  FillChar(route,SizeOf(route),#0);
  for i:=0 TO maxPx+1 do begin besetzt[i,0]:=255; besetzt[i,maxPy+1]:=255 end;
  for i:=0 TO maxPy+1 do begin besetzt[0,i]:=255; besetzt[maxPx+1,i]:=255 end;
 { ZeigeVerteilung; }
  ZeigePunkte(true);
  erfolg:=FALSE;  abbruch:=false; saveNr:=0;
  xmin:=1; xmax:=maxPX;
  ymin:=1; ymax:=maxPY;
end;

procedure TRouterForm.LoescheMarkierungen;
var i,k, p : WORD;
    b      : boolean;
begin
  b:=zeigen and not keinePause;
  p:=pause Div 4;
  for i:= xMin TO xMax do
    for k:= yMin TO yMax do
      if (0<besetzt[i,k]) and (besetzt[i,k]<4) then
        begin
          besetzt[i,k]:=0;
          MarkTempPunkt(i,k, tempFarbe[0]);
          if b then delay(p);
        end
end;

procedure TRouterForm.MakeListeAutomatisch(var p:pktListe; var v : vbListe);
type TPktByteArr = array[1..maxAnzahlPunkte] of BYTE;
var i, k : integer;
    ok   : BOOLEAN;
    mArr : TPktByteArr;
    pA,pB,mx,my : Integer;
begin
  maxPunkte:=spinEdit1.value;
  maxVerbind:=spinEdit2.value;
  edit1.text:=RSArr[rsStelleVerbindungenHer];
  Randomize;
  mx:=maxPx;
  while mx*fakX>=panelBrett.width do dec(mx);
  my:=maxPy;
  while my*fakY >=panelEdit.Top do dec(my);
  for i:=1 TO maxPunkte do
    begin
      p[i].x:=Random(mx-3)+2;
      p[i].y:=Random(my-3)+2
    end;
  anzahlPunkte:=maxPunkte;
  mArr:=Default(TPktByteArr);
  i:=1;
  Repeat
    repeat
      pA:=1+Random(maxPunkte);  v[i].a:=pA;
      pB:=1+Random(maxPunkte);  v[i].b:=pB;
      ok:=(pA<>pB) and (mArr[pA]<4) and (mArr[pB]<4);
      k:=1;
      While ok and (k<i-1) do
        begin
          if (v[k].a=pA) and (v[k].b=pB) OR
             (v[k].a=pB) and (v[k].b=pA) then ok:=FALSE;
          k:=k+1;
        end;
      if ok then begin Inc(mArr[v[k].a]); Inc(mArr[pB]) end;
    until ok;
    i:=i+1;
  Until i> maxVerbind;
end;

procedure TRouterForm.MakeRoute(a,b:punkt;nr,step:integer;richtung:BYTE;
                                var aErfolg : BOOLEAN);
var rtg     : array[1..4] of 1..4;
    i,k,j   : integer;
    pi,pk   : punkt;
    disti,distk : integer;
    revers,rmax : BYTE;

  procedure NextPunkt(a:punkt;richtung:BYTE;out p:punkt);
  begin
    p.x:=a.x;p.y:=a.y;
    case richtung of
            1 : if a.x<xMax then p.x:=a.x+1;
            2 : if a.y>yMin then p.y:=a.y-1;
            3 : if a.x>xMin then p.x:=a.x-1;
            4 : if a.y<yMax then p.y:=a.y+1
          end
  end;

  function Distanz(a,b:punkt):integer;
  begin
    Distanz:=Abs(a.x-b.x)+Abs(a.y-b.y)
  end;

  function QuadrDist(a:punkt):WORD;
  begin
    QuadrDist:=Sqr(a.x-b.x)+Sqr(a.y-b.y)
  end;

begin
  for i:=0 TO 3 do
    if richtung+i>=5 then rtg[i+1]:=richtung+i-4 else rtg[i+1]:=richtung+i;
  if step>1 then begin rtg[3]:=rtg[4]; rmax:=3 end
            else begin rmax:=4; MarkPunkt(a,tempFarbe[6]); end;
  for i:=2 TO rmax do
    begin
      NextPunkt(a,rtg[i],pi);
      disti:=Distanz(pi,b);
      k:=i-1; j:=rtg[i];
      repeat
        NextPunkt(a,rtg[k],pk);
        distk:=Distanz(pk,b);
        if (disti<distk)
          then begin rtg[k+1]:=rtg[k]; rtg[k]:=j end
          else k:=1;
        k:=k-1
      until (k=0)
    end;
  i:=0;
  Application.ProcessMessages;
  repeat
    i:=i+1;
    if step>2 then
      begin
          if rtg[i]<3 then revers:=rtg[i]+2
                      else revers:=rtg[i]-2;
          if route[nr,step-2]=revers then
           if i<rmax then Inc(i)
        end;
    NextPunkt(a,rtg[i],pi);
    route[nr,step]:=rtg[i];
    if (pi.x=b.x) and (pi.y=b.y)
      then begin
             if zeigen
               then begin
                      ZeichneWegStueck(a.x,a.y,pi.x,pi.y,tempFarbe[5]);
                      CheckPause;
                    end
               else CheckHalt;
             route[nr,step+1]:=0;
             if neu then begin Inc(saveNr); loesung[saveNr]:=nr; end;
             if nr=maxVerbind
               then begin
                      if neu then begin MerkeLoesung; aErfolg:=einzel end
                             else aErfolg:=true
                    end
               else begin
                      for k:=xMin TO xMax Do
                        for j:=yMin TO yMax do
                          if besetzt[k,j]=254 then besetzt[k,j]:=0;
                      MarkPunkt(b,tempFarbe[6]);
                      if neu
                        then begin
                               k:=vb[nr+1].a; j:=vb[nr+1].b;
                             end
                        else begin
                               k:=StrToInt(stringGrid1.cells[testNr,nr+1]);
                               j:=vb[k].b; k:=vb[k].a;
                             end;
                      {  NeueGrenzen(xmin,xmax,ymin,ymax,pkt[k],TRUE);
                        NeueGrenzen(xmin,xmax,ymin,ymax,pkt[j],FALSE); }
                      MarkStartZiel(pkt[k],pkt[j],true);
                      if pkt[k].x<pkt[j].x
                        then begin
                               NeueGrenzen(xmin,xmax,ymin,ymax,pkt[k],TRUE);
                               NeueGrenzen(xmin,xmax,ymin,ymax,pkt[j],true);
                               MakeRoute(pkt[k],pkt[j],nr+1,1,1,aErfolg)
                             end
                        else begin
                               NeueGrenzen(xmin,xmax,ymin,ymax,pkt[j],TRUE);
                               NeueGrenzen(xmin,xmax,ymin,ymax,pkt[k],true);
                               MakeRoute(pkt[j],pkt[k],nr+1,1,1,aErfolg);
                             end;
                      if not aErfolg then
                        begin
                          ZeichneWegStueck(a.x,a.y,pi.x,pi.y, tempFarbe[0]);
                          for k:=xMin TO xMax Do
                            for j:=yMin TO yMax do
                              if (besetzt[k,j]=nr+1) OR (besetzt[k,j]=254) then besetzt[k,j]:=0;
                        end

                    end;
             Dec(saveNr);
           end
      else if besetzt[pi.x,pi.y]=0
             then begin
                    k:=0; disti:=Distanz(pi,b);
                    if rtg[i]<3 then revers:=rtg[i]+2
                                else revers:=rtg[i]-2;
                    besetzt[pi.x,pi.y]:=nr;
                    if disti>1 then
                      repeat
                        NextPunkt(pi,rtg[i],pi);
                        distK:=Distanz(pi,b);
                        if ((besetzt[pi.x,pi.y]=0) and (distk<disti))
                          then begin
                                 disti:=distK;
                                 k:=k+1; step:=step+1;
                                 besetzt[pi.x,pi.y]:=nr;
                                 route[nr,step]:=rtg[i];
                               end
                          else {if distk>1 then }NextPunkt(pi,revers,pi);
                      until not ( ((besetzt[pi.x,pi.y]=0) and (distk<disti)) ) or (disti<=1);
                    if zeigen
                      then begin
                             ZeichneWegStueck(a.x,a.y,pi.x,pi.y,TempFarbe[5]);
                             CheckPause;
                           end
                      else CheckHalt;
                    MakeRoute(pi,b,nr,step+1,rtg[i],aErfolg);
                    if not aErfolg then
                      begin
                        if distanz(pi,b)<3 then besetzt[pi.x,pi.y]:=0
                                           else besetzt[pi.x,pi.y]:=254;
                        ZeichneWegStueck(a.x,a.y,pi.x,pi.y,TempFarbe[0]);
                        while k>0 do
                          begin
                            step:=step-1;
                            k:=k-1;
                            NextPunkt(pi,revers,pi);
                            if step>1 then besetzt[pi.x,pi.y]:=254;
                          end;
                       end;
                  end
    until (i=rmax) OR aErfolg  or abbruch;
end;

procedure TRouterForm.MakeRouteLee(nr,routeNr:integer;var aErfolg : BOOLEAN);
var i,k,j,no : integer;

  procedure LoeschRoute(i:integer);
  var x,y,k, x0,y0,rtg,rtg0 : WORD;
  begin
    x:=pkt[vb[i].b].x; y:=pkt[vb[i].b].y; k:=1; rtg:=route[i,1];
    x0:=x; y0:=y; rtg0:=rtg;
    while rtg<>0 do
      begin
        if rtg0<>rtg then
          begin
            ZeichneWegStueck(x0,y0,x,y,tempFarbe[0]);
            x0:=x; y0:=y; rtg0:=rtg;
          end;
        case rtg of
             1 : Inc(x);
             2 : Inc(y);
             3 : Dec(y);
             4 : Dec(x);
            end;
        if zeigen then MarkTempPunkt(x,y,tempFarbe[0]);
        besetzt[x,y]:=0; route[i,k]:=0; Inc(k); rtg:=route[i,k];
      end;
    ZeichneWegStueck(x0,y0,x,y,tempFarbe[0]);
    ZeichneWegStueck(x,y,pkt[vb[i].a].x,pkt[vb[i].a].y,tempFarbe[0]);
  end;

begin
  i:=0;
  no:=1;
  repeat
    i:=i+1;
    if route[i,1]=0 then
      begin
        k:=vb[i].a; j:=vb[i].b;
        MarkStartZiel(pkt[k],pkt[j],true);
        Markieren(pkt[k],pkt[j],no);
        MarkStartZiel(pkt[k],pkt[j],false);
        MarkPunkt(pkt[k],tempFarbe[6]);
        MarkPunkt(pkt[j],tempFarbe[6]);
        if no>0 then begin
                       VerfolgeWegZurueck(pkt[k],pkt[j],i,no);
                       loesung[routeNr]:=i;
                       if routeNr=maxVerbind
                         then begin
                                MerkeLoesung;
                                aErfolg:=einzel;
                              end
                         else MakeRouteLee(1,routeNr+1,aErfolg);
                       if not aErfolg then LoeschRoute(i)
                     end
               else LoescheMarkierungen
      end
  until (i>=maxVerbind) OR aErfolg  OR (no=0) OR abbruch
end;

procedure TRouterForm.Markieren(a,b:punkt;out nr:integer);
  TYPE lifo   = ^liste;
       liste  = RECORD
                  x,y : WORD;
                  no  : BYTE;
                  vor,nach : lifo
                end;
  var hilf,speicher,ende:lifo;
      i,x,y        : WORD;
      ok,gefunden : BOOLEAN;
  begin
    x:=a.x; y:=a.y;
    gefunden:=FALSE;
    New(speicher);speicher^.vor:=NIL;speicher^.nach:=NIL;
    speicher^.x:=a.x; speicher^.y:=a.y; speicher^.no:=255;
    ende:=speicher;
    repeat
      a.x:=ende^.x;a.y:=ende^.y;
      if ende^.no>=3 then nr:=1 else nr:=ende^.no+1;
      for i:=1 TO 4 do
        begin
          ok:=FALSE;
          case i of
              1 : if a.x<xMax then begin x:=a.x+1; y:=a.y; ok:=TRUE end;
              2 : if a.y>yMin then begin y:=a.y-1; x:=a.x; ok:=TRUE end;
              3 : if a.x>xMin then begin x:=a.x-1; y:=a.y; ok:=TRUE end;
              4 : if a.y<yMax then begin y:=a.y+1; x:=a.x; ok:=TRUE end
             end;
          if ok and (besetzt[x,y]=0)
            then begin
                   New(hilf); hilf^.vor:=NIL; hilf^.nach:=speicher;
                   hilf^.x:=x; hilf^.y:=y; hilf^.no:=nr;
                   speicher^.vor:=hilf; speicher:=hilf; besetzt[x,y]:=nr;
                   if zeigen
                     then begin MarkTempPunkt(x,y,tempFarbe[nr]); delay(pause Div 2); end
                     else Application.ProcessMessages;
                  CheckHalt
                 end
            else if (x=b.x) and (y=b.y) then gefunden:=TRUE
         end;
       hilf:=ende^.vor;DisPose(ende);ende:=hilf;
    until (ende = NIL) OR gefunden or abbruch;
    while ende<>NIL do begin hilf:=ende^.vor;DisPose(ende);ende:=hilf end;
    if not gefunden then nr:=0
  end;

procedure TRouterForm.MarkPunkt(a:punkt;farbe:TColor);
begin
  besetzt[a.x,a.y]:=255;
  with PaintBox1.canvas do
    begin
      pen.color:=farbe;
      brush.color:=farbe;
      rectangle(a.x*fakX-ax0,a.y*fakY-ay0,a.x*fakX+ax0,a.y*fakY+ay0);
    end;
end;

procedure TRouterForm.MarkStartZiel(a,b:punkt;zeig:boolean);
var farbe:TColor;
begin
  if zeig then farbe:=tempFarbe[6] else farbe:=PaintBox1.Color;
  besetzt[a.x,a.y]:=255;
  besetzt[b.x,b.y]:=255;
  with PaintBox1.canvas do
    begin
      pen.color:=farbe;
      brush.color:=farbe;
      brush.Style:=bsSolid;
      rectangle(a.x*fakX-2,a.y*fakY-2,a.x*fakX+2,a.y*fakY+2);
      rectangle(b.x*fakX-2,b.y*fakY-2,b.x*fakX+2,b.y*fakY+2);
    end;
  if not zeig then
   begin MarkPunkt(a,tempFarbe[6]); MarkPunkt(b,tempFarbe[6]) end;
end;

procedure TRouterForm.MarkTempPunkt(x,y:Integer;farbe:TColor);
begin
  with PaintBox1.canvas do
    begin
      pen.color:=farbe;
      brush.color:=farbe;
      rectangle(x*fakX-ax0,y*fakY-ay0,x*fakX+ax0,y*fakY+ay0);
    end;
end;

procedure TRouterForm.MerkeLoesung;
var h,x : integer;
begin
  lsgNr:=lsgNr+1;
  if stringGrid1.colCount<lsgNr+1 then stringGrid1.colCount:=lsgNr+1;
  x:=(stringGrid1.width-10);
  if lsgNr>0 then x:=x DIV (lsgNr+1);
  if x>cWidth
    then stringGrid1.defaultColWidth:=x
    else stringGrid1.defaultColWidth:=cWidth;
  stringGrid1.Cells[lsgNr,0]:=IntToStr(lsgNr+1)+RSArr[rsLsg];
  for h:=1 to maxVerbind do stringGrid1.cells[lsgNr,h]:=IntToStr(loesung[h]);
end;

procedure TRouterForm.NeueGrenzen(var neuXMin,neuXMax,neuYMin,neuYMax:WORD;p:punkt;groesser:BOOLEAN);
begin
  if p.x<neuXMin
    then neuXMin:=p.x
    else if p.x>neuXMax then neuXMax:=p.x
                        else if groesser then
                               begin
                                 if neuXMin>1 then Dec(neuXMin);
                                 if neuXMax<maxPX then Inc(neuXMax)
                               end;
  if p.y<neuYMin
    then neuYMin:=p.y
    else if p.y>neuYMax then neuYMax:=p.y
                        else if groesser then
                               begin
                                 if neuYMin>1 then Dec(neuYMin);
                                 if neuYMax<maxPY then Inc(neuYMax)
                               end;
end;

procedure TRouterForm.NeueVerteilung;
begin
  MakeListeAutomatisch(pkt,vb);
  SortListe(pkt,vb);
  InitFeld;
end;

procedure TRouterForm.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var k,j,n : integer;
    s     : string;
begin
  if punktEingabe and (anzahlPunkte<StrToInt(spinEdit1.text))
    then begin
           Inc(anzahlPunkte);
           pkt[anzahlPunkte].x:=x div fakX;
           pkt[anzahlPunkte].y:=y div fakY;
           if anzahlPunkte<=26
             then j:=(anzahlPunkte-1)+ord('A')
             else j:=(anzahlPunkte-26)+ord('a');
           s:=char(j);
           PaintBox1.canvas.pen.color:=clRed;
           paintBox1.Canvas.Brush.Color:=clRed;
           paintBox1.Canvas.ellipse(x-2,y-2,x+2,y+2);
           n:=paintBox1.Canvas.TextHeight(s);
           paintBox1.Canvas.Brush.Color:=clWhite;
           paintBox1.Canvas.TextOut(x+3,y-3-n,s);
           punkteingabe:=anzahlPunkte<StrToInt(spinEdit1.text);
           if not punkteingabe then
             begin
               edit1.text:=RSArr[rsVerbindungenMarkieren];
               k:=spinEdit1.value;
               stringGrid2.height:=panelEdit.top-(paintbox1.top+maxBildY+ay0+5);
               stringGrid2.colCount:=k+1;
               stringGrid2.rowCount:=k+1;
               for j:=1 to k do
                 begin
                   if j<=26 then s:=Char(ordStadt0+j)
                            else s:=Char(ordStadt0+(j DIV 26))+Char(ordStadt0+(j Mod 26));
                   stringGrid2.Cells[j,0]:=s;
                   stringGrid2.Cells[0,j]:=s;
                   stringGrid2.Cells[j,j]:='-';
                   for n:=1 to k do if n<>j then stringGrid2.Cells[j,n]:='';
                 end;
               stringGrid2.visible:=true;
               stringGrid2.repaint;
               anzahlVb:=0;
             end;
         end;
end;

procedure TRouterForm.PaintBox1Paint(Sender: TObject);
begin
  ZeigePunkte(makeNeu);
  if makeNeu then ZeigeVerbindungen;
end;

procedure TRouterForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked);
end;


procedure TRouterForm.PanelBeendenCommandResize(Sender: TObject);
begin
  BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;

procedure TRouterForm.SortListe(p : pktListe;var v : vbListe);
var i,k,j,disti,distk : WORD;
    vk                : pktVerbindung;

  function Distanz(a,b:punkt):WORD;
  begin Distanz:=Abs(a.x-b.x)+Abs(a.y-b.y) end;

begin
  edit1.Text:=RSArr[rsSortierePunkte];
  for i:=2 TO maxVerbind do
    begin
      vk:=v[i];
      disti:=Distanz(p[vk.a],p[vk.b]);
      k:=i-1;j:=i;
      repeat
        distK:=Distanz(p[v[k].a],p[v[k].b]);
        if disti<distk then begin v[k+1]:=v[k];j:=j-1 end;
        k:=k-1;
      until (k=0) OR (disti>=distk);
      v[j]:=vk
    end;
end;

procedure TRouterForm.SpeedButtonInputClick(Sender: TObject);
begin
  paintbox1.visible:=true;
  if SpeedButtonInput.down
    then begin
           anzahlPunkte:=0;
           punktEingabe:=true;
           ZeigePunkte(true);
           edit1.text:=RSArr[rsPunkteEingeben];
           makeNeu:=true;
         end;
end;

procedure TRouterForm.SpinEdit1Change(Sender: TObject);
begin
  makeNeu:=True;
end;

procedure TRouterForm.SpinEdit1Exit(Sender: TObject);
begin
  if (spinEdit1.value<maxVerbind Div 3)
    then begin spinEdit1.value:=maxVerbind Div 3  end
    else if (spinEdit1.value>maxAnzahlPunkte)
           then spinEdit1.value:=maxAnzahlPunkte
           else begin maxPunkte:=spinEdit1.value; exit; end;
  spinEdit1.setFocus;
end;

procedure TRouterForm.SpinEdit2Exit(Sender: TObject);
var tempMax : Integer;
begin
  if maxAnzahlVerbindungen <= maxPunkte*3
    then tempMax:=maxAnzahlVerbindungen
    else tempMax:=maxPunkte*3;
  if (spinEdit2.value<1)
     then spinEdit2.value:=1
     else if (spinEdit2.value>tempMax)
            then spinEdit2.value:=tempMax
            else begin maxVerbind:=spinEdit2.value; exit end;
  spinEdit2.SetFocus;
end;

procedure TRouterForm.StarteMakeRoute(startNr:integer;neueLoesung:Boolean);
var k,j : Integer;
begin
  neu:=neueLoesung; erfolg:=false;   saveNr:=0;
  k:=vb[startNr].a; j:=vb[startNr].b;
  MarkStartZiel(pkt[k],pkt[j],true);
  xmin:=pkt[k].x; xmax:=xmin;
  ymin:=pkt[k].y; ymax:=ymin;
  NeueGrenzen(xmin,xmax,ymin,ymax,pkt[j],false);
  FillChar(besetzt,SizeOf(besetzt),#0);
  if pkt[k].x<pkt[j].x
    then MakeRoute(pkt[k],pkt[j],1,1,1,erfolg)
    else MakeRoute(pkt[j],pkt[k],1,1,1,erfolg);
end;

procedure TRouterForm.StringGrid1Click(Sender: TObject);
begin
  if lsgNr>=0 then AusgabeLsg(StringGrid1.col);
end;

procedure TRouterForm.StringGrid2Click(Sender: TObject);
var a,b,i : integer;
    ok    : boolean;
    s1    : string;
begin
  a:=stringGrid2.Row;
  b:=stringGrid2.Col;
  if (anzahlVb=spinEdit2.value) or (a=b) or (a=0) or (b=0) then exit;
  s1:=stringGrid2.Cells[b,a];
  if (s1='') and (m[a]<4) and (m[b]<4)
    then begin
           Inc(anzahlVb);
           vb[anzahlVb].a:=a;
           vb[anzahlVb].b:=b;
           stringGrid2.Cells[b,a]:='X';
           stringGrid2.Cells[a,b]:='X';
           Inc(m[a]); Inc(m[b]);
           paintBox1.canvas.pen.color:=clBlack;
           paintBox1.canvas.moveTo(pkt[a].x*fakX,pkt[a].y*fakY);
           paintBox1.canvas.lineTo(pkt[b].x*fakX,pkt[b].y*fakY);
           if anzahlVB=spinEdit2.value then
             begin
               SpeedButtonInput.down:=false;
               stringGrid2.Visible:=false;
               makeNeu:=false;
               SortListe(pkt,vb);
               edit1.text:='';
             end;
         end
    else if s1='X' then
           begin
             i:=1;
             repeat
               ok:= ((vb[i].a=a) and (vb[i].b=b)) or ((vb[i].a=b) and (vb[i].b=a)) ;
               if not ok then Inc(i);
             until ok or (i=anzahlVb);
             vb[i].a:=0; vb[i].b:=0;
             Dec(m[a]); Dec(m[b]);
             stringGrid2.Cells[b,a]:='';
             stringGrid2.Cells[a,b]:='';
             Dec(anzahlVb);
             paintBox1.canvas.pen.color:=paintBox1.color;
             paintBox1.canvas.moveTo(pkt[a].x*fakX,pkt[a].y*fakY);
             paintBox1.canvas.lineTo(pkt[b].x*fakX,pkt[b].y*fakY);
           end;
end;

procedure TRouterForm.VerfolgeWegZurueck(a,b:punkt;i,nr:integer);
  var x,y, j, n,x0,y0,x1,y1,rtg : WORD;
      ok, first        : BOOLEAN;
  begin
    x:=b.x; y:=b.y; n:=0; first:=true;
    x1:=x; y1:=y; rtg:=1;
    repeat
      x0:=x; y0:=y;
      if nr=1 then nr:=3 else Dec(nr);
      j:=0;  ok:=false;
      repeat
        j:=j+1;
        case j of
             1 : begin ok:=besetzt[x+1,y]=nr; if ok then Inc(x) end;
             2 : begin ok:=besetzt[x,y+1]=nr; if ok then Inc(y) end;
             3 : begin ok:=besetzt[x,y-1]=nr; if ok then Dec(y) end;
             4 : begin ok:=besetzt[x-1,y]=nr; if ok then Dec(x) end;
             end
      until ok OR (j=4);
      if ok then
        begin
          if zeigen then MarkTempPunkt(x,y,tempFarbe[0]);
          if first
            then begin first:=false; rtg:=j end
            else if j<>rtg then
                   begin
                     ZeichneWegStueck(x1,y1,x0,y0,tempFarbe[5]);
                     rtg:=j;
                     x1:=x0; y1:=y0;
                   end;
          Inc(n); route[i,n]:=j;
          besetzt[x,y]:=254;
        end
    until not ok or abbruch;
    if zeigen then MarkTempPunkt(x,y,tempFarbe[0]);
    ZeichneWegStueck(x1,y1,x,y,tempFarbe[5]);
    ZeichneWegStueck(x,y, a.x, a.y,tempFarbe[5]);
    route[i,n+1]:=0;
    LoescheMarkierungen
  end;

procedure TRouterForm.ZeichneWegStueck(x0,y0,x,y: integer;farbe:TColor);
begin
  with PaintBox1.canvas do
    begin
      pen.color:=farbe;
      MoveTo(x0*fakX,y0*fakY);
      LineTo(x*fakX,y*fakY);
    end
end;

procedure TRouterForm.ZeigePunkte(aNeu:boolean);
var i     : integer;
begin
  if aNeu then
    with PaintBox1.canvas do
    begin
      pen.color:=clBlack;
      brush.color:=clWhite;
      Rectangle(0,0,maxBildX+ax0+1,maxBildY+ay0+1);
    end;
  for i:=1 TO anzahlPunkte do MarkPunkt(pkt[i],tempFarbe[6]);
  edit1.text:='';
end;

procedure TRouterForm.ZeigeVerbindungen;
var k : integer;
begin
  paintbox1.Canvas.pen.color:=clsilver;
  for k:=1 to maxVerbind do
    begin
      paintbox1.Canvas.MoveTo(pkt[vb[k].a].x*fakX, pkt[vb[k].a].y*fakY);
      paintbox1.Canvas.LineTo(pkt[vb[k].b].x*fakX, pkt[vb[k].b].y*fakY);
    end;
end;

end.
