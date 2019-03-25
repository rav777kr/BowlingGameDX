program BowlingGame;

{$DEFINE GAMELOGGER}

uses
  Forms,
  SysUtils,
  fMain in 'Client\fMain.pas' {frmMain},
  Core.Registration in 'Core\Core.Registration.pas',
  Core.Interfaces in 'Core\Core.Interfaces.pas',
  Core.BowlingGame in 'Core\Core.BowlingGame.pas',
  Core.Ball in 'Core\Core.Ball.pas',
  Core.ScoreFrame in 'Core\Core.ScoreFrame.pas',
  Core.ScoreCard in 'Core\Core.ScoreCard.pas',
  Core.Observable in 'Core\Core.Observable.pas',
  frmGameScoreBoard in 'Client\frmGameScoreBoard.pas' {GameScoreBoardFrame: TFrame},
  Core.Link in 'Core\Core.Link.pas',
  Core.BaseInterfaces in 'Core\Core.BaseInterfaces.pas',
  Core.ListProcessor in 'Core\Core.ListProcessor.pas',
  Core.ScoreFrameProcessor in 'Core\Core.ScoreFrameProcessor.pas',
  Core.ResourceStrings in 'Core\Core.ResourceStrings.pas';

{$R *.RES}

begin
  //Logger.StartLogSession( 'BowlingGame', ExtractFilePath( Application.ExeName ) , ChangeFileExt( Application.ExeName, '.ini' ), True, False );
  try
    Core.Registration.RegisterServices;
    Forms.Application.Initialize;
    Forms.Application.ShowMainForm := True;
    Application.CreateForm(TfrmMain, frmMain);
  Forms.Application.Run;
  finally
    //Logger.StopLogSession;
  end;
end.
