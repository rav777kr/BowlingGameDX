unit Core.ScoreFrameProcessor;

interface

uses
    System.SysUtils
  , System.Classes
  , System.Rtti

  {Spring}
  , Spring
  , Spring.Collections

  {BowlingGame}
  , Core.BaseInterfaces
  , Core.Interfaces
  , Core.ListProcessor
  ;


type

  TScoreFrameProcessor = class(TLinkedListProcessor<Integer, IScoreFrame>, IScoreFrameProcessor)
  strict protected
    function ProcessDataItem( AFrame: IScoreFrame; APins, ALastFrameTotal: TValue ): TValue; override;
  end;

implementation


{ TScoreFrameProcessor }

function TScoreFrameProcessor.ProcessDataItem(AFrame: IScoreFrame;
  APins, ALastFrameTotal: TValue): TValue;
var
  pins: Integer;
begin
  try
    pins := 0;
    if not APins.IsEmpty then
      pins := APins.AsType<Integer>;
    AFrame.AddToFrameTotal( pins );
    Result := TValue.From( AFrame.FrameTotal );
  finally
  end;
end;



end.
