unit BackTrackDemo_Sprache;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   stellt Konstanten-Array bereit; dieser wird überschrieben mit dem Inhalt der
            Datei "BackTrackDemo_Sprache.txt", wenn diese Verzeichnis der Exe-Datei gefunden wird.
   Autor:   H. Niemeyer  (c) 2023
   Version: 1.0

   letzte Änderung: 15.12.2023 *)

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms;

const
  sprachFile = 'BackTrackDemo_Sprache.txt';

  rsSprachName = 0;
  rsKreuz = rsSprachName + 1;
  rsPlus = rsKreuz + 1;
  rsKamin = rsPlus + 1;
  rsAcht = rsKamin + 1;
  rsPyramide = rsAcht + 1;
  rsPfeil1 = rsPyramide + 1;
  rsHerkules = rsPfeil1 + 1;
  rsSpiegel = rsHerkules + 1;
  rsPfeil2 = rsSpiegel + 1;
  rsDiamant = rsPfeil2 + 1;
  rsSolitaer = rsDiamant + 1;
  rsSolitaer2 = rsSolitaer + 1;



(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\BackMain.lfm          *)
(*                         BackMain.lfm                         *)
(* ************************************************************ *)

const
  rsBacktrackingBeispiele = rsSolitaer2 + 1;
  rsNDamenProblem = rsBacktrackingBeispiele + 1;
  rsWegDesSpringers = rsNDamenProblem + 1;
  rsProblemSalesmanA = rsWegDesSpringers + 1;
  rsZahlenraetsel = rsProblemSalesmanA + 1;
  rsHausVomNikolaus = rsZahlenraetsel + 1;
  rsSchliessen = rsHausVomNikolaus + 1;
  rsRouterMitLee = rsSchliessen + 1;
  rsProblemSalesmanB = rsRouterMitLee + 1;
  rsRucksackPacken = rsProblemSalesmanB + 1;
  rsVierfarbenproblem = rsRucksackPacken + 1;
  rsProgrammInfo = rsVierfarbenproblem + 1;
  rsLabyrinth = rsProgrammInfo + 1;
  rsSudoku = rsLabyrinth + 1;

(* ************************************************************ *)
(*          C:\myProjects\Backtracking_Laz\n_Damen.pas          *)
(*                         n_Damen.pas                          *)
(* ************************************************************ *)

const
  rsLoesungenZu = rsSudoku + 1;
  rsKeineLoesung = rsLoesungenZu + 1;
  rsLoesungenErmittelt = rsKeineLoesung + 1;
  rsEsGibt = rsLoesungenErmittelt + 1;
  rsUnabhLoesungen = rsEsGibt + 1;
  rsEsWurden = rsUnabhLoesungen + 1;
  rsMax = rsEsWurden + 1;
  rsEntfernSymLoesung = rsMax + 1;
  rsAchseWO = rsEntfernSymLoesung + 1;
  rsAchseNWSO = rsAchseWO + 1;
  rsAchseNS = rsAchseNWSO + 1;
  rsAchseSWNO = rsAchseNS + 1;
  rsDrehungUm90 = rsAchseSWNO + 1;
  rsDrehungUm180 = rsDrehungUm90 + 1;
  rsDrehungUm270 = rsDrehungUm180 + 1;
  rsNoch = rsDrehungUm270 + 1;
  rsLoesung = rsNoch + 1;
  rsEn = rsLoesung + 1;

(* ************************************************************ *)
(*          C:\myProjects\Backtracking_Laz\n_Damen.lfm          *)
(*                         n_Damen.lfm                          *)
(* ************************************************************ *)

const
  rsNDamen = rsEn + 1;
  rsUnabhLoesungenBestimmen = rsNDamen + 1;
  rsNeuerTest = rsUnabhLoesungenBestimmen + 1;
  rsAnzahlDamen = rsNeuerTest + 1;
  rsAlleLoesungenSuchen = rsAnzahlDamen + 1;
  rsZwischenschritteZeigen = rsAlleLoesungenSuchen + 1;
  rsStarten = rsZwischenschritteZeigen + 1;
  rsBeenden = rsStarten + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\springer.pas          *)
(*                         springer.pas                         *)
(* ************************************************************ *)

const
  rsLsg = rsBeenden + 1;
  rsEineLoesungGefunden = rsLsg + 1;
  rsLoesungenGefunden = rsEineLoesungGefunden + 1;
  rsLoesungNr = rsLoesungenGefunden + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\springer.lfm          *)
(*                         springer.lfm                         *)
(* ************************************************************ *)

const
  rsStartPos = rsLoesungNr + 1;
  rsSpalteX = rsStartPos + 1;
  rsZeileY = rsSpalteX + 1;
  rsGroesseSchachbretts = rsZeileY + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\nikolaus.pas          *)
(*                         nikolaus.pas                         *)
(* ************************************************************ *)

const
  rsLoesungSuchen = rsGroesseSchachbretts + 1;
  rsLoesungenSuchen = rsLoesungSuchen + 1;
  rsEineLoesungGefunden1 = rsLoesungenSuchen + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\nikolaus.lfm          *)
(*                         nikolaus.lfm                         *)
(* ************************************************************ *)

const
  rsDasHausVomNikolaus = rsEineLoesungGefunden1 + 1;
  rsLinienNachfahren = rsDasHausVomNikolaus + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\rundreise.pas         *)
(*                        rundreise.pas                         *)
(* ************************************************************ *)

const
  rsPunkteEingeben = rsLinienNachfahren + 1;
  rsAktuellKleinsteLaenge = rsPunkteEingeben + 1;
  rsGrenze = rsAktuellKleinsteLaenge + 1;
  rsLaenge = rsGrenze + 1;
  rsAnfangsUndEndlaenge = rsLaenge + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\rundreise.lfm         *)
(*                        rundreise.lfm                         *)
(* ************************************************************ *)

const
  rsWegSalesmanA = rsAnfangsUndEndlaenge + 1;
  rsAnzahlDerStaedte = rsWegSalesmanA + 1;
  rsMethode = rsAnzahlDerStaedte + 1;
  rsTAMethode = rsMethode + 1;
  rsSAMethode = rsTAMethode + 1;
  rsVollstaendigeSuche = rsSAMethode + 1;
  rsStaedteEingeben = rsVollstaendigeSuche + 1;
  rsEntfernungen = rsStaedteEingeben + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\zahlraet.pas          *)
(*                         zahlraet.pas                         *)
(* ************************************************************ *)

const
  rsWert = rsEntfernungen + 1;
  rsLoesungenGefunden1 = rsWert + 1;
  rsUnzulaessigesZeichen = rsLoesungenGefunden1 + 1;
  rsUnzulaessigerOperator = rsUnzulaessigesZeichen + 1;
  rsZuvieleSymbole = rsUnzulaessigerOperator + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\zahlraet.lfm          *)
(*                         zahlraet.lfm                         *)
(* ************************************************************ *)

const
  rsOptimierteSuche = rsZuvieleSymbole + 1;
  rsEingabe = rsOptimierteSuche + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\AlgoInfo.pas          *)
(*                         AlgoInfo.pas                         *)
(* ************************************************************ *)

