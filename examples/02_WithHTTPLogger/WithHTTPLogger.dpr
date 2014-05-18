program WithHTTPLogger;

uses
  Forms,
  uMain in 'uMain.pas' {Main},
  uHTTPLogger in 'uHTTPLogger.pas' {HTTPLogger};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(THTTPLogger, HTTPLogger);
  Application.Run;
end.
