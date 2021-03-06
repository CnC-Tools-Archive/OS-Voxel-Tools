unit FormNewVxlUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Voxel_Engine;

type
  TFrmNew = class(TForm)
    grpNewSize: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    txtNewX: TEdit;
    txtNewY: TEdit;
    txtNewZ: TEdit;
    grpCurrentSize: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    txtCurrentX: TEdit;
    txtCurrentY: TEdit;
    txtCurrentZ: TEdit;
    Bevel1: TBevel;
    Panel1: TPanel;
    Image1: TImage;
    Label9: TLabel;
    Label10: TLabel;
    Bevel2: TBevel;
    Panel2: TPanel;
    BtOK: TButton;
    BtCancel: TButton;
    GrpVoxelType: TGroupBox;
    rbLand: TRadioButton;
    rbAir: TRadioButton;
    procedure FormActivate(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    x, y, z: integer; //size of voxel section currently
    changed: boolean; //has x,y or z changed at all? if not, no need to do anything
  end;


implementation

uses FormMain;

{$R *.DFM}

procedure TFrmNew.FormActivate(Sender: TObject);
begin
   changed := false;
   txtCurrentX.Text := IntToStr(x);
   txtNewX.Text := txtCurrentX.Text;
   txtCurrentY.Text := IntToStr(y);
   txtNewY.Text := txtCurrentY.Text;
   txtCurrentZ.Text := IntToStr(z);
   txtNewZ.Text := txtCurrentZ.Text;
end;

procedure TFrmNew.BtOKClick(Sender: TObject);
var
   i, code: integer;
   procedure ValError(v: string; Ctrl: TEdit);
   begin
      MessageDlg(v + ' must be an integer number between 1 and 255',mtError,[mbOK],0);
      Ctrl.SetFocus;
   end;
   procedure Reset;
   begin
      x := StrToInt(txtNewX.Text);
      y := StrToInt(txtNewY.Text);
      z := StrToInt(txtNewZ.Text);
      changed := false;
   end;
begin
   changed := false;
   // X
   Val(txtNewX.Text,i,code);
   if (code <> 0) or not (i in [1..255]) then
   begin
      ValError('x',txtNewX);
      Reset;
      Exit;
   end;
   if i <> x then
   begin
      x := i;
      changed := true;
   end;
   // Y
   Val(txtNewY.Text,i,code);
   if (code <> 0) or not (i in [1..255]) then
   begin
      ValError('y',txtNewY);
      Reset;
      Exit;
   end;
   if i <> y then
   begin
      y := i;
      changed := true;
   end;
   // Z
   Val(txtNewZ.Text,i,code);
   if (code <> 0) or not (i in [1..255]) then
   begin
      ValError('z',txtNewZ);
      reset;
      Exit;
   end;
   if i <> z then
   begin
      z := i;
      changed := true;
   end;
   BtOK.Enabled := false;
   FrmMain.SetVoxelChanged(true);
   Close;
end;

procedure TFrmNew.BtCancelClick(Sender: TObject);
begin
   changed:=false;
   Close;
end;

procedure TFrmNew.FormCreate(Sender: TObject);
begin
   changed:=false;
   Panel1.DoubleBuffered := true;
end;

end.
