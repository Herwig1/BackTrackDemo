unit puzzle3x3;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Puzzle 3x3
   Autor:   H. Niemeyer  (c) 2023
   Version: 1.1

   letzte Änderung: 15.12.2023 *)

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Grids, Buttons, StdCtrls, Spin,
  BildSchirmAnpassung, pausensteuerung, puzzleDef, puzzleDragUnit, BackTrackDemo_Sprache;

type

  { TPuzzleForm }

  TPuzzleForm = class(TForm)
    BitBtnZeigLsg: TBitBtn;
    BitBtnBeenden: TBitBtn;
    BitBtnStart: TBitBtn;
    CheckBoxAlleLsg: TCheckBox;
    CheckBoxZwischenSchritt: TCheckBox;
    DrawGridStart: TDrawGrid;
    DrawGridPuzzle: TDrawGrid;
    FramePausenStrg1: TFramePausenStrg;
    LabelTries: TLabel;
    LabelAnzLsg: TLabel;
    Panel1: TPanel;
    PanelZeigLsg: TPanel;
    PanelBeenden: TPanel;
    PanelInfo: TPanel;
    PanelStart: TPanel;
    PanelLinks: TPanel;
    PanelRechts: TPanel;
    SpinEditSolveNr: TSpinEdit;
    StringGridAblauf: TStringGrid;
    ToggleBox1: TToggleBox;
    ToggleBoxBsp: TToggleBox;
    procedure BitBtnStartClick(Sender: TObject);
    procedure BitBtnZeigLsgClick(Sender: TObject);
    procedure CheckBoxZwischenSchrittClick(Sender: TObject);
    procedure DrawGridPuzzleDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DrawGridPuzzleDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DrawGridPuzzleDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGridPuzzleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGridPuzzleStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure DrawGridStartDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DrawGridStartDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DrawGridStartDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGridStartStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PanelBeendenResize(Sender: TObject);
    procedure PanelInfoResize(Sender: TObject);
    procedure PanelLinksResize(Sender: TObject);
    procedure ToggleBox1Click(Sender: TObject);
    procedure ToggleBoxBspClick(Sender: TObject);
  private
    imageSize       : integer;
    aktPuzzleBsp    : TPuzzleTeile;
    orgBilderListe  : TPuzzleBilder;
    bilderListe     : TPuzzleBilder;
    aktPos          : array[0..puzzleSize-1] of integer;
    belegt          : array[0..puzzleSize-1] of boolean;
    BildInLsgGrid,
    manuell         : boolean;
    lastNr, lastSol : integer;
    myPuzzle        : TPuzzle;
    mySolver        : TSolver;
    FDragObject     : TMyDragObject;
    fManuLsg        : TManuLsg;
    procedure MoveBildToPuzzle(bildNr, puzzlePosition :integer;nachQuadrat:boolean);
    procedure ResetGrids(alle:boolean);
    procedure RotateBildUm(bildNr, rotation: integer);
    procedure ShowSolution(nr:integer);
    procedure Undo;
  public
    procedure ShowRemoveBackTrack;
    procedure ShowSetBackTrack(k: integer; aktPiece : TPlaced_piece);
  end;

var
  PuzzleForm: TPuzzleForm;

implementation

{$R *.lfm}

{ TPuzzleForm }

procedure TPuzzleForm.BitBtnStartClick(Sender: TObject);
var k : integer;
begin
  panelZeigLsg.visible:=false;
  LabelAnzLsg.Caption:='';
  PanelBeenden.Enabled:=false;
  ResetGrids(true);
  PanelStart.Visible:=false;
  FramePausenStrg1.NormalStart;
  manuell:=false;
  labelTries.Caption:='';
  if myPuzzle<>nil then myPuzzle.Free;;
  myPuzzle:=TPuzzle.create(aktPuzzleBsp);
  if mySolver<>nil then mySolver.Free;
  mySolver:=TSolver.Create(myPuzzle);
  mySolver.SolvePuzzleAnimation(CheckBoxAlleLsg.checked);

  FramePausenStrg1.Visible:=false;
  PanelStart.Visible:=true;
  if not Abbruch then
    if mySolver.solutions=nil
      then begin
             BildInLsgGrid:=false;
           end
      else begin
             k:=Length(mySolver.solutions);
             SpinEditSolveNr.MaxValue:=k;
             SpinEditSolveNr.Value:=1;
             SpinEditSolveNr.Enabled:=(k>1);
             if k=1
               then LabelAnzLsg.Caption:=RSArr[rsEineLsg]
               else LabelAnzLsg.Caption:=IntToStr(k)+RSArr[rsLoesungenGefunden];
             BitBtnZeigLsgClick(nil);
             LabelTries.Caption:=IntToStr(mySolver.total_tries);
           end;
  panelZeigLsg.visible:=not abbruch;
  PanelBeenden.Enabled:=true;
  manuell:=true;
