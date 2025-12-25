program CounterStrikeButton;

uses
  Vcl.Forms,
  Cod.Instances,
  MainUI in 'MainUI.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;

  SetSemaphore('com.codrutsoft.rebindcapstocountetstrikebutton');
  InstanceAuto(TAutoInstanceMode.TerminateIfOtherExist);

  Application.MainFormOnTaskbar := True;
  Application.ShowMainForm := false;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
