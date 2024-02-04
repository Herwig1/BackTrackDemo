//
unit AlgoInfo;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Erläuterungen zu den Beispielen
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  Controls, Forms, Dialogs, StdCtrls, Buttons, ExtCtrls,
  BackTrackDemo_Sprache;

type

  { TInfoForm }

  TInfoForm = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    BitBtnBeenden: TBitBtn;
  private
    { Private-Deklarationen }
    procedure InfoDamen;
    procedure infoSpringer;
    procedure InfoReise;
    procedure InfoReise2;
    procedure InfoNikolaus;
    procedure InfoRaetsel;
    procedure InfoRouterLee;
    procedure InfoVierFarben;
    procedure InfoRucksack;
    procedure InfoLabyrinth;
    procedure InfoSolitaire;
    procedure InfoPuzzle3x3;
    procedure InfoSudoku;
  public
    { Public-Deklarationen }
    procedure ShowInfo(nr:integer);
  end;

var
  InfoForm: TInfoForm;

implementation

 {$R *.lfm}

procedure TInfoForm.InfoDamen;
begin
  caption:=RSArr[rsInfoNDamen0];
  with memo1.lines do
    begin
     Add(RSArr[rsInfoNDamen1]);
     Add('');
     Add(RSArr[rsInfoNDamen2]);
     Add('');
     Add(RSArr[rsInfoNDamen3]);
     Add('');
     Add(RSArr[rsInfoNDamen4]);
     Add('');
    end;
end;

procedure TInfoForm.infoSpringer;
begin
  caption:=RSArr[rsInfoSpringer0];
   with memo1.lines do
    begin
     Add(RSArr[rsInfoSpringer1]);
     Add('');
     Add(RSArr[rsSiehe]);
     Add('N. Wirth  Algorithmen und Datenstrukturen, Teubner 79, Kap 3.4  Backtracking Algorithmen, Seite 191 ff');
     Add('');
     Add(RSArr[rsAchtung]);
     Add(RSArr[rsInfoSpringer2]);
     Add('');
     Add(RSArr[rsInfoSpringer3]);
     Add('');
    end
end;

procedure TInfoForm.InfoReise;
begin
  caption:=RSArr[rsInfoSalesmanA0];
  with memo1.lines do
    begin
     Add(RSArr[rsInfoSalesmanA1]);
     Add(RSArr[rsInfoSalesmanA2]);
     Add(' ');
     Add(RSArr[rsSieheCtJannuar1994]);
     Add(RSArr[rsInfoSAAlgorithmus0]);
     Add(RSArr[rsInfoSAAlgorithmus1]);
     Add(' ');
     Add(RSArr[rsInfoTAAlgoritmus]);
     Add(RSArr[rsSchwellenakzeptanz]);
     Add(' ');
     Add(RSArr[rsBEGINNESA]);
     Add(RSArr[rsWaehleKonfiguration]);
     Add(RSArr[rsWaehleAnfangswert]);
     Add(RSArr[rsWIEDERHOLE]);
     Add(RSArr[rsWIEDERHOLE1]);
     Add(RSArr[rsWaehleNeueKonfig]);
     Add(RSArr[rsAltenKonfiguration]);
     Add(RSArr[rsBerechneQualitaetsfkt]);
     Add(RSArr[rsDEQneuQalt]);
     Add('{SA *******}');
     Add(RSArr[rsWENNDE0]);
     Add(RSArr[rsDANNAlteKonfigneueKonfig]);
     Add(RSArr[rsSONSTWENNZufallszahlexpDEkT]);
     Add(RSArr[rsDANNAlteKonfigneueKonfig1]);
     Add('{SA *******}');
     Add('{TA +++++++}');
     Add(RSArr[rsWENNDET]);
     Add(RSArr[rsDANNAlteKonfigneueKonfig2]);
     Add('{TA +++++++}');
     Add(RSArr[rsBISrQualitaetOk]);
     Add(RSArr[rsVerringereT]);
     Add(RSArr[rsBISQualitaetsfktKonst]);
     Add(RSArr[rsENDE]);
     Add('');
     Add('');
     Add(RSArr[rsKlickZwischenloesung]);
     Add('');
    end;
end;


procedure TInfoForm.InfoReise2;
begin
  caption:=RSArr[rsInfoSalesmanB0];
  with memo1.lines do
    begin
     Add(RSArr[rsInfoSalesmanB1]);
     Add(RSArr[rsInfoSalesmanB2]);
     Add(RSArr[rsInfoSalesmanB3]);
     Add(RSArr[rsInfoSalesmanB4]);
     Add('');
     Add(RSArr[rsKlickZwischenloesung]);
     Add('');
    end;
end;


procedure TInfoForm.InfoRaetsel;
begin
  caption:=RSArr[rsInfoZahlenraetsel0];
  with memo1.lines do
    begin
     Add(RSArr[rsInfoZahlenraetsel1]);
     Add(RSArr[rsInfoZahlenraetsel2]);
    end;