const
  rsInfoNDamen0 = rsEingabe + 1;
  rsInfoNDamen1 = rsInfoNDamen0 + 1;
  rsInfoNDamen2 = rsInfoNDamen1 + 1;
  rsInfoNDamen3 = rsInfoNDamen2 + 1;
  rsInfoNDamen4 = rsInfoNDamen3 + 1;
  rsInfoSpringer0 = rsInfoNDamen4 + 1;
  rsInfoSpringer1 = rsInfoSpringer0 + 1;
  rsSiehe = rsInfoSpringer1 + 1;
  rsAchtung = rsSiehe + 1;
  rsInfoSpringer2 = rsAchtung + 1;
  rsInfoSpringer3 = rsInfoSpringer2 + 1;
  rsInfoSalesmanA0 = rsInfoSpringer3 + 1;
  rsInfoSalesmanA1 = rsInfoSalesmanA0 + 1;
  rsInfoSalesmanA2 = rsInfoSalesmanA1 + 1;
  rsSieheCtJannuar1994 = rsInfoSalesmanA2 + 1;
  rsInfoSAAlgorithmus0 = rsSieheCtJannuar1994 + 1;
  rsInfoSAAlgorithmus1 = rsInfoSAAlgorithmus0 + 1;
  rsInfoTAAlgoritmus = rsInfoSAAlgorithmus1 + 1;
  rsSchwellenakzeptanz = rsInfoTAAlgoritmus + 1;
  rsBEGINNESA = rsSchwellenakzeptanz + 1;
  rsWaehleKonfiguration = rsBEGINNESA + 1;
  rsWaehleAnfangswert = rsWaehleKonfiguration + 1;
  rsWIEDERHOLE = rsWaehleAnfangswert + 1;
  rsWIEDERHOLE1 = rsWIEDERHOLE + 1;
  rsWaehleNeueKonfig = rsWIEDERHOLE1 + 1;
  rsAltenKonfiguration = rsWaehleNeueKonfig + 1;
  rsBerechneQualitaetsfkt = rsAltenKonfiguration + 1;
  rsDEQneuQalt = rsBerechneQualitaetsfkt + 1;
  rsWENNDE0 = rsDEQneuQalt + 1;
  rsDANNAlteKonfigneueKonfig = rsWENNDE0 + 1;
  rsSONSTWENNZufallszahlexpDEkT = rsDANNAlteKonfigneueKonfig + 1;
  rsDANNAlteKonfigneueKonfig1 = rsSONSTWENNZufallszahlexpDEkT + 1;
  rsWENNDET = rsDANNAlteKonfigneueKonfig1 + 1;
  rsDANNAlteKonfigneueKonfig2 = rsWENNDET + 1;
  rsBISrQualitaetOk = rsDANNAlteKonfigneueKonfig2 + 1;
  rsVerringereT = rsBISrQualitaetOk + 1;
  rsBISQualitaetsfktKonst = rsVerringereT + 1;
  rsENDE = rsBISQualitaetsfktKonst + 1;
  rsKlickZwischenloesung = rsENDE + 1;
  rsInfoSalesmanB0 = rsKlickZwischenloesung + 1;
  rsInfoSalesmanB1 = rsInfoSalesmanB0 + 1;
  rsInfoSalesmanB2 = rsInfoSalesmanB1 + 1;
  rsInfoSalesmanB3 = rsInfoSalesmanB2 + 1;
  rsInfoSalesmanB4 = rsInfoSalesmanB3 + 1;
  rsInfoZahlenraetsel0 = rsInfoSalesmanB4 + 1;
  rsInfoZahlenraetsel1 = rsInfoZahlenraetsel0 + 1;
  rsInfoZahlenraetsel2 = rsInfoZahlenraetsel1 + 1;
  rsInfoHausVomNikolaus0 = rsInfoZahlenraetsel2 + 1;
  rsInfoHausVomNikolaus1 = rsInfoHausVomNikolaus0 + 1;
  rsInfoHausVomNikolaus2 = rsInfoHausVomNikolaus1 + 1;
  rsKlickLoesung = rsInfoHausVomNikolaus2 + 1;
  rsInfoAutorouting0 = rsKlickLoesung + 1;
  rsInfoAutorouting1 = rsInfoAutorouting0 + 1;
  rsInfoAutorouting2 = rsInfoAutorouting1 + 1;
  rsInfoLeeAlgo0 = rsInfoAutorouting2 + 1;
  rsInfoLeeAlgo1 = rsInfoLeeAlgo0 + 1;
  rsInfoLeeAlgo2 = rsInfoLeeAlgo1 + 1;
  rsSZBCt390Seite240 = rsInfoLeeAlgo2 + 1;
  rsInfoAutorouting3 = rsSZBCt390Seite240 + 1;
  rsVierFarbenProblem0 = rsInfoAutorouting3 + 1;
  rsVierFarbenProblem1 = rsVierFarbenProblem0 + 1;
  rsVierFarbenProblem2 = rsVierFarbenProblem1 + 1;
  rsVierFarbenProblem3 = rsVierFarbenProblem2 + 1;
  rsVierFarbenProblem4 = rsVierFarbenProblem3 + 1;
  rsRucksackProblem0 = rsVierFarbenProblem4 + 1;
  rsRucksackProblem1 = rsRucksackProblem0 + 1;
  rsRucksackProblem2 = rsRucksackProblem1 + 1;
  rsRucksackProblem3 = rsRucksackProblem2 + 1;
  rsRucksackProblem4 = rsRucksackProblem3 + 1;
  rsRucksackProblem5 = rsRucksackProblem4 + 1;
  rsWegAusLabyrinth0 = rsRucksackProblem5 + 1;
  rsWegAusLabyrinth1 = rsWegAusLabyrinth0 + 1;
  rsWegAusLabyrinth2 = rsWegAusLabyrinth1 + 1;
  rsWegAusLabyrinth3 = rsWegAusLabyrinth2 + 1;
  rsHinweisLeeAlgo0 = rsWegAusLabyrinth3 + 1;
  rsHinweisLeeAlgo1 = rsHinweisLeeAlgo0 + 1;
  rsHinweisLeeAlgo2 = rsHinweisLeeAlgo1 + 1;
  rsHinweisLeeAlgo3 = rsHinweisLeeAlgo2 + 1;
  rsWegAusLabyrinth4 = rsHinweisLeeAlgo3 + 1;
  rsSolitaerProblem0 = rsWegAusLabyrinth4 + 1;
  rsSolitaerProblem1 = rsSolitaerProblem0 + 1;
  rsSolitaerProblem2 = rsSolitaerProblem1 + 1;
  rsSolitaerProblem3 = rsSolitaerProblem2 + 1;
  rsSolitaerProblem4 = rsSolitaerProblem3 + 1;
  rsSolitaerProblem5 = rsSolitaerProblem4 + 1;
  rsLoesungVonDavidDirkse0 = rsSolitaerProblem5 + 1;
  rsLoesungVonDavidDirkse1 = rsLoesungVonDavidDirkse0 + 1;
  rsLoesungVonDavidDirkse2 = rsLoesungVonDavidDirkse1 + 1;
  rsLoesungVonDavidDirkse3 = rsLoesungVonDavidDirkse2 + 1;
  rsScrambleSquarePuzzle0 = rsLoesungVonDavidDirkse3 + 1;
  rsScrambleSquarePuzzle2 = rsScrambleSquarePuzzle0 + 1;
  rsSudoku1 = rsScrambleSquarePuzzle2 + 1;
  rsSudoku2 = rsSudoku1 + 1;
  rsSudoku4 = rsSudoku2 + 1;


(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\RouteLee.pas          *)
(*                         RouteLee.pas                         *)
(* ************************************************************ *)

const
  rsStelleVerbindungenHer = rsSudoku4 + 1;
  rsVerbindungenMarkieren = rsStelleVerbindungenHer + 1;
  rsSortierePunkte = rsVerbindungenMarkieren + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\RouteLee.lfm          *)
(*                         RouteLee.lfm                         *)
(* ************************************************************ *)

const
  rsRouterMitLeeAlgorithmus1 = rsSortierePunkte + 1;
  rsAnzahlPunkteAuswahl = rsRouterMitLeeAlgorithmus1 + 1;
  rsAnzahlVerbindungen = rsAnzahlPunkteAuswahl + 1;
  rsZufallsbeispiel = rsAnzahlVerbindungen + 1;
  rsLeeAlgorithmus = rsZufallsbeispiel + 1;

(* ************************************************************ *)
(*          C:\myProjects\Backtracking_Laz\rundweg.pas          *)
(*                         rundweg.pas                          *)
(* ************************************************************ *)

