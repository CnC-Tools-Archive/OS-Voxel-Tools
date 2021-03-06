object Frm3DModelizer: TFrm3DModelizer
  Left = 723
  Top = 264
  BorderStyle = bsSizeToolWin
  Caption = '3D Modelizer'
  ClientHeight = 1003
  ClientWidth = 363
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 26
    Width = 363
    Height = 977
    Cursor = crCross
    Align = alClient
    BevelOuter = bvLowered
    Color = clBlack
    ParentBackground = False
    TabOrder = 0
    OnMouseDown = Panel2MouseDown
    OnMouseMove = Panel2MouseMove
    OnMouseUp = Panel2MouseUp
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 363
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      363
      26)
    object SpeedButton2: TSpeedButton
      Left = 2
      Top = 3
      Width = 23
      Height = 22
      Hint = 'Reset Depth'
      Flat = True
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        1800000000000003000000000000000000000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF808080FF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF80808000000000000000000000
        0000808080FF00FFFF00FF000000808080FF00FFFF00FFFF00FFFF00FFFF00FF
        0000000000000000000000000000000000000000000000008080800000000000
        00FF00FFFF00FFFF00FF808080000000000000808080FF00FFFF00FFFF00FFFF
        00FF808080000000000000000000000000808080FF00FFFF00FF808080000000
        808080FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000000000000000000000
        00000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FF808080000000000000000000000000000000808080FF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000000000000000000000000000
        00000000000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000000000
        000000000000000000000000000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FF808080000000000000000000000000000000808080FF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000
        000000000000000000000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF8080
        80000000808080FF00FFFF00FF808080000000000000000000000000808080FF
        00FFFF00FFFF00FFFF00FF808080000000000000808080FF00FFFF00FFFF00FF
        0000000000008080800000000000000000000000000000000000000000000000
        00FF00FFFF00FFFF00FFFF00FFFF00FF808080000000FF00FFFF00FF80808000
        0000000000000000000000808080FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FF808080FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
      ParentShowHint = False
      ShowHint = True
      OnClick = SpeedButton2Click
    end
    object btn3DRotateX2: TSpeedButton
      Left = 48
      Top = 3
      Width = 24
      Height = 22
      Hint = 'Rotate Up'
      AllowAllUp = True
      GroupIndex = 20
      Flat = True
      Glyph.Data = {
        EE000000424DEE0000000000000076000000280000000D0000000F0000000100
        04000000000078000000C40E0000C40E00001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777778877777
        7000777770077777700077777800777770007777778087777000777777700777
        7000777777700777700077777770077770007777777007777000777087808777
        7000777000007777700077700008777770007770000008777000777000008777
        700077700087777770007770877777777000}
      ParentShowHint = False
      ShowHint = True
      OnClick = btn3DRotateX2Click
    end
    object btn3DRotateY2: TSpeedButton
      Left = 72
      Top = 3
      Width = 23
      Height = 22
      Hint = 'Rotate Left'
      AllowAllUp = True
      GroupIndex = 21
      Flat = True
      Glyph.Data = {
        EE000000424DEE0000000000000076000000280000000F0000000F0000000100
        04000000000078000000C40E0000C40E00001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7770777777777777777077777777777777707777777777777770777777777777
        7770000000077777777080000087777777707000007777778080780000877778
        0080770080000000077077807780000877707778777777777770777777777777
        777077777777777777707777777777777770}
      ParentShowHint = False
      ShowHint = True
      OnClick = btn3DRotateY2Click
    end
    object btn3DRotateY: TSpeedButton
      Left = 95
      Top = 3
      Width = 23
      Height = 22
      Hint = 'Rotate Right'
      AllowAllUp = True
      GroupIndex = 21
      Flat = True
      Glyph.Data = {
        EE000000424DEE0000000000000076000000280000000F0000000F0000000100
        04000000000078000000C40E0000C40E00001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7770777777777777777077777777777777707777777777787770777800008770
        8770770000000080077080087777800008708087777770000070777777778000
        0080777777770000000077777777777777707777777777777770777777777777
        777077777777777777707777777777777770}
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      OnClick = btn3DRotateYClick
    end
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 363
      Height = 2
      Align = alTop
      Shape = bsTopLine
      ExplicitWidth = 240
    end
    object SpeedButton1: TSpeedButton
      Left = 118
      Top = 3
      Width = 23
      Height = 22
      Hint = 'Views'
      Flat = True
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000130B0000130B000000000000000000006C63634C4747
        413C3C403B3B4C47473B3636524D4D4540402924242924242924242924242924
        24292424292424453C3C5854542727271919190808081A1A1A00000000000000
        00000000000000000000000000000000000000000000002721213B3636000000
        0000000000000000000202031F1F1F0808080000000000000000000000000000
        000000000000002721213B363600000000000005050503033E1F1F5A30303011
        11110202020000000000000000000000000000000000002721213B3636000000
        00000030303049495E3C3C3C3434342929490202400A0A0A0101010000000000
        000000000000002721213B36360000000000001C1C1C31313106060D00000018
        181E3D3D652A2A2A0F0F0F0000000000000000000000002721213B3636000000
        0000000000000000000000002424245959632E2E5D2323270B0B0B0000000000
        000000000000002721213B36360000000000000000000000000000000C0C0C12
        123D0F0F4800000D0000000000000000000000000000002721213B3636000000
        0000000000000000000000000000000000001111110000000000000000000000
        000000000000002721213B363600000000000000000000000000000000000000
        00000404040000000000000000000000000000000000002721213B3636000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000002721218D83836B64645D57575F58584A43434A43434A434349
        43434741414540404A43434A43434A43434A43434A4343625757CBB9B9A29494
        B1A1A1B9A8A8A29393C0AFAFA69797946B5FB59E9AAA9A9ACAB7B7CAB7B7CAB7
        B7CAB7B7CAB7B7C6B1B1C7B4B4BAA8A8C3B0B0B6A4A4B7A5A5C1AEAEC8B4B4BC
        A8A8BBA8A8BFACACC8B4B4C8B4B4C8B4B4C8B4B4C8B4B4C4AFAFB19792A58A84
        B49790AC938EAD928CBBA19ABFA39BC3A7A0C5ABA3C6ABA3C9B0A8CAAFA7CBB0
        A7CDB3AACAB2AABFA8A3B08D83A88072A87E6FB59183B38D7DB89383BB9786C0
        9C8BC6A594C9A897CDAC99CEAB96CFA991D5B198D4B5A2B49E97}
      ParentShowHint = False
      PopupMenu = Popup3d
      ShowHint = True
      OnMouseUp = SpeedButton1MouseUp
    end
    object btn3DRotateX: TSpeedButton
      Left = 25
      Top = 3
      Width = 23
      Height = 22
      Hint = 'Rotate Down'
      AllowAllUp = True
      GroupIndex = 20
      Flat = True
      Glyph.Data = {
        EE000000424DEE0000000000000076000000280000000D0000000F0000000100
        04000000000078000000C40E0000C40E00001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777778077
        7000777777800077700077778000007770007778000000777000777778000077
        7000777770000077700077778087807770007777007777777000777700777777
        7000777700777777700077770077777770007777808777777000777770087777
        700077777700777770007777778877777000}
      ParentShowHint = False
      ShowHint = True
      Transparent = False
      OnClick = btn3DRotateXClick
    end
    object SpPlay: TSpeedButton
      Left = 225
      Top = 3
      Width = 23
      Height = 22
      Anchors = [akTop, akRight]
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        33333333333333333333333333333333333333FFFFFFFFFFFFF3300000000000
        003337777777777777F330F777777777703337F33333333337F330F333333333
        703337F3333F333337F330F333033333703337F3337FF33337F330F333003333
        703337F33377FF3337F330F333000333703337F333777FF337F330F333000033
        703337F33377773337F330F333000333703337F33377733337F330F333003333
        703337F33377333337F330F333033333703337F33373333337F330F333333333
        703337F33333333337F330FFFFFFFFFFF03337FFFFFFFFFFF7F3300000000000
        0033377777777777773333333333333333333333333333333333}
      NumGlyphs = 2
      OnClick = SpPlayClick
    end
    object SpStop: TSpeedButton
      Left = 248
      Top = 3
      Width = 23
      Height = 22
      Anchors = [akTop, akRight]
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        33333333333333333333333333333333333333FFFFFFFFFFFFF3300000000000
        003337777777777777F330F777777777703337F33333333337F330F333333333
        703337F33333333337F330F333333333703337F333FFFFF337F330F330000033
        703337F3377777F337F330F330000033703337F3377777F337F330F330000033
        703337F3377777F337F330F330000033703337F3377777F337F330F330000033
        703337F33777773337F330F333333333703337F33333333337F330F333333333
        703337F33333333337F330FFFFFFFFFFF03337FFFFFFFFFFF7F3300000000000
        0033377777777777773333333333333333333333333333333333}
      NumGlyphs = 2
      OnClick = SpStopClick
    end
    object Label1: TLabel
      Left = 277
      Top = 8
      Width = 32
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Frame:'
    end
    object spin3Djmp: TSpinEdit
      Left = 144
      Top = 3
      Width = 37
      Height = 22
      Hint = 'Rotate Step Size'
      Color = clBtnFace
      MaxLength = 2
      MaxValue = 99
      MinValue = 1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Value = 10
      OnChange = spin3DjmpChange
    end
    object SpFrame: TSpinEdit
      Left = 315
      Top = 3
      Width = 50
      Height = 22
      Anchors = [akTop, akRight]
      MaxLength = 1
      MaxValue = 1
      MinValue = 1
      TabOrder = 1
      Value = 1
      OnChange = SpFrameChange
    end
  end
  object MainMenu1: TMainMenu
    Left = 144
    Top = 40
    object File1: TMenuItem
      Caption = 'File'
      object SaveModelAs: TMenuItem
        Caption = 'Save Model As...'
        OnClick = SaveModelAsClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
    object Options1: TMenuItem
      Caption = 'Options'
      object BackgroundColour1: TMenuItem
        Caption = 'Background Colour'
        OnClick = BackgroundColour1Click
      end
      object FontColor1: TMenuItem
        Caption = 'Font Color'
        OnClick = FontColor1Click
      end
    end
    object ools1: TMenuItem
      Caption = 'Tools'
      object akeScreenshotBMP1: TMenuItem
        Caption = 'Take Screenshot (BMP)'
        OnClick = akeScreenshotBMP1Click
      end
      object akeScreenshotJPG1: TMenuItem
        Caption = 'Take Screenshot (JPG)'
        OnClick = akeScreenshotJPG1Click
      end
      object akeScreenshotPNG1: TMenuItem
        Caption = 'Take Screenshot (PNG)'
        OnClick = akeScreenshotPNG1Click
      end
      object akeScreenshot1: TMenuItem
        Caption = 'Take Screenshot (TGA)'
        OnClick = akeScreenshot1Click
      end
      object akeScreenshotDDS1: TMenuItem
        Caption = 'Take Screenshot (DDS)'
        OnClick = akeScreenshotDDS1Click
      end
      object ake360DegScreenshots1: TMenuItem
        Caption = 'Make 360 Deg Animation (GIF)'
        OnClick = ake360DegScreenshots1Click
      end
      object MakeaCustom360DegAnimationGIF1: TMenuItem
        Caption = 'Make a Custom 360 Deg Animation (GIF)...'
        OnClick = MakeaCustom360DegAnimationGIF1Click
      end
    end
  end
  object ColorDialog1: TColorDialog
    Left = 176
    Top = 40
  end
  object Popup3d: TPopupMenu
    AutoPopup = False
    TrackButton = tbLeftButton
    Left = 144
    Top = 72
    object Views1: TMenuItem
      Caption = 'Views'
      object Front1: TMenuItem
        Caption = 'Front'
        OnClick = Front1Click
      end
      object Back1: TMenuItem
        Caption = 'Back'
        OnClick = Back1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object LEft1: TMenuItem
        Caption = 'Left'
        OnClick = LEft1Click
      end
      object Right1: TMenuItem
        Caption = 'Right'
        OnClick = Right1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Bottom1: TMenuItem
        Caption = 'Bottom'
        OnClick = Bottom1Click
      end
      object op1: TMenuItem
        Caption = 'Top'
        OnClick = op1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Cameo1: TMenuItem
        Caption = 'Cameo'
        OnClick = Cameo1Click
      end
      object Cameo21: TMenuItem
        Caption = 'Cameo2'
        OnClick = Cameo21Click
      end
      object Cameo31: TMenuItem
        Caption = 'Cameo3'
        OnClick = Cameo31Click
      end
      object Cameo41: TMenuItem
        Caption = 'Cameo4'
        OnClick = Cameo41Click
      end
    end
    object Display1: TMenuItem
      Caption = 'Display'
      object CurrentSectionOnly1: TMenuItem
        Caption = 'Current Section Only'
        OnClick = CurrentSectionOnly1Click
      end
      object WholeVoxel1: TMenuItem
        Caption = 'Whole Voxel'
        Checked = True
        OnClick = CurrentSectionOnly1Click
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object CameraRotationAngles1: TMenuItem
        Caption = 'Camera Rotation Angles'
        OnClick = CameraRotationAngles1Click
      end
      object EnableBackFaceCuling1: TMenuItem
        Caption = 'Enable Back Face Culing'
        OnClick = EnableBackFaceCuling1Click
      end
      object EnableShaders1: TMenuItem
        Caption = 'Enable Shaders'
        OnClick = EnableShaders1Click
      end
      object DisplayNormalVectors1: TMenuItem
        Caption = 'Display Normal Vectors'
        OnClick = DisplayNormalVectors1Click
      end
      object FillMode1: TMenuItem
        Caption = 'Fill Mode'
        object DisplayFMSolid: TMenuItem
          Caption = 'Solid'
          Checked = True
          OnClick = DisplayFMSolidClick
        end
        object DisplayFMWireframe: TMenuItem
          Caption = 'Wireframe'
          OnClick = DisplayFMWireframeClick
        end
        object DisplayFMPointCloud: TMenuItem
          Caption = 'Point Cloud'
          OnClick = DisplayFMPointCloudClick
        end
      end
    end
    object RenderQuality1: TMenuItem
      Caption = 'Model Quality'
      object RenderCubes: TMenuItem
        Caption = 'Editing Cubes (Very Low)'
        OnClick = RenderCubesClick
      end
      object RenderVisibleCubes: TMenuItem
        Caption = 'Visible Cubes (Very Low)'
        OnClick = RenderVisibleCubesClick
      end
      object RenderVisibleTriangles: TMenuItem
        Caption = 'Visible Triangle Cubes (Low)'
        OnClick = RenderVisibleTrianglesClick
      end
      object RenderQuads: TMenuItem
        Caption = 'Quad Based 3D Model (Low)'
        OnClick = RenderQuadsClick
      end
      object RenderManifolds: TMenuItem
        Caption = 'Topologically Correct Triangle Model (Low)'
        OnClick = RenderManifoldsClick
      end
      object Render4Triangles: TMenuItem
        Caption = 'High Poly 3D Model (Medium)'
        OnClick = Render4TrianglesClick
      end
      object RenderTriangles: TMenuItem
        Caption = 'Triangle Smoothed 3D Model (Medium)'
        OnClick = RenderTrianglesClick
      end
      object RenderSmoothManifolds: TMenuItem
        Caption = 'Smooth Top. Correct 3D Model (Medium)'
        Checked = True
        OnClick = RenderSmoothManifoldsClick
      end
      object RenderModel: TMenuItem
        Caption = 'Triangle Based 3D Model (High)'
        Enabled = False
        OnClick = RenderModelClick
      end
    end
    object RemapColour1: TMenuItem
      Caption = 'Remap Colour'
      object Gold1: TMenuItem
        Caption = 'Gold'
        OnClick = Gold1Click
      end
      object Red1: TMenuItem
        Caption = 'DarkRed'
        Checked = True
        OnClick = Red1Click
      end
      object Orange1: TMenuItem
        Caption = 'Orange'
        OnClick = Orange1Click
      end
      object Magenta1: TMenuItem
        Caption = 'Magenta'
        OnClick = Magenta1Click
      end
      object Purple1: TMenuItem
        Caption = 'Purple'
        OnClick = Purple1Click
      end
      object Blue1: TMenuItem
        Caption = 'DarkBlue'
        OnClick = Blue1Click
      end
      object Green1: TMenuItem
        Caption = 'DarkGreen'
        OnClick = Green1Click
      end
      object DarkSky1: TMenuItem
        Caption = 'DarkSky'
        OnClick = DarkSky1Click
      end
      object White1: TMenuItem
        Caption = 'White'
        Visible = False
        OnClick = White1Click
      end
    end
    object FaceSetup1: TMenuItem
      Caption = 'Face Settings'
      object FaceFXConvertQuadstoTriangles: TMenuItem
        Caption = 'Convert Quads to Triangles'
        OnClick = FaceFXConvertQuadstoTrianglesClick
      end
      object FaceFXConvertQuadsto48Triangles: TMenuItem
        Caption = 'Convert Quads To "4-8 Subdivision" Triangles'
        OnClick = FaceFXConvertQuadsto48TrianglesClick
      end
      object FaceFXCleanupInvisibleFaces: TMenuItem
        Caption = 'Cleanup Invisible Faces'
        OnClick = FaceFXCleanupInvisibleFacesClick
      end
      object FaceFXOptimizeMesh: TMenuItem
        Caption = 'Optimize Mesh'
        OnClick = FaceFXOptimizeMeshClick
      end
      object FaceFXOptimizeMeshIgnoringColours: TMenuItem
        Caption = 'Optimize Mesh Ignoring Colours'
        OnClick = FaceFXOptimizeMeshIgnoringColoursClick
      end
      object FaceFXOptimizeMeshCustom: TMenuItem
        Caption = 'Custom Mesh Optimization...'
        OnClick = FaceFXOptimizeMeshCustomClick
      end
    end
    object ModelEffects1: TMenuItem
      Caption = 'Model Effects'
      object QuickandRestrictedMeshOperator1: TMenuItem
        Caption = 'Quick and Restricted Mesh Operations'
        object ModelFXSmooth: TMenuItem
          Caption = 'Smooth'
          OnClick = ModelFXSmoothClick
        end
        object ModelFXSquaredSmooth: TMenuItem
          Caption = 'Squared Smooth'
          OnClick = ModelFXSquaredSmoothClick
        end
        object ModelFXHeavySmooth: TMenuItem
          Caption = 'Cubic Smooth'
          OnClick = ModelFXHeavySmoothClick
        end
        object ModelFXLanczos: TMenuItem
          Caption = 'Lanczos Smooth'
          OnClick = ModelFXLanczosClick
        end
        object ModelFXSincErosion: TMenuItem
          Caption = 'Sinc Smooth'
          OnClick = ModelFXSincErosionClick
        end
        object ModelFXEulerErosion: TMenuItem
          Caption = 'Euler Smooth'
          OnClick = ModelFXEulerErosionClick
        end
        object ModelFXHeavyEulerErosion: TMenuItem
          Caption = 'Heavy Euler Smooth'
          OnClick = ModelFXHeavyEulerErosionClick
        end
        object ModelFXSincInfiniteErosion: TMenuItem
          Caption = 'Sinc Infinite Smooth'
          OnClick = ModelFXSincInfiniteErosionClick
        end
      end
      object SlowandFlexibleMeshOperations1: TMenuItem
        Caption = 'Slow and Flexible Mesh Operations'
        object ModelFXSmooth2: TMenuItem
          Caption = 'Smooth'
          OnClick = ModelFXSmooth2Click
        end
        object ModelFXSquaredSmooth2: TMenuItem
          Caption = 'Squared Smooth'
          OnClick = ModelFXSquaredSmooth2Click
        end
        object ModelFXCubicSmooth2: TMenuItem
          Caption = 'Cubic Smooth'
          OnClick = ModelFXCubicSmooth2Click
        end
        object ModelFXLanczosSmooth2: TMenuItem
          Caption = 'Lanczos Smooth'
          OnClick = ModelFXLanczosSmooth2Click
        end
        object ModelFXSincSmooth2: TMenuItem
          Caption = 'Sinc Smooth'
          OnClick = ModelFXSincSmooth2Click
        end
        object ModelFXEulerSmooth2: TMenuItem
          Caption = 'Euler Smooth'
          OnClick = ModelFXEulerSmooth2Click
        end
        object ModelFXHeavyEulerSmooth2: TMenuItem
          Caption = 'Heavy Euler Smooth'
          OnClick = ModelFXHeavyEulerSmooth2Click
        end
        object ModelFXSincInfiniteSmooth2: TMenuItem
          Caption = 'Sinc Infinite Smooth'
          OnClick = ModelFXSincInfiniteSmooth2Click
        end
      end
      object ModelFXGaussianSmooth: TMenuItem
        Caption = 'Gaussian Smooth'
        OnClick = ModelFXGaussianSmoothClick
      end
      object ModelFXUnsharp: TMenuItem
        Caption = 'Unsharp Masking'
        OnClick = ModelFXUnsharpClick
      end
      object ModelFXInflate: TMenuItem
        Caption = 'Inflate'
        OnClick = ModelFXInflateClick
      end
      object ModelFXDeflate: TMenuItem
        Caption = 'Deflate'
        OnClick = ModelFXDeflateClick
      end
    end
    object ColourEffects1: TMenuItem
      Caption = 'Colour Effects'
      object ColourFXSmooth: TMenuItem
        Caption = 'Smooth'
        OnClick = ColourFXSmoothClick
      end
      object ColourFXHeavySmooth: TMenuItem
        Caption = 'Heavy Smooth'
        OnClick = ColourFXHeavySmoothClick
      end
      object LanczosDilatation1: TMenuItem
        Caption = 'Lanczos Smooth'
        OnClick = LanczosDilatation1Click
      end
      object ColourFXConvertFacetoVertex: TMenuItem
        Caption = 'Convert Face to Vertex Colours'
        OnClick = ColourFXConvertFacetoVertexClick
      end
      object ColourFXConvertFaceToVertexS: TMenuItem
        Caption = 'Convert Face To Vertex Colours (with Smooth)'
        OnClick = ColourFXConvertFaceToVertexSClick
      end
      object ColourFXConvertFaceToVertexHS: TMenuItem
        Caption = 'Convert Face To Vertex Colours (with Heavy Smooth)'
        OnClick = ColourFXConvertFaceToVertexHSClick
      end
      object ColourFXConvertFaceToVertexLS: TMenuItem
        Caption = 'Convert Face To Vertex Colours (with Lanczos Smooth)'
        OnClick = ColourFXConvertFaceToVertexLSClick
      end
      object ColourFXConvertVertexToFace: TMenuItem
        Caption = 'Convert Vertex To Face Colours'
        Enabled = False
        OnClick = ColourFXConvertVertexToFaceClick
      end
    end
    object NormalEffects1: TMenuItem
      Caption = 'Normal Effects'
      object NormalFXNormalize: TMenuItem
        Caption = 'ReNormalize Mesh'
        OnClick = NormalFXNormalizeClick
      end
      object NormalsFXConvertFaceToVertexNormals: TMenuItem
        Caption = 'Convert Face Normals to Vertex Normals'
        OnClick = NormalsFXConvertFaceToVertexNormalsClick
      end
      object NormalsFXQuickSmoothNormals: TMenuItem
        Caption = 'Quick Smooth Normals'
        OnClick = NormalsFXQuickSmoothNormalsClick
      end
      object NormalsFXSmoothNormals: TMenuItem
        Caption = 'Smooth Normals'
        OnClick = NormalsFXSmoothNormalsClick
      end
      object NormalsFXCubicSmoothNormals: TMenuItem
        Caption = 'Cubic Smooth Normals'
        OnClick = NormalsFXCubicSmoothNormalsClick
      end
      object NormalsFXLanczosSmoothNormals: TMenuItem
        Caption = 'Lanczos Smooth Normals'
        OnClick = NormalsFXLanczosSmoothNormalsClick
      end
    end
    object TextureEffects1: TMenuItem
      Caption = 'Texture Effects'
      object TextureFXDiffuse: TMenuItem
        Caption = 'Extract Texture Atlas (SBGAMES2010)'
        OnClick = TextureFXDiffuseClick
      end
      object TextureFXDiffuseCustom: TMenuItem
        Caption = 'Extract Texture Atlas (SBGAMES2010)...'
        OnClick = TextureFXDiffuseCustomClick
      end
      object TextureFXDiffuseOrigami: TMenuItem
        Caption = 'Extract Texture Atlas (Origami)'
        OnClick = TextureFXDiffuseOrigamiClick
      end
      object TextureFXDiffuseOrigamiGA: TMenuItem
        Caption = 'Extract Texture Atlas (Origami GA)'
        OnClick = TextureFXDiffuseOrigamiGAClick
      end
      object TextureFXDiffuseOrigamiParametric: TMenuItem
        Caption = 'Extract Texture Atlas (Origami Parametric)'
        OnClick = TextureFXDiffuseOrigamiParametricClick
      end
      object TextureFXDiffuseOrigamiParametricDC: TMenuItem
        Caption = 'Extract Texture Atlas (Origami Parametric DC)'
        OnClick = TextureFXDiffuseOrigamiParametricDCClick
      end
      object TextureFXDiffuseIDC: TMenuItem
        Caption = 'Extract Texture Atlas (Intense Distortion Control)'
        OnClick = TextureFXDiffuseIDCClick
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object TextureFXDiffuseTexture: TMenuItem
        Caption = 'Diffuse Texture Type'
        object TextureFXTraditionalDiffuseTexture: TMenuItem
          Caption = 'Traditional Diffuse Texture'
          OnClick = TextureFXDiffuseTextureClick
        end
        object TextureFXDiffuseTexturewithMoreContrast: TMenuItem
          Caption = 'Diffuse Texture with More Contrast'
          OnClick = TextureFXDiffuseTexturewithMoreContrastClick
        end
        object TextureFXDebug: TMenuItem
          Caption = 'Debug Texture Atlas'
          OnClick = TextureFXDebugClick
        end
      end
      object TextureFXNormal: TMenuItem
        Caption = 'Generate Normal Map'
        OnClick = TextureFXNormalClick
      end
      object TextureFXBump: TMenuItem
        Caption = 'Generate Bump Mapping'
        OnClick = TextureFXBumpClick
      end
      object TextureFXBumpCustom: TMenuItem
        Caption = 'Generate Bump Mapping...'
        OnClick = TextureFXBumpCustomClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object TextureFSExport: TMenuItem
        Caption = 'Export All Textures'
        OnClick = TextureFSExportClick
      end
      object TextureFSExportHeightMap: TMenuItem
        Caption = 'Export HeightMap'
        OnClick = TextureFSExportHeightMapClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object extureFileType1: TMenuItem
        Caption = 'Texture File Type'
        object TextureFSFTDDS: TMenuItem
          Caption = 'Direct Draw Surface (DDS)'
          Checked = True
          OnClick = TextureFSFTDDSClick
        end
        object TextureFSFTTGA: TMenuItem
          Caption = 'TARGA (TGA)'
          OnClick = TextureFSFTTGAClick
        end
        object TextureFSFTJPG: TMenuItem
          Caption = 'JPEG (JPG)'
          OnClick = TextureFSFTJPGClick
        end
        object TextureFSFTBMP: TMenuItem
          Caption = 'Bitmap (BMP)'
          OnClick = TextureFSFTBMPClick
        end
      end
      object extureSize1: TMenuItem
        Caption = 'Texture Size'
        object TextureFXSize4096: TMenuItem
          Caption = '4096 x 4096'
          OnClick = TextureFXSize4096Click
        end
        object TextureFXSize2048: TMenuItem
          Caption = '2048 x 2048'
          OnClick = TextureFXSize2048Click
        end
        object TextureFXSize1024: TMenuItem
          Caption = '1024 x 1024'
          Checked = True
          OnClick = TextureFXSize1024Click
        end
        object TextureFXSize512: TMenuItem
          Caption = '512 x 512'
          OnClick = TextureFXSize512Click
        end
        object TextureFXSize256: TMenuItem
          Caption = '256 x 256'
          OnClick = TextureFXSize256Click
        end
        object TextureFXSize128: TMenuItem
          Caption = '128 x 128'
          OnClick = TextureFXSize128Click
        end
        object TextureFXSize64: TMenuItem
          Caption = '64 x 64'
          OnClick = TextureFXSize64Click
        end
        object TextureFXSize32: TMenuItem
          Caption = '32 x 32'
          OnClick = TextureFXSize32Click
        end
      end
      object TextureFXNumMipMaps: TMenuItem
        Caption = 'Texture MipMaps'
        object TextureFX10MipMaps: TMenuItem
          Caption = '10'
          OnClick = TextureFX10MipMapsClick
        end
        object TextureFX9MipMaps: TMenuItem
          Caption = '9'
          Checked = True
          OnClick = TextureFX9MipMapsClick
        end
        object TextureFX8MipMaps: TMenuItem
          Caption = '8'
          OnClick = TextureFX8MipMapsClick
        end
        object TextureFX7MipMaps: TMenuItem
          Caption = '7'
          OnClick = TextureFX7MipMapsClick
        end
        object TextureFX6MipMaps: TMenuItem
          Caption = '6'
          OnClick = TextureFX6MipMapsClick
        end
        object TextureFX5MipMaps: TMenuItem
          Caption = '5'
          OnClick = TextureFX5MipMapsClick
        end
        object TextureFX4MipMaps: TMenuItem
          Caption = '4'
          OnClick = TextureFX4MipMapsClick
        end
        object TextureFX3MipMaps: TMenuItem
          Caption = '3'
          OnClick = TextureFX3MipMapsClick
        end
        object TextureFX2MipMaps: TMenuItem
          Caption = '2'
          OnClick = TextureFX2MipMapsClick
        end
        object TextureFX1MipMaps: TMenuItem
          Caption = '1'
          OnClick = TextureFX1MipMapsClick
        end
      end
    end
    object QualityAnalysis1: TMenuItem
      Caption = 'Quality Analysis'
      object QualityAnalysisAspectRatio: TMenuItem
        Caption = 'Aspect Ratio'
        OnClick = QualityAnalysisAspectRatioClick
      end
      object QualityAnalysisSkewness: TMenuItem
        Caption = 'Skewness'
        OnClick = QualityAnalysisSkewnessClick
      end
      object QualityAnalysisSmoothness: TMenuItem
        Caption = 'Smoothness'
        OnClick = QualityAnalysisSmoothnessClick
      end
    end
  end
  object AnimationTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = AnimationTimerTimer
    Left = 176
    Top = 72
  end
  object Anim360Timer: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = Anim360TimerTimer
    Left = 208
    Top = 72
  end
  object SaveModelDialog: TSaveDialog
    DefaultExt = 'obj'
    Filter = 'Wavefront OBJ|*.obj|Polygon File Format PLY|*.ply'
    Left = 208
    Top = 40
  end
end
