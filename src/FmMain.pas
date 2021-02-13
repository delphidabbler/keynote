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
    lblESName: TLabel;
    lblESScaleNumber: TLabel;
    lblESOr: TLabel;
    edESScaleNumber: TEdit;
    gbESIntervals: TGroupBox;
    chkESInterval1: TCheckBox;
    chkESInterval4: TCheckBox;
    chkESInterval3: TCheckBox;
    chkESInterval2: TCheckBox;
    chkESInterval5: TCheckBox;
    chkESInterval6: TCheckBox;
    chkESInterval7: TCheckBox;
    chkESInterval8: TCheckBox;
    chkESInterval9: TCheckBox;
    chkESInterval10: TCheckBox;
    chkESInterval11: TCheckBox;
    chkESInterval12: TCheckBox;
    btnESAccept: TButton;
    cbedESName: TComboEdit;
    btnImportScales: TButton;
    btnExportScales: TButton;
    ListBox1: TListBox;
    lblImportedScales: TLabel;
    btnConfirmImport: TButton;
    dlgExport: TSaveDialog;
    dlgImport: TOpenDialog;
    alMain: TActionList;
    actESAccept: TAction;
    btnESEditScale: TButton;
    btnESNewScale: TButton;
    btnESRenameScale: TButton;
    actESEditScale: TAction;
    actESNewScale: TAction;
    actESRenameScale: TAction;
    lblESCategory: TLabel;
    cbESCategories: TComboBox;
    btnESEditCategories: TButton;
    actESEditCategories: TAction;
    btnESCancel: TButton;
    actESCancel: TAction;
    btnESDeleteScale: TButton;
    actESDeleteScale: TAction;
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

uses
  UMusic;

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
