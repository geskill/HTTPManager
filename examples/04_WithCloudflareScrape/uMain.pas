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
  // RegExpr
  RegExpr,
  // BESEN
  BESEN, BESENConstants, BESENErrors, BESENValue,
  // Indy
  IdURI,
  // IdHTTPManager
  uHTTPInterface, uHTTPManager, uHTTPManagerClasses, uHTTPEvent, uHTTPClasses, uHTTPConst, uHTTPIndyImplementor;

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
    procedure FormDestroy(Sender: TObject);
    procedure bGETClick(Sender: TObject);
    procedure bPOSTClick(Sender: TObject);
    procedure bHTTPLoggerClick(Sender: TObject);
    procedure bCloseClick(Sender: TObject);

  private
    HTTPManager: IHTTPManager;
    FHTTPScrapeEventHandler: IHTTPScrapeEventHandler;
  public
    procedure HandleScrape(const AHTTPProcess: IHTTPProcess; out AHTTPData: IHTTPData; var AHandled: WordBool);
    function ExecJavaScript(const AScript: string): string;
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

  FHTTPScrapeEventHandler := TIHTTPScrapeEventHandler.Create(HandleScrape);
  THTTPManager.Instance().OnRequestScrape.Add(FHTTPScrapeEventHandler);
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  THTTPManager.Instance().OnRequestScrape.Remove(FHTTPScrapeEventHandler);
  FHTTPScrapeEventHandler := nil;
end;

procedure TMain.HandleScrape(const AHTTPProcess: IHTTPProcess; out AHTTPData: IHTTPData; var AHandled: WordBool);
var
  jschl_vc, pass, jschl_answer, jschl_script: string;

  LProtocol, LHost, LURL, LParams: string;
  LCanHandleCloudflare: Boolean;

  HTTPRequest: IHTTPRequest;
  HTTPOptions: IHTTPOptions;
begin
  LCanHandleCloudflare := False;

  if (AHTTPProcess.HTTPResult.HTTPResponse.Server = 'cloudflare-nginx') and
  { . } (Pos('/cdn-cgi/', string(AHTTPProcess.HTTPResult.HTTPResponse.Refresh)) > 0) and
  { . } (AHTTPProcess.HTTPData.HTTPRequest.Cookies.IndexOfName('cf_clearance') = -1) then
  begin
    with TIdURI.Create(AHTTPProcess.HTTPData.Website) do
      try
        LProtocol := Protocol;
        LHost := Host;
      finally
        Free;
      end;

    with TRegExpr.Create do
      try
        InputString := AHTTPProcess.HTTPResult.SourceCode;

        Expression := 'name="jschl_vc" value="(\w+)"';
        if Exec(InputString) then
        begin
          jschl_vc := Match[1];
        end;

        Expression := 'name="pass" value="(.*?)"';
        if Exec(InputString) then
        begin
          pass := Match[1];
        end;

        Expression := 'setTimeout\(function\(\){\s+(var t,r,a,f.+?\r?\n.+?a\.value =.+?)\r?\n';
        if Exec(InputString) then
        begin
          jschl_script := Match[1];

          InputString := jschl_script;
          Expression := 'a\.value =(.+?) \+ .+?;';

          jschl_script := Replace(InputString, '$1', True);

          ModifierM := True;
          InputString := jschl_script;
          Expression := '\s{3,}([a-z]{1}.*?$)';

          jschl_script := Replace(InputString, '', False);

          jschl_answer := IntToStr(StrToInt(ExecJavaScript(jschl_script)) + length(LHost));

          LCanHandleCloudflare := True;
        end;
      finally
        Free;
      end;

    if LCanHandleCloudflare then
    begin
      Sleep(4500);

      LParams := 'jschl_vc=' + jschl_vc + '&jschl_answer=' + jschl_answer + '&pass=' + pass;
      LURL := LProtocol + '://' + LHost + '/cdn-cgi/l/chk_jschl?' + LParams;

      HTTPRequest := THTTPRequest.Create(LURL);
      with HTTPRequest do
      begin
        Method := mGET;
        Referer := LURL;
        Cookies.Add('__cfduid=' + AHTTPProcess.HTTPResult.HTTPResponse.Cookies.Values['__cfduid']);
      end;

      HTTPOptions := AHTTPProcess.HTTPData.HTTPOptions;
      with HTTPOptions do
      begin
        HandleRedirects := True;
        RedirectMaximum := 1;
      end;
      AHTTPData := THTTPData.Create(HTTPRequest, HTTPOptions, nil);

      AHandled := True;
    end;
  end;
end;

function TMain.ExecJavaScript(const AScript: string): string;
var
  LCompatibility: LongWord;
  LInstance: TBESEN;
  LValue: TBESENValue;
begin
  Result := '';

  LCompatibility := COMPAT_BESEN;
  LInstance := TBESEN.Create(LCompatibility);
  try
    LValue.ValueType := bvtUNDEFINED;
    LValue.Obj := nil;
    LValue := TBESEN(LInstance).Execute(AScript);
    try
      Result := IntToStr(Round(LValue.Num));

      LValue.ValueType := bvtUNDEFINED;
      LValue.Obj := nil;
      TBESEN(LInstance).GarbageCollector.CollectAll;
    except
      on e: EBESENError do
      begin
        OutputDebugString(PChar(e.Name + '(' + IntToStr(TBESEN(LInstance).LineNumber) + '): ' + e.Message));
      end;
      on e: Exception do
      begin
        OutputDebugString(PChar('Exception(' + IntToStr(TBESEN(LInstance).LineNumber) + '): ' + e.Message));
      end;
    end;
  finally
    LInstance.Free;
  end;
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
    { . } repeat
    { ... } sleep(50); // you can lower the time to make more checks if the request is finished
    { . } until HTTPManager.HasResult(RequestID);
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
    { . } repeat
    { ... } sleep(50); // you can lower the time to make more checks if the request is finished
    { . } until HTTPManager.HasResult(RequestID);
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
