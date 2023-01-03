unit Test.Music.Notes;

interface

uses
  DUnitX.TestFramework,

  Music.Notes;

type

  [TestFixture]
  TTestNoteValues = class
  private
    NV1, NV1eq, NV2: TNoteValue;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure default_ticks_property_is_crotchet;
    [Test]
    procedure assigning_non_zero_ticks_property_succeeds;
    [Test]
    procedure assigning_0_to_ticks_property_fails;
    [Test]
    procedure passing_non_zero_ticks_to_ctor_succeeds;
    [Test]
    procedure passing_0_to_ctor_fails;

    [Test]
    procedure Operator_EQ_succeeds;
    [Test]
    procedure Operator_EQ_fails;
    [Test]
    procedure Operator_NEQ_succeeds;
    [Test]
    procedure Operator_NEQ_fails;
    [Test]
    procedure Operator_LT_succeeds;
    [Test]
    procedure Operator_LT_fails;
    [Test]
    procedure Operator_LTE_succeeds;
    [Test]
    procedure Operator_LTE_fails;
    [Test]
    procedure Operator_GT_succeeds;
    [Test]
    procedure Operator_GT_fails;
    [Test]
    procedure Operator_GTE_succeeds;
    [Test]
    procedure Operator_GTE_fails;

    [Test]
    [TestCase('Maxima',    '32768')]    // Maxima     = 8*4096 ticks
    [TestCase('8',         '8')]        // 1/512 note = 4096/512 ticks
    [TestCase('Semibreve', '4096')]     // Semibreve  = 4096 ticks
    [TestCase('Semiquaver','256')]      // Semiquaver = 4096/16 ticks
    procedure DottedValueInTicks_is_noop_when_dots_is_0(Ticks: UInt16);

    [Test]
    // Expected ticks calculated from table at
    // https://en.wikipedia.org/wiki/Note_value#List
    // Maxima = 8*4096 ticks with 3 dots => 15 whole notes = 61400 ticks
    [TestCase('Maxima, 3 dots', '32768,3,61440')]
    // Semibreve = 4096 ticks with 1 dot => 3/2 whole notes = 6144 ticks
    [TestCase('Semibreve, 1 dot', '4096,1,6144')]
    // Semiquaver = 256 ticks with 2 dots => 7/64 whole notes = 448 ticks
    [TestCase('Semiquaver, 2 dots', '256,2,448')]
    // 1/512 note = 8 ticks with 3 dots => 15/4096 whole notes = 15 ticks
    [TestCase('1/512 note, 3 dots', '8,3,15')]
    procedure DottedValueInTicks_with_non_zero_dots(Ticks: UInt16;
      Dots: TNoteValue.TDots; ExpectedTicks: UInt16);

    [Test]
    [TestCase('Ticks < 1/512 note, 2 dots','7,2')]
    [TestCase('Ticks < 1/512 note, 1 dot','6,1')]
    [TestCase('Ticks < 1/512 note, 3 dots','1,3')]
    [TestCase('Ticks = 0, 3 dots','1,3')]
    procedure DottedValueInTicks_with_bad_range_args_fails(BadTicks: UInt16;
      Dots: TNoteValue.TDots);

    [Test]
    [TestCase('Ticks 28, dots 3', '28,3')]
    [TestCase('Ticks 28, dots 2', '26,2')]
    [TestCase('Ticks 29, dots 1', '26,2')]
    procedure DottedValueInTicks_with_invalid_ticks_fails(BadTicks: UInt16;
      Dots: TNoteValue.TDots);

    [Test]
    // Maxima = 8 * 4096 = 32768 ticks
    [TestCase('Maxima', '8.0,32768')]
    // Breve = 2 * 4096 = 8192 ticks
    [TestCase('Breve', '2.0,8192')]
    // Semibreve = 1 * 4096 = 4096 ticks
    [TestCase('SemiBreve', '1.0,4096')]
    // Minim = 1/2 * 4096 = 2048 ticks
    [TestCase('Minim', '0.5,2048')]
    // Demisemiquaver = 1/32 * 4096 = 128 ticks
    [TestCase('Demisemiquaver', '0.03125,128')]
    procedure Relative_prop(Expected: Double; Ticks: UInt16);

    [Test]
    // Crotchet = 1/4 * 4096 = 1024 ticks
    [TestCase('Crotchet, 60CPM', '1000,1024,60')]
    // Crotchet = 1/4 * 4096 = 1024 ticks
    [TestCase('Crotchet, 120CPM', '500,1024,120')]
    // Semibreve = 1 * 4096 = 4096 ticks
    [TestCase('Semibreve, 120CPM', '2000,4096,120')]
    // Semiquaver = 1/16 * 4096 = 256 ticks
    [TestCase('Semiquaver, 100CPM', '150,256,100')]
    // Semiquaver = 1/16 * 4096 = 256 ticks
    [TestCase('Semiquaver, 145CPM', '103,256,145')]
    // Demisemihemidemisemiquaver = 1/256 * 4096 = 16 ticks
    [TestCase('Demisemihemidemisemiquaver, 90CPM', '10,16,90')]
    procedure DurationMS(Expected: UInt32; Ticks: UInt16;
      CrotchetsPerMin: UInt16);
  end;

  [TestFixture]
  TTestNotes = class
  private
    const
      CMinus1 = 0;
      C0 = 12;
      C9 = 120;
      G9 = 127;
      Bb7 = 106;
      B7 = 107;
      C8 = 108;
      A4 = 69;
      Db5 = 73;
      G4 = 67;
      C1 = 24;
    var
      N0, N6, N7, N8, N42, N100, N100Dup, N127: TNote;
      NMinus1: TNote;
      NC0: TNote;
      NC1: TNote;
      NC9: TNote;
      NG9: TNote;
      NBb7: TNote;
      NB7: TNote;
      NC8: TNote;
      NA4: TNote;
      NDb5: TNote;
      NG4: TNote;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure note_pitch_without_ctor_is_0;
    [Test]
    procedure note_pitch_with_ctor_is_correct;
    [Test]
    procedure bad_note_pitch_in_ctor_fails_assertion;
    [Test]
    procedure OctaveNumber_is_correct;
    [Test]
    procedure OctaveOffset_is_correct;
    [Test]
    procedure Operator_EQ_succeeds;
    [Test]
    procedure Operator_EQ_fails;
    [Test]
    procedure Operator_NEQ_succeeds;
    [Test]
    procedure Operator_NEQ_fails;
    [Test]
    procedure Operator_LT_succeeds;
    [Test]
    procedure Operator_LT_fails;
    [Test]
    procedure Operator_LTE_succeeds;
    [Test]
    procedure Operator_LTE_fails;
    [Test]
    procedure Operator_GT_succeeds;
    [Test]
    procedure Operator_GT_fails;
    [Test]
    procedure Operator_GTE_succeeds;
    [Test]
    procedure Operator_GTE_fails;
    [Test]
    procedure middle_C;
    [Test]
    procedure concert_A;
    [Test]
    procedure GetFullName_flat;
    [Test]
    procedure GetFullName_sharp;
    [Test]
    procedure GetNameOf;
    [Test]
    procedure Frequency;
  end;

