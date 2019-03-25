unit frmGameScoreBoard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls
  , Rtti
  {Spring}
  , Spring.Collections
  {BowlingGame}
  , Core.BaseInterfaces
  , Core.Interfaces
  , Core.Observable, Vcl.Grids
  //, Core.ScoreMonitor
  ;

type

  TframeCardItem = class(TPanel)
  private
    FMemo: TMemo;
  public
    constructor Create( AOwner: TComponent );
    destructor Destroy; override;
    procedure Update(const AFrame: TFrameInfo);
  end;

  TGridViewUpdater = class(TGameObserver)
  strict private
    FLastFrameInfo: TFrameInfo;
    FFrameItemCache: IDictionary<String, TPanel>;
    FOwner: TComponent;
    FFrameControl: TFrame;
    FGrid: TStringGrid;
    procedure SetupGrid;
    function FindFrameRow(const ARowText: String): Integer;
    procedure UpdateGridRow(const AFrame: TFrameInfo);
    procedure AddOrUpdateFrame(const AFrameInfo: TFrameInfo);
  public
    constructor Create( AOwner: TComponent; AFrameControl: TFrame; AGrid: TStringGrid );
    destructor Destroy; override;
    procedure Update(const AFrame: TValue); override;
  end;

  TGameScoreBoardFrame = class(TFrame)
    sgScore: TStringGrid;
    Panel1: TPanel;
    lblTotalScore: TLabel;
    Label1: TLabel;
    procedure sgScoreDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
  strict private
    FGame: IBowlingGame;
    //FScoreCardUpdater: IScoreCardUpdater;
    FScoreCardUpdater: IGameObserver;
  public
    constructor Create( AOwner: TComponent; AGame: IBowlingGame );
    destructor Destroy; override;
  end;

implementation

uses
  System.TypInfo
  ;


{$R *.dfm}

const
  ciMAX_FRAME_COUNT = 10;
  ciMAX_FRAME_ITEM_COUNT = 8;
  ciCol_FrameNo = 0;
  ciCol_FrameTotal = 1;
  ciCol_Status = 2;
  ciCol_ExtraPins = 3;
  ciCol_RollTotal = 4;
  ciCol_RollNo1 = 5;
  ciCol_RollNo2 = 6;
  ciCol_RollNo3 = 7;


{ TGridViewUpdater }

constructor TGridViewUpdater.Create( AOwner: TComponent;
  AFrameControl: TFrame; AGrid: TStringGrid );
begin
  inherited Create;
  FOwner := AOwner;
  FFrameControl := AFrameControl;
  FGrid := AGrid;
  SetupGrid;
  //FFrameItemCache := TCollections.CreateDictionary<String, TPanel>([doOwnsValues]);
  FFrameItemCache := TCollections.CreateDictionary<String, TPanel>;
  FLastFrameInfo.FrameNo := -1;
end;

destructor TGridViewUpdater.Destroy;
begin

  inherited;
end;