const
  rsSucheAbgebrochen = rsLeeAlgorithmus + 1;
  rsRundwegKleinsteLaenge = rsSucheAbgebrochen + 1;
  rsKeinenRundwegGefunden = rsRundwegKleinsteLaenge + 1;
  rsUngueltigerWertAnzahlStaedte = rsKeinenRundwegGefunden + 1;

(* ************************************************************ *)
(*          C:\myProjects\Backtracking_Laz\rundweg.lfm          *)
(*                         rundweg.lfm                          *)
(* ************************************************************ *)

const
  rsWegSalesmanB = rsUngueltigerWertAnzahlStaedte + 1;
  rsEntfernungenEingeben = rsWegSalesmanB + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\Rucksack.pas          *)
(*                         Rucksack.pas                         *)
(* ************************************************************ *)

const
  rsWert1 = rsEntfernungenEingeben + 1;
  rsGewicht = rsWert1 + 1;
  rsBesteLoesung = rsGewicht + 1;
  rsLoesungenerste = rsBesteLoesung + 1;
  rsNr = rsLoesungenerste + 1;
  rsGewicht1 = rsNr + 1;
  rsTeileEingeben = rsGewicht1 + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\Rucksack.lfm          *)
(*                         Rucksack.lfm                         *)
(* ************************************************************ *)

const
  rsRucksack = rsTeileEingeben + 1;
  rsAnzahlDerTeile = rsRucksack + 1;
  rsGesamtgewicht = rsAnzahlDerTeile + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\vierfarb.pas          *)
(*                         vierfarb.pas                         *)
(* ************************************************************ *)

const
  rsLaenderMarkieren = rsGesamtgewicht + 1;
  rsEinfaerben = rsLaenderMarkieren + 1;
  rsFaerbungGefunden = rsEinfaerben + 1;
  rsKeineFaerbungGefunden = rsFaerbungGefunden + 1;
  rsLand = rsKeineFaerbungGefunden + 1;
  rsFarbe = rsLand + 1;
  rsSucheUmrandungFuerLand = rsFarbe + 1;
  rsKannFuerLand = rsSucheUmrandungFuerLand + 1;
  rsKeineGrenzeErstellen = rsKannFuerLand + 1;
  rsSucheNachUmrandungenBeendet = rsKeineGrenzeErstellen + 1;
  rsSucheGrenzenUndNachbarn = rsSucheNachUmrandungenBeendet + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\vierfarb.lfm          *)
(*                         vierfarb.lfm                         *)
(* ************************************************************ *)

const
  rsVierFarb = rsSucheGrenzenUndNachbarn + 1;
  rsNeueEingabe = rsVierFarb + 1;
  rsVierLaender = rsNeueEingabe + 1;
  rsAnzahlDerLaender = rsVierLaender + 1;
  rsLandZufuegen = rsAnzahlDerLaender + 1;
  rsLandEntfernen = rsLandZufuegen + 1;

(* ************************************************************ *)
(*       C:\myProjects\Backtracking_Laz\backtrackinfo.lfm       *)
(*                      backtrackinfo.lfm                       *)
(* ************************************************************ *)

const
  rsInfo = rsLandEntfernen + 1;
  rsVersion = rsInfo + 1;
  rsDemosZuBacktrack = rsVersion + 1;
  rsOK = rsDemosZuBacktrack + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\Labyrinth.pas         *)
(*                        Labyrinth.pas                         *)
(* ************************************************************ *)

const
  rsWeglaenge = rsOK + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\Labyrinth.lfm         *)
(*                        Labyrinth.lfm                         *)
(* ************************************************************ *)

const
  rsAusgang = rsWeglaenge + 1;
  rsStartrichtung = rsAusgang + 1;
  rsVerfahren = rsStartrichtung + 1;
  rsBacktrackingGeradeaus = rsVerfahren + 1;
  rsBacktrackingErstRechts = rsBacktrackingGeradeaus + 1;
  rsBacktrackingZufaellig = rsBacktrackingErstRechts + 1;
  rsBesteLoesungSuchen = rsBacktrackingZufaellig + 1;
  rsHindernisLinksZiehen = rsBesteLoesungSuchen + 1;
  rsFreiesFeldRechtsZiehen = rsHindernisLinksZiehen + 1;
  rsStartDoppelclickFreiesFeld = rsFreiesFeldRechtsZiehen + 1;
  rsAusgangDoppelclickHindernis = rsStartDoppelclickFreiesFeld + 1;
  rsNeuStart = rsAusgangDoppelclickHindernis + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\solitaer.pas          *)
(*                         solitaer.pas                         *)
(* ************************************************************ *)

const
  rsAbbruchSpeichern = rsNeuStart + 1;
  rsSpielBeenden = rsAbbruchSpeichern + 1;
  rsManuell = rsSpielBeenden + 1;
  rsFortsetzen = rsManuell + 1;
  rsZeit = rsFortsetzen + 1;
  rsMs = rsZeit + 1;
  rsBisher = rsMs + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\solitaer.lfm          *)
(*                         solitaer.lfm                         *)
(* ************************************************************ *)

const
  rsBruteForceRekursiv = rsBisher + 1;
  rsBruteForceOptimiert = rsBruteForceRekursiv + 1;
  rsBruteForceIterativ = rsBruteForceOptimiert + 1;
  rsBruteForceMitFilter1 = rsBruteForceIterativ + 1;
  rsBruteForceMitFilter2 = rsBruteForceMitFilter1 + 1;
  rsBruteForceBeideFilter = rsBruteForceMitFilter2 + 1;
  rsNormal = rsBruteForceBeideFilter + 1;
  rsSpiralfoermig = rsNormal + 1;
  rsBlockweise = rsSpiralfoermig + 1;
  rsRechtsObenLinksUnten = rsBlockweise + 1;
  rsObenLinksUntenRechts = rsRechtsObenLinksUnten + 1;
  rsLinksUntenRechtsOben = rsObenLinksUntenRechts + 1;
  rsUntenRechtsObenLinks = rsLinksUntenRechtsOben + 1;
  rsReihenfolge = rsUntenRechtsObenLinks + 1;
  rsZaehlung = rsReihenfolge + 1;
  rsAusgangsbelegung = rsZaehlung + 1;
  rsGetestet = rsAusgangsbelegung + 1;
  rsErgebnis = rsGetestet + 1;
  rsZeigeZwischenstand = rsErgebnis + 1;
  rsZeigeZugFolge = rsZeigeZwischenstand + 1;
  rsZugZuruecknehmen = rsZeigeZugFolge + 1;

(* ************************************************************ *)
(*      C:\myProjects\Backtracking_Laz\pausensteuerung.pas      *)
(*                     pausensteuerung.pas                      *)
(* ************************************************************ *)

const
  rsKeinePause = rsZugZuruecknehmen + 1;
  rsVerzoegerung = rsKeinePause + 1;
  rsPausenlaenge = rsVerzoegerung + 1;
  rsVerkleinern = rsPausenlaenge + 1;
  rsVergroessern = rsVerkleinern + 1;
  rsHalbieren = rsVergroessern + 1;
  rsVerdoppeln = rsHalbieren + 1;

(* ************************************************************ *)
(*      C:\myProjects\Backtracking_Laz\pausensteuerung.lfm      *)
(*                     pausensteuerung.lfm                      *)
(* ************************************************************ *)

const
  rsPause256Ms = rsVerdoppeln + 1;
  rsAbbruch = rsPause256Ms + 1;
  rsVorgabe = rsAbbruch + 1;
  rsKeine = rsVorgabe + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\puzzle3x3.pas         *)
(*                        puzzle3x3.pas                         *)
(* ************************************************************ *)

const
  rsEineLsg = rsKeine + 1;
  rsTeileNr = rsEineLsg + 1;
  rsDrehung = rsTeileNr + 1;

(* ************************************************************ *)
(*         C:\myProjects\Backtracking_Laz\puzzle3x3.lfm         *)
(*                        puzzle3x3.lfm                         *)
(* ************************************************************ *)

