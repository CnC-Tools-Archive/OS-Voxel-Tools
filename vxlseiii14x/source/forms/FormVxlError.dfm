object FrmVxlError: TFrmVxlError
  Left = 243
  Top = 216
  BorderStyle = bsToolWindow
  Caption = ' '
  ClientHeight = 325
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel3: TBevel
    Left = 0
    Top = 58
    Width = 490
    Height = 7
    Align = alTop
    Shape = bsTopLine
  end
  object Bevel4: TBevel
    Left = 0
    Top = 271
    Width = 490
    Height = 8
    Align = alBottom
    Shape = bsBottomLine
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 490
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 490
      Height = 58
      Align = alClient
    end
    object Label5: TLabel
      Left = 24
      Top = 24
      Width = 235
      Height = 13
      Caption = 'This window reports errors in the voxel you loaded'
      Transparent = True
    end
    object Label6: TLabel
      Left = 8
      Top = 8
      Width = 63
      Height = 13
      Caption = 'Voxel Error'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 279
    Width = 490
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    object BtClose: TButton
      Left = 408
      Top = 11
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'Close'
      TabOrder = 0
      OnClick = BtCloseClick
    end
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 72
    Width = 473
    Height = 193
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Header Information'
      object Label1: TLabel
        Left = 8
        Top = 8
        Width = 68
        Height = 13
        Caption = 'Information:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object InfoBox1: TRichEdit
        Left = 8
        Top = 32
        Width = 449
        Height = 89
        Color = clBtnFace
        Lines.Strings = (
          
            'The voxels header contains information like what it is, the size' +
            ' of the body part of the file, '
          'etc. '
          
            'One or more of these do not appear to be correct. Fixing this ca' +
            'n not harm your voxel.'
          ''
          'Cause:'
          'VXLSE III v1.0 when creating voxels.')
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object BtFixErrorHeader: TButton
        Left = 8
        Top = 128
        Width = 75
        Height = 25
        Caption = 'Fix Error'
        TabOrder = 1
        OnClick = BtFixErrorHeaderClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Normals'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label2: TLabel
        Left = 8
        Top = 8
        Width = 68
        Height = 13
        Caption = 'Information:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RichEdit1: TRichEdit
        Left = 8
        Top = 32
        Width = 449
        Height = 89
        Color = clBtnFace
        Lines.Strings = (
          
            'One or more of the voxels sections has differing normals values,' +
            ' the voxel can only be one '
          'voxel type. '
          ''
          'Cause:'
          
            'This error can be caused by the old VXLSE II Import Section and ' +
            'manualy editing normals.')
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object BtFixErrorNormals: TButton
        Left = 8
        Top = 128
        Width = 75
        Height = 25
        Caption = 'Fix Error'
        TabOrder = 1
        OnClick = BtFixErrorNormalsClick
      end
    end
  end
end
