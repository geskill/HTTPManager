unit uMain;

interface

uses
  // Delphi
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  // OmniThreadLibrary
  OtlParallel, OtlTaskControl,
  // IdHTTPManager
  uHTTPInterface, uHTTPManager, uHTTPClasses, uHTTPIndyImplementor;

type
  TMain = class(TForm)
    bClose: TButton;
    eGETRequest: TEdit;
    bGET: TButton;
    mGETResult: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
    procedure bGETClick(Sender: TObject);
  private
    HTTPManager: IHTTPManager;
  public
    { Public-Deklarationen }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
begin
  Caption := Caption + ' - ' + THTTPManager.Instance().Implementor.Name;
end;

procedure TMain.bGETClick(Sender: TObject);
var
  RequestID: Double;
begin
  HTTPManager := THTTPManager.Instance();

  RequestID := HTTPManager.Get(THTTPRequest.Create(eGETRequest.Text));

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
      { . } if(HTTPProcess.HTTPResult.HTTPResponseInfo.RedirectCount > 0) then
      { ... } eGETRequest.Text := HTTPProcess.HTTPResult.HTTPResponseInfo.LastRedirect;
      { . } mGETResult.Lines.Text := HTTPProcess.HTTPResult.SourceCode;
      { . } if HTTPProcess.HTTPResult.HasError then
      { ... } ShowMessage(HTTPProcess.HTTPResult.HTTPResponseInfo.ErrorClassName + ': ' + HTTPProcess.HTTPResult.HTTPResponseInfo.ErrorMessage);
      { } end
      { } ));
end;

procedure TMain.bCloseClick(Sender: TObject);
begin
  Close;
end;

end.
