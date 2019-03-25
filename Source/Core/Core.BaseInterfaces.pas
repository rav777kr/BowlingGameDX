unit Core.BaseInterfaces;

interface

uses
    Spring.Collections
  , Spring.DesignPatterns
  , Rtti
   ;


type

  IGameObserver = interface
    ['{12747FB2-8809-464D-A8C0-278DEF88F8CF}']
    procedure Update(const AData: TValue);
  end;

  IGameObservable = interface (IObservable<IGameObserver>)
    ['{A001A725-CBCF-4952-B1CB-A860B244A4E9}']
    procedure UpdateView(const AGameData: TValue);
  end;

  IGameLink<T> = interface
    ['{993631F9-E46D-4D6A-A067-E7E38E7BAC60}']
    function UpdateLink: TValue;
  end;

  IGameConfig = interface
    ['{2C5CFA02-6ED1-4DF5-AE83-EE2D2D0A91FB}']
    function GetMaxFrameCount: Integer;
    function GetLastFrameMaxRollCount: Integer;
    function GetNonLastFrameMaxRollCount: Integer;
    function GetMaxPinCountPerRoll: Integer;

    property MaxFrameCount: Integer read GetMaxFrameCount;
    property NonLastFrameMaxRollCount: Integer read GetNonLastFrameMaxRollCount;
    property LastFrameMaxRollCount: Integer read GetLastFrameMaxRollCount;
    property MaxPinCountPerRoll: Integer read GetMaxPinCountPerRoll;
  end;

  IGameLinkedList<T> = interface(ILinkedList<T>)
    ['{7CC38B03-DCC0-49BD-864C-FE14384DD72A}']
  end;

  IGameDataProcessor<K, V> = interface
    ['{474FB646-5BEF-4C0A-A7D0-956813A74EFF}']
    //clear the dictionary
    procedure Clear;
    //dictionary item count
    function GetCount: Integer;
    //get the queue item count i.e. dictionary value at this key level
    function GetCountAtKey(const AKey: K): Integer;
    //push an entry in queue i.e. dictionary value at this key level
    procedure AddItemAtKey(const AKey: K; const AValue: V);
    //pop an entry from the queue i.e. dictionary value at this key level
    function ExtractItemAtKey(const AKey: K): V;
    //extract the entry i.e. queue from the dictionary
    function Extract(const AKey: K): IGameLinkedList<V>;
    //process all links i.e. queue from the dictionary
    procedure ProcessData( AKey: K; AInitialParam: TValue );

    property Count: Integer read GetCount;
    property CountAtKey[const AKey: K]: Integer read GetCountAtKey;
  end;


implementation


end.
