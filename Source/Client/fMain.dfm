object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Bowling Game'
  ClientHeight = 424
  ClientWidth = 758
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pScoreBoard: TPanel
    Left = 265
    Top = 0
    Width = 493
    Height = 424
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 759
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 491
      Height = 35
      Align = alTop
      Caption = 'Score Board'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
  end
  object pGameInputs: TPanel
    Left = 0
    Top = 0
    Width = 265
    Height = 424
    Align = alLeft
    TabOrder = 1
    ExplicitHeight = 759
    object GroupBox1: TGroupBox
      Left = 1
      Top = 161
      Width = 263
      Height = 152
      Align = alTop
      Caption = 'Score Options'
      TabOrder = 0
      object Label1: TLabel
        Left = 15
        Top = 15
        Width = 50
        Height = 13
        Caption = 'Frame No:'
      end
      object lblScoreRoll1: TLabel
        Left = 23
        Top = 72
        Width = 30
        Height = 13
        Caption = 'Roll 1:'
      end
      object lblScoreRoll2: TLabel
        Left = 23
        Top = 95
        Width = 30
        Height = 13
        Caption = 'Roll 2:'
      end
      object lblScoreRoll3: TLabel
        Left = 23
        Top = 118
        Width = 30
        Height = 13
        Caption = 'Roll 3:'
      end
      object lblScoreFrame: TLabel
        Left = 175
        Top = 112
        Width = 58
        Height = 25
        AutoSize = False
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
      object Button2: TButton
        Left = 13
        Top = 41
        Width = 245
        Height = 25
        Action = actGetFrameScore
        TabOrder = 0
      end
      object edFrameNo: TEdit
        Left = 71
        Top = 14
        Width = 187
        Height = 21
        TabOrder = 1
        Text = '1'
      end
      object edScoreRoll1: TEdit
        Left = 71
        Top = 72
        Width = 82
        Height = 21
        Color = clMenuBar
        ReadOnly = True
        TabOrder = 2
        Text = '0'
      end
      object edScoreRoll2: TEdit
        Left = 71
        Top = 95
        Width = 82
        Height = 21
        Color = clMenuBar
        ReadOnly = True
        TabOrder = 3
        Text = '0'
      end
      object edScoreRoll3: TEdit
        Left = 71
        Top = 118
        Width = 82
        Height = 21
        Color = clMenuBar
        ReadOnly = True
        TabOrder = 4
        Text = '0'
      end
    end
    object GroupBox3: TGroupBox
      Left = 1
      Top = 81
      Width = 263
      Height = 80
      Align = alTop
      Caption = 'Ball Rolling Options'
      TabOrder = 1
      object Label3: TLabel
        Left = 13
        Top = 15
        Width = 50
        Height = 13
        Caption = 'Pin Count:'
      end
      object edPinCount: TEdit
        Left = 83
        Top = 14
        Width = 176
        Height = 21
        TabOrder = 0
        Text = '1'
      end
      object Button1: TButton
        Left = 13
        Top = 41
        Width = 245
        Height = 25
        Action = actRollBall
        TabOrder = 1
      end
    end
    object GroupBox2: TGroupBox
      Left = 1
      Top = 1
      Width = 263
      Height = 80
      Align = alTop
      Caption = 'New Game Options'
      TabOrder = 2
      object Label2: TLabel
        Left = 13
        Top = 17
        Width = 64
        Height = 13
        Caption = 'Player Name:'
      end
      object Button3: TButton
        Left = 12
        Top = 41
        Width = 246
        Height = 25
        Action = actStartGame
        TabOrder = 0
      end
      object edPlayerName: TEdit
        Left = 83
        Top = 14
        Width = 176
        Height = 21
        TabOrder = 1
        Text = 'Ravinder'
      end
    end
  end
  object alMain: TActionList
    Left = 432
    Top = 328
    object actStartGame: TAction
      Caption = 'Start Game'
      OnExecute = actStartGameExecute
    end
    object actRollBall: TAction
      Caption = 'Roll Ball'
      OnExecute = actRollBallExecute
    end
    object actGetFrameScore: TAction
      Caption = 'Get Frame Score'
      OnExecute = actGetFrameScoreExecute
    end
  end
end
