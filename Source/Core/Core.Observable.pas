unit Core.Observable;

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
  ;


type

  TGameObserver = class(TInterfacedObject, IGameObserver)
  public
    procedure Update(const AData: TValue); virtual; abstract;
  end;

  TGameObservable = class(TObservable<IGameObserver>)
  strict private
    FGameData: TValue;
  protected
    procedure DoNotify(const AObserver: IGameObserver); override;
  public
    procedure UpdateView(const AGameData: TValue);
  end;


implementation

{ TGameObservable }

procedure TGameObservable.DoNotify(const AObserver: IGameObserver);
begin
  inherited;
  AObserver.Update(FGameData);
end;

procedure TGameObservable.UpdateView(const AGameData: TValue);
begin
  FGameData := AGameData;
  Notify;
end;

end.
