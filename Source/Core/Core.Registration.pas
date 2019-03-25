unit Core.Registration;

interface

uses System.SysUtils
  , Core.BaseInterfaces
  , Core.Interfaces
  , Core.BowlingGame
  , Core.ScoreCard
  //, Core.Queue
  //, Core.ScoreMonitor
  , Core.Ball
  , Core.ScoreFrame
  , Core.Observable
  , Core.ListProcessor
  , Core.ScoreFrameProcessor
  ;


procedure RegisterServices;

implementation

uses
   Spring.Container
   ;

procedure RegisterServices;
begin
  try
    //GlobalContainer.RegisterType<TModelBase, T>(ResName + MODEL_SUFFIX);
    GlobalContainer.RegisterType<TGameConfig>.Implements<IGameConfig>.InjectConstructor([10, 2, 3, 10]).AsSingleton;

    GlobalContainer.RegisterType<TScoreFrame>.Implements<IScoreFrame>;
    GlobalContainer.RegisterType<TScoreFrameFactory>.Implements<IScoreFrameFactory>.AsSingleton;

    GlobalContainer.RegisterType<TBall>.Implements<IBall>;
    GlobalContainer.RegisterType<TBallFactory>.Implements<IBallFactory>.AsSingleton;

    GlobalContainer.RegisterType<TBowlingGame>.Implements<IBowlingGame>;
    GlobalContainer.RegisterType<TScoreCard>.Implements<IScoreCard>;

    GlobalContainer.RegisterType<TGameLinkedList<IScoreFrame>>.Implements<IGameLinkedList<IScoreFrame>>;
    GlobalContainer.RegisterType<TScoreFrameProcessor>.Implements<IScoreFrameProcessor>;

    //GlobalContainer.RegisterType<TScoreFrameQueueProcessor>.Implements<IQueueProcessor<Integer, IScoreFrameLink>>;
    //GlobalContainer.RegisterType<TScoreFrameQueueProcessor>.Implements<IScoreFrameQueueProcessor>;
    //GlobalContainer.RegisterType<TScoreCardMonitor>.Implements<IScoreCardMonitor>;
    //GlobalContainer.RegisterType<TDictionaryQueue<Integer, IScoreFrame>>.Implements<IDictionaryQueue<Integer, IScoreFrame>>;
    //GlobalContainer.RegisterType<TDictionaryQueue<Integer, IScoreFrameLink>>.Implements<IDictionaryQueue<Integer, IScoreFrameLink>>;
    //GlobalContainer.RegisterType<TScoreFrameQueueProcessor>.Implements<IScoreFrameQueueProcessor>;
    //GlobalContainer.RegisterType<TScoreFrameProcessor>.Implements<IGameDataProcessor<Integer, IScoreFrame>>;

    GlobalContainer.Build;
  finally
  end;
end;

end.
