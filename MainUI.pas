unit MainUI;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.SystemRT, Winapi.CommCtrl,
  Cod.Windows, System.Generics.Collections, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Menus, ShellAPI, Winapi.ActiveX, System.Win.ComObj,
  Winapi.Winrt, Winapi.ApplicationModel, Cod.WindowsRT, Cod.SysUtils,
  Cod.WindowsRT.ActivationManager, Cod.UWP, Winapi.Management;

const
  WM_CUSTOM_RUN = WM_USER + 100;

type
  TMainForm = class(TForm)
    Tray: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    Support1: TMenuItem;
    N1: TMenuItem;
    Visitwebsite1: TMenuItem;
    Delayed1Run: TTimer;
    procedure Support1Click(Sender: TObject);
    procedure Visitwebsite1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure TrayClick(Sender: TObject);
    procedure Delayed1RunTimer(Sender: TObject);
  private
    { Private declarations }
    procedure DoMessageRun(var Msg: TMessage); message WM_CUSTOM_RUN;
  public
    { Public declarations }
  end;

procedure DoRunCSGO;

var
  MainForm: TMainForm;

  // Hook(er)
  KeyboardHook: HHOOK;
  MissingCounter: integer=0;

  ExistanceValidated: boolean=false;

implementation

{$R *.dfm}

var
  WinSActive: Boolean = False;

function LowLevelKeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  kbData: PKBDLLHOOKSTRUCT;
  IsKeyDown, IsKeyUp: Boolean;
begin
  Result := 0;

  try
    const Window = GetActiveWindow;
    if Window = 0 then
      Exit;
    const Proc = Window.GetProcessID.ProcessHandleReadOnly;
    if Proc = 0 then
      Exit;
    try
      if Proc.GetModuleName.ToLower <> 'explorer.exe' then
        Exit;
    finally
      Proc.CloseHandle;
    end;
  except
    exit;
  end;

  if nCode = HC_ACTION then
  begin
    kbData := PKBDLLHOOKSTRUCT(lParam);
    //IsKeyDown := (wParam = WM_KEYDOWN) or (wParam = WM_SYSKEYDOWN);
    IsKeyUp   := (wParam = WM_KEYUP)   or (wParam = WM_SYSKEYUP);

    // Run Counter-Strike 2: Global Offensive
    if (kbData^.vkCode = VK_CAPITAL) and IsKeyUp then begin
      DoRunCSGO;

      Exit(1);
    end;
  end;

  Result := CallNextHookEx(KeyboardHook, nCode, wParam, lParam);
end;

procedure InstallKeyboardHook;
begin
  KeyboardHook := SetWindowsHookEx(WH_KEYBOARD_LL, @LowLevelKeyboardProc, HInstance, 0);
end;

procedure UninstallKeyboardHook;
begin
  if KeyboardHook <> 0 then
    UnhookWindowsHookEx(KeyboardHook);
end;


procedure DoRunCSGO;
const
  CSTRIKE_URI = 'steam://run/730';
begin
  ShellRun(CSTRIKE_URI, true, '');
end;

procedure TMainForm.Delayed1RunTimer(Sender: TObject);
begin
  TTimer(Sender).Enabled := false;

  // Run
  DoRunCSGO;
end;

procedure TMainForm.DoMessageRun(var Msg: TMessage);
begin
  Delayed1Run.Enabled := true;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Support1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://go.codrutsoft.com/support/', nil, nil, SW_SHOW);
end;

procedure TMainForm.TrayClick(Sender: TObject);
begin
  DoRunCSGO;
end;

procedure TMainForm.Visitwebsite1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://www.codrutsoft.com/', nil, nil, SW_SHOW);
end;

initialization
  // Install hook
  InstallKeyboardHook;
finalization
  // Free hook(er)
  UninstallKeyboardHook;
end.
