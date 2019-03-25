unit fMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.Actions,
  Vcl.ActnList, Vcl.Grids, Vcl.StdCtrls

  , Core.Interfaces
  , Core.BowlingGame
  ;

type
  TfrmMain = class(TForm)
    alMain: TActionList;
    actStartGame: TAction;
    actRollBall: TAction;
    pScoreBoard: TPanel;
    pGameInputs: TPanel;
    Panel1: TPanel;
    actGetFrameScore: TAction;
    GroupBox1: TGroupBox;
    Button2: TButton;
    GroupBox3: TGroupBox;
    Label3: TLabel;
    edPinCount: TEdit;
    Button1: TButton;
    Label1: TLabel;
    edFrameNo: TEdit;
    GroupBox2: TGroupBox;
    Button3: TButton;
    edPlayerName: TEdit;
    Label2: TLabel;
    lblScoreRoll1: TLabel;
    edScoreRoll1: TEdit;
    lblScoreRoll2: TLabel;
    edScoreRoll2: TEdit;
    lblScoreRoll3: TLabel;
    edScoreRoll3: TEdit;
    lblScoreFrame: TLabel;
    procedure actStartGameExecute(Sender: TObject);
    procedure actRollBallExecute(Sender: TObject);
    procedure actGetFrameScoreExecute(Sender: TObject);
  private
    { Private declarations }
    FScoreBoardFrame: TFrame;
    FGame: IBowlingGame;
  public
    { Public declarations }
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
  end;

var
  frmMain: TfrmMain;

implementation

uses
    frmGameScoreBoard
  , Spring.Services
  ;


{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited;
  FGame := ServiceLocator.GetService< IBowlingGame >;
  FScoreBoardFrame := TGameScoreBoardFrame.Create(Self, FGame);
  FScoreBoardFrame.Parent := pScoreBoard;
  FScoreBoardFrame.Align := alClient;
end;

destructor TfrmMain.Destroy;
begin
  inherited;
end;

procedure TfrmMain.actStartGameExecute(Sender: TObject);
begin
  FGame.StartGame(edPlayerName.Text);
end;


procedure TfrmMain.actRollBallExecute(Sender: TObject);
begin
  FGame.RollBall(StrToIntDef(edPinCount.Text,0));
end;

procedure TfrmMain.actGetFrameScoreExecute(Sender: TObject);
var
  info: TFrameInfo;
begin
  edScoreRoll1.Text := EmptyStr;
  edScoreRoll2.Text := EmptyStr;
  edScoreRoll3.Text := EmptyStr;
  info := FGame.GetScoreByFrame(StrToIntDef(edFrameNo.Text,1));
  if info.Rolls.Count > 0 then
    edScoreRoll1.Text := info.Rolls[0].Pins.ToString;
  if info.Rolls.Count > 1 then
    edScoreRoll2.Text := info.Rolls[1].Pins.ToString;
  if info.Rolls.Count > 2 then
    edScoreRoll3.Text := info.Rolls[2].Pins.ToString;
  lblScoreFrame.Caption := info.FrameTotal.ToString;
end;


end.
