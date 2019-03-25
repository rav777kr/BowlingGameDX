object GameScoreBoardFrame: TGameScoreBoardFrame
  Left = 0
  Top = 0
  Width = 561
  Height = 490
  TabOrder = 0
  object sgScore: TStringGrid
    Left = 0
    Top = 0
    Width = 561
    Height = 392
    Align = alClient
    DrawingStyle = gdsGradient
    FixedColor = clActiveBorder
    RowCount = 10
    GradientEndColor = clSilver
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 0
    OnDrawCell = sgScoreDrawCell
  end
  object Panel1: TPanel
    Left = 0
    Top = 392
    Width = 561
    Height = 98
    Align = alBottom
    TabOrder = 1
    object lblTotalScore: TLabel
      Left = 153
      Top = 1
      Width = 88
      Height = 96
      Align = alLeft
      AutoSize = False
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 1
    end
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 152
      Height = 96
      Align = alLeft
      AutoSize = False
      Caption = 'Total Score:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
  end
end
