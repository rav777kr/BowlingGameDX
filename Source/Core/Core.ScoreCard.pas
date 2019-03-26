unit Core.ScoreCard;

interface

uses
    System.SysUtils
  , System.Classes
  , System.Rtti

  {Spring}
  , Spring
  , Spring.Collections
  , Generics.Collections

  {BowlingGame}
  , Core.BaseInterfaces
  , Core.Interfaces
  //, Core.Queue
  ;


type

  TScoreCard = class(TInterfacedObject, IScoreCard)
  strict private
    type
      TCardData = record
        FrameSequence: Integer;
        ExpectedRollCount: Integer;
        BallSequence: Integer;
        RollSequence: Integer;
        RollPinCount: Integer;
        IsGameOver: Boolean;
      end;
  strict private
    FCardData: TCardData;
    FPlayerName: String;
    FGameConfig: IGameConfig;
    FFrames: IList<IScoreFrame>;
    FScoreFrameProcessor: IScoreFrameProcessor;
    FFrameObservers: IList<IGameObserver>;
    FFrameFactory: IScoreFrameFactory;
  private
    procedure AttachAllObserversToFrames( const AForceNotify: Boolean );
    procedure AttachObserverToFrames(Observer: IGameObserver; const AForceNotify: Boolean);
    procedure DetachObserverFromFrames(Observer: IGameObserver);
    procedure CreateFrames(const ACount: Integer);
    function GetFrame( const ASequenceNo: Integer ): IScoreFrame;
    procedure CalculateSequences;
    procedure ProcessFrameQueue;
    procedure BeforeRollBall;
    procedure AfterRollBall;
  private
    function GetPlayerName: String;
    procedure SetPlayerName(const AValue: String);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterObserver(AObserver: IGameObserver);
    procedure UnregisterObserver(AObserver: IGameObserver);
    function GetTotalScore: Integer;

    function GetFrameInfoByFrameNo(const AFrameNo: Integer): TFrameInfo;
    procedure ResetScoreCard(const APlayerName: String);
    procedure RollBall(const APinCount: Integer);

    property PlayerName: String read GetPlayerName write SetPlayerName;
  end;

implementation

uses
    Spring.Services
  , Core.ScoreFrame
  , Core.ResourceStrings
  ;

{ TScoreCard }

constructor TScoreCard.Create;
begin
  inherited Create;
  FPlayerName := EmptyStr;
  FFrames := TCollections.CreateList<IScoreFrame>;
  FFrameObservers := TCollections.CreateList<IGameObserver>;

  FCardData.FrameSequence := 0;
  FCardData.ExpectedRollCount := 0;
  FCardData.RollSequence := 0;
  FCardData.BallSequence := 0;
  FCardData.RollPinCount := 0;
  FCardData.IsGameOver := False;

  FGameConfig := ServiceLocator.GetService< IGameConfig >;
  FScoreFrameProcessor := ServiceLocator.GetService< IScoreFrameProcessor >;

  FFrameFactory := ServiceLocator.GetService< IScoreFrameFactory >;
end;

destructor TScoreCard.Destroy;
begin
  inherited;
end;

function TScoreCard.GetPlayerName: String;
begin
  Result := FPlayerName;
end;

function TScoreCard.GetTotalScore: Integer;
begin
  if FCardData.FrameSequence > 0 then
    Result := GetFrame( FCardData.FrameSequence ).FrameTotal;

end;

procedure TScoreCard.SetPlayerName(const AValue: String);
begin
  FPlayerName := AValue;
end;

function TScoreCard.GetFrameInfoByFrameNo(const AFrameNo: Integer): TFrameInfo;
var
  f: IScoreFrame;
begin
  f := FFrames.SingleOrDefault(
                (function(const f: IScoreFrame): Boolean
                begin
                  Result := f.FrameInfo.FrameNo = AFrameNo;
                end),
                nil);
  if Assigned( f ) then
    Result := f.FrameInfo
  else
    raise EValueNotFoundException.CreateResFmt(@SGameObjectWithValueNotFound, ['ScoreFrame', AFrameNo.ToString]);
end;

procedure TScoreCard.CreateFrames(const ACount: Integer);
var
  I: Integer;
  f, pf: IScoreFrame;
begin
  f := nil;
  pf := nil;
  for I := 0 to Pred(ACount) do
  begin
    f := FFrameFactory.CreateFrame( I + 1, pf );
    pf := f;
    FFrames.Add( f );
  end;
end;

procedure TScoreCard.RegisterObserver(AObserver: IGameObserver);
begin
  FFrameObservers.Add(AObserver);
end;

procedure TScoreCard.AttachAllObserversToFrames( const AForceNotify: Boolean );
var
  o: IGameObserver;
begin
  for o in FFrameObservers do
    AttachObserverToFrames( o, AForceNotify );
end;

procedure TScoreCard.AttachObserverToFrames(Observer: IGameObserver;
  const AForceNotify: Boolean);
var
  f: IScoreFrame;
begin
  for f in FFrames do
  begin
    f.Attach(Observer);
    if AForceNotify then
      f.UpdateView(TValue.From(f.FrameInfo));
  end;
end;

procedure TScoreCard.DetachObserverFromFrames(Observer: IGameObserver);
var
  f: IScoreFrame;
begin
  for f in FFrames do
    f.Detach(Observer);
end;

procedure TScoreCard.UnregisterObserver(AObserver: IGameObserver);
begin
  DetachObserverFromFrames(AObserver);
  FFrameObservers.Remove(AObserver);
end;

