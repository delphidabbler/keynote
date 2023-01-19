unit Data.Scales;

interface

uses
  System.Classes,
  System.Generics.Collections,

  Music.Notes,
  Music.Scales;

type
  // Test data record. Each field maps to a column of the data file, in order
  TScaleTestData = record
    ScaleNumber: UInt16;
    IsZeitlerScale: Boolean;
    ZeitlerNumberAsc: UInt16;
    ZeitlerNumberDesc: UInt16;
    ScaleName: string;
    ZeitlerName: string;
    Cardinality: Cardinal;
    PitchClassSet: TPitchClassSet;
    RotationalSymmetry: TRotationalSymmetry;
    IsPalindromic: Boolean;
    IsChiral: Boolean;
    Hemitonia: Cardinal;
    Cohemitonia: Cardinal;
    Imperfections: Cardinal;
    Perfections: Cardinal;
    ModeCount: Cardinal;
    IsPrimeForm: Boolean;
    PrimeRingNumber: UInt16;
    IsDeep: Boolean;
    Intervals: TIntervalPattern;
    Leap: Cardinal;
    IntervalVector: TIntervalVector;
    IsBalanced: Boolean;
    Modes: TArray<UInt16>;
    Complement: TArray<UInt16>;
    Inverse: UInt16;
  end;

  TScaleTestLookup = class(TDictionary<UInt16, TScaleTestData>);

  TScalesTestDataReader = class
  strict private
    const
      ColScaleNumber = 'SN';
      ColIsZeietlerScale = 'Is_Zeitler';
      ColZeitlerNumberAsc = 'ZNBE';
      ColZeitlerNumberDesc = 'ZNLE';
      ColName = 'R_Name';
      ColZeitlerName = 'Z_Name';
      ColCardinality = 'Cardinality';
      ColPitchClassSet = 'PCS';
      ColRotationalSymmetry = 'RotSym';
      ColIsPalindromic = 'Palindrome';
      ColIsChiral = 'Chirality';
      ColHemitonia = 'Hemitonia';
      ColCohemitonia = 'Cohemitonia';
      ColImperfections = 'Imperfections';
      ColPerfections = 'Perfections';
      ColModeCount = 'Mode_Count';
      ColIsPrimeForm = 'Prime_Form';
      ColPrimeRingNumber = 'RN_Prime';
      ColIsDeep = 'Deep';
      ColIntervals = 'Intervals';
      ColLeap = 'Leap';
      ColIntervalVector = 'Int_Vector';
      ColIsBalanced = 'Balanced';
      ColModes = 'Modes';
      ColComplement = 'Complement';
      ColInverse = 'Inverse';
    var
      fHeadings: TStringList;
      fData: TScaleTestLookup;
    procedure ReadData;
    procedure ProcessHeader(const HeaderText: string);
    function IndexOfHeading(const Heading: string): Integer;
    procedure ProcessData(const DataText: string);
    function GetValue(Idx: UInt16): TScaleTestData;
  public
    constructor Create;
    destructor Destroy; override;
    function GetEnumerator: TEnumerator<TScaleTestData>;
    property Values[Idx: UInt16]: TScaleTestData read GetValue;
    property Data: TScaleTestLookup read fData;
  end;

implementation

uses
  System.SysUtils,
  System.Character,
  System.IOUtils;

{ TScalesTestDataReader }

constructor TScalesTestDataReader.Create;
begin
  inherited;
  fData := TScaleTestLookup.Create;
  fHeadings := TStringList.Create;
  ReadData;
end;

destructor TScalesTestDataReader.Destroy;
begin
  fHeadings.Free;
  fData.Free;
  inherited;
end;

function TScalesTestDataReader.GetEnumerator: TEnumerator<TScaleTestData>;
begin
  Result := fData.Values.GetEnumerator;
end;

function TScalesTestDataReader.GetValue(Idx: UInt16): TScaleTestData;
begin
  if not fData.TryGetValue(Idx, Result) then
    raise Exception.Create('Unknown ring number ' + Idx.ToString);
end;

function TScalesTestDataReader.IndexOfHeading(const Heading: string): Integer;
begin
  Result := fHeadings.IndexOf(Heading);
  Assert(Result >= 0);
end;

