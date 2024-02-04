unit BackMain;

(* Projekt: Backtracking Demo: Demonstration ausgewählter Backtrackingbeispiele
   Modul:   Hauptmodul; Auswahl der Beispiele und der zugehörigen Erläuterungen
   Autor:   H. Niemeyer  (c) 2010 - 2023
   Version: 1.7

   letzte Änderung: 15.12.2023 *)

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  BildSchirmAnpassung, BackTrackInfo, BackTrackDemo_Sprache;

type

  { TMainForm }

  TMainForm = class(TForm)
    BitBtnHelp12: TBitBtn;
    BitBtnHelp13: TBitBtn;
    Button1: TButton;
    ButtonSudoku: TButton;
    ButtonPuzzle: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    ButtonZahlenraetsel: TButton;
    ButtonVierfarb: TButton;
    ButtonRucksack: TButton;
    Button10: TButton;
    ButtonSolitaer: TButton;

    BitBtnHelp1: TBitBtn;
    BitBtnHelp2: TBitBtn;
    BitBtnHelp3: TBitBtn;
    BitBtnHelp4: TBitBtn;
    BitBtnHelp5: TBitBtn;
    BitBtnHelp6: TBitBtn;
    BitBtnHelp7: TBitBtn;
    BitBtnHelp8: TBitBtn;
    BitBtnHelp9: TBitBtn;
    BitBtnHelp10: TBitBtn;
    BitBtnHelp11: TBitBtn;
    BitBtnAbout: TBitBtn;
    BitBtnBeenden: TBitBtn;

    procedure ButtonPuzzleClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure ButtonSudokuClick(Sender: TObject);
    procedure ButtonZahlenraetselClick(Sender: TObject);
    procedure ButtonVierfarbClick(Sender: TObject);
    procedure ButtonRucksackClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure ButtonSolitaerClick(Sender: TObject);

    procedure BitBtnHelp1Click(Sender: TObject);
    procedure BitBtnAboutClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

uses n_Damen, springer, nikolaus, rundReise, zahlraet, AlgoInfo, RouteLee,
     rundweg, Rucksack, vierfarb, Labyrinth, solitaer, puzzle3x3, sudoku;

 {$R *.lfm}

procedure TMainForm.Button1Click(Sender: TObject);
begin
  NDameForm:=TNDameForm.Create(self);
  nDameForm.showModal;
  nDameForm.free;
end;

procedure TMainForm.ButtonPuzzleClick(Sender: TObject);
begin
  PuzzleForm:=TPuzzleForm.create(self);
  PuzzleForm.ShowModal;
  PuzzleForm.free
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  SpringerForm:= TSpringerForm.Create(self);
  springerForm.Showmodal;
  springerForm.free;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  TravelForm:=TTravelForm.Create(self);
  TravelForm.showModal;
  TravelForm.free;
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  RundwegForm:=TRundwegForm.Create(self);
  RundwegForm.showModal;
  RundwegForm.free;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
   NikolausForm:=TNikolausForm.Create(self);
   NikolausForm.showModal;
   NikolausForm.free;
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
  RouterForm:=TRouterForm.Create(self);
  RouterForm.showModal;
  RouterForm.free;
end;

procedure TMainForm.ButtonSudokuClick(Sender: TObject);
begin
  SudokuForm:=TSudokuForm.create(self);
  SudokuForm.ShowModal;
  SudokuForm.free;
end;

procedure TMainForm.ButtonZahlenraetselClick(Sender: TObject);
begin
  Zahlenraetsel:=TZahlenraetsel.create(self);
  Zahlenraetsel.ShowModal;
  Zahlenraetsel.free;
end;

procedure TMainForm.ButtonVierfarbClick(Sender: TObject);
begin
  VierFarbForm:=TVierFarbForm.Create(self);
  VierFarbForm.showModal;
  VierFarbForm.free;
end;

procedure TMainForm.ButtonRucksackClick(Sender: TObject);
begin
  RucksackForm:=TRucksackForm.Create(self);
  RucksackForm.showModal;
  RucksackForm.free;
end;

procedure TMainForm.Button10Click(Sender: TObject);
begin
  LabyForm:=TLabyForm.create(Self);
  LabyForm.showModal;
  LabyForm.free;
end;

procedure TMainForm.ButtonSolitaerClick(Sender: TObject);
begin
  FormSolitaer:= TFormSolitaer.Create(self);
  FormSolitaer.ShowModal;
  FormSolitaer.free;
end;

procedure TMainForm.BitBtnHelp1Click(Sender: TObject);
begin
  if (sender As TBitBtn).tag>0 then
    begin
      InfoForm:=TInfoForm.Create(self);
      InfoForm.ShowInfo((sender As TBitBtn).tag);
      InfoForm.free;
    end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SkaliereForm(self);
  TranslationsFor_BackMain;
end;

procedure TMainForm.BitBtnAboutClick(Sender: TObject);
begin
  AboutBox:=TAboutBox.Create(self);
  TranslationsFor_backtrackinfo;
  AboutBox.ShowModal;
  AboutBox.free;
end;

end.
