unit zahlraet;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Zahlenrätsel: ein Buchstabe entspricht einer Ziffer
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls, Buttons,
  BildSchirmAnpassung, pausensteuerung, BackTrackDemo_Sprache;

TYPE  glTyp1 = array[1..3] of STRING[50];
      opTyp  = array[1..6] of CHAR;
      Lgs    = array[1..3,1..3] of integer;
      StrLgs = Array[1..5,1..5] of string[6];


CONST{ op  : opTyp = ('*','-','*','+','-','+'); }
      orgGrid : strLgs
              = (('EDB',   '-', 'CD',   '=', 'EB'),
                 ('*' ,    ' ' , '/',   ' ',  '*'),
                 ('G',     '*',  'K',   '=', 'EA'),
                 ('=====','===','=====','===','====='),
                 ('GFE',   '-', 'EI',   '=', 'GDK') );

type

  { TZahlenraetsel }

  TZahlenraetsel = class(TForm)
    ButtonStart: TBitBtn;
    CheckBoxZwischenSchritt: TCheckBox;
    FramePausenStrg1: TFramePausenStrg;
    PanelBeendenCommand: TPanel;
    BitBtnBeenden: TBitBtn;
    PanelLinks: TPanel;
    PanelEdit: TPanel;
    edit1: TEdit;
    StringGridGleichungen: TStringGrid;
    PanelRechts: TPanel;
    StringGridLoesungen: TStringGrid;
    PanelStart: TPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ButtonInput: TButton;
    PanelLsg: TPanel;
    StringGridTempWerte: TStringGrid;
    z1: TLabel;
    z2: TLabel;
    z3: TLabel;
    z4: TLabel;
    z5: TLabel;
    procedure ButtonStartClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PanelBeendenCommandResize(Sender: TObject);
    procedure StringGridLoesungenClick(Sender: TObject);
  private
     zahl    : Lgs;
     op      : opTyp;
     zLsgStr : Array[1..3,1..3] of string[6];
     frei    : array['0'..'9'] of boolean;
     testeGl : Array[1..10] of integer;

     optimiert       : boolean;
     einzel, geloest : boolean;
     symStr,lsgStr   : String[10];
     last_nr         : BYTE;
     lsg_Nr, cWidth  : integer;
     gZeile          : glTyp1;
    { Private-Deklarationen }
     procedure Ersetze(alt,neu:CHAR);
     function Gleichung(n:integer):boolean;
     procedure MakeLgs;
     procedure MakeZahlGl(z:integer);
     procedure Test(symNr:BYTE;var ok:boolean);
     function testen:Boolean;
     Procedure Zeige_Loesung(nr:integer);
     procedure zeigModusNeu;
  public
    { Public-Deklarationen }
  end;

var
  Zahlenraetsel: TZahlenraetsel;

implementation

  {$R *.lfm}

procedure TZahlenraetsel.ButtonStartClick(Sender: TObject);
var ziffer : char;
    k      : integer;