const
  rsUmschaltenDunkelhell = rsDrehung + 1;
  rsBeispiel2 = rsUmschaltenDunkelhell + 1;
  rsLoesungen = rsBeispiel2 + 1;
  rsLoesungZeigen = rsLoesungen + 1;

(* ************************************************************ *)
(*          C:\myProjects\Backtracking_Laz\sudoku.pas           *)
(*                          sudoku.pas                          *)
(* ************************************************************ *)

const
  rsBacktrackingbruteForce = rsLoesungZeigen + 1;
  rsBacktrackingBFOptimiert = rsBacktrackingbruteForce + 1;
  rsBacktrackingErstZwangsbelegung = rsBacktrackingBFOptimiert + 1;
  rsAbgebrochen = rsBacktrackingErstZwangsbelegung + 1;
  rsGeloest = rsAbgebrochen + 1;
  rsLoesungenGefunden2 = rsGeloest + 1;
  rsLogik = rsLoesungenGefunden2 + 1;
  rsEindeutigeWerteSetzen = rsLogik + 1;
  rsMoeglichkeitenReduzieren = rsEindeutigeWerteSetzen + 1;
  rsDublettenBehandeln = rsMoeglichkeitenReduzieren + 1;

(* ************************************************************ *)
(*          C:\myProjects\Backtracking_Laz\sudoku.lfm           *)
(*                          sudoku.lfm                          *)
(* ************************************************************ *)

const
  rsSudokuLoesungen = rsDublettenBehandeln + 1;
  rsBeispiel = rsSudokuLoesungen + 1;
  rsBacktrackingBruteForce1 = rsBeispiel + 1;
  rsBacktrackingBruteForceOpimiert = rsBacktrackingBruteForce1 + 1;
  rsBacktrackingerstZwangsbelegung1 = rsBacktrackingBruteForceOpimiert + 1;
  rsLogikTest = rsBacktrackingerstZwangsbelegung1 + 1;
  rsUserEingabe = rsLogikTest + 1;
  rsZeigeZwangsbelegung = rsUserEingabe + 1;
  rsZeigeHilfen = rsZeigeZwangsbelegung + 1;
  rsVerbergeHilfen = rsZeigeHilfen + 1;
  rsAktualisiereHilfe = rsVerbergeHilfen + 1;
  rsInitialisieren = rsAktualisiereHilfe + 1;
  rsLeeresFeld = rsInitialisieren + 1;
  rsManuellenModusVerlassen = rsLeeresFeld + 1;

  lastEntry = rsManuellenModusVerlassen;