implementation

uses
  System.SysUtils,
  System.Math;

{ TTestNoteValues }

procedure TTestNoteValues.assigning_0_to_ticks_property_fails;
begin
  Assert.WillRaise(
    procedure
    begin
      var N: TNoteValue;
      N.Ticks := 0;
    end,
    EArgumentOutOfRangeException,
    'N.Ticks := 0'
  );
end;

procedure TTestNoteValues.assigning_non_zero_ticks_property_succeeds;
begin
  var N1, N2, N3, N4: TNoteValue;
  N1.Ticks := TNoteValue.Maxima;
  Assert.AreEqual(TNoteValue.Maxima, N1.Ticks, 'N1.Ticks = Maxima');
  N2.Ticks := TNoteValue.Semiquaver;
  Assert.AreEqual(TNoteValue.Semiquaver, N2.Ticks, 'N2.Ticks = Semiquaver');
  N3.Ticks := 1;
  Assert.AreEqual(1, N3.Ticks, 'N3.Ticks = 1');
  N4.Ticks := High(UInt16);
  Assert.AreEqual(High(UInt16), N4.Ticks, 'N4.Ticks = High(UInt16)');
end;

procedure TTestNoteValues.default_ticks_property_is_crotchet;
begin
  var N: TNoteValue;
  Assert.AreEqual(TNoteValue.Crotchet, N.Ticks);
end;

procedure TTestNoteValues.DottedValueInTicks_is_noop_when_dots_is_0(
  Ticks: UInt16);
begin
  Assert.AreEqual(Ticks, TNoteValue.DottedValueInTicks(Ticks, 0));
end;

procedure TTestNoteValues.DottedValueInTicks_with_bad_range_args_fails(
  BadTicks: UInt16; Dots: TNoteValue.TDots);
begin
  Assert.WillRaise(
    procedure
    begin
      TNoteValue.DottedValueInTicks(BadTicks, Dots)
    end,
    EArgumentOutOfRangeException,
    'Ticks out of range'
  );
