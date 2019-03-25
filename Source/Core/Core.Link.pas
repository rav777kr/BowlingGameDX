unit Core.Link;

interface

uses
    System.SysUtils
  , System.Classes
  , System.Rtti

  {BowlingGame}
  , Core.BaseInterfaces
  ;


type

  TGameLink<T> = class(TInterfacedObject, IGameLink<T>)
  strict protected
    FParentFrame: T;
    FChildFrame: T;
  public
    constructor Create(AParentFrame, AChildFrame: T);
    destructor Destroy; override;
    function UpdateLink: TValue; virtual; abstract;
  end;

implementation


{ TGameLink<T> }

constructor TGameLink<T>.Create(AParentFrame, AChildFrame: T);
begin
  inherited Create;
  FParentFrame := AParentFrame;
  FChildFrame := AChildFrame;
end;

destructor TGameLink<T>.Destroy;
begin
  inherited;
end;


end.
