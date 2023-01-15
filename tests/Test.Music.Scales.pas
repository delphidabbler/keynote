unit Test.Music.Scales;

interface

uses

  System.Generics.Collections,

  DUnitX.TestFramework,

  Data.Scales,

  Music.Scales;

type

  [TestFixture]
  TTestScale = class
  private
    type
      TScalesMap = TDictionary<UInt16,TScale>;
      TScaleNumberArray = array of UInt16;

    const
      RingNumber_Bad_Zero = UInt16(0);
      RingNumber_Bad_HiBitsSet = UInt16($1235);
      RingNumber_Bad_Unrooted = UInt16(2472);

      RingNumber_Good_Low = UInt16(1);
      RingNumber_Good_Middle = UInt16(2471);
      RingNumber_Good_High = UInt16(4095);

      IntervalPattern_Bad_Empty: TIntervalPattern = [];
      IntervalPattern_Bad_DoesnotSumTo12: TIntervalPattern = [2,1,3,2];

      PitchClassSet_Bad_Empty: TPitchClassSet = [];
      PitchClassSet_Bad_Unrooted: TPitchClassSet = [1, 2, 7, 11];

// TODO: for use if and when IsBalanced method is implemented
//      AllBalancedScales: TScaleNumberArray = [
//        65, // not in Ring's list of balanced scales
//        273, 325, 403, 455, 585, 611, 715, 793, 819, 845, 871, 923, 975, 1105,
//        1235, 1365, 1495, 1625, 1651, 1755, 1885, 1911, 2015, 2249, 2275, 2353,
//        2405, 2457, 2483, 2509, 2535, 2665, 2795, 2873, 2925, 3003, 3055, 3185,
//        3289, 3315, 3445, 3549, 3575, 3705, 3835, 3965, 4095
//      ];

    var
      fTestData: TScalesTestDataReader;

      // Map of Ring number to TScale record with that Ring number
      fScales: TScalesMap;  // Use only after TScale.RingNumber has been tested

    // Get test data record for given Ring number
    function TD(const RingNumber: UInt16): TScaleTestData;

    procedure CheckIntervalPattern(const Expected, Got: TIntervalPattern;
      const Msg: string = '');

    function RingNumbersFromScales(const AScales: array of TScale): TArray<UInt16>;

    procedure CheckRingNumbers(const Expected, Got: array of UInt16;
      const Msg: string = ''); overload;
    procedure CheckRingNumbers(const Expected: array of UInt16;
      const Got: array of TScale;
      const Msg: string = ''); overload;
    procedure CheckSortedScales(const Expected: array of UInt16;
      const Got: array of TScale; const Msg: string = '');

    function IsInArray(const A: array of UInt16; const V: UInt16): Boolean;

  public

    constructor Create;
    destructor Destroy; override;

    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Ordering of following tests is significant: later tests may depend on
    // methods tested earlier, but not vice versa

    [Test]
    [TestCase('0 (< lowest) -> not rooted','0,False')]
    [TestCase('4097 (> highest) -> hit bits set', '4097,False')]
    [TestCase('2472 -> not rooted','2472,False')]
    [TestCase('1 (lowest)-> OK', '1,True')]
    [TestCase('4095 (highest)','4095,True')]
    [TestCase('2471','2471,True')]
    // no dependency
    procedure IsValidRingNumber(N: Integer; Expected: Boolean);

    [Test]
    // test depends on RingNumber property & IsValidRingNumber method
    procedure RingNumber_prop_setter_and_getter_valid_number;
    [Test]
    // test depends on RingNumber property & IsValidRingNumber method
    procedure RingNumber_prop_setter_and_getter_invalid_number;

    [Test]
    // test depends on RingNumber property getter
    procedure default_ctor_creates_Chromatic_scale;

    [Test]
    // depends only on RingNumber property setter
    procedure RingNumber_ctor_valid_number;
    [Test]
    // depends only on RingNumber property setter
    procedure RingNumber_ctor_invalid_number;

    // test depends on default & RingNumber ctors & property getter
    [Test]
    procedure assignment_is_correct;

    [Test]
    // depends only on RingNumber property getter
    procedure equals_op_true_for_same_scales;
    [Test]
    // depends only on RingNumber property getter
    procedure equals_op_false_for_different_scales;

    [Test]
    // depends only on RingNumber property getter
    procedure notequals_op_false_for_same_scales;
    [Test]
    // depends only on RingNumber property getter
    procedure notequals_op_true_for_different_scales;

    [Test]
    // depends only on RingNumber property getter
    procedure Cardinality_is_correct;

    [Test]
    // depends only on RingNumber property getter & setter
    procedure Inverse_is_correct;

    [Test]
    // depends on Inverse method and equals operator
    procedure IsPalindromic_is_correct;

    // no dependency
    [Test]
    procedure IsValidPitchClassSet_is_true;
    // no dependency
    [Test]
    procedure IsValidPitchClassSet_is_false;

    [Test]
    // depends only on RingNumber property getter
    procedure PitchClassSet_prop_getter;
    [Test]
    // depends on RingNumber property setter and IsValidPitchClassSet method
    procedure PitchClassSet_prop_setter_valid_pattern;
    [Test]
    // depends on RingNumber property setter and IsValidPitchClassSet method
    procedure PitchClassSet_prop_setter_invalid_pattern;

    [Test]
    // depends on RingNumber property setter and IsValidPitchClassSet method
    procedure PitchClassSet_ctor_valid_set;
    [Test]
    // depends on RingNumber property setter and IsValidPitchClassSet method
    procedure PitchClassSet_ctor_invalid_set;

    [Test]
    // no dependency
    procedure IsValidIntervalPattern_is_true;
    [Test]
    // no dependency
    procedure IsValidIntervalPattern_is_false;

    [Test]
    // depends on Cardinality method
    procedure IntervalPattern_prop_getter;
    [Test]
    // depends on RingNumber property getter & IsValidIntervalPattern method
    procedure IntervalPattern_prop_setter_valid_pattern;
    [Test]
    // depends on RingNumber property getter & IsValidIntervalPattern method
    procedure IntervalPattern_prop_setter_invalid_pattern;

    [Test]
    // depends on RingNumber property getter & IsValidIntervalPattern method
    procedure IntervalPattern_ctor_valid_pattern;
    [Test]
    // depends on RingNumber property getter & IsValidIntervalPattern method
    procedure IntervalPattern_ctor_invalid_pattern;

    [Test]
    // depends on IntervalPattern property getter
    procedure Hemitonia_is_correct;

    [Test]
    // depends only on RingNumber property getter
    procedure Cohemitonia_is_correct;

    [Test]
    // depends on IntervalPattern property getter
    procedure Leap_is_correct;

    [Test]
    // depends on Leap method
    procedure IsZeitler_is_correct;

    [Test]
    // depends on IsZeitler method
    procedure ZeitlerNumberAscending_is_correct;
    [Test]
    // depends on IsZeitler method
    procedure ZeitlerNumberDescending_is_correct;

    [Test]
    // depends on RingNumber getter & ctor
    procedure Modes_is_correct;

    [Test]
    // depends on Modes
    procedure ModeCount_is_correct;

    [Test]
    // depends on RingNumber getter & ctor
    procedure ModalFamily_is_correct;

    [Test]
    // depends on RingNumber getter & ctor
    procedure IsContainedIn_is_true;
    [Test]
    // depends on RingNumber getter & ctor
    procedure IsContainedIn_is_false;

    [Test]
    // depends on IsContainedIn
    procedure IsModeOf_is_true;
    [Test]
    // depends on IsContainedIn
    procedure IsModeOf_is_false;

    [Test]
    // depends only on RingNumber getter
    procedure RotationalSymmetry_is_correct;

    [Test]
    // depends on RotationalSymmetry
    procedure RotationalSymmetryCount_is_correct;

    [Test]
    // depends on ModalFamily
    procedure Perfections_is_correct;

    [Test]
    // depends on Perfections
    procedure Imperfections_is_correct;

    [Test]
    // depends on Inverse, Modes & IsContainedIn
    procedure IsChiral_is_correct;

    [Test]
    // depends on Inverse
    procedure RahnPrime_is_correct;

    // depends on RahnPrime
    [Test]
    procedure IsPrime_is_correct;

    // depends only on RingNumber getter
    [Test]
    procedure IntervalVector_is_correct;

    // depends on IntervalVector
    [Test]
    procedure IsDeep_is_correct;

    // depends on ModalFamily
    [Test]
    procedure Complement_is_correct;

  end;

