unit Core.Interfaces;

interface

uses
    Spring.Collections
  , Spring.DesignPatterns
  , Core.BaseInterfaces
  , SysUtils
   ;


type

  EGameException = class(Exception);
  EGameInvalidValueException = class(EGameException);
  EValueNotFoundException = class(EGameException);

  IScoreFrame = interface;
  TFrameStatus = (fsNormal, fsSpare, fsStrike);

  TRollInfo = record
    RollNo: Integer;
    Pins: Integer;
    constructor Create(const ARollNo, APins: Integer);
  end;

  TFrameInfo = record
    FrameNo: Integer;
    Rolls: IList<TRollInfo>;
    RollTotal: Integer;
    ExtraPinTotal: Integer;
    FrameTotal: Integer;
    Status: TFrameStatus;
    constructor Create(const AFrameNo, AFrameTotal: Integer; const AStatus: TFrameStatus);
  end;

  IBall = interface
    ['{D8AB5FAD-DAC8-4650-84BA-F6CE1E47EC19}']
    procedure Roll(const ARollInfo: TRollInfo);
  end;

  IBallFactory = interface
    ['{DCE2E62B-ECA1-403C-BE95-76ED3BDB9AC6}']
    function CreateBall(const AFrame: IScoreFrame): IBall;
  end;

  IScoreFrameProcessor = interface(IGameDataProcessor<Integer, IScoreFrame>)
    ['{0D005AFF-F592-4B73-A8A7-AF7C4B4A9F7A}']
  end;

  IScoreFrame = interface(IGameObservable)
    ['{1313AA67-A5D9-4B75-9092-533C1B6431A6}']
    function GetFrameNo: Integer;
    function GetStatus: TFrameStatus;
    function GetFrameTotal: Integer;
    function GetRollTotal: Integer;
    function GetRolls: IList<TRollInfo>;
    function GetFrameInfo: TFrameInfo;
    function GetPrevFrameInfo: TFrameInfo;
    procedure AddRollInfo(const ARollInfo: TRollInfo);
    procedure UpdateFrameTotal(const ATotal: Integer);
    procedure AddToFrameTotal(const APins: Integer);

    property FrameTotal: Integer read GetFrameTotal;
    property RollTotal: Integer read GetRollTotal;
    property FrameNo: Integer read GetFrameNo;
    property Rolls: IList<TRollInfo> read GetRolls;
    property Status: TFrameStatus read GetStatus;
    property FrameInfo: TFrameInfo read GetFrameInfo;
  end;

  IScoreFrameFactory = interface
    ['{5EAC514E-F37D-4FDE-AD95-F279B6A1C570}']
    function CreateFrame(const AFrameNo: Integer; APrevFrame: IScoreFrame): IScoreFrame;
  end;

  IScoreCard = interface
    ['{BA7DD8C0-EAF6-4467-9AE7-EA6BB6378525}']
    function GetPlayerName: String;
    procedure SetPlayerName(const AValue: String);
    function GetFrameInfoByFrameNo(const AFrameNo: Integer): TFrameInfo;
    function GetTotalScore: Integer;
    procedure ResetScoreCard(const APlayerName: String);
    procedure RollBall(const APinCount: Integer);
    procedure RegisterObserver(AObserver: IGameObserver);
    procedure UnregisterObserver(AObserver: IGameObserver);

    property PlayerName: String read GetPlayerName write SetPlayerName;
  end;

  IBowlingGame = interface
    ['{3AC22901-7FD8-42CF-AC2D-D8C115C37A7F}']
    procedure StartGame(const APlayerName: String);
    procedure RollBall(const APins: Integer);
    function GetScoreByFrame(const AFrameNo: Integer): TFrameInfo;
    function GetTotalScore: Integer;
    procedure RegisterObserver(AObserver: IGameObserver);
    procedure UnregisterObserver(AObserver: IGameObserver);
  end;

implementation



{ TRollInfo }

constructor TRollInfo.Create(const ARollNo, APins: Integer);
begin
  RollNo := ARollNo;
  Pins := APins;
end;

{ TFrameInfo }

constructor TFrameInfo.Create(const AFrameNo, AFrameTotal: Integer;
  const AStatus: TFrameStatus);
begin
  FrameNo := AFrameNo;
  FrameTotal := AFrameTotal;
  Status := AStatus;
  ExtraPinTotal := 0;
end;

end.
