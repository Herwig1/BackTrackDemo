unit solitaerdef;

interface

type
   TSprungRtg = (rechts,unten,links,oben,keinSprung);
   TSprungArr = Array[rechts..oben] of boolean;

const vollBlockBild = 1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256 ; // = 511
     qSize = 7;   // = 9;
     qMitte = ((qSize-3) div 2) + 2;
     mitteL = qMitte-1;
     mitteR = qMitte+1;
     mitteO = qMitte-1;
     mitteU = qMitte+1;

     maxZugZahl9 = 108;
     maxZugZahl7 = 76;

     maxZugZahl = 36 {mittlere Felder} + 20 {Randfelder} + 20 {Randfelder-1} + 16*(qSize-7);

var zugvon : Array[1..qSize,1..qSize] of TSprungArr;

procedure InitZugVon;

implementation

procedure InitZugVon;
var x,y : integer;
    r   : TSprungRtg;
begin
  fillChar(zugVon,SizeOf(Zugvon),0);
 // 5 Züge in erster Reihe möglich
  zugvon[mitteL,1,unten]:=true; zugvon[mitteL,1,rechts]:=true;
  zugvon[qMitte,1,unten]:=true;
  zugvon[mitteR,1,unten]:=true; zugvon[mitteR,1,links]:=true;
 // 5 Züge in letzter Reihe möglich
  zugvon[mitteL,qSize,oben]:=true; zugvon[mitteL,qSize,rechts]:=true;
  zugvon[qMitte,qSize,oben]:=true;
  zugvon[mitteR,qSize,oben]:=true; zugvon[mitteR,qSize,links]:=true;
 // 5 Züge in zweiter Reihe möglich
  zugvon[mitteL,2,unten]:=true; zugvon[mitteL,2,rechts]:=true;
  zugvon[qMitte,2,unten]:=true;
  zugvon[mitteR,2,unten]:=true; zugvon[mitteR,2,links]:=true;
 // 5 Züge in vorletzter Reihe möglich
  zugvon[mitteL,qSize-1,oben]:=true; zugvon[mitteL,qSize-1,rechts]:=true;
  zugvon[qMitte,qSize-1,oben]:=true;
  zugvon[mitteR,qSize-1,oben]:=true; zugvon[mitteR,qSize-1,links]:=true;


 // 5 Züge in erster Spalte möglich
  zugvon[1,mitteO,rechts]:=true; zugvon[1,mitteO,unten]:=true;
  zugvon[1,qMitte,rechts]:=true;
  zugvon[1,mitteU,rechts]:=true; zugvon[1,mitteU,oben]:=true;
 // 5 Züge in letzter Spalte möglich
  zugvon[qSize,mitteO,links]:=true; zugvon[qSize,mitteO,unten]:=true;
  zugvon[qSize,qMitte,links]:=true;
  zugvon[qSize,mitteU,links]:=true; zugvon[qSize,mitteU,oben]:=true;
 // 5 Züge in zweiter Spalte möglich
  zugvon[2,mitteO,rechts]:=true; zugvon[2,mitteO,unten]:=true;
  zugvon[2,qMitte,rechts]:=true;
  zugvon[2,mitteU,rechts]:=true; zugvon[2,mitteU,oben]:=true;
 // 5 Züge in vorletzter Spalte möglich
  zugvon[qSize-1,mitteO,links]:=true; zugvon[qSize-1,mitteO,unten]:=true;
  zugvon[qSize-1,qMitte,links]:=true;
  zugvon[qSize-1,mitteU,links]:=true; zugvon[qSize-1,mitteU,oben]:=true;

 if qSize=9 then
  begin
 // 8 Zuge in dritter Reihe möglich  - qSize = 9 !
  zugvon[mitteL,3,unten]:=true; zugvon[mitteL,3,oben]:=true; zugvon[mitteL,3,rechts]:=true;
  zugvon[qMitte,3,unten]:=true; zugvon[qMitte,3,oben]:=true;
  zugvon[mitteR,3,unten]:=true; zugvon[mitteR,3,oben]:=true; zugvon[mitteR,3,links]:=true;
 // 8 Zuge in vorvorletzter Reihe möglich  - qSize = 9 !
  zugvon[mitteL,qSize-2,oben]:=true; zugvon[mitteL,qSize-2,unten]:=true; zugvon[mitteL,qSize-2,rechts]:=true;
  zugvon[qMitte,qSize-2,oben]:=true; zugvon[qMitte,qSize-2,unten]:=true;
  zugvon[mitteR,qSize-2,oben]:=true; zugvon[mitteR,qSize-2,unten]:=true; zugvon[mitteR,qSize-2,links]:=true;
 // 8 Zuge in dritter Spalte möglich  - qSize = 9 !
  zugvon[3,mitteO,rechts]:=true; zugvon[3,mitteO,links]:=true; zugvon[3,mitteO,unten]:=true;
  zugvon[3,qMitte,rechts]:=true; zugvon[3,qMitte,links]:=true;
  zugvon[3,mitteU,rechts]:=true; zugvon[3,mitteU,links]:=true; zugvon[3,mitteU,oben]:=true;
 // 8 Zuge in vorvorletzter Spalte möglich  - qSize = 9 !
  zugvon[qSize-2,mitteO,links]:=true; zugvon[qSize-2,mitteO,rechts]:=true; zugvon[qSize-2,mitteO,unten]:=true;
  zugvon[qSize-2,qMitte,links]:=true; zugvon[qSize-2,qMitte,rechts]:=true;
  zugvon[qSize-2,mitteU,links]:=true; zugvon[qSize-2,mitteU,rechts]:=true; zugvon[qSize-2,mitteU,oben]:=true;
  end;

 // weitere 36 Züge
  for x:=mitteL to mitteR do
    for y:=mitteO to mitteU do
      for r:=rechts to oben do zugvon[x,y,r]:=true;
end;

end.
 
