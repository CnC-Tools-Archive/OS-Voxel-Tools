unit FormNewSectionImage;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, jpeg;

type
  TFrmNewSectionImage = class(TForm)
    txtOffset: TEdit;
    lblName: TLabel;
    txtName: TEdit;
    lblPosition: TLabel;
    chkBefore: TRadioButton;
    chkAfter: TRadioButton;
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
    before,
    aborted: boolean;
    offset: integer;
    Name: array[1..16] of Char;
  end;


implementation

uses PngImage;

{$R *.DFM}

procedure TFrmNewSectionImage.FormActivate(Sender: TObject);
begin
     aborted := true;
end;

procedure TFrmNewSectionImage.btnCancelClick(Sender: TObject);
begin
     aborted := true;
     Close;
end;

procedure TFrmNewSectionImage.btnOKClick(Sender: TObject);
   function CheckName: boolean;
   var
      ch: char;
      i: integer;
   begin
      Result := (Length(txtName.Text) in [1..16]);
      if not Result then
      begin
         MessageDlg('Name must be between 1 and 16 characters long!',mtError,[mbOK],0);
         Exit;
      end;
      txtName.Text := UpperCase(txtName.Text);
      for i := 1 to Length(txtName.Text) do
      begin
         ch := txtName.Text[i];
         if not (ch in ['A'..'Z','0'..'9']) then
         begin
            Result := False;
            MessageDlg('Name can only contain letters and digits!',mtError,[mbOK],0);
            txtName.SetFocus;
            Exit;
         end;
         Name[i] := ch;
      end;
      //Code changed to get rid of compiler warning. This is better anyway.
      for i := Length(txtName.Text)+1 to 16 do
      begin
         Name[i] := #0; // zero-terminated
      end;
   end;
var
   code: integer;
   procedure ValError(v: string; Ctrl: TEdit);
   begin
      MessageDlg(v + ' must be an integer number between 1 and 255', mtError,[mbOK],0);
      Ctrl.SetFocus;
   end;
begin
   // Name
   if not CheckName then
      Exit;

   // Z
   Val(txtOffset.Text,offset,code);
   if (code <> 0) or not (offset in [1..255]) then
   begin
      ValError('offset',txtOffset);
      Exit;
   end;
   btOK.Enabled := false;
   before := chkBefore.Checked;
   aborted := false;
   Close;
end;

procedure TFrmNewSectionImage.EdImageChange(Sender: TObject);
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

procedure TFrmNewSectionImage.BtBrowseImageClick(Sender: TObject);
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
