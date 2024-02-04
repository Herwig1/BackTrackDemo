unit puzzleDef;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Definitionen und Hilfsobjekte zu Puzzle 3x3
   Autor:   H. Niemeyer  (c) 2023
   Version: 1.0

   letzte Änderung: 17.11.2023 *)

interface

uses
  Classes, SysUtils, Types, Forms, Graphics, Grids, ExtCtrls,
  pausensteuerung;    // abbruch

const puzzleSize = 3*3;
      NUM_ORIENTATIONS = 4;
      NUM_EDGES = 4;   	   //  Names and values for the four edges of each piece.
      topEdge   = 0;
      rightEdge = 1;
      bottomEdge= 2;
      leftEdge  = 3;
      Directions : array[0..puzzleSize-1] of byte =
                      (rightEdge, leftEdge, topEdge, rightEdge, rightEdge, bottomEdge, bottomEdge, leftEdge, leftEdge);

 //     all_pieces : array[0..puzzleSize-1] of byte = (0, 1, 2, 3, 4, 5, 6, 7, 8);
      puzzleFeldNr: array[0..2,0..2] of smallInt = ( (6,5,4),(7,0,3),(8,1,2));
      orgBmSize   = 120;


type TPlaced_piece = record
                       idx : smallInt; // The piece's index into the array with information about every piece.
		       rot : smallInt; // The correct orientation of the piece.
                       platzNr : smallInt;    // position in puzzle
		     end;

     TPiece         = array[0..NUM_EDGES-1] of smallInt;
     TStartPieces   = array of TPiece;
     TPuzzleTeile   = array[0..puzzleSize-1] of TPiece;
     TPuzzleTeilArr = array of TPuzzleTeile;
     TSolution      = array[0..puzzleSize-1] of TPlaced_piece;
     TSolutionList  = array of TSolution;
     TPuzzleNumArr  = array[0..puzzleSize] of word;

 const
    startPuzzle : TPuzzleTeile = ( ( 3,-4,-2, 1), (-2, 4,-1, 3), ( 2, 4,-1,-3),
                                   ( 3,-2,-1, 4), ( 3, 1,-4,-2), ( 2,-1, 4,-3),
                                   ( 4,-3, 1,-2), ( 1, 2,-3,-4), (-3,-4, 1, 2) );

    Beispiel2   : TPuzzleTeile = ( ( 3, 2,-1,-4), ( 3,-2, 4,-1), ( 1, 3,-4,-2),
                                   (-3, 4, 2,-1), (-1,-4, 2, 3), ( 4,-2, 1,-3),
                                   ( 2,-3,-4, 1), (-1,-2, 4, 3), ( 2,-3,-1, 4) );

    noPiece : TPlaced_piece =(idx:-1; rot:0; platzNr:-1);

type
  TEinzelBild = class(TObject)
    bild  : TImage;
    edges : TPiece;
    rot   : integer;
    procedure Assign(aBild:TEinzelBild); virtual;
    constructor Create;                  virtual;
    procedure DrawBild;
    procedure Free; virtual;
    procedure Rotate(aRot:integer);
    procedure ZeichneBM(aDrawGrid: TDrawGrid; x,y : integer);
  end;

  { TPuzzleBilder }

  TPuzzleBilder =  class(TObject)
    bilder : array[0..puzzleSize-1] of TEinzelBild;
    procedure Assign(aListe:TPuzzleBilder);  virtual;
    procedure ChangeBilder(neuBilder:TPuzzleTeile);
    constructor Create;                      virtual;
    procedure Draw(aDrawGrid: TDrawGrid; x, y, nr:integer);
    procedure Free; virtual;
    procedure NeuZeichnen;
    procedure RestorePuzzleBild(nr:integer; orgBilder:TPuzzleBilder);
  end;

   TManuLsg = class(TObject)
      last : smallInt;
      lsgArr : array[0..puzzleSize-1] of TPlaced_piece;
      procedure Clear;
      procedure Add(aBildNr,aPlatzNr:byte);
      function GetLsgDataByBild(bildNr:integer):TPlaced_piece;
      function GetLsgDataByPos(posNr:integer):TPlaced_piece;
      function GetPosInManuLsg(posNr:integer):integer;
      function LastBildNr:smallInt;
      function LastRot:smallInt;
      function LastPlatzNr:smallInt;
      procedure Remove(nr:smallInt);
  end;


   { siehe c't 17/2023 Seite 130 ff.
      When the solver tries to place a piece this data is needed to check if the piece will fit.
      see `TPuzzle::will_fit()`}