end;

procedure TPuzzleForm.BitBtnZeigLsgClick(Sender: TObject);
var nr : integer;
begin
  if lastSol>=0 then
    begin
      bilderListe.Assign(orgBilderListe);
      ResetGrids(zeigen or not BildInLsgGrid);
    end;
  nr:=SpinEditSolveNr.Value;
  showSolution(nr);
end;

procedure TPuzzleForm.CheckBoxZwischenSchrittClick(Sender: TObject);
begin
  FramePausenStrg1.SetZwischenSchritt(CheckBoxZwischenSchritt.Checked);
end;

procedure TPuzzleForm.DrawGridPuzzleDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var posNr, aCol, aRow  : integer;
    altPos, bildNr, r  : integer;
    schiebeImPuzzle    : boolean;
begin
  if FDragObject.Control is TDrawGrid then
    begin
      DrawGridPuzzle.MouseToCell(X, Y, ACol, ARow);
      posNr:= puzzleFeldNr[aCol,aRow];
      bildNr:=FDragObject.BildNr;
      r:=FDragObject.Rot;
      altPos:=FDragObject.QPos;
      schiebeImPuzzle := (altPos>=0);
      if schiebeImPuzzle
        then MoveBildToPuzzle(-1, altPos, false);
      MoveBildToPuzzle(bildNr, posNr, true);
      if r>0 then
        begin
          fManuLsg.lsgArr[fManuLsg.last].rot:=r;
          stringGridAblauf.Cells[posNr+1,1]:=IntToStr(90*r);
          if schiebeImPuzzle then bilderListe.bilder[bildnr].rot:=r;
        end;
      DrawGridPuzzle.Col:=aCol;
      DrawGridPuzzle.Row:=aRow;
    end;
end;

procedure TPuzzleForm.DrawGridPuzzleDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var posNr,aCol,aRow : integer;
begin
  DrawGridPuzzle.MouseToCell(X, Y, ACol, ARow);
  posNr:= puzzleFeldNr[aCol,aRow];
  if aktPos[posNr]>=0
    then  Accept := false
    else  Accept := (Source is TMyDragObject);
end;

procedure TPuzzleForm.DrawGridPuzzleDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var posNr : integer;
begin
  posNr:= puzzleFeldNr[aCol,aRow];
  if aktPos[posNr]>=0 then
      bilderListe.Draw(DrawGridPuzzle, aRect.Left, aRect.top, aktPos[posNr]);
end;

procedure TPuzzleForm.DrawGridPuzzleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var aCol, aRow, posNr, neuRot, inLsgNr : integer;
    data : TPlaced_piece;
begin
  if button<>mbRight then exit;
  DrawGridPuzzle.MouseToCell(X, Y, ACol, ARow);
  posNr:= puzzleFeldNr[ACol, ARow];
  if aktPos[posNr]>=0 then
    begin
      inLsgNr:=fManuLsg.GetPosInManuLsg(posNr);
      data:=fManuLsg.lsgArr[inLsgNr];
      neuRot:=(data.rot + 1) mod 4;
      fManuLsg.lsgArr[inLsgNr].rot:=neuRot;
      bilderListe.bilder[data.idx].edges:=orgBilderListe.bilder[data.idx].edges;
      if neuRot=0
        then bilderListe.bilder[data.idx].DrawBild
        else bilderListe.bilder[data.idx].Rotate(neuRot);
      stringGridAblauf.Cells[data.platzNr+1,1]:=IntToStr(90*neuRot);
      DrawGridPuzzle.repaint;
      stringGridAblauf.repaint;
    end;