implementation

uses
  System.SysUtils,
  System.Generics.Defaults;


{ TTestScale }

procedure TTestScale.assignment_is_correct;
const
  RN: UInt16 = 2471;
begin
  var S := TScale.CreateFromRingNumber(RN);
  var T: TScale;
  Assert.IsFalse(RN = T.RingNumber, 'Before assignment');
  T := S;
  Assert.IsTrue(RN = T.RingNumber, 'After assignment');
end;

procedure TTestScale.Cardinality_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.Cardinality, fScales[D.RingNumber].Cardinality, D.RingName);
end;

procedure TTestScale.CheckIntervalPattern(const Expected, Got: TIntervalPattern;
  const Msg: string);
begin
  var Same: Boolean;
  if Length(Expected) = Length(Got) then
  begin
    Same := True;
    for var I := Low(Expected) to High(Expected) do
    begin
      if Expected[I] <> Got[I] then
      begin
        Same := False;
        Break;
      end;
    end;
  end
  else
    Same := False;
  Assert.IsTrue(Same, Msg);
end;

procedure TTestScale.CheckRingNumbers(const Expected: array of UInt16;
  const Got: array of TScale; const Msg: string);
begin
  CheckRingNumbers(Expected, RingNumbersFromScales(Got), Msg);
end;

