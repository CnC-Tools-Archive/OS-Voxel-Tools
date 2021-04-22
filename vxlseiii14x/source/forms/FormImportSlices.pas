unit FormImportSlices;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, jpeg;

type
  TFrmImportSlices = class(TForm)
    txtOffset: TEdit;
    Bevel1: TBevel;
    BtOK: TButton;
    BtCancel: TButton;
    EdImage: TEdit;
    lblImage: TLabel;
    BtBrowseImage: TButton;
    OpenDialog: TOpenDialog;
    radioRight: TRadioButton;
    radioDown: TRadioButton;
    GroupBox1: TGroupBox;
    lblSlicesPixelOffset: TLabel;
    Label1: TLabel;
    ImgSlicesPixelOffset: TImage;
    ImgSample: TImage;
    lblEstimatedSize: TLabel;
    procedure EdImageChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure BtBrowseImageClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    aborted: boolean;
    offset: integer;
  end;


implementation

uses PngImage;

{$R *.DFM}

procedure TFrmImportSlices.FormActivate(Sender: TObject);
begin
     aborted := true;
end;

procedure TFrmImportSlices.btnCancelClick(Sender: TObject);
begin
     aborted := true;
     Close;
end;

procedure TFrmImportSlices.btnOKClick(Sender: TObject);
var
   code: integer;
   procedure ValError(v: string; Ctrl: TEdit);
   begin
      MessageDlg(v + ' must be an integer number between 1 and 255', mtError,[mbOK],0);
      Ctrl.SetFocus;
   end;
begin
   // Z
   Val(txtOffset.Text,offset,code);
   if (code <> 0) or not (offset in [1..255]) then
   begin
      ValError('offset',txtOffset);
      Exit;
   end;
   btOK.Enabled := false;
   aborted := false;
   Close;
end;

procedure TFrmImportSlices.EdImageChange(Sender: TObject);
var
   x,y,z, code: integer;
   Image: TPngObject;
begin
   if FileExists(EdImage.Text) then
   begin
      Image := TPNGObject.Create;
      Image.LoadFromFile(EdImage.Text);

      Val(txtOffset.Text,offset,code);
      if offset = 0 then
      begin
         x := 0;
         y := 0;
         z := 0;
      end
      else
      begin
         if radioRight.Checked then
         begin
            x := offset;
            z := image.Height;
            y := image.Width div offset;
         end
         else
         begin
            x := image.Width;
            z := offset;
            y := image.Height div offset;
         end;
      end;
      if (x <= 0) or (x > 255) or (y <= 0) or (y > 255) or (z <= 0) or (z > 255)  then
      begin
         lblEstimatedSize.Caption := 'Section has invalid size.';
      end
      else
      begin
         lblEstimatedSize.Caption := 'Estimated Section Size: [' + IntToStr(x) + ', ' + IntToStr(y) + ', ' + IntToStr(z) + '].'
      end;
      Image.Free;
   end
   else
   begin
      lblEstimatedSize.Caption := 'No valid image selected.';
   end;
end;

procedure TFrmImportSlices.BtBrowseImageClick(Sender: TObject);
begin
   if OpenDialog.Execute then
   begin
      EdImage.Text := OpenDialog.FileName;
      if FileExists(EdImage.Text) then
      begin
         BtOK.Enabled := true;
      end
      else
      begin
         BtOK.Enabled := false;
      end;
   end;
end;

end.
