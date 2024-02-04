unit puzzleDragUnit;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   DragObjekt für puzzle3x3
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.6

   letzte Änderung: 17.11.2023  *)

interface

uses
  LCLIntf,
  SysUtils, Classes, Graphics, Controls, Dialogs;

type
  TMyDragObject = class(TDragControlObject)
  private
    fBildNr, fQPos, fRot : integer;
    FImageList : TDragImageList;
  protected
    function GetDragImages: TDragImageList; override;
  public
    Procedure StartDrag(G:TGraphic; p:TPoint; nr,r,qp:integer);
    Constructor Create(AControl: TControl); override;
    Destructor Destroy;override;
    Property BildNr:integer read fBildNr;
    Property Rot:integer read fRot;
    Property QPos:integer read fQPos;
  end;

implementation

constructor TMyDragObject.Create(AControl: TControl);
begin
  inherited;
  FImageList:=TDragImageList.Create(nil);
  AlwaysShowDragImages := True;
end;

destructor TMyDragObject.Destroy;
begin
  FImageList.Free;
  inherited;
end;

function TMyDragObject.GetDragImages: TDragImageList;
begin
  Result := FImageList;
end;

Procedure TMyDragObject.StartDrag(G:TGraphic; p:TPoint; nr,r,qp:integer);
var bmp:TBitMap;
begin
  fBildNr:=nr;
  fRot:=r;
  fQPos:=qp;
  bmp:=TBitMap.Create;
  try
    FImageList.Width := g.Width;
    FImageList.Height := g.Height;
    bmp.Width := g.Width;
    bmp.Height := g.Height;
    bmp.Canvas.Draw(0,0,g);
    FImageList.Add(bmp,nil);
    FImageList.DragHotspot := Point(bmp.Width div 2, bmp.Height div 2);
  finally
    bmp.Free;
  end;
  FImageList.SetDragImage(0,p.x,p.y)
end;

end.