type
     TPieceToPlace = record
        piece : TPiece;    // The edge data of the original piece
        rot   : integer;   // Will it fit with this orientation?
        edge  : integer;   // Will this edge fit?
       end;

  // This class represents a 3x3 Scramble Square™️ puzzle.

    { TPuzzle }
    TPuzzle =  class(TObject)
       {  An array with the 9 pieces of the puzzle.
          This array represents the raw puzzle pieces. Neither the
          order nor the correct orientation of the puzzle is known.  }
        fPieces : TPuzzleTeile;

        { This array will contain the solution of the puzzle if one could be found.
          For each piece in the original array `pieces_` this array
          contains its index and correct orientation.      }
         fSolution : TSolution;
    private
      function will_edge_fit( a, b : TPieceToPlace ): boolean;
    public
      constructor Create(myPieces:TPuzzleTeile);
      function solution(k:integer) : TPlaced_piece;
      function GetSolution:TSolution;
      procedure place_piece_at(k:integer; const piece : TPlaced_piece );
      function idx(i:integer) : integer;
      function rot(i:integer) : integer;
      function will_fit(k, current_piece_idx, rot0 : integer) : boolean;
    end;

    {   siehe c't 17/2023 Seite 130 ff.
        Solver for any 3x3 Scramble Square™? puzzle.

          The solver places the first piece in the center because it doesn't
          need to be rotated; rotating it will rotate the entire puzzle.
          The next piece is placed to the right of the first, the following
          in a clockwise spiral around the center.
          For every piece all of the four possible orientations are tested.
          If it fits the solver goes a level deeper and the process
          repeats with the remaining pieces until all pieces are placed.
          If it doesn't fit the next available piece is chosen. }

type
     indexArray = array of byte;

     { TSolver }

     TSolver = class
                 fPieces    : TPuzzle;
    		 fSolutions : TSolutionList;
                 num_calls_at_level_ : TPuzzleNumArr;
                private
                  lsgGefunden, alleLsgSuchen : boolean;
                  procedure solveAnimation(k:integer; current_puzzle:TPuzzle;available_pieces : indexArray);
                public
                  constructor Create(aPuzzle:TPuzzle);
                  function GetSolution(nr:integer):TSolution;
                  procedure SetShowForm(aForm:TForm);
                  function solutions: TSolutionList;
                  procedure SolvePuzzleAnimation(suchAlle:boolean);
                  function total_tries : integer;
    	          function tries_at_level: TPuzzleNumArr;
                end;


function setHG(aFarbe:TColor):boolean;
procedure SetBildSize(mySize:integer);

implementation

uses puzzle3x3;

type
   TPolygon =  Array of TPoint;

const
   farbe : array[0..NUM_EDGES] of TColor = (  TColor($FFFFFD), clRed, clBlue, clYellow, clGreen );

var BGColor : TColor = clBlack;
    bmSize, bmCenter : integer;
    poly1A, poly1B, poly2A, poly2B, poly3A, poly3B, poly4A, poly4B : TPolygon;


procedure SetBildSize(mySize:integer);
var ofs, ofsB: integer;
begin
  if bmSize=mySize then exit;
  bmSize:=mySize;
  bmCenter:=(bmSize div 2)+1;
  ofs := 20*mySize Div orgBmSize;
  ofsB := ofs*3 div 2;
  poly1A := TPolygon( [Point(bmCenter-ofs,0), Point(bmCenter+ofs,0),Point(bmCenter,2*ofs)] );
  poly1B := TPolygon( [Point(bmCenter-ofs,0),Point(bmCenter+ofs,0),Point(bmCenter+ofsB,ofsB),Point(bmCenter-ofsB,ofsB)] );
  poly2A := TPolygon( [Point(bmCenter-ofsb,0),Point(bmCenter+ofs,0),Point(bmCenter+2*ofs,ofs),Point(bmCenter-ofsB,ofs)] );
  poly2B := TPolygon( [Point(bmCenter-ofs,0),Point(bmCenter+ofsb,0),Point(bmCenter+ofsB,ofs),Point(bmCenter,ofs)] );

  poly3A := TPolygon( [Point(bmCenter-10,0),Point(bmCenter+ofs,0),Point(bmCenter-10-ofs,ofsB)] );
  poly3B := TPolygon( [Point(bmCenter-ofs,0),Point(bmCenter+10,0),Point(bmCenter-2*ofs,ofsB)] );

  poly4A := TPolygon( [Point(bmCenter,0),Point(bmCenter+ofs,0),Point(bmCenter-2*ofs,ofsB)] );
  poly4B := TPolygon( [Point(bmCenter,0),Point(bmCenter-ofs,0),Point(bmCenter-2*ofs,ofsB)] );
end;


function setHG(aFarbe:TColor):boolean;
var k : integer;
begin
  for k:=1 to High(Farbe) do
    if aFarbe=farbe[k] then exit(false);
  BGColor:=aFarbe;
  result:=true;
end;


{ TEinzelBild }

procedure TEinzelBild.Assign(aBild:TEinzelBild);
begin
  edges:=aBild.edges;
  bild.Picture.Bitmap.Assign(aBild.bild.Picture.Bitmap);
  rot:=aBild.rot;
end;

constructor  TEinzelBild.Create;
begin
  inherited;
  bild:=TImage.Create(nil);
end;

procedure TEinzelBild.Free;
begin
  bild.free;
  inherited Free;
end;

procedure TEinzelBild.DrawBild;
var poly  : TPolygon;
    k, nr, old : integer;
    bm    : TBitMap;

    procedure uebertrage(aPoly:TPolygon;var poly:TPolygon);
    var n, tmp : integer;
    begin
      SetLength(poly,Length(aPoly));
      for n:=0 to High(aPoly) do poly[n]:=aPoly[n];
      if rot=0 then exit;
      for n:=0 to High(poly) do
        begin
          tmp:=poly[n].x;
          case rot of   // Drehung mit dem Uhrzeigersinn: 1-90° / 2-180° /3-270°
              1 : begin poly[n].x :=bmSize-poly[n].y; poly[n].y:=tmp; end;
              2 : begin poly[n].x :=bmSize-tmp;       poly[n].y:=bmSize-poly[n].y; end;
              3 : begin poly[n].x :=poly[n].y;        poly[n].y:=bmSize-tmp; end;
            end;
        end;
    end;

begin
  bm:=TBitMap.Create;
  bm.Width:=bmSize;
  bm.Height:=bmSize;
  bm.PixelFormat:= pf24bit;
  if BGColor<>clBlack then
    begin
      bm.Canvas.Pen.Color:=BGColor;
      bm.Canvas.Brush.Color:=BGColor;
      bm.Canvas.Rectangle(0,0,bmSize,bmSize);
    end;
  old:=rot;
  poly:=nil;
  for k:=topEdge to LeftEdge do
    begin
      nr:=edges[k];
      rot:=(old+k) mod 4;
      case nr of
          -4 : uebertrage(poly4B,poly);
          -3 : uebertrage(poly3B,poly);
          -2 : uebertrage(poly2B,poly);
          -1 : uebertrage(poly1B,poly);
           1 : uebertrage(poly1A,poly);
           2 : uebertrage(poly2A,poly);
           3 : uebertrage(poly3A,poly);
           4 : uebertrage(poly4A,poly);
        end;
      if BGColor=clBlack
        then bm.Canvas.Pen.Color:=farbe[abs(nr)]//; clWhite
        else bm.Canvas.Pen.Color:=clBlack;
     // bm.Canvas.Pen.Color:=farbe[abs(nr)];
      bm.Canvas.Brush.Color:=farbe[abs(nr)];
      bm.Canvas.Polygon(poly);
    end;
  rot:=old;
  bild.Picture.Bitmap:=bm;
end;

procedure TEinzelBild.Rotate(aRot: integer);
var alt : TPiece;
    k   : integer;
begin
  if aRot<>0 then
    begin
      alt:=edges;
      for k:=topEdge to leftEdge do edges[(4+k-aRot) mod 4]:=alt[k];
      DrawBild;
    end;
end;

procedure TEinzelBild.ZeichneBM(aDrawGrid: TDrawGrid; x, y: integer);
begin
  aDrawGrid.Canvas.Draw(x,y, bild.Picture.Bitmap)
end;


{ TPuzzleBilder }

procedure TPuzzleBilder.Assign(aListe:TPuzzleBilder);
var k : integer;
begin
  for k:=0 to puzzleSize-1
    do bilder[k].Assign(aListe.bilder[k]);
end;

procedure TPuzzleBilder.ChangeBilder(neuBilder:TPuzzleTeile);
var k : integer;
begin
  for k:=0 to puzzleSize-1 do
    begin
      bilder[k].edges:=neuBilder[k];
      bilder[k].DrawBild;
    end;
end;

constructor TPuzzleBilder.Create;
var k : integer;
begin
  inherited;
  if bmSize<21 then bmSize:=21;
  for k:=0 to puzzleSize-1 do
    begin
      bilder[k]:=TEinzelBild.Create;
      bilder[k].edges:=startPuzzle[k];
      bilder[k].DrawBild;
    end;
end;

procedure TPuzzleBilder.Draw(aDrawGrid: TDrawGrid; x, y, nr:integer);
begin
  bilder[nr].ZeichneBM(aDrawGrid, x, y);
end;

procedure TPuzzleBilder.Free;
var k : integer;
begin
  for k:=0 to puzzleSize-1  do bilder[k].free;
  inherited Free;
end;

procedure TPuzzleBilder.NeuZeichnen;
var k : integer;
begin
  for k:=0 to 8 do bilder[k].DrawBild;
end;

procedure TPuzzleBilder.RestorePuzzleBild(nr:integer; orgBilder:TPuzzleBilder);
begin
  bilder[nr].Assign(orgBilder.bilder[nr]);
end;


{ TManuLsg }

procedure TManuLsg.Clear;
var k : integer;
begin
  last:=-1;
  for k:=0 to High(lsgArr) do lsgArr[k]:= noPiece;
end;

procedure TManuLsg.Add(aBildNr,aPlatzNr:byte);
begin
  if last<puzzleSize-1 then
    begin
      inc(last);
      lsgArr[last].idx:=aBildNr;
      lsgArr[last].rot:=0;
      lsgArr[last].platzNr:=aPlatzNr
    end;
end;

function TManuLsg.GetLsgDataByBild(bildNr:integer):TPlaced_piece;
var k : integer;
begin
  result.idx:=-1;
  for k:=0 to puzzleSize-1 do
    if lsgArr[k].idx=bildNr then
      begin
        result:=lsgArr[k];
        break;
      end;
end;

function TManuLsg.GetLsgDataByPos(posNr:integer):TPlaced_piece;
var k : integer;
begin
  result.idx:=-1;
  for k:=0 to puzzleSize-1 do
    if lsgArr[k].platzNr=posNr then
      begin
        result:=lsgArr[k];
        break;
      end;
end;

function TManuLsg.GetPosInManuLsg(posNr:integer):integer;
var k : integer;
begin
  result:=-1;
  for k:=0 to puzzleSize-1 do
    if lsgArr[k].platzNr=posNr then
      begin
        result:=k;
        break;
      end;
end;

function TManuLsg.LastBildNr:smallInt;
begin
  result:=lsgArr[last].idx;
end;

function TManuLsg.LastPlatzNr:smallInt;
begin
  result:=lsgArr[last].platzNr;
end;

function TManuLsg.LastRot:smallInt;
begin
  result:=lsgArr[last].rot;
end;

procedure TManuLsg.Remove(nr:smallInt);
var k:integer;
begin
  if nr<0 then nr:=last;
  if (nr<=last) then
    begin
      if nr<last then
        for k:=nr+1 to last do lsgArr[k-1]:=lsgArr[k];
      lsgArr[last]:=noPiece;
      dec(last)
    end;
end;


(* ############################################################### *)
{ TPuzzle }

constructor TPuzzle.Create(myPieces: TPuzzleTeile);
begin
 fPieces:=myPieces;
 FillChar(fSolution, SizeOf(fSolution),0);
end;


function TPuzzle.will_edge_fit( a, b : TPieceToPlace ): boolean;
  var av, bv : integer;
  begin
    av := a.piece[(a.edge + a.rot) mod 4];
    bv := b.piece[(b.edge + b.rot) mod 4];
    result:= ( (av + bv) = 0 );
  end;

function TPuzzle.solution(k:integer) : TPlaced_piece;
  begin
    result:=fSolution[k]
  end;

procedure TPuzzle.place_piece_at(k:integer; const piece : TPlaced_piece );
  begin
    fSolution[k] := piece;
  end;

function TPuzzle.idx(i:integer) : integer;
  begin
     result:= fSolution[i].idx;
  end;

function TPuzzle.rot(i:integer) : integer;
  begin
    result:= fSolution[i].rot;
  end;

function TPuzzle.GetSolution:TSolution;
  begin
    result:=fSolution;
  end;

function TPuzzle.will_fit(k, current_piece_idx, rot0 : integer) : boolean;
var rot1         : integer;
    edge0, edge1 : integer;
    fits         : boolean;

   function SetPiece(aPieceIndex, rot, edge : integer) : TPieceToPlace;
   begin
     result.piece:=fPieces[aPieceIndex];
     result.rot:=rot;
     result.edge:=edge;
   end;

  begin
    if (k = 0) then exit(true);
    rot1 := rot(k - 1);           // get rotation of previous piece
    edge0 := Directions[k];
    edge1 := (NUM_EDGES + edge0 - 2) mod NUM_EDGES;
    fits := will_edge_fit(SetPiece(current_piece_idx, rot0, edge0),
                           SetPiece(idx(k - 1), rot1, edge1));
    case k of
       3: result := fits and will_edge_fit(
                               SetPiece(current_piece_idx, rot0, topEdge),
                               SetPiece(idx(0), rot(0), bottomEdge) );
       5: result := fits and will_edge_fit(
                               SetPiece(current_piece_idx, rot0, rightEdge),
                               SetPiece(idx(0), rot(0), leftEdge));
       7: result := fits and will_edge_fit(
                               SetPiece(current_piece_idx, rot0, bottomEdge),
                               SetPiece(idx(0), rot(0), topEdge));
       8: result := fits and will_edge_fit(
                               SetPiece(current_piece_idx, rot0, bottomEdge),
                               SetPiece(idx(1), rot(1), topEdge));
        else result:=fits;
    end;
 end;


(* ############################################################# *)
{ TSolver }

var fShowForm  : TPuzzleForm;
    all_pieces : indexArray;

constructor TSolver.Create(aPuzzle: TPuzzle);
var k : integer;
begin
  fPieces:=aPuzzle;
  fSolutions:=nil;
  fillChar(num_calls_at_level_,SizeOf(num_calls_at_level_),0);
  SetLength(all_pieces,puzzleSize);
  for k:=0 to puzzleSize-1 do all_pieces[k]:=k;
end;

function TSolver.GetSolution(nr: integer): TSolution;
var k : integer;
 begin
   if (fSolutions=nil) or (nr>High(fSolutions))
     then for k:=0 to puzzleSize-1 do result[k]:=noPiece
     else result:=fSolutions[nr];
 end;


procedure TSolver.SetShowForm(aForm: TForm);
begin
  fShowForm:=TPuzzleForm(aForm);
end;

function TSolver.solutions: TSolutionList;
 begin
   result:=fSolutions;
 end;

procedure TSolver.solveAnimation(k: integer; current_puzzle: TPuzzle;
  available_pieces: indexArray);
var idx, next_piece_idx, rot, n : integer;
    next_puzzle                 : TPuzzle;
    remaining_pieces            : indexArray;
    next_piece                  : TPlaced_piece;
begin
  num_calls_at_level_[k]:=num_calls_at_level_[k]+1;
  if (k = puzzleSize)  // YAY! We're at the deepest level, i.e. we found a solution.
    then begin
           SetLength(fSolutions,Length(fSolutions)+1);
  	   fSolutions[High(fSolutions)]:=current_puzzle.GetSolution;
           lsgGefunden:=not alleLsgSuchen;
           CheckPause;
           exit
     	 end;
  for  idx := 0 to High(available_pieces) do
    begin
      next_piece_idx := available_pieces[idx];
      for rot := 0 to NUM_ORIENTATIONS-1 do
        begin
          if (current_puzzle.will_fit(k, next_piece_idx, rot)) then
            begin
              next_puzzle:=TPuzzle.Create(current_puzzle.fPieces);
              next_puzzle.fSolution:=current_puzzle.fSolution;
              next_piece.idx:=next_piece_idx;
              next_piece.rot:=rot;
              next_piece.platzNr:=k;
              next_puzzle.place_piece_at(k, next_piece);
              SetLength(remaining_pieces, length(available_pieces)-1);
              for n:=0 to idx-1 do remaining_pieces[n]:=available_pieces[n];
              for n:=idx+1 to High(available_pieces) do remaining_pieces[n-1]:=available_pieces[n];
              if zeigen
                 then fShowForm.ShowSetBackTrack(k, next_piece)
                 else fShowForm.LabelTries.Caption:=IntToStr(total_tries);

              if abbruch then begin next_puzzle.Free; exit; end;
              solveAnimation(k + 1, next_puzzle, remaining_pieces);
              if not lsgGefunden and not abbruch and zeigen
                then fShowForm.ShowRemoveBackTrack;
              next_puzzle.Free;
            end;
          if (k = 0) then  break;
        end;
      if lsgGefunden or abbruch then exit;
    end;
end;


procedure TSolver.SolvePuzzleAnimation(suchAlle:boolean);
begin
  fillChar(num_calls_at_level_,SizeOf(num_calls_at_level_),0);
  lsgGefunden:=false;
  alleLsgSuchen:=suchAlle;
  fShowForm:=PuzzleForm;
  fShowForm.LabelTries.Caption:='';
  solveAnimation(0, fPieces, all_pieces);
end;

function TSolver.tries_at_level: TPuzzleNumArr;
 begin
   result:= num_calls_at_level_;
 end;

function TSolver.total_tries : integer;
 var sum, k : integer;
 begin
   sum:=0;
   for k:=Low(num_calls_at_level_) to High(num_calls_at_level_) do
     sum:=sum+num_calls_at_level_[k];
   result:=sum;
 end;

end.

