unit BildSchirmAnpassung;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   BildSchirmAnpassung
   Autor:   H. Niemeyer  (c) 2010 - 2015
   Version: 1.5

   letzte Änderung: 26.11.2015 *)

{$mode objfpc}{$H+}

interface

uses Forms, Graphics, Controls;

const screenBreite     = 1680; {Auflösung, unter der das Fenster erstellt wurde}
      screenHoehe      = 1050;
      orgPixelsPerInch =   96;
      orgDPI           =   96;

procedure SkaliereForm(aForm:TForm);

procedure HighDPI(FromDPI: integer);
procedure ScaleDPI(Control: TControl; FromDPI: integer);

implementation

procedure SkaliereForm(aForm:TForm);
begin
  if aForm.Position=poDefault then aForm.Position:=poScreenCenter;
  ScaleDPI(aForm, orgDPI);
end;

procedure HighDPI(FromDPI: integer);
var i : integer;
begin
  if Screen.PixelsPerInch = FromDPI then exit;
  for i := 0 to Screen.FormCount - 1 do
    ScaleDPI(Screen.Forms[i], FromDPI);
end;

procedure ScaleDPI(Control: TControl; FromDPI: integer);
var i          : integer;
    WinControl : TWinControl;
begin
  if Screen.PixelsPerInch = FromDPI then exit;
  with Control do
  begin
    Left := ScaleX(Left, FromDPI);
    Top := ScaleY(Top, FromDPI);
    Width := ScaleX(Width, FromDPI);
    Height := ScaleY(Height, FromDPI);
  end;

  if Control is TWinControl then
  begin
    WinControl := TWinControl(Control);
    if WinControl.ControlCount = 0 then
      exit;
    for i := 0 to WinControl.ControlCount - 1 do
      ScaleDPI(WinControl.Controls[i], FromDPI);
  end;
end;

end.