end;

procedure TTestNoteValues.DottedValueInTicks_with_invalid_ticks_fails(
  BadTicks: UInt16; Dots: TNoteValue.TDots);
begin
  Assert.WillRaise(
    procedure
    begin
      TNoteValue.DottedValueInTicks(BadTicks, Dots);
    end,
    EArgumentException,
    'Ticks not divisible by 2 ^ Dots'
  );
end;

procedure TTestNoteValues.DottedValueInTicks_with_non_zero_dots(Ticks: UInt16;
  Dots: TNoteValue.TDots; ExpectedTicks: UInt16);
begin
  Assert.AreEqual(ExpectedTicks, TNoteValue.DottedValueInTicks(Ticks, Dots));
end;

procedure TTestNoteValues.DurationMS(Expected: UInt32; Ticks,
  CrotchetsPerMin: UInt16);
begin
  var NV := TNoteValue.Create(Ticks);
  Assert.AreEqual(Expected, NV.DurationMS(CrotchetsPerMin));
end;

procedure TTestNoteValues.Operator_EQ_fails;
begin
  Assert.IsFalse(NV1 = NV2);
end;

procedure TTestNoteValues.Operator_EQ_succeeds;
begin
  Assert.IsTrue(NV1 = NV1eq);
end;

procedure TTestNoteValues.Operator_GTE_fails;
begin
  Assert.IsFalse(NV1 >= NV2);
end;

procedure TTestNoteValues.Operator_GTE_succeeds;
begin
  Assert.IsTrue(NV2 >= NV1, '>= | NV2 > NV1');
  Assert.IsTrue(NV1 >= NV1eq, '>= | NV1 = NV1eq');
end;

procedure TTestNoteValues.Operator_GT_fails;
begin
  Assert.IsFalse(NV1 > NV2);
end;

procedure TTestNoteValues.Operator_GT_succeeds;
begin
  Assert.IsTrue(NV2 > NV1);
end;

procedure TTestNoteValues.Operator_LTE_fails;
begin
  Assert.IsFalse(NV2 <= NV1);
end;

procedure TTestNoteValues.Operator_LTE_succeeds;
begin
  Assert.IsTrue(NV1 < NV2, '<= | NV1 < NV2');
  Assert.IsTrue(NV1 <= NV1eq, '<= | Nv1 = NV1eq');
end;

procedure TTestNoteValues.Operator_LT_fails;
begin
  Assert.IsFalse(NV2 < NV1);
end;

procedure TTestNoteValues.Operator_LT_succeeds;
begin
  Assert.IsTrue(NV1 < NV2);
end;

procedure TTestNoteValues.Operator_NEQ_fails;
begin
  Assert.IsFalse(NV1 <> NV1eq);
end;

procedure TTestNoteValues.Operator_NEQ_succeeds;
begin
  Assert.IsTrue(NV1 <> NV2);
end;

procedure TTestNoteValues.passing_0_to_ctor_fails;
begin
  Assert.WillRaise(
    procedure
    begin
      var N := TNoteValue.Create(0);
    end,
    EArgumentOutOfRangeException,
    'ATicks = 0'
  );
end;

procedure TTestNoteValues.passing_non_zero_ticks_to_ctor_succeeds;
begin
  var N1 := TNoteValue.Create(TNoteValue.Maxima);
  Assert.AreEqual(TNoteValue.Maxima, N1.Ticks, 'Set N1 = Maxima');
  var N2 := TNoteValue.Create(TNoteValue.Semiquaver);
  Assert.AreEqual(TNoteValue.Semiquaver, N2.Ticks, 'Set N2 = Semiquaver');
  var N3 := TNoteValue.Create(1);
  Assert.AreEqual(1, N3.Ticks, 'Set N3 = 1');
  var N4 := TNoteValue.Create(High(UInt16));
  Assert.AreEqual(High(UInt16), N4.Ticks, 'Set N4 = High(UInt16)');
end;

procedure TTestNoteValues.Relative_prop(Expected: Double; Ticks: UInt16);
begin
  var NV := TNoteValue.Create(Ticks);
  Assert.AreEqual(Expected, NV.RelativeValue, 0.001);
end;

procedure TTestNoteValues.Setup;
begin
  NV1 := TNoteValue.Create(TNoteValue.Crotchet);
  NV1eq := TNoteValue.Create(TNoteValue.Crotchet);
  NV2 := TNoteValue.Create(TNoteValue.Semibreve);
end;

procedure TTestNoteValues.TearDown;
begin

end;

{ TTestNotes }