var RSArr : array[rsSprachName..lastEntry] of string = (
    'deutsch',
    'Kreuz',
    'Plus',
    'Kamin',
    'Acht',
    'Pyramide',
    'Pfeil-1',
    'Herkules',
    'Spiegel',
    'Pfeil-2',
    'Diamant',
    'Solitär',
    'Solitär 2',
// BackMain.lfm
    'Backtracking Beispiele',
    'N - Damen Problem',
    'Weg des Springers',
    'Problem des Handlungreisenden I',
    'Zahlenrätsel',
    'Haus vom Nikolaus',
    'Schließen',
    'Router mit Lee-Algorithmus',
    'Problem des Handlungreisenden II',
    'Rucksack packen',
    'Vierfarbenproblem',
    '&ProgrammInfo',
    'Labyrinth',
    'Sudoku',
// n_Damen.pas
    'Lösung(en) zu ',
    'keine Lösung gefunden',
    ' Lösungen ermittelt',
    'Es gibt ',
    ' unabhängige Lösungen',
    'Es wurden ',
    ' (max. ',
    'Entferne alle symmetrischen Lösungen bzgl. ',
    'der Achse W-O',
    'der Achse NW-SO',
    'der Achse N-S',
    'der Achse SW-NO',
    'der Drehung um +90°',
    'der Drehung um 180°',
    'der Drehung um 270°',
    'noch ',
    ' Lösung',
    'en ',
// n_Damen.lfm
    'n-Damen',
    'unabhängige Lösungen bestimmen',
    'neuer Test',
    'Anzahl der Damen: ',
    'alle Lösungen suchen',
    'Zwischenschritte zeigen',
    'Starten',
    'beenden',
// springer.pas
    '. Lsg',
    'eine Lösung gefunden',
    ' Lösungen gefunden',
    'Lösung Nr. ',
// springer.lfm
    'Startposition:',
    'Spalte x',
    'Zeile y',
    'Größe des Schachbretts',
// nikolaus.pas
    'Lösung suchen ..',
    'Lösungen suchen ..',
    '(eine) Lösung gefunden!',
// nikolaus.lfm
    'Das Haus vom Nikolaus',
    'Linien nachfahren',
// rundreise.pas
    'Punkte eingeben',
    'aktuell kleinste Länge: %7.4f',
    'Grenze',
    'Länge',
    'Anfangslänge: %7.4f   Endlänge: %7.4f',
// rundreise.lfm
    'Weg des Handlungsreisenden I        ( jede Stadt nur einmal besuchen )',
    'Anzahl der Städte: ',
    'Methode',
    'TA-Methode',
    'SA-Methode',
    'vollständige Suche',
    'Städte eingeben',
    'Entfernungen',
// zahlraet.pas
    'Wert',
    ' Lösung(en) gefunden',
    'unzulässiges Zeichen',
    'unzulässiger Operator',
    'zuviele Symbole: (',
// zahlraet.lfm
    'optimierte Suche',
    'Eingabe',
// AlgoInfo.pas
    'Informationen zum N-Damen Problem',
    'Das Programm versucht nach dem Rückverfolgungs-(Backtracking-) Algorithmus N Damen auf einem Spielfeld der Größe NxN so zu plazieren, daß keine Dame eine andere nach den Schachregeln schlagen kann.',
    'Die Feldgröße n (1<=n<=16) kann frei bestimmt werden.',
    'Unabhängige Lösungen sind solche, die sich nicht durch Achsensymmetrie oder Drehungen in einander überführen lassen.',
    'Nach Maus-Klick auf eine Lösung wird diese in der Grafik dargestellt.',
    'Informationen zur Rundreise des Springers',
    'Das Programm versucht von einer gegebenen Startposition einen Weg des Springers zu finden, so daß jedes Feld genau einmal besucht wird. Es gelten die Regeln des Springerzugs.',
    'siehe:',
    'Achtung: ',
    'Die Suche kann sehr lange dauern! Daher nur kleine Felder wählen!',
    'Nach Maus-Klick auf eine Lösung werden die Springerzüge in der Grafik animiert.',
    'Informationen zum Rundweg des Handlungsreisenden I',
    'Das Programm versucht einen Rundweg so zu ermitteln, daß jeder Ort nur einmal besucht wird und die Fahrstrecke möglichst klein wird. Es ist vorausgesetzt, daß alle Orte verbunden sind!',
    'Neben der Backtracking-Methode (vollständige Suche) sind noch zwei Algorithmen implementiert, die nicht das Backtracking benutzen und nicht immer die kleinste Fahrstrecke liefern. Dafür sind sie wesentlich schneller',
    'siehe c''t Jannuar 1994',
    'Algorithmen abgeleitet aus Verhalten einer Schmelze beim Erstarren.',
    'SA - Simulated-Annealing-Algorithmus; Simuliertes Erstarren (1983; IBM)',
    'TA - Threshold-Accepting-Algoritmus',
    'Schwellenakzeptanz (1990; IBM, Dueck, Scheuer) ',
    'BEGINNE  {SA bzw. TA zur Minimierung}',
    'wähle eine Ausgangskonfiguration;',
    'wähle einen Anfangswert T>0;',
    'WIEDERHOLE',
    '  WIEDERHOLE',
    '    wähle eine neue Konfiguration, die eine kleine Änderung der',
    '    alten Konfiguration ist;',
    '    berechne die Qualitätsfunktion Q der neuen Konfiguration;',
    '    DE:=Q(neu)-Q(alt);',
    '    WENN DE<0',
    '       DANN alte Konfiguration:=neue Konfiguration',
    '       SONST WENN Zufallszahl<exp(-DE/(kT))',
    '             DANN alte Konfiguration:=neue Konfiguration',
    '    WENN DE<T',
    '       DANN alte Konfiguration:=neue Konfiguration ',
    '  BIS lange keine Erniedrigung der Qualität;',
    '  verringere T;',
    'BIS überhaupt keine Verringerung der Qualitätsfunktion mehr;',
    'ENDE.',
    'Nach Maus-Klick auf eine Zwischenlösung wird der Rundweg in der Grafik animiert.',
    'Informationen zum Rundweg des Handlungsreisenden II',
    'Das Programm versucht einen Rundweg so zu ermitteln, daß die Fahrstrecke möglichst klein wird. Dabei dürfen die Orte mehrmals besucht werden und Straßen teilweise in beiden Richtungen durchfahren werden.',
    'Die Orte und Entfernungen können frei gewählt werden.',
    'Ein Leerfeld oder 0 in der Entfernungsmatrix bedeutet: keine Verbindung.',
    'Einbahnstraßen werden je nach Richtung in gelb oder aqua dargestellt.',
    'Informationen zur Lösung des Zahlenrätsels',
    'Wie bei Zahlenrätseln üblich stellt jeder Buchstabe eine Ziffer dar.',
    'Das Programm sucht durch Ausprobieren alle Lösungen.',
    'Informationen zum Haus vom Nikolaus',
    'Das Programm kann alle Lösungen des bekannten Problems finden',
    'Der Startpunkt ist frei wählbar',
    'Nach Maus-Klick auf eine Lösung wird sie in der Grafik animiert dargestellt.',
    'Autorouting nach dem Lee-Algorithmus',
    'Das Programm versucht eine Anzahl von Punkten überkreuzungsfrei zu verbinden.',
    'Praktischer Hintergrund ist z.B. das Erstellen einer Platine.',
    'Von dem Anfangspunkt läßt man Wellen ausgehen, bis der Endpunkt erricht ist oder keine neue Wellenfront mehr erzeugt werden kann.',
    'Im 1. Fall wird der Weg vom Endpunkt zum Anfangspunkt zurückverfolgt (Lee-Algorithmus). Dies ist auch der kürzeste Weg, den man erzeugen kann.',
    'Im 2. Fall - der Endpunkt wurde nicht erreicht - wird ein zuvor ermittelter Weg gelöscht und ein neuer Versuch gestartet. (Backtracking)',
    '(s. z.B. c''t 3/90  Seite 240)',
    'Der zweite Algorithmus versucht den Weg direkt zu finden. Es werden nicht immer Lösungen gefunden! Darüber hinaus ist auch das Zeitverhalten schlechter.',
    'Vier-Farben-Problem',
    'Das Programm versucht eine Anzahl von Flächen mit möglichst wenig Farben so einzufärben, daß Flächen mit gemeinsamer Grenze nicht die gleiche Farbe besitzen.',
    'Praktischer Hintergrund ist z.B. das Erstellen von Atlanten (politische Karten).',
    'Das zugrundeliegende Vierfarbenproblem wurde erst vor einiger Zeit mathematisch korrekt bewiesen.',
    'In dem Programm können max. 20 Rechteckflächen beliebig ineinander verschachtelt werden. Bedingung ist allerdings, daß die Flächen zusammenhängend bleiben.',
    'Rucksack-Problem',
    'Das Programm versucht eine Anzahl von Gegenständen in einen Rucksack zu packen, sodaß bei einer vorgegebener Gewichtsbegrenzung der Gesamtwert der Gegenstände möglichst groß ist.',
    'Praktischer Hintergrund ist z.B. das Zusammenstellen einer (Flug-)Fracht.',
    'Die Lösung kann durch erschöpfende Suche gefunden werden.',
    'In dem Programm können max. 20 Teile mit unterschiedlichen Gewichten und Werten vorgegeben werden. ',
    'Die gelben Rechtecke repräsentieren den Wert, die roten das Gewicht.',
    'Weg aus dem Labyrinth',
    'Das Programm versucht einen Weg aus einem Labyrinth zu finden. Die Startposition ist rot, der Ausgang grün dargestellt',
    'Die Lösung des Problems wird einmal durch das Backtracking-Verfahren, zum andern aber auch durch den Lee-Algorithmus versucht. Es können auch Lösungen gefunden werden, wo das Verfahren "immer rechts halten" versagt, wenn z.B. die Startposition im Labyrinth liegt, genauer in einem Raum, der umlaufen werden kann.',
    'Der Backtracking-Algorithmus ist nicht so effizient, wie ein direkter Vergleich zeigt - insbesondere, wenn die Weglänge minimal werden soll! Das Zeitverhalten wird nochmals dramatisch schlechter, wenn die Gänge mehr als eine Einheit breit gemacht werden.',
    'Hinweis zum Lee-Algorithmus:',
    'Von der Startposition läßt man Wellen ausgehen, bis der Ausgang/Endpunkt erreicht ist oder keine neue Wellenfront mehr erzeugt werden kann.',
    'Im 1. Fall wird der Weg vom Ausgang/Endpunkt zur Startposition zurückverfolgt (Lee-Algorithmus). Dies ist auch der kürzeste Weg, den man erzeugen kann.',
    'Im 2. Fall - der Ausgang wurde nicht erreicht - gibt es keine Lösung.',
    'Mit linker Maustaste und Ziehen können Hindernisse gezeichnet werden; mit rechter Maustaste und Ziehen können Hindernisse beseitigt werden. Ein Doppelklick auf einem freien Feld legt den Startpunkt in dieses Feld, bei einem Doppelklick auf ein Hindernis erhält man dort den neuen Ausgang/Endpunkt.',
    'Solitär-Problem',
    'Das Programm versucht das Brettspiel "Solitär" bzw. einige Abänderungen zu lösen. Ohne entsprechende Algoritmen benötigen die reinen Brute-Force-Methoden sehr viel Zeit.',
    'Man kann auch versuchen, manuell eine Lösung zu finden',
    'Geht man mit der Maus über einen Stein, wird dieser grün eingefärbt, wenn ein eindeutiger Zug möglich ist. Ein Klick auf den Stein führt dann diesen Zug aus. Sind mehrere Züge möglich, wird der Stein rot eingefärbt. Dann muss man ihn anklicken und anschließend einen Klick auf das Sprungziel führen',
    'Das rot umrandete Feld ist das Zielfeld, auf dem sich der letzte Stein befinden muss.',
    'Achtung: die Lösung von Solitär 2 benötigt mit den effektivsten Methoden dieses Programmes knapp 2 Mrd. Testzüge!',
    'Vorlage für die Lösungsalgorithmen war die Lösung von David Dirkse.',
    'siehe:  David Dirkse, solitaire version 2, july, 2010, http://www.davdata.nl/math/peg-solitaire.html',
    'Bei dem ersten Filter wird versucht, sich wiederholende Zugfolgen, die nicht zum Ziel führen können, zu identifizieren und damit dann auch zu vermeiden.',
    'Bei dem zweiten Filter wird eine Bewertung der Stellung vorgenommen. z.B. ist keine Lösung möglich, wenn man keinen Stein mehr hat, mit dem man zum Endfeld springen könnte.',
    'Das Programm versucht ein 3x3 Scramble Square™ Puzzle zu lösen. Ein sehr effektiver Algoritmus wurde in der Computerzeitschrift c''t 17/2023 Seite 130 ff. vorgestellt. Dieser ist Grundlage für das Demoprogramm',
    'Mit Drag und Drop können die Bilder an eine Stelle im Quadrat verschoben werden. (Von dort auch wieder in die Bilderleiste). Drückt man die rechte Maustaste, wird im Quadrat das Bild unter der Maus um 90° gedreht.',
    'Das Programm versucht ein Sudoku zu lösen. Neben dem Brute Force Ansatz werden noch weitere verbesserte Ansätze zur Verfügung gestellt: Eine Optimierung, bei der man mit den Zeilen beginnt, die die meisten Einträge haben. eine zweite Optimierung, bei der zunächst die Stellen behandelt werden, für die es nur eine Möglichkeit gibt.',
    ' Eine 4. Möglichkeit ist die, dass durch Logik-Betrachtungen das Sudoku gelöst wird (liefert nicht immer eine Lösung)',
    'Neben den vorgegebenen Beispielen können auch ein andere Sudokus eingegeben werden',
// RouteLee.pas
    'Stelle Verbindungen her',
    'Verbindungen markieren',
    'Sortiere Punkte nach Verbindungsweglänge',
// RouteLee.lfm
    'Router    ( mit Lee-Algorithmus )',
    'Anzahl der Punkte zur Auswahl',
    'Anzahl der Verbindungen',
    'Zufallsbeispiel ',
    'Lee-Algorithmus',
// rundweg.pas
    'Suche abgebrochen',
    'Rundweg mit kleinster Länge: ',
    'Keinen Rundweg gefunden',
    'ungültiger Wert für Anzahl der Städte',
// rundweg.lfm
    'Weg des Handlungsreisenden II   ( jede Stadt kann mehrmals besucht werden )',
    'Entfernungen eingeben',
// Rucksack.pas
    'Wert: ',
    '  Gewicht: ',
    'Beste Lösung: ',
    ' Lösungen (erste): ',
    'Nr',
    'Gewicht',
    'Teile eingeben',
// Rucksack.lfm
    'Rucksack',
    'Anzahl der Teile: ',
    'Gesamtgewicht',
// vierfarb.pas
    'Länderrechtecke mit der Maus im oberen Teil markieren.',
    'Einfärben',
    'Färbung gefunden',
    'keine Färbung gefunden: der Algorithmus ist offenbar fehlerhaft',
    'Land ',
    'Farbe',
    'Suche Umrandung für Land ',
    'Kann für Land ',
    ' keine Grenze erstellen',
    'Suche nach Umrandungen beendet',
    'Suche Grenzen und Nachbarn',
// vierfarb.lfm
    '4 Farbenproblem',
    'Neue Eingabe',
    '4 neue Länder',
    'Anzahl der Länder: ',
    'Land zufügen',
    'Land entfernen',
// backtrackinfo.lfm
    'Info',
    'Version 1.7  vom  15.12.2023',
    'Eine Sammlung von 13 Demonstrationsprogrammen zu Backtracking-Algorithmen',
    'OK',
// Labyrinth.pas
    'Weglänge: ',
// Labyrinth.lfm
    'Ausgang',
    'Startrichtung:',
    'Verfahren',
    'Backtracking -  geradeaus',
    'Backtracking -  erst rechts',
    'Backtracking -  zufällig',
    'beste Lösung suchen',
    'Hindernis - linke Maustaste und ziehen',
    'freies Feld - rechte Maustaste und ziehen',
    'Start - Doppelclick auf freiem Feld',
    'Ausgang - Doppelclick auf Hindernis',
    'NeuStart',
// solitaer.pas
    'Abbruch+Speichern',
    'Spiel beenden',
    'Manuell',
    'Fortsetzen',
    'Zeit: ',
    ' ms',
    'bisher ',
// solitaer.lfm
    'BruteForce rekursiv',
    'BruteForce rekursiv optimiert',
    'BruteForce iterativ',
    'BruteForce iterativ mit Filter1',
    'BruteForce iterativ mit Filter2',
    'BruteForce iterativ, beide Filter',
    'normal',
    'spiralförmig',
    'blockweise',
    'rechts - oben - links - unten',
    'oben - links - unten - rechts ',
    'links - unten - rechts - oben ',
    'unten - rechts - oben - links',
    'Reihenfolge',
    'Zählung',
    'Ausgangsbelegung',
    'getestet:',
    'Ergebnis',
    'zeige Zwischenstand',
    'zeige ZugFolge',
    'Zug zurücknehmen',
// pausensteuerung.pas
    'keine Pause',
    'Verzögerung ',
    'Pausenlänge ',
    'verkleinern',
    'vergrößern',
    'halbieren',
    'verdoppeln',
// pausensteuerung.lfm
    'Pausenlänge 256 ms',
    'Abbruch',
    'Vorgabe',
    'keine',
// puzzle3x3.pas
    '1 Lösung gefunden',
    'Teile Nr.',
    'Drehung',
// puzzle3x3.lfm
    'Umschalten dunkel/hell',
    'Beispiel 2',
    'Lösungen:',
    'Lösung zeigen',
// sudoku.pas
    'Backtracking (brute force):',
    'Backtracking (brute force: Reihefolge der Zeilen optimiert):',
    'Backtracking (suche zunächst Zwangsbelegung):',
    'abgebrochen',
    'gelöst !!',
    ' Lösungen gefunden!!',
    'Logik:',
    'eindeutig bestimmte Werte suchen und setzen',
    'Möglichkeiten reduzieren',
    'Dubletten behandeln',
// sudoku.lfm
    'Sudoku - automatische und manuelle Lösungen',
    'Beispiel',
    'Backtracking (Brute Force)',
    'Backtracking (Brute Force opimiert)',
    'Backtracking (erst Zwangsbelegung)',
    'Logik-Test',
    'User Eingabe',
    'Zeige Zwangsbelegung',
    'zeige Hilfen',
    'verberge Hilfen',
    'aktualisiere Hilfe',
    'Initialisieren',
    'Leeres Feld',
    'manuellen Modus verlassen'
  );

