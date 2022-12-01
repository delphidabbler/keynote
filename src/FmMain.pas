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
    tabGenerator: TTabItem;
    tabEditScales: TTabItem;
    tabImport: TTabItem;
    tabSettings: TTabItem;
    pnlGenInput: TPanel;
    lblGenScale: TLabel;
    cbGenScale: TComboBox;
    lblGenKey: TLabel;
    cbGenKey: TComboBox;
    btnGenGenerate: TButton;
    pnlGenOutput: TPanel;
    btnGenPlay: TButton;
    lbGenResults: TListBox;
    lbiGenNotes: TListBoxItem;
    ghGenNotes: TListBoxGroupHeader;
    ghGenIntervals: TListBoxGroupHeader;
    lbiGenIntervals: TListBoxItem;
    sbStgSettings: TVertScrollBox;
    lblStgIntervalStyle: TLabel;
    cbStgIntervalStyle: TComboBox;
    lblESScale: TLabel;
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
    cbedESScale: TComboEdit;
    btnImpImportScales: TButton;
    lbImpImportedScales: TListBox;
    lblImpImportedScales: TLabel;
    btnImpConfirmImport: TButton;
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
    btnESEditCategories: TButton;
    actESEditCategories: TAction;
    btnESCancel: TButton;
    actESCancel: TAction;
    btnESDeleteScale: TButton;
    actESDeleteScale: TAction;
    actGenGenerate: TAction;
    actGenPlay: TAction;
    actImpImportScales: TAction;
    actImpConfirmImport: TAction;
    lblStgScaleStyle: TLabel;
    cbStgScaleStyle: TComboBox;
    timerSettings: TTimer;
    gestureMgr: TGestureManager;
    ghGenScale: TListBoxGroupHeader;
    lbiGenScale: TListBoxItem;
    cbedESCategories: TComboEdit;
    btnStgSave: TButton;
    actStgSave: TAction;
    procedure FormCreate(Sender: TObject);
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
  tcMain.ActiveTab := tabGenerator;
end;

end.