begin
  BitBtnBeenden.Enabled:=false;
  edit1.text:='';
  for k:=0 to lsg_Nr do StringGridLoesungen.cols[k].Clear;
  einzel:=not checkBox1.checked;
  optimiert:=checkBox2.checked;
  if not testen then exit;
  MakeLgs;
  for ziffer:='0' TO '9' do frei[ziffer]:=TRUE;
  FillCHAR(zahl,SizeOf(zahl),#0);

  geloest:=FALSE;
  StringGridGleichungen.enabled:=false;
  lsg_Nr:=0;
  for k:=1 to Length(symStr) do
    begin
      StringGridTempWerte.Cells[k,0]:=symStr[k];
      StringGridTempWerte.Cells[k,1]:=' ';
    end;
  StringGridTempWerte.Cells[0,1]:=RSArr[rsWert];
  PanelStart.hide;
  FramePausenStrg1.NormalStart;
  StringGridTempWerte.Visible:=true;
  Test(1,geloest);
  StringGridTempWerte.Visible:=false;
  FramePausenStrg1.hide;
  PanelStart.show;
  PanelStart.Repaint;
  if lsg_Nr<=0
    then edit1.text:=RSArr[rsKeineLoesung]
    else begin
           edit1.text:=IntToStr(lsg_Nr)+RSArr[rsLoesungenGefunden1];
           Zeige_Loesung(lsg_Nr);
         end;
  StringGridGleichungen.enabled:=true;
  BitBtnBeenden.Enabled:=true;
end;

procedure TZahlenraetsel.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt( CheckBoxZwischenSchritt.Checked );
end;

procedure TZahlenraetsel.Ersetze(alt,neu:CHAR);
type TGeaendert =  array[1..3] of boolean;
var s   : String;
    p,i,k : Integer;
    geaendert : TGeaendert;
begin
  geaendert := Default(TGeaendert);
  for k:=1 to 3 do
    begin
      s:=gZeile[k];
      repeat
        p:=system.Pos(alt,s);
        if p>0 then begin s[p]:=neu; geaendert[k]:=true end;
      until p=0;
     if geaendert[k] then
       begin
         gZeile[k]:=s;
         for i:=1 to 3 do
           repeat
             p:=system.Pos(alt,zLsgStr[k,i]);
             if p>0 then zLsgStr[k,i][p]:=neu;
           until p=0;
        end;
    end;
  if zeigen then
    if neu in ['0'..'9'] then
      begin
        if geaendert[1] then z1.caption:=gZeile[1];
        if geaendert[2] then z3.caption:=gZeile[2];
        if geaendert[3] then z5.caption:=gZeile[3];
      end;
end;

procedure TZahlenraetsel.FormActivate(Sender: TObject);
var sp,z : integer;
begin
  for sp:=1 to 5 do
    for z:=1 to 5 do StringGridGleichungen.cells[sp-1,z-1]:=orgGrid[z,sp];
  cWidth:=StringGridLoesungen.defaultColWidth;
  MakeLgs;
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  lsg_Nr:=0;
  TranslationsFor_zahlraet
end;

procedure TZahlenraetsel.FormCreate(Sender: TObject);
var fs : integer;
begin
  SkaliereForm(self);
  fs:=StringGridLoesungen.Font.Size;
  repeat
    fs:=fs-1;
    StringGridLoesungen.Font.Size:=fs;
    edit1.Font.size:=fs;
  until StringGridLoesungen.Font.size<font.size;
  StringGridGleichungen.Font.Size:=font.size+2;
  PanelLsg.Font.Size:=font.size+3;
end;

function TZahlenraetsel.Gleichung(n:integer):BOOLEAN;

  function Rechne(z1,z2:integer):integer;
  begin
    rechne:=-1;
    case op[n] of
         '+' : Rechne:=z1+z2;
         '-' : Rechne:=z1-z2;
         '*' : {if z1*z2<10000 then }Rechne:=z1*z2{ else Rechne:=-1};
         '/' : if (z2>0) and (z1 MOD z2 =0) then Rechne:=z1 DIV z2
        end
  end;

begin
  if n<4
    then Gleichung:=Rechne(zahl[n,1],zahl[n,2])=zahl[n,3]
    else Gleichung:=Rechne(zahl[1,n-3],zahl[2,n-3])=zahl[3,n-3]
end;

procedure TZahlenraetsel.MakeLgs;
var sp,z : integer;
    s,s1    : string;
begin
  for z:=1 to 5 do
   if z<>4 then
    begin
      s:='';
      for sp:=1 to 5 do
        begin
          s1:=StringGridGleichungen.cells[sp-1,z-1];
          if odd(sp) then while Length(s1)<6 do s1:=' '+s1
                     else s1:=' '+s1+' ';
          s:=s+s1;
        end;
      case z Of
         1 : begin z1.caption:=s; gZeile[1]:=s end;
         2 : z2.caption:=s;
         3 : begin z3.caption:=s; gZeile[2]:=s end;
         5 : begin z5.caption:=s; gZeile[3]:=s end;
         end;
    end;
end;

procedure TZahlenraetsel.MakeZahlGl(z:integer);
var sp : integer;
begin
  for sp:=1 to 3 do zahl[z,sp]:=StrToInt(zLsgStr[z,sp]);
end;

procedure TZahlenraetsel.PanelBeendenCommandResize(Sender: TObject);
begin
   BitBtnBeenden.Left:=PanelBeendenCommand.Width-BitBtnBeenden.Width-20;
end;

procedure TZahlenraetsel.StringGridLoesungenClick(Sender: TObject);
begin
  if lsg_Nr>0 then
    begin
      if StringGridLoesungen.col>0 then zeige_Loesung(StringGridLoesungen.col);
    end;
end;

{ ****************** Hauptprocedure ************** }
procedure TZahlenraetsel.Test(symNr:BYTE;var ok:BOOLEAN);
var ziffer,alt: CHAR;

    function TesteLGS:boolean;
    begin
      result:=true;
      if testeGl[symNr]>0 then
        begin
          if testeGl[symNr] and 1 = 1
            then begin MakeZahlGL(1); result:=Gleichung(1) end;
          if result and (testeGl[symNr] and 2 = 2)
            then begin MakeZahlGL(2); result:=Gleichung(2) end;
          if result and (testeGl[symNr] and 4 = 4)
            then begin
                   MakeZahlGL(3);
                   result:=Gleichung(3) and Gleichung(4) and
                           Gleichung(5) and Gleichung(6);
                 end;
        end;
    end;

    procedure SchreibLoesung;
    var k,x : integer;
    begin
      if lsg_Nr=0 then
        for k:=1 to last_nr do StringGridLoesungen.cells[0,k]:=symStr[k];
      lsg_Nr:=lsg_nr+1;
      if StringGridLoesungen.colCount<lsg_Nr+1 then StringGridLoesungen.colCount:=lsg_Nr+1;
      x:=(StringGridLoesungen.width-10);
      if lsg_Nr>0 then x:=x DIV (lsg_Nr+1);
        if x>cWidth
          then StringGridLoesungen.defaultColWidth:=x
          else StringGridLoesungen.defaultColWidth:=cWidth;
      StringGridLoesungen.Cells[lsg_Nr,0]:=IntToStr(lsg_Nr)+RSArr[rsLsg];
      for k:=1 to last_nr do StringGridLoesungen.cells[lsg_Nr,k]:=lsgStr[k];
    end;


begin
  alt:=symStr[symNr];
  for ziffer:='9' DOWNTO '0' do
    if frei[ziffer] then
      begin
        Ersetze(alt,ziffer);
        StringGridTempWerte.Cells[SymNr,1]:=ziffer;
        lsgStr[symNr]:=ziffer;
        CheckPause;
        zeigModusNeu;
        if symNr=last_nr
          then begin
                 ok:=TesteLGS;
                 if ok then
                   begin
                     SchreibLoesung;
                     z3.caption:=gZeile[2];
                     z5.caption:=gZeile[3];
                     ok:=einzel
                   end;
               end
          else begin
                 frei[ziffer]:=FALSE;
                 if not abbruch and TesteLGS then Test(symNr+1,ok);
                 frei[ziffer]:=TRUE;
                 StringGridTempWerte.Cells[SymNr,1]:=' ';
               end;
        if ok or abbruch then Exit;
        Ersetze(ziffer,alt);
      end
end;

function TZahlenraetsel.testen:Boolean;
var sp,z     : integer;
    s,sv     : string;
    b        : boolean;
    zx,zy    : integer;
    opNr     : integer;

    function TesteZahl(Var s : string):boolean;
    var k : integer;
    begin
      result:=Length(s)>0;
       for k:=length(s) downto 1 do
          begin
            case s[k] of
              ' ' : system.Delete(s,k,1);
              'A'..'Z' : if Pos(s[k],sv)=0 then sv:=sv+s[k];
              'a'..'z' : begin
                           s[k]:=UpCase(s[k]);
                           if Pos(s[k],sv)=0 then sv:=sv+s[k];
                         end;
              else result:=false;
              end;
          end;
       if length(s)=0 then result:=false;
    end;

    function TesteOp(Var s : string):boolean;
    var k : integer;
    begin
      result:=Length(s)>0;
       for k:=length(s) downto 1 do
          begin
            case s[k] of
              ' ' : system.Delete(s,k,1);
              '+','-','*','/' : ;
              else result:=false;
             end;
          end;
       if length(s)=0 then result:=false;
    end;

begin
  result:=false; sv:='';
  FillChar(op,SizeOf(op),#0);
  FillChar(testeGl,SizeOf(testeGl),#0);
  opNr:=0;
  for z:=1 to 5 do
  begin
    zx:=0; if z=1 then zy:=1 else if z=3 then zy:=2 else zy:=3;
    for sp:=1 to 5 do
      begin
        s:=StringGridGleichungen.cells[sp-1,z-1];
        if odd(sp) and odd(z)
          then begin
                 zx:=zx+1;
                 b:=TesteZahl(s);
                 if b
                   then zLsgStr[zy,zx]:=s
                   else begin
                          z5.caption:=RSArr[rsUnzulaessigesZeichen];
                        end;
                end
          else if ( odd(z) and (sp=2) ) or  ( (z=2) and odd(sp) )
                   then begin
                          opNr:=opNr+1;
                          b:=testeOp(s);
                          if b
                            then op[opNr]:=s[1]
                            else begin
                                   z5.caption:=RSArr[rsUnzulaessigerOperator];
                                 end;
                        end
                   else begin
                          b:=true;
                          s:=orgGrid[z,sp];
                        end;
        if not b then
          begin
            exit;
          end;
        StringGridGleichungen.cells[sp-1,z-1]:=s;
      end;
     if optimiert
       then begin
              if z=1 then testeGl[Length(sv)]:=1;
              if z=3 then testeGl[Length(sv)]:=testeGl[Length(sv)]+2;
              if z=5 then testeGl[Length(sv)]:=testeGl[Length(sv)]+4;
            end
       else if z=5 then testeGl[Length(sv)]:=1+2+4;
    end;
  result:=length(sv)<=10;
  if result
    then begin
           symStr:=sv; lsgStr:=sv; last_nr:=Length(sv);
           s:=op[4]; op[4]:=op[2]; op[2]:=op[5]; op[5]:=op[3]; op[3]:=op[6];
           op[6]:=s[1];
         end
    else z5.caption:=RSArr[rsZuvieleSymbole]+IntToStr(length(sv))+')'
end;

Procedure TZahlenRaetsel.Zeige_Loesung(nr:integer);
var k : integer;
begin
  for k:=1 to last_Nr do ersetze(StringGridLoesungen.cells[0,k][1],StringGridLoesungen.cells[nr,k][1]);
end;


procedure TZahlenRaetsel.zeigModusNeu;
begin
  PanelLsg.Visible:=zeigen;
  stringGridTempWerte.TopRow:=Ord(not zeigen);
end;

end.
