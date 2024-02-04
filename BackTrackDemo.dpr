program BackTrackDemo;

uses
  Forms, Interfaces,
  BackMain in 'BackMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Backtracking Demos';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