procedure TranslationsFor_BackMain;
procedure TranslationsFor_n_Damen;
procedure TranslationsFor_springer;
procedure TranslationsFor_nikolaus;
procedure TranslationsFor_rundreise;
procedure TranslationsFor_zahlraet;
procedure TranslationsFor_AlgoInfo;
procedure TranslationsFor_RouteLee;
procedure TranslationsFor_rundweg;
procedure TranslationsFor_Rucksack;
procedure TranslationsFor_vierfarb;
procedure TranslationsFor_backtrackinfo;
procedure TranslationsFor_Labyrinth;
procedure TranslationsFor_solitaer;
procedure TranslationsFor_TFramePausenStrg(aFrame : TFrame);
procedure TranslationsFor_puzzle3x3;
procedure TranslationsFor_sudoku;

implementation 

uses solitaer, BackMain, n_Damen, springer, nikolaus, rundreise, zahlraet, 
AlgoInfo, RouteLee, rundweg, Rucksack, vierfarb, backtrackinfo, Labyrinth, 
pausensteuerung, puzzle3x3, sudoku;

procedure TranslationsFor_TFramePausenStrg(aFrame : TFrame);
begin
  with aFrame as TFramePausenStrg do
    begin
      LabelPausenLaenge.Caption := RSArr[rsPause256Ms];
      BitBtnBreak.Caption := RSArr[rsAbbruch];
      BitBtnPauseHalf.Caption := RSArr[rsHalbieren];
      BitBtnPauseDouble.Caption := RSArr[rsVerdoppeln];
      BitBtnPauseDefault.Caption := RSArr[rsVorgabe];
      BitBtnPauseNone.Caption := RSArr[rsKeine];
    end;  // with
end;  //TranslationsFor_TFramePausenStrg