end;

procedure TPuzzleForm.DrawGridPuzzleStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var p                 : TPoint;
    ACol, ARow, posNr : integer;
    aktImage          : TImage;
    tmp               : TPlaced_piece;
begin
   if not manuell then exit;
   p:=DrawGridPuzzle.ScreenToClient(mouse.cursorpos);
   DrawGridPuzzle.MouseToCell(p.X, p.Y, ACol, ARow);
   posNr:= puzzleFeldNr[aCol,aRow];
   if (aktPos[posNr]>=0)
     then begin
            tmp:=fManuLsg.GetLsgDataByPos(posNr);
            if Assigned(FDragObject) then FDragObject.Free;
            FDragObject := TMyDragObject.Create(DrawGridPuzzle);
            aktImage:=BilderListe.bilder[aktPos[posNr]].bild;
            FDragObject.StartDrag(aktImage.Picture.Graphic,p, tmp.idx,tmp.rot,posNr);
          end
     else begin
            if Assigned(FDragObject) then FDragObject.Free;
            FDragObject:=nil;
          end;
  DragObject := FDragObject;
end;

procedure TPuzzleForm.DrawGridStartDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var bildNr, posNr : smallInt;
begin
  if FDragObject.Control is TDrawGrid then
    if  TDrawGrid(FDragObject.Control)=DrawGridPuzzle then
    begin
      bildNr:=FDragObject.BildNr;
      posNr:=0;
      while aktPos[posNr]<>bildNr do inc(posNr);
      MoveBildToPuzzle(-1, posNr,false);
    end;
end;

procedure TPuzzleForm.DrawGridStartDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var nr,k,aCol,aRow : integer;
begin
   DrawGridStart.MouseToCell(X, Y, ACol, ARow);
   if not odd(aCol) then
     begin
       nr:=aCol div 2;
       for k:=0 to high(aktPos) do
         if aktPos[k]=nr
           then begin Accept := Source is TMyDragObject; exit; end;
     end;
   Accept := false;
end;

procedure TPuzzleForm.DrawGridStartDrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var nr, k : integer;
begin
  if not odd(aCol) then
    begin
      nr:=aCol div 2;
      for k:=0 to high(aktPos) do
        if aktPos[k]=nr then exit;
      bilderListe.Draw(DrawGridStart, aRect.Left, aRect.top, nr mod puzzleSize);;
    end;
end;

procedure TPuzzleForm.DrawGridStartStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
 p              : TPoint;
 nr, ACol, ARow : integer;
 aktImage       : TImage;
begin
  if not manuell then exit;
  p:=DrawGridStart.ScreenToClient(mouse.cursorpos);
  DrawGridStart.MouseToCell(p.X, p.Y, ACol, ARow);
  nr:= ACol div 2;
  if (nr*2 = ACol) and (not belegt[nr]) then
    begin
      if Assigned(FDragObject) then FDragObject.Free;
      FDragObject := TMyDragObject.Create(DrawGridStart);
      aktImage:=BilderListe.bilder[nr].bild;
      FDragObject.StartDrag(aktImage.Picture.Graphic, p, nr, 0, -1);
    end
  else begin
         if Assigned(FDragObject) then FDragObject.Free;
         FDragObject:=nil;
      end;
  DragObject := FDragObject;
end;

procedure TPuzzleForm.FormActivate(Sender: TObject);
begin
  FramePausenStrg1.FrameResize(nil);
  FramePausenStrg1.Init(checkBoxZwischenSchritt,false);
  TranslationsFor_puzzle3x3;
  manuell:=true;
  labelTries.Caption:='';
end;

