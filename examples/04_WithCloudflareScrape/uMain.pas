unit uMain;

interface

uses
  // Delphi
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  // Dev Express
  cxPCdxBarPopupMenu, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxPC, cxContainer, cxEdit, cxTextEdit, dxBarBuiltInMenu,
  // OmniThreadLibrary
  OtlParallel, OtlTaskControl,
  // IdHTTPManager
  uHTTPInterface, uHTTPManager, uHTTPManagerClasses, uHTTPEvent, uHTTPClasses, uHTTPConst, uHTTPCloudflareAntiScrape, uHTTPIndyImplementor;

type
  TMain = class(TForm)
    cxPageControl: TcxPageControl;
    cxTSGetRequest: TcxTabSheet;
    cxTSPostRequest: TcxTabSheet;
    bClose: TButton;
    bHTTPLogger: TButton;
    cxTEGETURL: TcxTextEdit;
    bGET: TButton;
    mGETResult: TMemo;
    cxTEPOSTURL: TcxTextEdit;
    bPOST: TButton;
    mPOSTParams: TMemo;
    lPOSTParams: TLabel;
    mPOSTResult: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure bGETClick(Sender: TObject);
    procedure bPOSTClick(Sender: TObject);
    procedure bHTTPLoggerClick(Sender: TObject);
    procedure bCloseClick(Sender: TObject);

  private
    HTTPManager: IHTTPManager;
  end;

var
  Main: TMain;

implementation

uses
  uHTTPLogger;
{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
begin
  Caption := Caption + ' - ' + THTTPManager.Instance().Implementor.Name;
end;

procedure TMain.bGETClick(Sender: TObject);
var
  RequestID: Double;

  HTTPOptions: IHTTPOptions;
begin
  HTTPManager := THTTPManager.Instance();

  HTTPOptions := THTTPOptions.Create();
  HTTPOptions.HandleRedirects := False;
  HTTPOptions.RedirectMaximum := 0;

  RequestID := HTTPManager.Get(THTTPRequest.Create(cxTEGETURL.Text), HTTPOptions);

  Parallel.Async(
    { } procedure
    { } begin
    { . } HTTPManager.WaitFor(RequestID);
    { } end,
    { } Parallel.TaskConfig.OnTerminated(
      { } procedure(const task: IOmniTaskControl)
      { } var
      { . } HTTPProcess: IHTTPProcess;
      { } begin
      { . } HTTPProcess := HTTPManager.GetResult(RequestID);
      { . } if (HTTPProcess.HTTPResult.HTTPResponseInfo.RedirectCount > 0) then
      { ... } cxTEGETURL.Text := HTTPProcess.HTTPResult.HTTPResponseInfo.LastRedirect;
      { . } mGETResult.Lines.Text := HTTPProcess.HTTPResult.SourceCode;
      { . } if HTTPProcess.HTTPResult.HasError then
      { ... } ShowMessage(HTTPProcess.HTTPResult.HTTPResponseInfo.ErrorClassName + ': ' + HTTPProcess.HTTPResult.HTTPResponseInfo.ErrorMessage);
      { } end
      { } ));
end;

procedure TMain.bPOSTClick(Sender: TObject);
var
  RequestID: Double;

  I: Integer;

  HTTPParams: IHTTPParams;
begin
  HTTPManager := THTTPManager.Instance();

  HTTPParams := THTTPParams.Create;

  for I := 0 to mPOSTParams.Lines.Count - 1 do
    HTTPParams.AddFormField(mPOSTParams.Lines.Names[I], mPOSTParams.Lines.ValueFromIndex[I]);

  RequestID := HTTPManager.Post(THTTPRequest.Create(cxTEPOSTURL.Text), HTTPParams);

  Parallel.Async(
    { } procedure
    { } begin
    { . } HTTPManager.WaitFor(RequestID);
    { } end,
    { } Parallel.TaskConfig.OnTerminated(
      { } procedure(const task: IOmniTaskControl)
      { } var
      { . } HTTPProcess: IHTTPProcess;
      { } begin
      { . } HTTPProcess := HTTPManager.GetResult(RequestID);
      { . } if (HTTPProcess.HTTPResult.HTTPResponseInfo.RedirectCount > 0) then
      { ... } cxTEPOSTURL.Text := HTTPProcess.HTTPResult.HTTPResponseInfo.LastRedirect;
      { . } mPOSTResult.Lines.Text := HTTPProcess.HTTPResult.SourceCode;
      { . } if HTTPProcess.HTTPResult.HasError then
      { ... } ShowMessage(HTTPProcess.HTTPResult.HTTPResponseInfo.ErrorClassName + ': ' + HTTPProcess.HTTPResult.HTTPResponseInfo.ErrorMessage);
      { } end
      { } ));
end;

procedure TMain.bHTTPLoggerClick(Sender: TObject);
begin
  HTTPLogger.Show;
end;

procedure TMain.bCloseClick(Sender: TObject);
begin
  Close;
end;

end.