procedure TranslationsFor_BackMain;
begin
  MainForm.Caption := RSArr[rsBacktrackingBeispiele];
  MainForm.Button1.Caption := RSArr[rsNDamenProblem];
  MainForm.Button2.Caption := RSArr[rsWegDesSpringers];
  MainForm.Button3.Caption := RSArr[rsProblemSalesmanA];
  MainForm.ButtonZahlenraetsel.Caption := RSArr[rsZahlenraetsel];
  MainForm.Button5.Caption := RSArr[rsHausVomNikolaus];
  MainForm.BitBtnBeenden.Caption := RSArr[rsSchliessen];
  MainForm.Button6.Caption := RSArr[rsRouterMitLee];
  MainForm.Button4.Caption := RSArr[rsProblemSalesmanB];
  MainForm.ButtonRucksack.Caption := RSArr[rsRucksackPacken];
  MainForm.ButtonVierfarb.Caption := RSArr[rsVierfarbenproblem];
  MainForm.BitBtnAbout.Caption := RSArr[rsProgrammInfo];
  MainForm.Button10.Caption := RSArr[rsLabyrinth];
  MainForm.ButtonSolitaer.Caption := RSArr[rsSolitaer];
  MainForm.ButtonSudoku.Caption := RSArr[rsSudoku];
end;  //TranslationsFor_BackMain

procedure TranslationsFor_n_Damen;
begin
  NDameForm.Caption := RSArr[rsNDamen];
  NDameForm.ButtonUndependent.Caption := RSArr[rsUnabhLoesungenBestimmen];
  NDameForm.ButtonNewTest.Caption := RSArr[rsNeuerTest];
  NDameForm.StaticText1.Caption := RSArr[rsAnzahlDamen];
  NDameForm.CheckBoxAlleLsgSuchen.Caption := RSArr[rsAlleLoesungenSuchen];
  NDameForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  NDameForm.ButtonStart.Caption := RSArr[rsStarten];
  NDameForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
end;  //TranslationsFor_n_Damen

procedure TranslationsFor_springer;
begin
  SpringerForm.Caption := RSArr[rsWegDesSpringers];
  SpringerForm.Label2.Caption := RSArr[rsStartPos];
  SpringerForm.Label3.Caption := RSArr[rsSpalteX];
  SpringerForm.Label4.Caption := RSArr[rsZeileY];
  SpringerForm.StaticText1.Caption := RSArr[rsGroesseSchachbretts];
  SpringerForm.CheckBoxAlleLsgSuchen.Caption := RSArr[rsAlleLoesungenSuchen];
  SpringerForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  SpringerForm.ButtonStart.Caption := RSArr[rsStarten];
  SpringerForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
end;  //TranslationsFor_springer

procedure TranslationsFor_nikolaus;
begin
  NikolausForm.Caption := RSArr[rsDasHausVomNikolaus];
  NikolausForm.Label2.Caption := RSArr[rsStartPos];
  NikolausForm.CheckBoxAlleLsgSuchen.Caption := RSArr[rsAlleLoesungenSuchen];
  NikolausForm.CheckBoxLinieNachfahren.Caption := RSArr[rsLinienNachfahren];
  NikolausForm.ButtonStart.Caption := RSArr[rsStarten];
  NikolausForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  NikolausForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
end;  //TranslationsFor_nikolaus

procedure TranslationsFor_rundreise;
begin
  TravelForm.Caption := RSArr[rsWegSalesmanA];
  TravelForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
  TravelForm.StaticText1.Caption := RSArr[rsAnzahlDerStaedte];
  TravelForm.RadioGroup1.Caption := RSArr[rsMethode];
  with TravelForm.RadioGroup1 do
    begin
      Items[0] := RSArr[rsTAMethode];
      Items[1] := RSArr[rsSAMethode];
      Items[2] := RSArr[rsVollstaendigeSuche];
    end;  // with
  TravelForm.SpeedButtonInputCities.Caption := RSArr[rsStaedteEingeben];
  TravelForm.SpeedButtonDistances.Caption := RSArr[rsEntfernungen];
  TravelForm.ButtonStart.Caption := RSArr[rsStarten];
end;  //TranslationsFor_rundreise

procedure TranslationsFor_zahlraet;
begin
  Zahlenraetsel.Caption := RSArr[rsZahlenraetsel];
  Zahlenraetsel.BitBtnBeenden.Caption := RSArr[rsBeenden];
  Zahlenraetsel.CheckBox1.Caption := RSArr[rsAlleLoesungenSuchen];
  Zahlenraetsel.CheckBox2.Caption := RSArr[rsOptimierteSuche];
  Zahlenraetsel.ButtonInput.Caption := RSArr[rsEingabe];
  Zahlenraetsel.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  Zahlenraetsel.ButtonStart.Caption := RSArr[rsStarten];
end;  //TranslationsFor_zahlraet

procedure TranslationsFor_AlgoInfo;
begin
  InfoForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
end;  //TranslationsFor_AlgoInfo

procedure TranslationsFor_RouteLee;
begin
  RouterForm.Caption := RSArr[rsRouterMitLeeAlgorithmus1];
  RouterForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
  RouterForm.StringGrid2.Hint  := RSArr[rsVerbindungenMarkieren];
  RouterForm.Label2.Caption := RSArr[rsAnzahlPunkteAuswahl];
  RouterForm.Label3.Caption := RSArr[rsAnzahlVerbindungen];
  RouterForm.SpeedButtonInput.Caption := RSArr[rsEingabe];
  RouterForm.CheckBoxAlleLsg.Caption := RSArr[rsAlleLoesungenSuchen];
  RouterForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  RouterForm.ButtonRandomExample.Caption := RSArr[rsZufallsbeispiel];
  RouterForm.CheckBoxUseLee.Caption := RSArr[rsLeeAlgorithmus];
  RouterForm.ButtonStart.Caption := RSArr[rsStarten];
end;  //TranslationsFor_RouteLee

procedure TranslationsFor_rundweg;
begin
  RundwegForm.Caption := RSArr[rsWegSalesmanB];
  RundwegForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
  RundwegForm.StringGrid2.Hint  := RSArr[rsEntfernungenEingeben];
  RundwegForm.SpeedButtonInputCities.Caption := RSArr[rsStaedteEingeben];
  RundwegForm.SpeedButtonDistances.Caption := RSArr[rsEntfernungen];
  RundwegForm.StaticText1.Caption := RSArr[rsAnzahlDerStaedte];
  RundwegForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  RundwegForm.ButtonStart.Caption := RSArr[rsStarten];
end;  //TranslationsFor_rundweg

procedure TranslationsFor_Rucksack;
begin
  RucksackForm.Caption := RSArr[rsRucksack];
  RucksackForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
  RucksackForm.StringGrid2.Hint  := RSArr[rsEntfernungenEingeben];
  RucksackForm.SpeedButtonInputParts.Caption := RSArr[rsTeileEingeben];
  RucksackForm.StaticText1.Caption := RSArr[rsAnzahlDerTeile];
  RucksackForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  RucksackForm.StaticText2.Caption := RSArr[rsGesamtgewicht];
  RucksackForm.ButtonStart.Caption := RSArr[rsStarten];
end;  //TranslationsFor_Rucksack

procedure TranslationsFor_vierfarb;
begin
  VierFarbForm.Caption := RSArr[rsVierFarb];
  VierFarbForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
  VierFarbForm.SpeedButtonNewInput.Caption := RSArr[rsNeueEingabe];
  VierFarbForm.SpeedButton4NewCountries.Caption := RSArr[rsVierLaender];
  VierFarbForm.StaticText1.Caption := RSArr[rsAnzahlDerLaender];
  VierFarbForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  VierFarbForm.ButtonAddCountry.Caption := RSArr[rsLandZufuegen];
  VierFarbForm.ButtonRemoveCountry.Caption := RSArr[rsLandEntfernen];
  VierFarbForm.ButtonStart.Caption := RSArr[rsStarten];
end;  //TranslationsFor_vierfarb

procedure TranslationsFor_backtrackinfo;
begin
  AboutBox.Caption := RSArr[rsInfo];
  AboutBox.Version.Caption := RSArr[rsVersion];
  AboutBox.Comments.Caption := RSArr[rsDemosZuBacktrack];
  AboutBox.OKButton.Caption := RSArr[rsOK];
end;  //TranslationsFor_backtrackinfo