procedure TPuzzleForm.FormCreate(Sender: TObject);
begin
  SkaliereForm(self);
  aktPuzzleBsp := startPuzzle;
  orgBilderListe  := TPuzzleBilder.Create;
  bilderListe     := TPuzzleBilder.Create;
  fManuLsg := TManuLsg.Create;
  fManuLsg.clear;
  ResetGrids(true);
  StringGridAblauf.ColWidths[0]:=60;
  StringGridAblauf.Cells[0,0]:=RSArr[rsTeileNr];
  StringGridAblauf.Cells[0,1]:=RSArr[rsDrehung];
end;

procedure TPuzzleForm.FormDestroy(Sender: TObject);
begin
  fManuLsg.free;
  bilderListe.Free;
  orgBilderListe.Free;
  mySolver.Free;
  myPuzzle.free;
  if Assigned(FDragObject) then FDragObject.Free;
end;

procedure TPuzzleForm.MoveBildToPuzzle(bildNr, puzzlePosition: integer; nachQuadrat:boolean);
var nr : smallInt;
begin
  if nachQuadrat
    then begin
           aktPos[puzzlePosition]:=bildNr;
           fManuLsg.Add(bildNr, puzzlePosition);
           belegt[bildNr]:=true;
           stringGridAblauf.Cells[puzzlePosition+1,1]:=IntToStr(90*fManuLsg.LastRot);
           stringGridAblauf.Cells[puzzlePosition+1,0]:=IntToStr(bildNr);
         end
    else begin
           if bildNr=-10
             then nr:=fManuLsg.Last
             else nr:=fManuLsg.GetPosInManuLsg(puzzlePosition);
           bildNr:=fManuLsg.lsgArr[nr].idx;
           belegt[BildNr]:=false;
           fManuLsg.Remove(nr);
           bilderListe.RestorePuzzleBild(bildNr, orgBilderListe);
           aktPos[puzzlePosition]:=-1;
           stringGridAblauf.Cells[puzzlePosition+1,0]:='';
           stringGridAblauf.Cells[puzzlePosition+1,1]:='';
         end;
  DrawGridStart.repaint;
  DrawGridPuzzle.repaint;
  stringGridAblauf.Repaint;
  application.ProcessMessages;
end;

procedure TPuzzleForm.PanelBeendenResize(Sender: TObject);
begin
  BitBtnBeenden.Left:=(PanelBeenden.ClientWidth-BitBtnBeenden.Width) div 2;
end;

procedure TPuzzleForm.PanelInfoResize(Sender: TObject);
begin
  StringGridAblauf.Left:= (PanelInfo.ClientWidth-StringGridAblauf.Width) div 2;
  labelTries.Left:=(PanelInfo.ClientWidth-LabelTries.Width) div 2;
end;

procedure TPuzzleForm.PanelLinksResize(Sender: TObject);
var breite, w, h, k : integer;
begin
  breite:=PanelLinks.ClientWidth;
  w:=(breite - 8*DrawGridStart.DefaultColWidth -DrawGridStart.ColCount*DrawGridStart.GridLineWidth) div 9;
  w:=(w div 2)*2+1;
  h:=w;
  DrawGridStart.Height:=h+4;
  DrawGridStart.DefaultRowHeight:=h;
  for k:=0 to 8 do
    DrawGridStart.ColWidths[k*2]:=w;

  DrawGridPuzzle.DefaultColWidth:=w;
  DrawGridPuzzle.DefaultRowHeight:=w;
  DrawGridPuzzle.Width:=3*w+4+DrawGridPuzzle.GridLineWidth;
  DrawGridPuzzle.Height:=DrawGridPuzzle.Width;
  DrawGridPuzzle.Left:=(Panel1.Width-DrawGridPuzzle.Width) div 2;
  if w<>imageSize then
    begin
      imageSize:=w;
      SetBildSize(w);
      orgBilderListe.NeuZeichnen;
      bilderListe.NeuZeichnen;
      DrawGridStart.Repaint;
    end;
end;

procedure TPuzzleForm.ToggleBox1Click(Sender: TObject);
begin
  if ToggleBox1.Checked
    then setHG(clWhite)
    else setHG(clBlack);
  bilderListe.NeuZeichnen;
  orgBilderListe.NeuZeichnen;
  DrawGridStart.Repaint;
  DrawGridPuzzle.Repaint;
