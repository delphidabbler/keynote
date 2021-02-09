unit FmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Gestures, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.ListBox, FMX.Layouts, FMX.ComboEdit, FMX.Edit, System.Actions,
  FMX.ActnList;

type
  TMainForm = class(TForm)
    tbHeader: TToolBar;
    lblToolbar: TLabel;
    tcMain: TTabControl;
    tabMain: TTabItem;
    tabEdit: TTabItem;
    tabImportExport: TTabItem;
    tabSettings: TTabItem;
    gestureMgr: TGestureManager;
    pnlInput: TPanel;
    lblScale: TLabel;
    cbScale: TComboBox;
    lblKey: TLabel;
    cbKey: TComboBox;
    btnGenerate: TButton;
    pnlOutput: TPanel;
    btnPlay: TButton;
    lbResults: TListBox;
    lbiNotes: TListBoxItem;
    ghNotes: TListBoxGroupHeader;
    ghIntervals: TListBoxGroupHeader;
    lbiIntervals: TListBoxItem;
    sbSettings: TVertScrollBox;
    lblIntervalStyle: TLabel;
    cbIntervalStyle: TComboBox;
    lbiUKIntervalStyle: TListBoxItem;
    lbiUSIntervalStyle: TListBoxItem;
    lblKeyStyle: TLabel;
    cbKeyStyle: TComboBox;
    lbiKeyStyleC: TListBoxItem;
    lbiKeyStyleA: TListBoxItem;
    lblCSName: TLabel;
    lblCSRingNum: TLabel;
    lblCSOr: TLabel;
    edCSRingNum: TEdit;
    gbIntervals: TGroupBox;
    chkCSInterval1: TCheckBox;
    chkCSInterval4: TCheckBox;
    chkCSInterval3: TCheckBox;
    chkCSInterval2: TCheckBox;
    chkCSInterval5: TCheckBox;
    chkCSInterval6: TCheckBox;
    chkCSInterval7: TCheckBox;
    chkCSInterval8: TCheckBox;
    chkCSInterval9: TCheckBox;
    chkCSInterval10: TCheckBox;
    chkCSInterval11: TCheckBox;
    chkCSInterval12: TCheckBox;
    btnCSAccept: TButton;
    cbedCSName: TComboEdit;
    btnImportScales: TButton;
    btnExportScales: TButton;
    ListBox1: TListBox;
    lblImportedScales: TLabel;
    btnConfirmImport: TButton;
    dlgExport: TSaveDialog;
    dlgImport: TOpenDialog;
    alMain: TActionList;
    procedure FormCreate(Sender: TObject);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  { This defines the default active tab at runtime }
  tcMain.ActiveTab := tabMain;
end;

procedure TMainForm.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
{$IFDEF ANDROID}
  case EventInfo.GestureID of
    sgiLeft:
    begin
      if tcMain.ActiveTab <> tcMain.Tabs[tcMain.TabCount-1] then
        tcMain.ActiveTab := tcMain.Tabs[tcMain.TabIndex+1];
      Handled := True;
    end;

    sgiRight:
    begin
      if tcMain.ActiveTab <> tcMain.Tabs[0] then
        tcMain.ActiveTab := tcMain.Tabs[tcMain.TabIndex-1];
      Handled := True;
    end;
  end;
{$ENDIF}
end;

end.