procedure TranslationsFor_Labyrinth;
begin
  LabyForm.Caption := RSArr[rsLabyrinth];
  labyForm.LabelWeg.Caption:=RSArr[rsWeglaenge];
  LabyForm.Label1.Caption := RSArr[rsStartPos];
  LabyForm.Label4.Caption := RSArr[rsAusgang];
  LabyForm.Label11.Caption := RSArr[rsStartrichtung];
  LabyForm.RadioGroup1.Caption := RSArr[rsVerfahren];
  with LabyForm.RadioGroup1 do
    begin
      Items[0] := RSArr[rsBacktrackingGeradeaus];
      Items[1] := RSArr[rsBacktrackingErstRechts];
      Items[2] := RSArr[rsBacktrackingZufaellig];
      Items[3] := RSArr[rsLeeAlgorithmus];
    end;  // with
  LabyForm.CheckBoxBestLsg.Caption := RSArr[rsBesteLoesungSuchen];
  LabyForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  LabyForm.Label7.Caption := RSArr[rsHindernisLinksZiehen];
  LabyForm.Label8.Caption := RSArr[rsFreiesFeldRechtsZiehen];
  LabyForm.Label9.Caption := RSArr[rsStartDoppelclickFreiesFeld];
  LabyForm.Label10.Caption := RSArr[rsAusgangDoppelclickHindernis];
  LabyForm.ButtonStart.Caption := RSArr[rsStarten];
  LabyForm.ButtonNeuStart.Caption := RSArr[rsNeuStart];
  LabyForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
end;  //TranslationsFor_Labyrinth

procedure TranslationsFor_solitaer;
begin
  FormSolitaer.Caption := RSArr[rsSolitaer];
  FormSolitaer.BitBtnBeenden.Caption := RSArr[rsBeenden];
  with FormSolitaer.ComboBoxVerfahren do
    begin
      Items[0] := RSArr[rsBruteForceRekursiv];
      Items[1] := RSArr[rsBruteForceOptimiert];
      Items[2] := RSArr[rsBruteForceIterativ];
      Items[3] := RSArr[rsBruteForceMitFilter1];
      Items[4] := RSArr[rsBruteForceMitFilter2];
      Items[5] := RSArr[rsBruteForceBeideFilter];
      Text  := RSArr[rsBruteForceRekursiv];
    end;  // with
  FormSolitaer.ComboBoxBrettNumerierung.Items[0] := RSArr[rsNormal];
  with FormSolitaer.ComboBoxBrettNumerierung do
    begin
      Items[1] := RSArr[rsSpiralfoermig];
      Items[2] := RSArr[rsBlockweise];
      Text  := RSArr[rsNormal];
    end;  // with
  FormSolitaer.ComboBoxReihenfolge.Items[0] := RSArr[rsRechtsObenLinksUnten];
  with FormSolitaer.ComboBoxReihenfolge do
    begin
      Items[1] := RSArr[rsObenLinksUntenRechts];
      Items[2] := RSArr[rsLinksUntenRechtsOben];
      Items[3] := RSArr[rsUntenRechtsObenLinks];
      Text  := RSArr[rsRechtsObenLinksUnten];
    end;  // with
  FormSolitaer.CheckBoxAll.Caption := RSArr[rsAlleLoesungenSuchen];
  FormSolitaer.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  FormSolitaer.Label1.Caption := RSArr[rsMethode];
  FormSolitaer.Label2.Caption := RSArr[rsReihenfolge];
  FormSolitaer.Label3.Caption := RSArr[rsZaehlung];
  FormSolitaer.Label4.Caption := RSArr[rsAusgangsbelegung];
  FormSolitaer.LabelTestet.Caption := RSArr[rsGetestet];
  FormSolitaer.ButtonErgebnis.Caption := RSArr[rsErgebnis];
  FormSolitaer.ButtonAbbruchUndSpeichern.Caption := RSArr[rsAbbruchSpeichern];
  FormSolitaer.ButtonZeigeZwischenStand.Caption := RSArr[rsZeigeZwischenstand];
  FormSolitaer.ButtonZeigeZugFolge.Caption := RSArr[rsZeigeZugFolge];
  FormSolitaer.ButtonZugZurueck.Caption := RSArr[rsZugZuruecknehmen];
  FormSolitaer.ButtonManuell.Caption := RSArr[rsManuell];
  FormSolitaer.ButtonAutoPlay.Caption := RSArr[rsStarten];
end;  //TranslationsFor_solitaer

procedure TranslationsFor_puzzle3x3;
begin
  PuzzleForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
  PuzzleForm.CheckBoxAlleLsg.Caption := RSArr[rsAlleLoesungenSuchen];
  PuzzleForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  PuzzleForm.BitBtnStart.Caption := RSArr[rsStarten];
  PuzzleForm.ToggleBox1.Caption := RSArr[rsUmschaltenDunkelhell];
  PuzzleForm.ToggleBoxBsp.Caption := RSArr[rsBeispiel2];
  PuzzleForm.PanelZeigLsg.Caption := RSArr[rsLoesungen];
  PuzzleForm.BitBtnZeigLsg.Caption := RSArr[rsLoesungZeigen];
end;  //TranslationsFor_puzzle3x3

procedure TranslationsFor_sudoku;
begin
  SudokuForm.Caption := RSArr[rsSudokuLoesungen];
  SudokuForm.BitBtnBeenden.Caption := RSArr[rsBeenden];
  SudokuForm.ButtonBeispiel.Caption := RSArr[rsBeispiel];
  SudokuForm.RadioGroupMethode.Caption := RSArr[rsMethode];
  with SudokuForm.RadioGroupMethode do
    begin
      Items[0] := RSArr[rsBacktrackingBruteForce1];
      Items[1] := RSArr[rsBacktrackingBruteForceOpimiert];
      Items[2] := RSArr[rsBacktrackingerstZwangsbelegung1];
      Items[3] := RSArr[rsLogikTest];
      Items[4] := RSArr[rsUserEingabe];
    end;  // with
  SudokuForm.BitBtnStart.Caption := RSArr[rsStarten];
  SudokuForm.CheckBoxZwischenSchritt.Caption := RSArr[rsZwischenschritteZeigen];
  SudokuForm.CheckBoxAlleLsgSuchen.Caption := RSArr[rsAlleLoesungenSuchen];
  SudokuForm.BitBtnNeuStart.Caption := RSArr[rsNeuStart];
  SudokuForm.ButtonZeigeZwang.Caption := RSArr[rsZeigeZwangsbelegung];
  SudokuForm.ButtonZeigeHilfe.Caption := RSArr[rsZeigeHilfen];
  SudokuForm.ButtonVersteckeHilfe.Caption := RSArr[rsVerbergeHilfen];
  SudokuForm.ButtonAktualisiereHilfe.Caption := RSArr[rsAktualisiereHilfe];
  SudokuForm.ButtonInit.Caption := RSArr[rsInitialisieren];
  SudokuForm.ButtonLeeresFeld.Caption := RSArr[rsLeeresFeld];
  SudokuForm.BitBtnEndUserModus.Caption := RSArr[rsManuellenModusVerlassen];
end;  //TranslationsFor_sudoku



procedure LadeSprachElemente;
var k      : integer;
  s, datei : string;
  f        : textFile;
begin
  datei:=ExtractFilePath(Application.ExeName);
  datei:=datei+sprachFile;
  if not FileExists(datei) then exit;
  k:=0;
  try
    AssignFile(f,datei);
    Reset(f);
    while not EOF(f) and (k<=lastEntry) do 
      begin
        ReadLn(f,s);
        if pos('//',s)<>1 then
          begin
            RSArr[k]:=s;
            k:=k+1;
          end;
      end;
    Close(f);
    while (k<=lastEntry) do
      begin
        RSArr[k]:='.. ?';
        k:=k+1; 
      end;
  finally
  end;
end;


begin
  LadeSprachElemente;
end.
