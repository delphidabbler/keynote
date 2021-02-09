program KeyNote;

uses
  System.StartUpCopy,
  FMX.Forms,
  FmMain in 'FmMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