procedure TTestScale.CheckSortedScales(const Expected: array of UInt16;
  const Got: array of TScale; const Msg: string);

  function Same: Boolean;
  begin
    var GotRN := RingNumbersFromScales(Got);
    if Length(Expected) <> Length(Got) then
      Exit(False);
    for var I := 0 to Pred(Length(Expected)) do
    begin
      if Expected[I] <> GotRN[I] then
        Exit(False);
    end;
    Result := True;
  end;

begin
  Assert.IsTrue(Same, Msg);
end;

procedure TTestScale.CheckRingNumbers(const Expected, Got: array of UInt16;
  const Msg: string);

  function IsElemInGot(Elem: UInt16): Boolean;
  begin
    Result := False;
    for var G in Got do
    begin
      if G = Elem then
        Exit(True);
    end;
  end;

begin
  var Same: Boolean;
  if Length(Expected) = Length(Got) then
  begin
    Same := True;
    for var E in Expected do
    begin
      if not IsElemInGot(E) then
      begin
        Same := False;
        Break;
      end;
    end;
  end
  else
    Same := False;
  Assert.IsTrue(Same, Msg);
end;

procedure TTestScale.Cohemitonia_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.Cohemitonia, fScales[D.RingNumber].Cohemitonia, D.RingName);
end;

procedure TTestScale.Complement_is_correct;
begin
  for var D: TScaleTestData in fTestData do
  begin
    CheckRingNumbers(
      D.Complement, fScales[D.RingNumber].Complement, D.RingName
    );
  end;
end;

constructor TTestScale.Create;
begin
  fTestData := TScalesTestDataReader.Create;
  fScales := TScalesMap.Create;
  for var Data in fTestData do
  begin
    // ** Assumes TScale.RingNumber property works => fScales may only be used
    //    AFTER TScale.RingNumber has been tested.
    var Scale: TScale;
    Scale.RingNumber := Data.RingNumber;
    fScales.Add(Scale.RingNumber, Scale);
  end;
end;

procedure TTestScale.default_ctor_creates_Chromatic_scale;
begin
  var S: TScale;    // default
  Assert.AreEqual(4095, S.RingNumber);
end;

destructor TTestScale.Destroy;
begin
  fScales.Free;
  fTestData.Free;
  inherited;
end;

procedure TTestScale.equals_op_false_for_different_scales;
begin
  var S1 := TScale.CreateFromRingNumber(2471);
  var S2 := TScale.CreateFromRingNumber(1193);
  Assert.IsFalse(S1 = S2);
end;

procedure TTestScale.equals_op_true_for_same_scales;
begin
  var S1 := TScale.CreateFromRingNumber(2471);
  var S2 := TScale.CreateFromRingNumber(2471);
  Assert.IsTrue(S1 = S2);
end;

procedure TTestScale.Hemitonia_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.Hemitonia, fScales[D.RingNumber].Hemitonia, D.RingName);
end;

procedure TTestScale.Imperfections_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.Imperfections, fScales[D.RingNumber].Imperfections, D.RingName);
end;

procedure TTestScale.IntervalPattern_ctor_invalid_pattern;
begin
  Assert.WillRaise(
    procedure
    begin
      var S := TScale.CreateFromIntervalPattern(IntervalPattern_Bad_Empty);
    end,
    EScale
  );
end;

procedure TTestScale.IntervalPattern_ctor_valid_pattern;
begin
  for var D: TScaleTestData in fTestData do
  begin
    var S := TScale.CreateFromIntervalPattern(D.Intervals);
    Assert.AreEqual(D.Intervals, S.IntervalPattern, D.RingName);
  end;
