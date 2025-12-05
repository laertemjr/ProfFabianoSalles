unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    // Trata a mensagem do Windows que forçaria o redesenho da janela pelo Delphi
    procedure WMEraseBg(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  X, Y : Integer;
  fOffScreen: TBitmap; // “back buffer”

implementation

{$R *.dfm}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FreeAndNil(fOffScreen); // destruíndo o "back buffer"
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // criando o "back buffer"
  X := 0;
  Y := 0;
  fOffScreen := TBitmap.Create;
  fOffScreen.PixelFormat := pf24bit;
  fOffScreen.Width := ClientWidth;
  fOffScreen.Height := ClientHeight;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // primeiro desenhando na memória, para depois transferir para a "área visível" da tela
  // com isso, o efeito "flickering" (imagem piscante) é minimizado
  fOffScreen.Canvas.Brush.Color := clWhite;
  fOffScreen.Canvas.FillRect(fOffScreen.Canvas.ClipRect);
  fOffScreen.Canvas.Draw(X, Y, Image1.Picture.Graphic);

  BitBlt(Canvas.Handle, 0, 0,
         ClientWidth,
         ClientHeight,
         fOffScreen.Canvas.Handle,
         0, 0, SRCCOPY);

  Inc(X);
  Inc(Y);
  if X >= ClientWidth - Image1.Width then
     X := 0;
  if Y >= ClientHeight - Image1.Height then
     Y := 0;
end;

procedure TForm1.WMEraseBg(var Msg: TWMEraseBkgnd);
begin
   Msg.Result:= 0; // Informa ao Windows que o próprio programa tratará do redesenho da janela
end;

end.