procedure TTestNotes.bad_note_pitch_in_ctor_fails_assertion;
begin
  Assert.WillRaise(
    procedure
    begin
      var I := -1;
      var N := TNote.Create(I);
    end,
    EAssertionFailed,
    'int < 0'
  );
  Assert.WillRaise(
    procedure
    begin
      var I := 128;
      var N := TNote.Create(I);
    end,
    EAssertionFailed,
    'int > 127'
  );
end;

procedure TTestNotes.concert_A;
begin
  var N := TNote.Create(TNote.ConcertA);
  Assert.AreEqual(4, Integer(N.OctaveNumber), 'Octave');
  Assert.AreEqual(9, Integer(N.PitchClass), 'Offset');
end;

procedure TTestNotes.Frequency;
begin
  // Expected from varioua cross-checked online resources.
  Assert.AreEqual(Double(12543.85), Double(NG9.Frequency), 0.01, 'G9');
  Assert.AreEqual(Double(4186.01), Double(NC8.Frequency), 0.01, 'C8');
  Assert.AreEqual(Double(440.00), Double(NA4.Frequency), 0.01, 'A4');
  Assert.AreEqual(Double(554.37), Double(NDb5.Frequency), 0.01, 'Db5');
  Assert.AreEqual(Double(392.00), Double(NG4.Frequency), 0.01, 'G4');
  Assert.AreEqual(Double(32.70), Double(NC1.Frequency), 0.01, 'C1');
  Assert.AreEqual(Double(16.35), Double(NC0.Frequency), 0.01, 'C0');
  Assert.AreEqual(Double(8.18), Double(NMinus1.Frequency), 0.01, 'C-1');
end;