end;

procedure TInfoForm.InfoNikolaus;
begin
  caption:=RSArr[rsInfoHausVomNikolaus0];
  with memo1.lines do
    begin
     Add(RSArr[rsInfoHausVomNikolaus1]);
     Add(RSArr[rsInfoHausVomNikolaus2]);
     Add('');
     Add(RSArr[rsKlickLoesung]);
     Add('');
    end;
end;

procedure TInfoForm.InfoRouterLee;
begin
  caption:=RSArr[rsInfoAutorouting0];
  with memo1.lines do
    begin
      Add(RSArr[rsInfoAutorouting1]);
      Add(RSArr[rsInfoAutorouting2]);
      Add(' ');
      Add(RSArr[rsInfoLeeAlgo0]);
      Add(RSArr[rsInfoLeeAlgo1]);
      Add(RSArr[rsInfoLeeAlgo2]);
      Add(' ');
      Add(RSArr[rsSZBCt390Seite240]);
      Add(' ');
      Add(' ');
      Add(RSArr[rsInfoAutorouting3]);
    end;
end;

procedure TInfoForm.InfoVierFarben;
begin
  caption:=RSArr[rsVierFarbenProblem0];
  with memo1.lines do
    begin
      Add(RSArr[rsVierFarbenProblem1]);
      Add(RSArr[rsVierFarbenProblem2]);
      Add(' ');
      Add(RSArr[rsVierFarbenProblem3]);
      Add(' ');
      Add(RSArr[rsVierFarbenProblem4]);
    end;
end;

procedure TInfoForm.InfoRucksack;
begin
  caption:=RSArr[rsRucksackProblem0];
  with memo1.lines do
    begin
      Add(RSArr[rsRucksackProblem1]);
      Add(RSArr[rsRucksackProblem2]);
      Add(' ');
      Add(RSArr[rsRucksackProblem3]);
      Add(' ');
      Add(RSArr[rsRucksackProblem4]);
      Add(RSArr[rsRucksackProblem5]);
    end;
end;

procedure TInfoForm.InfoLabyrinth;
begin
  caption:=RSArr[rsWegAusLabyrinth0];
  with memo1.lines do
    begin
      Add(RSArr[rsWegAusLabyrinth1]);
      Add(RSArr[rsWegAusLabyrinth2]);
      Add(RSArr[rsWegAusLabyrinth3]);
      Add(' ');
      Add(RSArr[rsHinweisLeeAlgo0]);
      Add(RSArr[rsHinweisLeeAlgo1]);
      Add(RSArr[rsHinweisLeeAlgo2]);
      Add(RSArr[rsHinweisLeeAlgo3] );
      Add(' ');
      Add(RSArr[rsWegAusLabyrinth4]);
      Add(' ');
    end;
end;

procedure TInfoForm.InfoSolitaire;
begin
  caption:=RSArr[rsSolitaerProblem0];
  with memo1.lines do
    begin
      Add(RSArr[rsSolitaerProblem1]);
      Add(' ');
      Add(RSArr[rsSolitaerProblem2]);
      Add(RSArr[rsSolitaerProblem3]);
      Add(' ');
      Add(RSArr[rsSolitaerProblem4]);
      Add(' ');
      Add(RSArr[rsSolitaerProblem5]);
      Add(' ');
      Add(RSArr[rsLoesungVonDavidDirkse0]);
      Add(RSArr[rsLoesungVonDavidDirkse1]);
      Add(RSArr[rsLoesungVonDavidDirkse2]);
      Add(RSArr[rsLoesungVonDavidDirkse3]);
    end;
end;

procedure TInfoForm.InfoPuzzle3x3;
begin
  caption:='3x3 Scramble Square™ Puzzle';
  with memo1.lines do
    begin
      Add(RSArr[rsScrambleSquarePuzzle0]);
      Add(' ');
      Add(RSArr[rsSolitaerProblem2]);
      Add(RSArr[rsScrambleSquarePuzzle2]);
    end;
end;

procedure TInfoForm.InfoSudoku;
begin
  caption:=RSArr[rsSudoku];
  with memo1.lines do
    begin
      Add(RSArr[rsSudoku1]);
      Add(RSArr[rsSudoku2]);
      Add(RSArr[rsSolitaerProblem2]);
      Add(RSArr[rsSudoku4]);
    end;
end;

procedure TInfoForm.ShowInfo(nr:integer);
begin
  TranslationsFor_AlgoInfo;
  memo1.Clear;
  case nr of
     1 : InfoDamen;
     2 : infoSpringer;
     3 : InfoReise;
     4 : InfoRaetsel;
     5 : InfoNikolaus;
     6 : InfoRouterLee;
     7 : Inforeise2;
     8 : InfoVierFarben;
     9 : InfoRucksack;
    10 : InfoLabyrinth;
    11 : InfoSolitaire;
    12 : InfoPuzzle3x3;
    13 : InfoSudoku;
   end;
  memo1.repaint;
  ShowModal;
end;

end.
