unit Test.Music.Keys;

interface

uses
  DUnitX.TestFramework,

  Music.Notes,
  Music.Scales,
  Music.Keys;

type
  [TestFixture]
  TTestKey = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    {
      Order of tests is significant. Features tested in later tests may depend
      on those tested in earlier tests.

      TKey tests also assume that Core tests and TNote and TScale test have all
      passed.
    }

    // test depends on Tonic and Scale property getters
    [Test]
    procedure default_ctor_sets_key_to_c_major;

    // test depends on Tonic and Scale property getters
    [Test]
    procedure scale_and_tonic_ctor_sets_key_correctly;

    [Test]
    [TestCase('Octave too high (10)', 'False,0,10')]
    [TestCase('Start just out of range (A9)', 'False,9,9')]
    [TestCase('Start just too high (A8)', 'False,9,8')]
    [TestCase('Highest possible start (G#8)', 'True,8,8')]
    [TestCase('Start at note 0 (C4)', 'True,0,4')]
    [TestCase('Start at E3', 'True,4,3')]
    [TestCase('Lowest start note (C-1)', 'True,0,-1')]
    [TestCase('Octave too low (-2)', 'False,11,-2')]
    procedure CanGenerateFullScaleFromOctave_is_correct(Expected: Boolean;
      Tonic: TPitchClass; Octave: Int8);

    [Test]
    procedure Notes_valid_parameters;
    [Test]
    procedure Notes_exception_for_bad_parameters;

    [Test]
    [TestCase('0->1', '1,0,1')]
    [TestCase('4->3', '3,4,11')]
    [TestCase('2->0', '0,2,10')]
    [TestCase('7->7 (8ve)', '7,7,12')]
    procedure TransposeBy_is_correct(ExpectedTonic, StartTonic: TPitchClass;
      Semitones: TInterval);
    [Test]
    [TestCase('-ve interval (PC=0)', '0,-1')]
    [TestCase('0 interval (PC=7)', '7,0')]
    [TestCase('13 interval (PC=11)', '11,13')]
    procedure TransposeBy_fails_assertion(StartTonic: TPitchClass;
      Semitones: Integer);

  end;

implementation

uses
  System.SysUtils;

procedure TTestKey.CanGenerateFullScaleFromOctave_is_correct(Expected: Boolean;
  Tonic: TPitchClass; Octave: Int8);
begin
  var K := TKey.Create(TScale.CreateFromPitchClassSet(TScale.MajorPitchClassSet), Tonic);
  Assert.AreEqual(Expected, K.CanGenerateFullScaleFromOctave(Octave));
end;

procedure TTestKey.default_ctor_sets_key_to_c_major;
begin
  var K: TKey;    // call default ctor
  Assert.AreEqual(0, Integer(K.Tonic), 'Tonic');
  Assert.IsTrue(TScale.CreateFromPitchClassSet(TScale.MajorPitchClassSet) = K.Scale, 'Scale');
end;

procedure TTestKey.Notes_exception_for_bad_parameters;
begin
  Assert.WillRaise(
    procedure
    begin
      var K := TKey.Create(TScale.CreateFromScaleNumber(2471), 4);
      K.Notes(9);
    end,
    EKey
  );
end;

procedure TTestKey.Notes_valid_parameters;

  procedure CheckNotes(const Expected: array of Integer;
    const Got: array of TNote; const Msg: string);
  begin
    var Same: Boolean;
    if Length(Expected) = Length(Got) then
    begin
      Same := True;
      for var I := Low(Got) to High(Got) do
      begin
        if Got[I].Pitch <> Expected[I] then
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

type
  TIntArray = array of Integer;
begin
  var S1 := TScale.CreateFromPitchClassSet([0,3,7,9]);
  var K1 := TKey.Create(S1, 0);
  var N1 := K1.Notes(4);
  var E1 := TIntArray.Create(0,3,7,9,12);
  CheckNotes(E1, N1, '{0,3,7,9} 8ve=4, tonic=0');

  var N1a := K1.Notes(6);
  var E1a := TIntArray.Create(24,27,31,33,36);
  CheckNotes(E1a, N1a, '{0,3,7,9} 8ve=6, tonic=0');

  var N1b := K1.Notes(-1);
  var E1b := TIntArray.Create(-60,-57,-53,-51,-48);
  CheckNotes(E1b, N1b, '{0,3,7,9} 8ve=-1, tonic=0');

  var S2 := TScale.CreateFromPitchClassSet([0]);
  var K2 := TKey.Create(S2, 5);
  var N2 := K2.Notes(4);
  var E2 := TIntArray.Create(5,17);
  CheckNotes(E2, N2, '{0} 8ve=4, tonic=5');

  var S3 := TScale.CreateFromPitchClassSet([0,1,2,3,4,5,6,7,8,9,10,11]);
  var K3 := TKey.Create(S3, 4);
  var N3 := K3.Notes(5);
  var E3 := TIntArray.Create(16,17,18,19,20,21,22,23,24,25,26,27,28);
  CheckNotes(E3, N3, '{0,1,2,3,4,5,6,7,8,9,10,11} 8ve=5, tonic=4');
end;

procedure TTestKey.scale_and_tonic_ctor_sets_key_correctly;
const
  PCS: TPitchClassSet = [0,3,5,7,9];
  Tonic = 6;
begin
  var S := TScale.CreateFromPitchClassSet(PCS);
  var K := TKey.Create(S, Tonic);
  Assert.AreEqual(PCS, K.Scale.PitchClassSet, 'Scale');
  Assert.AreEqual(Tonic, Integer(K.Tonic), 'Tonic');
end;

procedure TTestKey.Setup;
begin
end;

procedure TTestKey.TearDown;
begin
end;

procedure TTestKey.TransposeBy_fails_assertion(StartTonic: TPitchClass;
  Semitones: Integer);
begin
  Assert.WillRaise(
    procedure
    begin
      var K := TKey.Create(TScale.CreateFromScaleNumber(2471), StartTonic);
      var KT := K.TransposeBy(Semitones);
    end,
    EAssertionFailed
  );
end;

procedure TTestKey.TransposeBy_is_correct(ExpectedTonic,
  StartTonic: TPitchClass; Semitones: TInterval);
begin
  var K := TKey.Create(TScale.CreateFromScaleNumber(2471), StartTonic);
  var KT := K.TransposeBy(Semitones);
  Assert.AreEqual(ExpectedTonic, KT.Tonic);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestKey);

end.