end;

procedure TTestScale.IntervalPattern_prop_getter;
begin
  for var D: TScaleTestData in fTestData do
    CheckIntervalPattern(D.Intervals, fScales[D.RingNumber].IntervalPattern, D.RingName);
end;

procedure TTestScale.IntervalPattern_prop_setter_invalid_pattern;
begin
  Assert.WillRaise(
    procedure
    begin
      var S: TScale;
      S.IntervalPattern := IntervalPattern_Bad_DoesnotSumTo12;
    end,
    EScale
  );
end;

procedure TTestScale.IntervalPattern_prop_setter_valid_pattern;
begin
  for var D: TScaleTestData in fTestData do
  begin
    var S: TScale;
    S.IntervalPattern := D.Intervals;
    CheckIntervalPattern(D.Intervals, S.IntervalPattern, D.RingName);
  end;
end;

procedure TTestScale.IntervalVector_is_correct;

  function SameVector(const A, B: TIntervalVector): Boolean;
  begin
    Result := True;
    for var I := Low(A) to High(A) do
      if A[I] <> B[I] then
        Exit(False);
  end;

begin
  for var D: TScaleTestData in fTestData do
    Assert.IsTrue(
      SameVector(D.IntervalVector, fScales[D.RingNumber].IntervalVector), D.RingName
    );
end;

procedure TTestScale.Inverse_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.Inverse, fScales[D.RingNumber].Inverse.RingNumber, D.RingName);
end;

procedure TTestScale.IsChiral_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.IsChiral, fScales[D.RingNumber].IsChiral, D.RingName);
end;

procedure TTestScale.IsContainedIn_is_false;
begin
  var A, B: TArray<TScale>;
  SetLength(A, 3);
  A[0] := TScale.CreateFromRingNumber(65);
  A[1] := TScale.CreateFromRingNumber(2741);
  A[2] := TScale.CreateFromRingNumber(3187);

  SetLength(B, 0);

  var S := TScale.CreateFromRingNumber(1453);

  Assert.IsFalse(S.IsContainedIn(A), '3 elem list');
  Assert.IsFalse(S.IsContainedIn(B), 'empty list');
end;

procedure TTestScale.IsContainedIn_is_true;
begin
  var A: TArray<TScale>;
  SetLength(A, 5);
  A[0] := TScale.CreateFromRingNumber(65);
  A[1] := TScale.CreateFromRingNumber(2741);
  A[2] := TScale.CreateFromRingNumber(3187);
  A[3] := TScale.CreateFromRingNumber(4033);
  A[4] := TScale.CreateFromRingNumber(1453);
  var SFirst := TScale.CreateFromRingNumber(65);
  var SMid := TScale.CreateFromRingNumber(3187);
  var SLast := TScale.CreateFromRingNumber(1453);
  Assert.IsTrue(SFirst.IsContainedIn(A), 'First');
  Assert.IsTrue(SMid.IsContainedIn(A), 'Mid');
  Assert.IsTrue(SLast.IsContainedIn(A), 'Last');
end;

procedure TTestScale.IsDeep_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.IsDeep, fScales[D.RingNumber].IsDeep, D.RingName);
end;

function TTestScale.IsInArray(const A: array of UInt16;
  const V: UInt16): Boolean;
begin
  Result := False;
  for var Elem in A do
    if Elem = V then
      Exit(True);
end;

procedure TTestScale.IsModeOf_is_false;
begin
  var SUnison := TScale.CreateFromRingNumber(1);   // no modes
  var STritone := TScale.CreateFromRingNumber(65);  // no modes
  var SMajor := TScale.CreateFromRingNumber(2741);  // 7-tone has modes
  var SKoptian := TScale.CreateFromRingNumber(3187);  // 7-tone has modes
  Assert.IsFalse(SUnison.IsModeOf(SMajor), 'Unison of Major');
  Assert.IsFalse(SUnison.IsModeOf(STritone), 'Unison of Tritone');
  Assert.IsFalse(STritone.IsModeOf(SMajor), 'Tritone of Major');
  Assert.IsFalse(SMajor.IsModeOf(SMajor), 'Major of Self');
  Assert.IsFalse(SMajor.IsModeOf(SKoptian), 'Major of Koptian');
  Assert.IsFalse(SKoptian.IsModeOf(SMajor), 'Major of Koptian');
end;