procedure TScoreCard.ResetScoreCard(const APlayerName: String);
begin
  FPlayerName := APlayerName;
  FFrames.Clear;

  FCardData.IsGameOver := False;
  FCardData.RollPinCount := 0;
  FCardData.FrameSequence := 1;
  FCardData.ExpectedRollCount := 2;
  FCardData.RollSequence := 1;
  FCardData.BallSequence := 1;

  FCardData.FrameSequence := 0;
  FCardData.ExpectedRollCount := 2;
  FCardData.RollSequence := 0;
  FCardData.BallSequence := 0;

  FScoreFrameProcessor.Clear;

  CreateFrames(FGameConfig.MaxFrameCount);
  AttachAllObserversToFrames( True );
end;

function TScoreCard.GetFrame( const ASequenceNo: Integer ): IScoreFrame;
begin
  Result := FFrames[ ASequenceNo - 1 ];
end;

procedure TScoreCard.CalculateSequences;
var
  lastFrame: IScoreFrame;
begin
  if FFrames.Count = 0 then
    raise EGameException.CreateRes(@SGameNotStarted);
  if ( FCardData.FrameSequence = 0 ) then
  begin
    Inc( FCardData.FrameSequence, 1 );
    Inc( FCardData.RollSequence, 1 );
    Inc( FCardData.BallSequence, 1 );
    Exit;
  end;
  try
    // frame is within our maximum frame count range
    if ( FCardData.FrameSequence <= FGameConfig.MaxFrameCount ) then
    begin
      Inc( FCardData.BallSequence );
      lastFrame := GetFrame( FCardData.FrameSequence );

      //calculate expected roll count per last roll
      if ( lastFrame.Status = fsNormal ) then
      begin
        FCardData.ExpectedRollCount := FGameConfig.NonLastFrameMaxRollCount;
        if ( FCardData.FrameSequence = FGameConfig.MaxFrameCount ) then
          FCardData.ExpectedRollCount := FGameConfig.LastFrameMaxRollCount;
      end
      else
      begin
        if ( FCardData.FrameSequence = FGameConfig.MaxFrameCount ) then
          FCardData.ExpectedRollCount := FGameConfig.LastFrameMaxRollCount
        else
          FCardData.ExpectedRollCount := FGameConfig.NonLastFrameMaxRollCount;
      end;

      //strike or spare roll case
      if ( lastFrame.Status <> fsNormal ) then
      begin
        //up to 9th frame
        if ( FCardData.FrameSequence < FGameConfig.MaxFrameCount ) then
        begin
          Inc( FCardData.FrameSequence );
          FCardData.RollSequence := 1;
          Exit;
        end
        else
        //last frame
        begin
          if ( lastFrame.Rolls.Count < FCardData.ExpectedRollCount ) then
            Inc( FCardData.RollSequence )
          else
            FCardData.IsGameOver := True;
        end;
      end
      else
      //normal roll case
      begin
        //up to 9th frame
        FCardData.RollSequence := FCardData.ExpectedRollCount - lastFrame.Rolls.Count;
        if ( FCardData.RollSequence = 0 ) then
        begin
          FCardData.RollSequence := 1;
          if ( FCardData.FrameSequence < FGameConfig.MaxFrameCount ) then
            Inc( FCardData.FrameSequence )
          else
          begin
            FCardData.RollSequence := 0;
            FCardData.IsGameOver := True;
          end;
        end;
      end;
    end;
  finally
    if FCardData.IsGameOver then
      raise EGameException.Create(SGameOver);
  end;
end;

procedure TScoreCard.ProcessFrameQueue;
var
  total: Integer;
  f: IScoreFrame;
begin
  if ( FCardData.FrameSequence = 0 ) then
    Exit;
  f := GetFrame( FCardData.FrameSequence );
  if FScoreFrameProcessor.CountAtKey[ FCardData.BallSequence ] > 0 then
  begin
    FScoreFrameProcessor.ProcessData( FCardData.BallSequence, FCardData.RollPinCount );
    total := f.GetPrevFrameInfo.FrameTotal + f.RollTotal;
    f.UpdateFrameTotal( total );
  end;

  if ( FCardData.FrameSequence < 10 ) then
  begin
    //for strike and spare, put the frame in the queue to be linked to the next frame for score updates
    if ( f.FrameInfo.Status <> fsNormal ) then
    begin
      //for strike, put current frame in the queue to be linked to the next frame for score updates
      FScoreFrameProcessor.AddItemAtKey( FCardData.BallSequence + 1, f );
      //for strike, put current frame AGAIN in the queue to be linked to the next frame for score updates
      if ( f.FrameInfo.Status = fsStrike ) then
        FScoreFrameProcessor.AddItemAtKey( FCardData.BallSequence + 2, f );
    end;
  end;
end;

procedure TScoreCard.BeforeRollBall;
begin
  CalculateSequences;
end;

procedure TScoreCard.AfterRollBall;
begin
  ProcessFrameQueue;
end;

procedure TScoreCard.RollBall(const APinCount: Integer);
var
  ball: IBall;
  factory: IBallFactory;
  f: IScoreFrame;
begin
  FCardData.RollPinCount := APinCount;

  try
    BeforeRollBall;

    f := GetFrame( FCardData.FrameSequence );
    factory := ServiceLocator.GetService< IBallFactory >;
    ball := factory.CreateBall( f );
    ball.Roll( TRollInfo.Create( FCardData.RollSequence, APinCount ) );

    AfterRollBall;

  finally
    FCardData.RollPinCount := APinCount;
  end;
end;


end.

