unit Core.ListProcessor;

interface

uses
    System.SysUtils
  , System.Classes
  , System.Rtti

  {Spring}
  , Spring
  , Spring.Collections
  , Spring.Collections.LinkedLists

  {BowlingGame}
  , Core.BaseInterfaces
  , Core.Interfaces
  ;


type

  TGameLinkedList<T> = class(TLinkedList<T>, IGameLinkedList<T>)
  end;

  TLinkedListProcessor<TKey, TVal> = class(TInterfacedObject, IGameDataProcessor<TKey, TVal>)
  strict private
    FLinks: IDictionary<TKey, IGameLinkedList<TVal>>;
    function GetNewLinkedList: IGameLinkedList<TVal>;
  strict protected
    function ProcessDataItem( AItem: TVal; AInitialParam, ALastLinkResult: TValue ): TValue; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function GetCount: Integer;
    function GetCountAtKey(const AKey: TKey): Integer;
    procedure AddItemAtKey(const AKey: TKey; const AValue: TVal);
    function ExtractItemAtKey(const AKey: TKey): TVal;
    function Extract(const AKey: TKey): IGameLinkedList<TVal>;
    procedure ProcessData( AKey: TKey; AInitialParam: TValue );
  public
    property Count: Integer read GetCount;
    property CountAtKey[const AKey: TKey]: Integer read GetCountAtKey;
  end;


implementation

uses
    Spring.Services
  ;



{ TLinkedListProcessor<TKey, TVal> }

constructor TLinkedListProcessor<TKey, TVal>.Create;
begin
  inherited Create;
  //FLinks := ServiceLocator.GetService< IDictionaryQueue<TKey, IGameLinkedList<TVal>> >;
  FLinks := TCollections.CreateDictionary<TKey, IGameLinkedList<TVal>>;
end;

destructor TLinkedListProcessor<TKey, TVal>.Destroy;
begin
  FLinks.Clear;
  inherited;
end;

function TLinkedListProcessor<TKey, TVal>.Extract(
  const AKey: TKey): IGameLinkedList<TVal>;
begin
  Result := FLinks.Extract( AKey );
end;

function TLinkedListProcessor<TKey, TVal>.GetCount: Integer;
begin
  Result := FLinks.Count;
end;

function TLinkedListProcessor<TKey, TVal>.GetCountAtKey(
  const AKey: TKey): Integer;
begin
  Result := 0;
  if FLinks.ContainsKey( AKey ) then
    Result := FLinks.Items[ AKey ].Count;
end;

function TLinkedListProcessor<TKey, TVal>.GetNewLinkedList: IGameLinkedList<TVal>;
begin
  Result := ServiceLocator.GetService< IGameLinkedList<TVal> >;
end;

procedure TLinkedListProcessor<TKey, TVal>.AddItemAtKey(const AKey: TKey;
  const AValue: TVal);
var
  VL: IGameLinkedList<TVal>;
begin
  if not FLinks.TryGetValue( AKey, VL ) then
  begin
    VL := GetNewLinkedList;
    FLinks.Add( AKey, VL );
  end;
  VL.Add( AValue );
end;

function TLinkedListProcessor<TKey, TVal>.ExtractItemAtKey(
  const AKey: TKey): TVal;
var
  VL: IGameLinkedList<TVal>;
begin
  Result := Default( TVal );
  if FLinks.TryGetValue( AKey, VL ) then
  begin
    if (VL.Count > 0) then
    begin
      Result := VL.FirstOrDefault;
      VL.RemoveFirst;
    end;
    if (VL.Count = 0) then
      FLinks.Remove( AKey );
  end;
end;

procedure TLinkedListProcessor<TKey, TVal>.Clear;
begin
  FLinks.Clear;
end;

procedure TLinkedListProcessor<TKey, TVal>.ProcessData(AKey: TKey;
  AInitialParam: TValue);
var
  item: TVal;
  VL: IGameLinkedList<TVal>;
  retVal: TValue;
  node: TLinkedListNode<TVal>;
  idx: Integer;
begin
  //Logger.Log( llVerbose, 'TLinkedListProcessor<TKey, TVal>.ProcessData', leEntry );
  try
    if not FLinks.TryGetValue( AKey, VL ) or ( GetCountAtKey( AKey ) = 0 ) then
      Exit;
    VL := Extract( AKey );
    idx := 0;
    node := nil;
    if VL.Count > 0 then
      node := VL.First;
    retVal := 0;
    while Assigned( node ) do
    begin
      item := node.Value;
      retVal := ProcessDataItem( item, AInitialParam, retVal );
      node := node.Next;
    end;
  finally
    //Logger.Log( llVerbose, 'TLinkedListProcessor<TKey, TVal>.ProcessData', leExit );
  end;
end;


end.