procedure TTestScale.IsModeOf_is_true;
begin
  var Major := TScale.CreateFromRingNumber(2741);  // 7-tone has modes
  var Minor := TScale.CreateFromRingNumber(1453);  // 7-tone has modes
  var Lanic := TScale.CreateFromRingNumber(281);  // 4-tone has modes
  var Zyphic := TScale.CreateFromRingNumber(2321);  // 4-tone has modes
  var Heptatonic_Chromatic_Descending  := TScale.CreateFromRingNumber(4033); // 7-tone has modes, non Zeigler
  var Heptatonic_Chromatic  := TScale.CreateFromRingNumber(127); // 7-tone has modes, non Zeigler
  Assert.IsTrue(Major.IsModeOf(Minor), 'Major of Minor');
  Assert.IsTrue(Minor.IsModeOf(Major), 'Minor of Major');
  Assert.IsTrue(Lanic.IsModeOf(Zyphic), 'Lanic of Zaphic');
  Assert.IsTrue(Zyphic.IsModeOf(Lanic), 'Zyphic of Lanic');
  Assert.IsTrue(Heptatonic_Chromatic_Descending.IsModeOf(Heptatonic_Chromatic), 'Hept Desc of Hept');
  Assert.IsTrue(Heptatonic_Chromatic.IsModeOf(Heptatonic_Chromatic_Descending), 'Hept of Hept Desc');
end;

procedure TTestScale.IsPalindromic_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.IsPalindromic, fScales[D.RingNumber].IsPalindromic, D.RingName);
end;

procedure TTestScale.IsPrime_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.IsPrimeForm, fScales[D.RingNumber].IsPrime, D.RingName);
end;

procedure TTestScale.IsValidIntervalPattern_is_false;
begin
  Assert.IsFalse(TScale.IsValidIntervalPattern(IntervalPattern_Bad_Empty), 'Empty');
  Assert.IsFalse(TScale.IsValidIntervalPattern(IntervalPattern_Bad_DoesnotSumTo12), 'Sum <> 12');
end;

procedure TTestScale.IsValidIntervalPattern_is_true;
begin
  for var D: TScaleTestData in fTestData do
    Assert.IsTrue(fScales[D.RingNumber].IsValidIntervalPattern(D.Intervals), D.RingName);
end;

procedure TTestScale.IsValidPitchClassSet_is_false;
begin
  Assert.IsFalse(TScale.IsValidPitchClassSet(PitchClassSet_Bad_Empty), 'Empty');
  Assert.IsFalse(TScale.IsValidPitchClassSet(PitchClassSet_Bad_Unrooted), 'Unrooted');
end;

procedure TTestScale.IsValidPitchClassSet_is_true;
begin
  for var D: TScaleTestData in fTestData do
    Assert.IsTrue(fScales[D.RingNumber].IsValidPitchClassSet(D.PitchClassSet), D.RingName);
end;

procedure TTestScale.IsValidRingNumber(N: Integer; Expected: Boolean);
begin
  Assert.AreEqual(Expected, TScale.IsValidRingNumber(N));
end;

procedure TTestScale.IsZeitler_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.IsZeitlerScale, fScales[D.RingNumber].IsZeitlerScale, D.RingName);
end;

procedure TTestScale.Leap_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(Integer(D.Leap), Integer(fScales[D.RingNumber].Leap), D.RingName);
end;

procedure TTestScale.ModalFamily_is_correct;
begin

  for var D: TScaleTestData in fTestData do
  begin
    // TTestScaleData doesn't contain a suitable element, so we must calculate
    // the expected result by adding ring number of element to Modes array and
    // then sorting it
    var Expected := D.Modes;
    SetLength(Expected, Length(Expected) + 1);
    Expected[Pred(Length(Expected))] := D.RingNumber;
    TArray.Sort<UInt16>(
      Expected,
      TDelegatedComparer<UInt16>.Create(
        function (const Left, Right: UInt16): Integer
        begin
          Result := Left - Right;
        end
      )
    );
    CheckSortedScales(Expected, fScales[D.RingNumber].ModalFamily, D.RingName);
  end;
end;

procedure TTestScale.ModeCount_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.ModeCount, fScales[D.RingNumber].ModeCount, D.RingName);
end;

procedure TTestScale.Modes_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    CheckRingNumbers(D.Modes, fScales[D.RingNumber].Modes, D.RingName);
end;

procedure TTestScale.notequals_op_false_for_same_scales;
begin
  var S1 := TScale.CreateFromRingNumber(1193);
  var S2 := TScale.CreateFromRingNumber(1193);
  Assert.IsFalse(S1 <> S2);