function TGridViewUpdater.FindFrameRow(const ARowText: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FGrid.RowCount - 1 do
  begin
    if SameText( FGrid.Cells[ ciCol_FrameNo, I ], ARowText ) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TGridViewUpdater.SetupGrid;
begin
  FGrid.RowCount := FGrid.FixedRows + ciMAX_FRAME_COUNT;
  FGrid.ColCount := FGrid.FixedCols + ciMAX_FRAME_ITEM_COUNT;
  FGrid.Cells[ciCol_FrameNo, 0] := 'Frame#';
  FGrid.Cells[ciCol_FrameTotal, 0] := 'Frame Total';
  FGrid.Cells[ciCol_Status, 0] := 'Status';
  FGrid.Cells[ciCol_ExtraPins, 0] := 'Extra';
  FGrid.Cells[ciCol_RollTotal, 0] := 'Roll Total';
  FGrid.Cells[ciCol_RollNo1, 0] := 'R1';
  FGrid.Cells[ciCol_RollNo2, 0] := 'R2';
  FGrid.Cells[ciCol_RollNo3, 0] := 'R3';

  FGrid.ColWidths[ciCol_FrameTotal] := 70;
  FGrid.ColWidths[ciCol_FrameNo] := 50;
  FGrid.ColWidths[ciCol_Status] := 50;
  FGrid.ColWidths[ciCol_ExtraPins] := 40;
  FGrid.ColWidths[ciCol_RollTotal] := 60;
  FGrid.ColWidths[ciCol_RollNo1] := 30;
  FGrid.ColWidths[ciCol_RollNo2] := 30;
  FGrid.ColWidths[ciCol_RollNo3] := 30;
end;

procedure TGridViewUpdater.Update(const AFrame: TValue);
begin
  inherited;
  AddOrUpdateFrame( AFrame.AsType<TFrameInfo> );
end;

procedure TGridViewUpdater.UpdateGridRow(const AFrame: TFrameInfo);
var
  row: Integer;
  tmpName: String;
begin
  row := FindFrameRow( AFrame.FrameNo.ToString );
  if row < 0 then
    row := FGrid.FixedRows + AFrame.FrameNo - 1;
  FGrid.Row := row;
  tmpName := GetEnumName( TypeInfo( TFrameStatus ), Ord( AFrame.Status ) );
  FGrid.Cells[ciCol_FrameNo, row] := AFrame.FrameNo.ToString;
  FGrid.Cells[ciCol_FrameTotal, row] := AFrame.FrameTotal.ToString;
  FGrid.Cells[ciCol_Status, row] := tmpName.Substring(2);
  FGrid.Cells[ciCol_ExtraPins, row] := AFrame.ExtraPinTotal.ToString;
  FGrid.Cells[ciCol_RollTotal, row] := AFrame.RollTotal.ToString;
  FGrid.Cells[ciCol_RollNo1, row] := EmptyStr;
  FGrid.Cells[ciCol_RollNo2, row] := EmptyStr;
  FGrid.Cells[ciCol_RollNo3, row] := EmptyStr;
  if AFrame.Rolls.Count > 0 then
    FGrid.Cells[ciCol_RollNo1, row] := IntToStr( AFrame.Rolls[0].Pins );
  if AFrame.Rolls.Count > 1 then
    FGrid.Cells[ciCol_RollNo2, row] := IntToStr( AFrame.Rolls[1].Pins );
  if AFrame.Rolls.Count > 2 then
    FGrid.Cells[ciCol_RollNo3, row] := IntToStr( AFrame.Rolls[2].Pins );
  with TGameScoreBoardFrame(FFrameControl) do
  begin
    lblTotalScore.Caption := AFrame.FrameTotal.ToString;
  end;
end;

procedure TGridViewUpdater.AddOrUpdateFrame(const AFrameInfo: TFrameInfo);
var
  fi: TPanel;
begin
  {
  if not FFrameItemCache.TryGetValue( AFrameInfo.FrameNo.ToString, fi ) then
  begin
    fi := TframeCardItem.Create(FOwner);
    fi.Parent := FFrameControl;
    fi.Align := alBottom;
    fi.Align := alTop;
    fi.Height := 80;
    FFrameItemCache.Add( AFrameInfo.FrameNo.ToString, fi );
  end;
  (fi as TframeCardItem).Update( AFrameInfo );
  fi.Font.Color := clRed;
  if ( FLastFrameInfo.FrameNo <> AFrameInfo.FrameNo ) then
  begin
    if FFrameItemCache.TryGetValue( FLastFrameInfo.FrameNo.ToString, fi ) then
    begin
      fi.Font.Color := clBlack;
    end;
    FLastFrameInfo := AFrameInfo;
  end;
  }
  UpdateGridRow( AFrameInfo );
end;


{ TframeCardItem }

constructor TframeCardItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMemo := TMemo.Create(AOwner);
  FMemo.Parent := Self;
  FMemo.Align := alClient;
  FMemo.ReadOnly := True;
  FMemo.ScrollBars := ssVertical;
  FMemo.Text := '';
end;

destructor TframeCardItem.Destroy;
begin
  FMemo.Free;
  inherited;
end;

procedure TframeCardItem.Update(const AFrame: TFrameInfo);
var
  I: Integer;
  tmpName: String;
begin
  tmpName := GetEnumName( TypeInfo( TFrameStatus ), Ord( AFrame.Status ) );
  FMemo.Clear;
  FMemo.Lines.Add(Format('FRAME #: %0:d    Frame Total: %1:d  ExtraPins: %2:d  Status: %3:s',[ AFrame.FrameNo, AFrame.FrameTotal, AFrame.ExtraPinTotal, tmpName ]));
  FMemo.Lines.Add(Format('Roll Count: %0:d   Roll Total: %1:d ',[ AFrame.Rolls.Count, AFrame.RollTotal ]));
  for I := 0 to Pred( AFrame.Rolls.Count ) do
    FMemo.Lines.Add(Format('Roll No %0:d : %1:d',[ AFrame.Rolls.Items[I].RollNo, AFrame.Rolls.Items[I].Pins ]));
  //FMemo.Lines.Add(Format('FRAME TOTAL: %d',[ AFrame.FrameTotal ]));
  //FMemo.Lines.Add(Format('Status: %s',[ tmpName ]));
end;

{ TGameScoreBoardFrame }

constructor TGameScoreBoardFrame.Create(AOwner: TComponent;
  AGame: IBowlingGame);
begin
  inherited Create(AOwner);
  FGame := AGame;
  FScoreCardUpdater := TGridViewUpdater.Create( Owner, Self, sgScore );
  FGame.RegisterObserver( FScoreCardUpdater );
end;

destructor TGameScoreBoardFrame.Destroy;
begin
  FGame.UnregisterObserver( FScoreCardUpdater );
  inherited;
end;

procedure TGameScoreBoardFrame.sgScoreDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
//
end;

end.
