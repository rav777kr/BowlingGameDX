unit Core.BowlingGame;

interface

uses
    System.SysUtils
  , System.Classes
  , System.Rtti

  {Spring}
  , Spring
  , Spring.Collections
  , Spring.DesignPatterns

  {BowlingGame}
  , Core.BaseInterfaces
  , Core.Interfaces
  , Core.ScoreCard
  ;


type

  TGameConfig = Class(TInterfacedObject, IGameConfig)
  strict private
    FMaxFrameCount: Integer;
    FNonLastFrameMaxRollCount: Integer;
    FLastFrameMaxRollCount: Integer;
    FMaxPinCountPerRoll: Integer;
    function GetMaxFrameCount: Integer;
    function GetLastFrameMaxRollCount: Integer;
    function GetNonLastFrameMaxRollCount: Integer;
    function GetMaxPinCountPerRoll: Integer;
  public
    constructor Create(const AMaxCount, ANonLastFrameMaxRollCount, ALastFrameMaxRollCount, AMaxPinCountPerRoll: Integer);
    property MaxFrameCount: Integer read GetMaxFrameCount;
    property NonLastFrameMaxRollCount: Integer read GetNonLastFrameMaxRollCount;
    property LastFrameMaxRollCount: Integer read GetLastFrameMaxRollCount;
    property MaxPinCountPerRoll: Integer read GetMaxPinCountPerRoll;
  end;

  TBowlingGame = Class(TInterfacedObject, IBowlingGame)
  strict private
    FScoreCard: IScoreCard;
  public
    Constructor Create;
    Destructor Destroy; override;
    procedure StartGame(const APlayerName: String);
    procedure RollBall(const APins: Integer);
    function GetScoreByFrame(const AFrameNo: Integer): TFrameInfo;
    function GetTotalScore: Integer;
    procedure RegisterObserver(AObserver: IGameObserver);
    procedure UnregisterObserver(AObserver: IGameObserver);
  end;

implementation

uses
  Spring.Services
  ;


{ TBowlingGame }

constructor TBowlingGame.Create;
begin
  inherited Create;
  FScoreCard := ServiceLocator.GetService< IScoreCard >;
end;

destructor TBowlingGame.Destroy;
begin
  inherited;
end;

function TBowlingGame.GetScoreByFrame(const AFrameNo: Integer): TFrameInfo;
begin
  Result := FScoreCard.GetFrameInfoByFrameNo( AFrameNo )
end;

function TBowlingGame.GetTotalScore: Integer;
begin
  Result := FScoreCard.GetTotalScore;
end;

procedure TBowlingGame.RegisterObserver(AObserver: IGameObserver);
begin
  FScoreCard.RegisterObserver( AObserver );
end;

procedure TBowlingGame.UnregisterObserver(AObserver: IGameObserver);
begin
  FScoreCard.UnregisterObserver( AObserver );
end;

procedure TBowlingGame.StartGame(const APlayerName: String);
begin
  FScoreCard.ResetScoreCard( APlayerName );
end;

procedure TBowlingGame.RollBall(const APins: Integer);
begin
  FScoreCard.RollBall( APins );
end;


{ TGameConfig }

constructor TGameConfig.Create(const AMaxCount, ANonLastFrameMaxRollCount,
  ALastFrameMaxRollCount, AMaxPinCountPerRoll: Integer);
begin
  inherited Create;
  FMaxFrameCount := AMaxCount;
  FNonLastFrameMaxRollCount := ANonLastFrameMaxRollCount;
  FLastFrameMaxRollCount := ALastFrameMaxRollCount;
  FMaxPinCountPerRoll := AMaxPinCountPerRoll;
end;

function TGameConfig.GetMaxFrameCount: Integer;
begin
  Result := FMaxFrameCount;
end;

function TGameConfig.GetMaxPinCountPerRoll: Integer;
begin
  Result := FMaxPinCountPerRoll;
end;

function TGameConfig.GetLastFrameMaxRollCount: Integer;
begin
  Result := FLastFrameMaxRollCount;
end;

function TGameConfig.GetNonLastFrameMaxRollCount: Integer;
begin
  Result := FNonLastFrameMaxRollCount;
end;

end.