procedure TScalesTestDataReader.ProcessData(const DataText: string);
var
  Columns: TArray<string>;

  function GetDataFor(const ColumnID: string): string;
  begin
    Result := Columns[IndexOfHeading(ColumnID)];
  end;

  function ParseCommaDelimSet(const CDS: string): TArray<Cardinal>;
  begin
    var Elems := CDS.Split([',']);
    SetLength(Result, Length(Elems));
    for var I := Low(Elems) to High(Elems) do
      Result[I] := Elems[I].Trim.ToInteger;
  end;

  function ParsePitchClassSet(const PCSStr: string): TPitchClassSet;
  begin
    Result := [];
    var Elems := ParseCommaDelimSet(PCSStr);
    for var Elem in Elems do
    begin
      var PitchClass: TPitchClass := TPitchClass(Elem);
      Include(Result, PitchClass);
    end;
  end;

  function ParseRotationalSymmetry(const RotSymStr: string):
    TRotationalSymmetry;
  begin
    Result := [];
    var Elems := ParseCommaDelimSet(RotSymStr);
    if (Length(Elems) > 0) and (Elems[0] = 0) then
      Exit;
    for var Elem in Elems do
    begin
      var RotSym := Elem;
      Include(Result, RotSym);
    end;
  end;

  function ParseIntervals(const IntervalsStr: string): TIntervalPattern;
  begin
    var Elems := ParseCommaDelimSet(IntervalsStr);
    SetLength(Result, Length(Elems));
    for var I := Low(Elems) to High(Elems) do
      Result[I] := TInterval(Elems[I]);
  end;

  function ParseIntervalVector(const IVStr: string): TIntervalVector;
  begin
    var Elems := ParseCommaDelimSet(IVStr);
    Assert(Length(Elems) = Length(Result));
    for var I := Low(Elems) to High(Elems) do
      Result[I - Low(Elems) + Low(Result)] := Elems[I];
  end;

  function ParseModeNumberList(const ModesStr: string): TArray<UInt16>;
  begin
    var Elems := ParseCommaDelimSet(ModesStr);
    SetLength(Result, Length(Elems));
    for var I := Low(Elems) to High(Elems) do
      Result[I] := UInt16(Elems[I]);
  end;

begin
  // Check for spurious lines. Don't know why they've been causing exceptions:
  // it's only happened since the TTestScale.IsDeep_is_correct was added, and
  // what that's got to do with it is beyond me!!!
  if (DataText = '') or (not DataText[1].IsDigit) then
    Exit;
  Columns := DataText.Split([#9]);
  var Data: TScaleTestData;
  Data.ScaleNumber := UInt16(GetDataFor(ColScaleNumber).ToInteger);
  Data.IsZeitlerScale := GetDataFor(ColIsZeietlerScale).ToBoolean;
  Data.ZeitlerNumberAsc := UInt16(StrToIntDef(GetDataFor(ColZeitlerNumberAsc), 0));
  Data.ZeitlerNumberDesc := UInt16(StrToIntDef(GetDataFor(ColZeitlerNumberDesc), 0));
  Data.ScaleName := GetDataFor(ColName);
  Data.ZeitlerName := GetDataFor(ColZeitlerName);
  Data.Cardinality := Cardinal(GetDataFor(ColCardinality).ToInteger);
  Data.PitchClassSet := ParsePitchClassSet(GetDataFor(ColPitchClassSet));
  Data.RotationalSymmetry := ParseRotationalSymmetry(
    GetDataFor(ColRotationalSymmetry)
  );
  Data.IsPalindromic := GetDataFor(ColIsPalindromic).ToBoolean;
  Data.IsChiral := GetDataFor(ColIsChiral).ToBoolean;
  Data.Hemitonia := GetDataFor(ColHemitonia).ToInteger;
  Data.Cohemitonia := GetDataFor(ColCohemitonia).ToInteger;
  Data.Imperfections := GetDataFor(ColImperfections).ToInteger;
  Data.Perfections := GetDataFor(ColPerfections).ToInteger;
  Data.ModeCount := GetDataFor(ColModeCount).ToInteger;
  Data.IsPrimeForm := GetDataFor(ColIsPrimeForm).ToBoolean;
  Data.PrimeRingNumber := GetDataFor(ColPrimeRingNumber).ToInteger;
  Data.IsDeep := GetDataFor(ColIsDeep).ToBoolean;
  Data.Intervals := ParseIntervals(GetDataFor(ColIntervals));
  Data.Leap := GetDataFor(ColLeap).ToInteger;
  Data.IntervalVector := ParseIntervalVector(GetDataFor(ColIntervalVector));
  Data.IsBalanced := GetDataFor(ColIsBalanced).ToBoolean;
  Data.Modes := ParseModeNumberList(GetDataFor(ColModes));
  Data.Complement := ParseModeNumberList(GetDataFor(ColComplement));
  Data.Inverse := UInt16(GetDataFor(ColInverse).ToInteger);
  fData.Add(Data.ScaleNumber, Data);
end;


procedure TScalesTestDataReader.ProcessHeader(const HeaderText: string);
begin
  var Headings := HeaderText.Split([#9]);
  fHeadings.AddStrings(Headings);
end;

procedure TScalesTestDataReader.ReadData;
begin
  // scales-table is a tab delimited file of data. The first row defines the
  // names of the fields. Following lines contain data for each field in same
  // order as heading.
  { TODO: Include this file in resources and read into string list }
  var Lines := TFile.ReadAllLines('..\..\..\..\tests\data\scales-table');
  Assert(Length(Lines) > 1);
  ProcessHeader(Lines[0]);
  for var I := 1 to Length(Lines) do
  begin
    if Lines[I].Trim <> '' then
      ProcessData(Lines[I]);
  end;
end;

end.
