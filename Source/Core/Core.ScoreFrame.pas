unit Core.ScoreFrame;

interface

uses
    System.SysUtils
  , System.Classes
  , System.Rtti

  {Spring}
  , Spring
  , Spring.DesignPatterns
  , Spring.Collections
  , Generics.Collections

  {BowlingGame}
  , Core.BaseInterfaces
  , Core.Interfaces
  , Core.Observable
  , Core.Link
  ;


type

  TScoreFrame = Class;

  TScoreFrameFactory = Class(TInterfacedObject, IScoreFrameFactory)
  public
    function CreateFrame(const AFrameNo: Integer; APrevFrame: IScoreFrame): IScoreFrame;
  end;

  TScoreFrame = Class(TGameObservable, IScoreFrame)
  strict private
    FFrameInfo: TFrameInfo;

    FGameConfig: IGameConfig;
    FPrevFrame: IScoreFrame;

    procedure ScoreFrameChanged;
    procedure Validate( const ARollInfo: TRollInfo );
  strict protected
    function GetFrameNo: Integer; virtual;
    function GetStatus: TFrameStatus; virtual;
    function GetFrameTotal: Integer; virtual;
    function GetRolls: IList<TRollInfo>; virtual;
    function GetFrameInfo: TFrameInfo; virtual;
    function GetPrevFrameInfo: TFrameInfo;
    function GetRollTotal: Integer;
  public
    constructor Create(const AFrameNo: Integer); overload;
    constructor Create(const AFrameNo: Integer; APrevFrame: IScoreFrame); overload;
    destructor Destroy; override;
    procedure AddRollInfo(const ARollInfo: TRollInfo); virtual;
    procedure UpdateFrameTotal(const ATotal: Integer); virtual;
    procedure AddToFrameTotal(const APins: Integer); virtual;

    property FrameNo: Integer read GetFrameNo;
    property FrameTotal: Integer read GetFrameTotal;
    property RollTotal: Integer read GetRollTotal;
    property Rolls: IList<TRollInfo> read GetRolls;
    property Status: TFrameStatus read GetStatus;
    property FrameInfo: TFrameInfo read GetFrameInfo;
  end;

implementation
uses
    Spring.Services
  , Core.ResourceStrings
  ;

{ TScoreFrameFactory }

function TScoreFrameFactory.CreateFrame(const AFrameNo: Integer;
  APrevFrame: IScoreFrame): IScoreFrame;
begin
  Result := TScoreFrame.Create( AFrameNo, APrevFrame );
end;


{ TScoreFrame }

constructor TScoreFrame.Create( const AFrameNo: Integer );
begin
  Create( AFrameNo, nil );
end;

constructor TScoreFrame.Create( const AFrameNo: Integer;
  APrevFrame: IScoreFrame );
begin
  inherited Create;
  FPrevFrame := APrevFrame;
  FFrameInfo.FrameNo := AFrameNo;
  FFrameInfo.FrameTotal := 0;
  FFrameInfo.Status := fsNormal;
  FFrameInfo.ExtraPinTotal := 0;
  FFrameInfo.Rolls := TCollections.CreateList<TRollInfo>;
  FGameConfig := ServiceLocator.GetService< IGameConfig >;
end;


destructor TScoreFrame.Destroy;
begin

  inherited;
end;

function TScoreFrame.GetPrevFrameInfo: TFrameInfo;
begin
  Result := TFrameInfo.Create( 0, 0, fsNormal);
  if Assigned( FPrevFrame ) then
    Result := FPrevFrame.FrameInfo;
end;

function TScoreFrame.GetFrameInfo: TFrameInfo;
begin
  Result := FFrameInfo;
end;

function TScoreFrame.GetFrameNo: Integer;
begin
  Result := FFrameInfo.FrameNo;
end;

function TScoreFrame.GetFrameTotal: Integer;
begin
  Result := FFrameInfo.FrameTotal;
end;

function TScoreFrame.GetRollTotal: Integer;
begin
  Result := FFrameInfo.RollTotal;
end;

function TScoreFrame.GetStatus: TFrameStatus;
begin
  Result := FFrameInfo.Status;
end;

function TScoreFrame.GetRolls: IList<TRollInfo>;
begin
  Result := FFrameInfo.Rolls;
end;

procedure TScoreFrame.ScoreFrameChanged;
begin
  UpdateView( TValue.From( FFrameInfo) );
end;

procedure TScoreFrame.Validate( const ARollInfo: TRollInfo );
var
  total: Integer;
begin
  total := ( RollTotal + ARollInfo.Pins );
  //only 10 pins permitted per roll
  if ( ARollInfo.Pins > FGameConfig.MaxPinCountPerRoll ) then
    raise EGameInvalidValueException.CreateResFmt(@SInvalidPins, [FGameConfig.MaxPinCountPerRoll]);
  //non-last frame
  if ( FrameNo < FGameConfig.MaxFrameCount )
    and ( total > FGameConfig.MaxPinCountPerRoll ) then
      raise EGameInvalidValueException.CreateResFmt(@SInvalidPins, [FGameConfig.MaxPinCountPerRoll]);
  //last frame
  if ( FrameNo = FGameConfig.MaxFrameCount ) then
  begin
    //normal status case - two rolls total should be less than 10 if one is less than 10
    case Status of
      fsNormal:
        begin
          if ( ( Rolls.Count = 1 ) and ( total > FGameConfig.MaxPinCountPerRoll ) ) then
            raise EGameInvalidValueException.CreateResFmt(@SInvalidPins, [FGameConfig.MaxPinCountPerRoll]);
        end;
      fsSpare:
        begin
          if ( ( Rolls.Count > 1 ) and ( total > ( 2 * FGameConfig.MaxPinCountPerRoll ) ) ) then
            raise EGameInvalidValueException.CreateResFmt(@SInvalidPins, [FGameConfig.MaxPinCountPerRoll]);
        end;
      fsStrike:
        begin
          if ( ( Rolls.Count >= 1 ) and ( total > ( 3 * FGameConfig.MaxPinCountPerRoll ) ) ) then
            raise EGameInvalidValueException.CreateResFmt(@SInvalidPins, [FGameConfig.MaxPinCountPerRoll]);
        end;
    end;
  end;
end;

procedure TScoreFrame.AddRollInfo( const ARollInfo: TRollInfo );
var
  total: Integer;
begin
  Validate( ARollInfo );
  FFrameInfo.Rolls.Add( ARollInfo );
  Inc( FFrameInfo.RollTotal, ARollInfo.Pins );
  total := FFrameInfo.RollTotal;
  if Assigned( FPrevFrame ) then
    total := FPrevFrame.FrameTotal + FFrameInfo.RollTotal;
  UpdateFrameTotal(  total );
  //check for total is spare or strike
  if FFrameInfo.RollTotal = FGameConfig.MaxPinCountPerRoll then
  begin
    //spare
    FFrameInfo.Status := fsSpare;
    //strike - current roll.pins hit max pin per roll
    if ( ARollInfo.Pins =  FGameConfig.MaxPinCountPerRoll ) then
      FFrameInfo.Status := fsStrike;
  end;
  ScoreFrameChanged;
end;

procedure TScoreFrame.AddToFrameTotal(const APins: Integer);
begin
  Inc( FFrameInfo.ExtraPinTotal, APins );
  UpdateFrameTotal( GetPrevFrameInfo.FrameTotal + RollTotal + FFrameInfo.ExtraPinTotal );
end;

procedure TScoreFrame.UpdateFrameTotal( const ATotal: Integer );
begin
  FFrameInfo.FrameTotal := ATotal;
  ScoreFrameChanged;
end;

end.