end;

procedure TPuzzleForm.ToggleBoxBspClick(Sender: TObject);
begin
  if ToggleBoxBsp.Checked
    then aktPuzzleBsp:=beispiel2
    else aktPuzzleBsp:=startPuzzle;
  orgBilderListe.ChangeBilder(aktPuzzleBsp);
  bilderListe.Assign(orgBilderListe);
  PanelZeigLsg.Visible:=false;
  ResetGrids(true);
end;

procedure TPuzzleForm.ResetGrids(alle:boolean);
var j : integer;
begin
  for j:=1 to 9 do
    begin
      stringGridAblauf.cells[j,0]:='';
      stringGridAblauf.cells[j,1]:='';
    end;
  lastNr:=0;
  if alle then
    begin
      for j:=0 to puzzleSize-1 do
        begin
          aktPos[j]:=-1;
          belegt[j]:=false;
        end;
      BildInLsgGrid:=false;
    end
  else for j:=0 to puzzleSize-1 do
         begin
           aktPos[j]:=j;
           belegt[j]:=true;
         end;

  DrawGridStart.Repaint;
  DrawGridPuzzle.Repaint;
  stringGridAblauf.Repaint;
  application.ProcessMessages;
end;

procedure TPuzzleForm.RotateBildUm(bildNr, rotation: integer);
begin
  rotation:= rotation mod NUM_ORIENTATIONS;
  if rotation=0 then exit;
  bilderListe.bilder[bildnr].Rotate(rotation);
  DrawGridPuzzle.repaint;
  Application.ProcessMessages;
end;

procedure TPuzzleForm.ShowRemoveBackTrack;
begin
  Undo;
  kurzePause(5);
  BildInLsgGrid:=false;
end;

procedure TPuzzleForm.ShowSetBackTrack(k: integer; aktPiece : TPlaced_piece);
var j : integer;
begin
  if k=0 then fManuLsg.Clear;
  MoveBildToPuzzle(aktPiece.idx, k, true);
  fManuLsg.lsgArr[k].rot:=aktPiece.rot;
  CheckPause;
  stringGridAblauf.Cells[k+1,1]:=IntToStr(aktPiece.rot*90);
  for j:=1 to aktPiece.rot do
     begin
       RotateBildUm(aktPiece.idx, 1);
       kurzePause(3);
     end;
  application.ProcessMessages;
  BildInLsgGrid:=(k=PuzzleSize);
end;

procedure TPuzzleForm.ShowSolution(nr: integer);
var aktSolution : TSolution;
    aktPiece    : TPlaced_piece;
    k, j        : integer;
begin
  if (nr>Length(mySolver.solutions)) or (nr<1) then exit;
  fManuLsg.Clear;
  lastNr:=0;
  lastSol:=nr-1;
  aktSolution:=mySolver.GetSolution(nr-1);

  for k:=0 to puzzleSize-1 do
    begin
      aktPiece:=aktSolution[k];
      stringGridAblauf.Cells[aktPiece.platzNr+1,0]:=IntToStr(aktPiece.idx);
      if zeigen
        then begin
               MoveBildToPuzzle(aktPiece.idx, aktPiece.platzNr, true);
               Delay(500);
             end
        else aktPos[aktPiece.platzNr]:=aktPiece.idx;
      stringGridAblauf.Cells[aktPiece.platzNr+1,1]:=IntToStr(aktPiece.rot*90);
      if zeigen
        then
          for j:=1 to aktPiece.rot do
            begin
              RotateBildUm(aktPiece.idx, 1);
              Delay(100)
             end
        else RotateBildUm(aktPiece.idx, aktPiece.rot);
      fManuLsg.Add(aktPiece.idx,aktPiece.platzNr);
      fManuLsg.lsgArr[k].rot:=aktPiece.rot;
      application.ProcessMessages;
    end;
  BildInLsgGrid:=true;
end;

procedure TPuzzleForm.Undo;
var posNr : smallInt;
begin
  posNr:= fManuLsg.LastPlatzNr;
  if posNr<0 then exit;
  MoveBildToPuzzle(-10, posNr,false);
end;


end.

