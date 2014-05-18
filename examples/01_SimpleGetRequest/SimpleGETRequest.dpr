program SimpleGETRequest;

uses
  Forms,
  uMain in 'uMain.pas' {Main};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
