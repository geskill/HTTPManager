unit uHTTPvBulletinRandomQuestionAntiCaptcha;

interface

uses
  // Interface
  uHTTPInterface,
  // Classes
  uHTTPManager, uHTTPExtensionClasses,
  // Const
  uHTTPConst;

type
  THTTPvBulletinRandomQuestionAntiCaptcha = class(THTTPAntiCaptcha)
  public
    class function GetExtensionName: string; override;

    function RequiresHandling(const AIHTTPResponse: IHTTPResponse): WordBool; override;
    procedure Handle(const ASenderContext: WideString; const ASenderName: WideString; const ASenderWebsite: WideString; const ASenderWebsiteSource: WideString; const ACaptcha: WideString; out ACaptchaSolution: WideString; var ACookies: WideString; var AHandled: WordBool); override;
  end;

implementation

{ THTTPvBulletinRandomQuestionAntiCaptcha }

class function THTTPvBulletinRandomQuestionAntiCaptcha.GetExtensionName: string;
begin
  Result := 'vBulletin-RandomQuestion';
end;

function THTTPvBulletinRandomQuestionAntiCaptcha.RequiresHandling(const AIHTTPResponse: IHTTPResponse): WordBool;
begin
  // TODO:
end;

procedure THTTPvBulletinRandomQuestionAntiCaptcha.Handle(const ASenderContext, ASenderName, ASenderWebsite, ASenderWebsiteSource, ACaptcha: WideString; out ACaptchaSolution: WideString; var ACookies: WideString; var AHandled: WordBool);
begin
  // TODO:
end;

end.