end;

procedure TTestScale.notequals_op_true_for_different_scales;
begin
  var S1 := TScale.CreateFromRingNumber(2471);
  var S2 := TScale.CreateFromRingNumber(1193);
  Assert.IsTrue(S1 <> S2);
end;

procedure TTestScale.Perfections_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.Perfections, fScales[D.RingNumber].Perfections, D.RingName);
end;

procedure TTestScale.PitchClassSet_ctor_invalid_set;
begin
  Assert.WillRaise(
    procedure
    begin
      var S := TScale.CreateFromPitchClassSet(PitchClassSet_Bad_Empty);
    end,
    EScale
  );
end;

procedure TTestScale.PitchClassSet_ctor_valid_set;
begin
  for var D: TScaleTestData in fTestData do
  begin
    var S := TScale.CreateFromPitchClassSet(D.PitchClassSet);
    Assert.AreEqual(D.PitchClassSet, S.PitchClassSet, D.RingName);
  end;
end;

procedure TTestScale.PitchClassSet_prop_getter;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.PitchClassSet, fScales[D.RingNumber].PitchClassSet, D.RingName);
end;

procedure TTestScale.PitchClassSet_prop_setter_invalid_pattern;
begin
  Assert.WillRaise(
    procedure
    begin
      var S: TScale;
      S.PitchClassSet := PitchClassSet_Bad_Unrooted;
    end,
    EScale
  );
end;

procedure TTestScale.PitchClassSet_prop_setter_valid_pattern;
begin
  for var D: TScaleTestData in fTestData do
  begin
    var S: TScale;
    S.PitchClassSet := D.PitchClassSet;
    Assert.AreEqual(D.PitchClassSet, S.PitchClassSet, D.RingName);
  end;
end;

procedure TTestScale.RahnPrime_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.PrimeRingNumber, fScales[D.RingNumber].RahnPrime.RingNumber, D.RingName);
end;

function TTestScale.RingNumbersFromScales(
  const AScales: array of TScale): TArray<UInt16>;
begin
  SetLength(Result, Length(AScales));
  for var I := Low(AScales) to High(AScales) do
    Result[I] := AScales[I].RingNumber;
end;

procedure TTestScale.RingNumber_ctor_invalid_number;
begin
  Assert.WillRaise(
    procedure
    begin
      var S := TScale.CreateFromRingNumber(2472);
    end,
    EScale
  );
end;

procedure TTestScale.RingNumber_ctor_valid_number;
begin
  var S := TScale.CreateFromRingNumber(2471);
  Assert.AreEqual(2471, S.RingNumber);
end;

procedure TTestScale.RingNumber_prop_setter_and_getter_invalid_number;
begin
  Assert.WillRaise(
    procedure
    begin
      var S: TScale;
      S.RingNumber := 4096;
    end,
    EScale
  );
end;

procedure TTestScale.RingNumber_prop_setter_and_getter_valid_number;
begin
  var S: TScale;
  for var D in fTestData do
  begin
    S.RingNumber := D.RingNumber;
    Assert.AreEqual(Integer(D.RingNumber), Integer(S.RingNumber), D.RingName);
  end;
end;

procedure TTestScale.RotationalSymmetryCount_is_correct;
begin
  for var D: TScaleTestData in fTestData do
  begin
    var RotCount: Cardinal := 0;
    for var Elem := 1 to 12 do
      if Elem in D.RotationalSymmetry then
        Inc(RotCount);
    Assert.AreEqual(RotCount, fScales[D.RingNumber].RotationalSymmetryCount, D.RingName);
  end;
end;

procedure TTestScale.RotationalSymmetry_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.RotationalSymmetry, fScales[D.RingNumber].RotationalSymmetry, D.RingName);
end;

procedure TTestScale.Setup;
begin
end;

function TTestScale.TD(const RingNumber: UInt16): TScaleTestData;
begin
  Result := fTestData.Values[RingNumber];
end;

procedure TTestScale.TearDown;
begin
end;

procedure TTestScale.ZeitlerNumberAscending_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.ZeitlerNumberAsc, fScales[D.RingNumber].ZeitlerNumber(True), D.RingName);
end;

procedure TTestScale.ZeitlerNumberDescending_is_correct;
begin
  for var D: TScaleTestData in fTestData do
    Assert.AreEqual(D.ZeitlerNumberDesc, fScales[D.RingNumber].ZeitlerNumber(False), D.RingName);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestScale);
end.

