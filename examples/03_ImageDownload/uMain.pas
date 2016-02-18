unit uMain;

interface

uses
  // Delphi
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, AxCtrls, ActiveX, jpeg, GIFImg,
  // Dev Express
  dxGDIPlusClasses,
  // OmniThreadLibrary
  OtlParallel, OtlTaskControl,
  // IdHTTPManager
  uHTTPInterface, uHTTPManager, uHTTPClasses, uHTTPIndyImplementor,
  // Utils
  uImageUtils;

type
  TMain = class(TForm)
    bClose: TButton;
    eGETRequest: TEdit;
    bDownload: TButton;
    Image: TImage;
    procedure FormCreate(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
    procedure bDownloadClick(Sender: TObject);
  private
    procedure DownloadImage(AImageLink: string; out AMemoryStream: TMemoryStream);
    procedure DrawImage(AMemoryStream: TMemoryStream);
  public

  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
begin
  Caption := Caption + ' - ' + THTTPManager.Instance().Implementor.Name;
end;

procedure TMain.bDownloadClick(Sender: TObject);
var
  ImageLink: string;

  MemoryStream: TMemoryStream;
begin
  ImageLink := eGETRequest.Text;

  Parallel.Async(
    { } procedure
    { } begin
    { . } DownloadImage(ImageLink, MemoryStream);
    { } end,
    { } Parallel.TaskConfig.OnTerminated(
      { } procedure(const task: IOmniTaskControl)
      { } begin
      { . } DrawImage(MemoryStream);
      { . } MemoryStream.Free;
      { } end
      { } ));
end;

procedure TMain.bCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMain.DownloadImage(AImageLink: string; out AMemoryStream: TMemoryStream);
var
  HTTPManager: IHTTPManager;
  HTTPOptions: IHTTPOptions;
  RequestID: Double;
  HTTPProcess: IHTTPProcess;
  OleStream: TOleStream;
  Dummy: Int64;
begin
  AMemoryStream := TMemoryStream.Create;

  // Required, because of TOleStream usage.
  CoInitializeEx(nil, COINIT_MULTITHREADED);
  try
    HTTPManager := THTTPManager.Instance();

    HTTPOptions := THTTPOptions.Create(TProxy.Create);

    HTTPOptions.ConnectTimeout := 10000;
    HTTPOptions.ReadTimeout := 25000;

    RequestID := HTTPManager.Get(THTTPRequest.Create(AImageLink), HTTPOptions);

    HTTPManager.WaitFor(RequestID);

    HTTPProcess := HTTPManager.GetResult(RequestID);

    OleStream := TOleStream.Create(HTTPProcess.HTTPResult.HTTPResponse.ContentStream);
    try
      HTTPProcess.HTTPResult.HTTPResponse.ContentStream.Seek(0, STREAM_SEEK_SET, Dummy);
      OleStream.Seek(0, STREAM_SEEK_SET);
      AMemoryStream.CopyFrom(OleStream, OleStream.Size);
    finally
      OleStream.Free;
    end;
  finally
    CoUninitialize;
  end;

  HTTPProcess := nil;
  HTTPOptions := nil;
  HTTPManager := nil;
end;

procedure TMain.DrawImage(AMemoryStream: TMemoryStream);
var
  _img_jpg: TJPEGImage;
  _img_png: TdxPNGImage;
  _img_gif: TGIFImage;
begin
  AMemoryStream.Position := 0;

  if IsJPG(AMemoryStream) then
  begin
    _img_jpg := TJPEGImage.Create;
    try
      _img_jpg.LoadFromStream(AMemoryStream);
      Image.Picture.Bitmap.Assign(_img_jpg);
    finally
      _img_jpg.Free;
    end;
  end
  else if IsPNG(AMemoryStream) then
  begin
    _img_png := TdxPNGImage.Create;
    try
      _img_png.LoadFromStream(AMemoryStream);
      Image.Picture.Assign(_img_png);
    finally
      _img_png.Free;
    end;
  end
  else if IsGIF(AMemoryStream) then
  begin
    _img_gif := TGIFImage.Create;
    try
      _img_gif.LoadFromStream(AMemoryStream);
      _img_gif.Animate := True;
      Image.Picture.Graphic := _img_gif;
    finally
      _img_gif.Free;
    end;
  end
  else if IsBMP(AMemoryStream) then
    Image.Picture.Bitmap.LoadFromStream(AMemoryStream);
end;

end.