procedure TTestNotes.GetFullName_flat;
begin
  Assert.AreEqual('C-1', NMinus1.GetFullName(False), 'C-1');
  Assert.AreEqual('A4', NA4.GetFullName(False), 'A4');
  Assert.AreEqual('B'#$266D'7', NBb7.GetFullName(False), 'Bb7');
  Assert.AreEqual('D'#$266D'5', NDb5.GetFullName(False), 'Db7');
end;

procedure TTestNotes.GetFullName_sharp;
begin
  Assert.AreEqual('C-1', NMinus1.GetFullName(True), 'C-1');
  Assert.AreEqual('A4', NA4.GetFullName(True), 'A4');
  Assert.AreEqual('A'#$266F'7', NBb7.GetFullName(True), 'A#7');
  Assert.AreEqual('C'#$266F'5', NDb5.GetFullName(True), 'C#5');
end;

procedure TTestNotes.GetNameOf;
begin
  Assert.AreEqual(
    'C'#$266F, TNote.GetNameOf(3, TAccidentals.TKind.Sharp), 'C#'
  );
  Assert.AreEqual(
    'B'#$266D, TNote.GetNameOf(2, TAccidentals.TKind.Flat), 'Bb'
  );
  Assert.AreEqual(
    'F'#$1D12A, TNote.GetNameOf(6, TAccidentals.TKind.DoubleSharp), 'F##'
  );
  Assert.AreEqual(
    'G'#$1D12B, TNote.GetNameOf(7, TAccidentals.TKind.DoubleFlat), 'Gbb'
  );
  Assert.AreEqual(
    'D'#$266E, TNote.GetNameOf(4, TAccidentals.TKind.Natural, False), 'D-natural'
  );
  Assert.AreEqual(
    'D', TNote.GetNameOf(4, TAccidentals.TKind.Natural), 'D'
  );
end;

procedure TTestNotes.middle_C;
begin
  var N := TNote.Create(TNote.MiddleC);
  Assert.AreEqual(4, Integer(N.OctaveNumber), 'Octave');
  Assert.AreEqual(0, Integer(N.PitchClass), 'Offset');
end;

procedure TTestNotes.note_pitch_without_ctor_is_0;
begin
  var N: TNote;
  Assert.AreEqual(0, Integer(N.Pitch));
end;

procedure TTestNotes.note_pitch_with_ctor_is_correct;
begin
  Assert.AreEqual(0, Integer(N0.Pitch), 'N0');
  Assert.AreEqual(6, Integer(N6.Pitch), 'N6');
  Assert.AreEqual(7, Integer(N7.Pitch), 'N7');
  Assert.AreEqual(8, Integer(N8.Pitch), 'N8');
  Assert.AreEqual(42, Integer(N42.Pitch), 'N42');
  Assert.AreEqual(100, Integer(N100.Pitch), 'N100');
  Assert.AreEqual(127, Integer(N127.Pitch), 'N127');
end;

procedure TTestNotes.OctaveNumber_is_correct;
begin
  Assert.AreEqual(-1, NMinus1.OctaveNumber, 'C-1');
  Assert.AreEqual(0, Integer(NC0.OctaveNumber), 'C0');
  Assert.AreEqual(9, Integer(NC9.OctaveNumber), 'C9');
  Assert.AreEqual(9, Integer(NG9.OctaveNumber), 'G9');
  Assert.AreEqual(7, Integer(NBb7.OctaveNumber), 'Bb7');
  Assert.AreEqual(7, Integer(NB7.OctaveNumber), 'B7');
  Assert.AreEqual(8, Integer(NC8.OctaveNumber), 'C8');
  Assert.AreEqual(4, Integer(NA4.OctaveNumber), 'A4');
  Assert.AreEqual(5, Integer(NDb5.OctaveNumber), 'Db5');
end;

procedure TTestNotes.OctaveOffset_is_correct;
begin
  Assert.AreEqual(0, Integer(NMinus1.PitchClass), 'C-1');
  Assert.AreEqual(0, Integer(NC0.PitchClass), 'C0');
  Assert.AreEqual(0, Integer(NC9.PitchClass), 'C9');
  Assert.AreEqual(7, Integer(NG9.PitchClass), 'G9');
  Assert.AreEqual(10, Integer(NBb7.PitchClass), 'Bb7');
  Assert.AreEqual(11, Integer(NB7.PitchClass), 'B7');
  Assert.AreEqual(0, Integer(NC8.PitchClass), 'C8');
  Assert.AreEqual(9, Integer(NA4.PitchClass), 'A4');
  Assert.AreEqual(1, Integer(NDb5.PitchClass), 'Db5');
end;

procedure TTestNotes.Operator_EQ_fails;
begin
  Assert.IsFalse(N8 = N100);
end;

procedure TTestNotes.Operator_EQ_succeeds;
begin
  Assert.IsTrue(N100 = N100Dup);
end;

procedure TTestNotes.Operator_GTE_fails;
begin
  Assert.IsFalse(N7 >= N8);
end;

procedure TTestNotes.Operator_GTE_succeeds;
begin
  Assert.IsTrue(N8 >= N7, '8 >= 7');
  Assert.IsTrue(N100 >= N100Dup, '100 >= 100');
end;

procedure TTestNotes.Operator_GT_fails;
begin
  Assert.IsFalse(N7 > N8, '7 > 8');
  Assert.IsFalse(N100 > N100Dup, '100 > 100');
end;

procedure TTestNotes.Operator_GT_succeeds;
begin
  Assert.IsTrue(N8 > N7);
end;

procedure TTestNotes.Operator_LTE_fails;
begin
  Assert.IsFalse(N8 <= N7);
end;

procedure TTestNotes.Operator_LTE_succeeds;
begin
  Assert.IsTrue(N100 <= N100Dup, '100 <= 100');
  Assert.IsTrue(N7 <= N8, '7 < 8');
end;

procedure TTestNotes.Operator_LT_fails;
begin
  Assert.IsFalse(N100 < N100Dup, '100 < 100');
  Assert.IsFalse(N8 < N7, '8 < 7');
end;

procedure TTestNotes.Operator_LT_succeeds;
begin
  Assert.IsTrue(N7 < N8);
end;

procedure TTestNotes.Operator_NEQ_fails;
begin
  Assert.IsFalse(N100 <> N100Dup);
end;

procedure TTestNotes.Operator_NEQ_succeeds;
begin
  Assert.IsTrue(N8 <> N7, '8 <> 7');
  Assert.IsTrue(N7 <> N8, '7 <> 8');
end;

procedure TTestNotes.Setup;
begin
  N0 := TNote.Create(0);
  N6 := TNote.Create(6);
  N7 := TNote.Create(7);
  N8 := TNote.Create(8);
  N42 := TNote.Create(42);
  N100 := TNote.Create(100);
  N100Dup := TNote.Create(100);
  N127 := TNote.Create(127);

  NMinus1 := TNote.Create(CMinus1);
  NC0 := TNote.Create(C0);
  NC1 := TNote.Create(C1);
  NC9 := TNote.Create(C9);
  NG9 := TNote.Create(G9);
  NBb7:= TNote.Create(Bb7);
  NB7 := TNote.Create(B7);
  NC8 := TNote.Create(C8);
  NA4 := TNote.Create(A4);
  NDb5:= TNote.Create(Db5);
  NG4 := TNote.Create(G4);
end;

procedure TTestNotes.TearDown;
begin
end;

initialization

TDUnitX.RegisterTestFixture(TTestNoteValues);
TDUnitX.RegisterTestFixture(TTestNotes);

end.

