unit Core.Ball;

interface

uses
    System.SysUtils
  , System.Classes
  , System.Rtti

  {Spring}
  , Spring
  , Spring.Collections

  {BowlingGame}
  , Core.Interfaces
  ;


type

  TBallFactory = Class(TInterfacedObject, IBallFactory)
  public
    function CreateBall(const AFrame: IScoreFrame): IBall;
  end;

  TBall = Class(TInterfacedObject, IBall)
  strict private
    FFrame: IScoreFrame;
  public
    Constructor Create( const AFrame: IScoreFrame );
    Destructor Destroy; override;
    procedure Roll(const ARollInfo: TRollInfo);
  end;


implementation



{ TBall }

constructor TBall.Create( const AFrame: IScoreFrame);
begin
  inherited Create;
  FFrame := AFrame;
end;

destructor TBall.Destroy;
begin

  inherited;
end;

procedure TBall.Roll(const ARollInfo: TRollInfo);
begin
  if Assigned( FFrame ) then
    FFrame.AddRollInfo( ARollInfo );
end;

{ TBallFactory }

function TBallFactory.CreateBall(const AFrame: IScoreFrame): IBall;
begin
  Result := TBall.Create( AFrame );
end;

end.
