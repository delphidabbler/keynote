unit Test.Music.Notes;

interface

uses
  System.Types,

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
    [TestCase('A=B','0,4096,4096')]
    [TestCase('A<B','-1,1024,4096')]
    [TestCase('A>B','1,1024,512')]
    procedure Compare(const Expected: TValueRelationship; Left, Right: UInt16);

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
      C_neg1_pitch = -60;
      Gb_neg1_pitch = -54;
      G_neg1_pitch = -53;
      Ab_neg1_pitch = -52;
      C_0_pitch = -48;
      C_1_pitch = -36;
      Gb_2_pitch = -18;
      C_4_pitch = 0;     // middle C
      G_4_pitch = 7;
      A_4_pitch = 9;     // concert pitch
      Db_5_pitch = 13;
      E_7_pitch = 40;
      Bb_7_pitch = 46;
      B_7_pitch = 47;
      C_8_pitch = 48;
      C_9_pitch = 60;
      G_9_pitch = 67;
      Ab_9_pitch = 68;
    var
      C_neg1: TNote;
      Gb_neg1: TNote;
      G_neg1: TNote;
      Ab_neg1: TNote;
      C_0: TNote;
      C_1: TNote;
      Gb_2: TNote;
      C_4: TNote;
      G_4: TNote;
      A_4: TNote;
      Db_5: TNote;
      E_7: TNote;
      E_7_dup: TNote;
      Bb_7: TNote;
      B_7: TNote;
      C_8: TNote;
      C_9: TNote;
      G_9: TNote;
      Ab_9: TNote;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure note_pitch_without_ctor_is_middle_c;
    [Test]
    procedure note_pitch_with_ctor_is_correct;
    [Test]
    procedure note_value_without_ctor_is_crotchet;
    [Test]
    procedure note_value_with_pitch_but_no_value_is_crotchet;
    [Test]
    procedure note_value_with_ctor_is_correct;
    [Test]
    procedure bad_note_pitch_in_ctor_fails_assertion;

    [Test]
    [TestCase('A=B','0,10,10')]
    [TestCase('A<B','-1,-24,68')]
    [TestCase('A>B','1,0,-1')]
    procedure ComparePitch(Expected: TValueRelationship;
      LeftPitch, RightPitch: TNotePitch);

    [Test]
    [TestCase('A=B','0,4096,4096')]
    [TestCase('A<B','-1,1024,4096')]
    [TestCase('A>B','1,1024,512')]
    procedure CompareValue(const Expected: TValueRelationship;
      LeftValue, RightValue: UInt16);

    [Test]
    [TestCase('P1=P2, V1=V2', '0,10,10,4096,4096')]
    [TestCase('P1=P2, V1<V2', '-1,10,10,1024,4096')]
    [TestCase('P1=P2, V1>V2', '1,10,10,1024,512')]
    [TestCase('P1<P2, V1=V2', '-1,-24,68,512,512,')]
    [TestCase('P1<P2, V1<V2', '-1,-24,68,256,512')]
    [TestCase('P1<P2, V1>V2', '-1,-24,68,512,256')]
    [TestCase('P1>P2, V1=V2', '1,0,-1,4096,4096')]
    [TestCase('P1>P2, V1<V2', '1,0,-1,256,512')]
    [TestCase('P1>P2, V1>V2', '1,0,-1,256,64')]
    procedure Compare(const Expected: TValueRelationship;
      LeftPitch, RightPitch: TNotePitch; LeftValue, RightValue: UInt16);
    [Test]
    procedure Value_prop_is_correct;
    [Test]
    procedure OctaveNumber_is_correct;
    [Test]
    procedure PitchClass_is_correct;
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

procedure TTestNoteValues.Compare(const Expected: TValueRelationship; Left,
  Right: UInt16);
begin
  var L := TNoteValue.Create(Left);
  var R := TNoteValue.Create(Right);
  Assert.AreEqual(Expected, TNoteValue.Compare(L, R));
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
      var I := Pred(Low(TNotePitch));
      var N := TNote.Create(I);
    end,
    EAssertionFailed,
    'pitch below low bounds'
  );
  Assert.WillRaise(
    procedure
    begin
      var I := Succ(High(TNotePitch));
      var N := TNote.Create(I);
    end,
    EAssertionFailed,
    'pitch above high bounds'
  );
end;

procedure TTestNotes.Compare(const Expected: TValueRelationship; LeftPitch,
  RightPitch: TNotePitch; LeftValue, RightValue: UInt16);
begin
  var L := TNote.Create(LeftPitch, TNoteValue.Create(LeftValue));
  var R := TNote.Create(RightPitch, TNoteValue.Create(RightValue));
  Assert.AreEqual(Expected, TNote.Compare(L, R));
end;

procedure TTestNotes.ComparePitch(Expected: TValueRelationship; LeftPitch,
  RightPitch: TNotePitch);
begin
  // Note: ComparePitch should ignore note value
  var L := TNote.Create(LeftPitch, TNoteValue.Create(TNoteValue.Semibreve));
  var R := TNote.Create(RightPitch, TNoteValue.Create(TNoteValue.Semiquaver));
  Assert.AreEqual(Expected, TNote.ComparePitch(L, R));
end;

procedure TTestNotes.CompareValue(const Expected: TValueRelationship; LeftValue,
  RightValue: UInt16);
begin
  // Note CompareValue should ignore note pitch
  var L := TNote.Create(A_4_pitch, TNoteValue.Create(LeftValue));
  var R := TNote.Create(C_1_pitch, TNoteValue.Create(RightValue));
  Assert.AreEqual(Expected, TNote.CompareValue(L, R));
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
  Assert.AreEqual(Double(13289.75), Double(Ab_9.Frequency), 0.01, 'Ab9');
  Assert.AreEqual(Double(12543.85), Double(G_9.Frequency), 0.01, 'G9');
  Assert.AreEqual(Double(4186.01), Double(C_8.Frequency), 0.01, 'C8');
  Assert.AreEqual(Double(440.00), Double(A_4.Frequency), 0.01, 'A4 (poncert)');
  Assert.AreEqual(Double(554.37), Double(Db_5.Frequency), 0.01, 'Db5');
  Assert.AreEqual(Double(392.00), Double(G_4.Frequency), 0.01, 'G4');
  Assert.AreEqual(Double(261.63), Double(C_4.Frequency), 0.01, 'C4 (middle C)');
  Assert.AreEqual(Double(32.70), Double(C_1.Frequency), 0.01, 'C1');
  Assert.AreEqual(Double(16.35), Double(C_0.Frequency), 0.01, 'C0');
  Assert.AreEqual(Double(8.18), Double(C_neg1.Frequency), 0.01, 'C-1');
end;

procedure TTestNotes.GetFullName_flat;
begin
  Assert.AreEqual('C-1', C_neg1.GetFullName(False), 'C-1');
  Assert.AreEqual('A4', A_4.GetFullName(False), 'A4');
  Assert.AreEqual('C4', C_4.GetFullName(False), 'C4 (middle C)');
  Assert.AreEqual('B'#$266D'7', Bb_7.GetFullName(False), 'Bb7');
  Assert.AreEqual('D'#$266D'5', Db_5.GetFullName(False), 'Db7');
  Assert.AreEqual('A'#$266D'9', Ab_9.GetFullName(False), 'Ab9');
end;

procedure TTestNotes.GetFullName_sharp;
begin
  Assert.AreEqual('C-1', C_neg1.GetFullName(True), 'C-1');
  Assert.AreEqual('A4', A_4.GetFullName(True), 'A4');
  Assert.AreEqual('A'#$266F'7', Bb_7.GetFullName(True), 'A#7');
  Assert.AreEqual('C'#$266F'5', Db_5.GetFullName(True), 'C#5');
  Assert.AreEqual('G'#$266F'9', Ab_9.GetFullName(True), 'G#9');
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

procedure TTestNotes.note_pitch_without_ctor_is_middle_c;
begin
  var N: TNote;
  Assert.AreEqual(Integer(TNote.MiddleC), Integer(N.Pitch));
end;

procedure TTestNotes.note_pitch_with_ctor_is_correct;
begin
  Assert.AreEqual(-60, Integer(C_neg1.Pitch), 'C-1');
  Assert.AreEqual(-54, Integer(Gb_neg1.Pitch), 'Gb-1');
  Assert.AreEqual(-53, Integer(G_neg1.Pitch), 'G-1');
  Assert.AreEqual(-52, Integer(Ab_neg1.Pitch), 'Ab-1');
  Assert.AreEqual(-18, Integer(Gb_2.Pitch), 'Gb2');
  Assert.AreEqual(40, Integer(E_7.Pitch), 'E7');
  Assert.AreEqual(67, Integer(G_9.Pitch), 'G9');
  Assert.AreEqual(68, Integer(Ab_9.Pitch), 'Ab9');
end;

procedure TTestNotes.note_value_without_ctor_is_crotchet;
begin
  var N: TNote;
  Assert.AreEqual(TNoteValue.Crotchet, N.Value.Ticks);
end;

procedure TTestNotes.note_value_with_ctor_is_correct;
begin
  var NBreve := TNote.Create(A_4_pitch, TNoteValue.Create(TNoteValue.Breve));
  Assert.AreEqual(TNoteValue.Breve, NBreve.Value.Ticks);
  var NSemiquaver := TNote.Create(A_4_pitch, TNoteValue.Create(TNoteValue.Semiquaver));
  Assert.AreEqual(TNoteValue.Semiquaver, NSemiquaver.Value.Ticks);
end;

procedure TTestNotes.note_value_with_pitch_but_no_value_is_crotchet;
begin
  var N := TNote.Create(A_4_pitch);
  Assert.AreEqual(TNoteValue.Crotchet, N.Value.Ticks);
end;

procedure TTestNotes.OctaveNumber_is_correct;
begin
  Assert.AreEqual(-1, C_neg1.OctaveNumber, 'C-1');
  Assert.AreEqual(0, Integer(C_0.OctaveNumber), 'C0');
  Assert.AreEqual(9, Integer(C_9.OctaveNumber), 'C9');
  Assert.AreEqual(9, Integer(G_9.OctaveNumber), 'G9');
  Assert.AreEqual(7, Integer(Bb_7.OctaveNumber), 'Bb7');
  Assert.AreEqual(7, Integer(B_7.OctaveNumber), 'B7');
  Assert.AreEqual(8, Integer(C_8.OctaveNumber), 'C8');
  Assert.AreEqual(4, Integer(A_4.OctaveNumber), 'A4');
  Assert.AreEqual(5, Integer(Db_5.OctaveNumber), 'Db5');
end;

procedure TTestNotes.Operator_EQ_fails;
begin
  Assert.IsFalse(Ab_neg1 = E_7);
end;

procedure TTestNotes.Operator_EQ_succeeds;
begin
  Assert.IsTrue(E_7 = E_7_dup);
end;

procedure TTestNotes.Operator_GTE_fails;
begin
  Assert.IsFalse(G_neg1 >= Ab_neg1);
end;

procedure TTestNotes.Operator_GTE_succeeds;
begin
  Assert.IsTrue(Ab_neg1 >= G_neg1, '-52 >= -53');
  Assert.IsTrue(E_7 >= E_7_dup, '40 >= 40');
end;

procedure TTestNotes.Operator_GT_fails;
begin
  Assert.IsFalse(G_neg1 > Ab_neg1, '-53 > -52');
  Assert.IsFalse(E_7 > E_7_dup, '40 > 40');
end;

procedure TTestNotes.Operator_GT_succeeds;
begin
  Assert.IsTrue(Ab_neg1 > G_neg1);
end;

procedure TTestNotes.Operator_LTE_fails;
begin
  Assert.IsFalse(Ab_neg1 <= G_neg1);
end;

procedure TTestNotes.Operator_LTE_succeeds;
begin
  Assert.IsTrue(E_7 <= E_7_dup, '40 <= 40');
  Assert.IsTrue(G_neg1 <= Ab_neg1, '-53 < -52');
end;

procedure TTestNotes.Operator_LT_fails;
begin
  Assert.IsFalse(E_7 < E_7_dup, '40 < 40');
  Assert.IsFalse(Ab_neg1 < G_neg1, '-52 < -53');
end;

procedure TTestNotes.Operator_LT_succeeds;
begin
  Assert.IsTrue(G_neg1 < Ab_neg1);
end;

procedure TTestNotes.Operator_NEQ_fails;
begin
  Assert.IsFalse(E_7 <> E_7_dup);
end;

procedure TTestNotes.Operator_NEQ_succeeds;
begin
  Assert.IsTrue(Ab_neg1 <> G_neg1, '-52 <> -53');
  Assert.IsTrue(G_neg1 <> Ab_neg1, '-53 <> -52');
end;

procedure TTestNotes.PitchClass_is_correct;
begin
  Assert.AreEqual(0, Integer(C_neg1.PitchClass), 'C-1');
  Assert.AreEqual(0, Integer(C_0.PitchClass), 'C0');
  Assert.AreEqual(0, Integer(C_9.PitchClass), 'C9');
  Assert.AreEqual(7, Integer(G_9.PitchClass), 'G9');
  Assert.AreEqual(10, Integer(Bb_7.PitchClass), 'Bb7');
  Assert.AreEqual(11, Integer(B_7.PitchClass), 'B7');
  Assert.AreEqual(0, Integer(C_8.PitchClass), 'C8');
  Assert.AreEqual(9, Integer(A_4.PitchClass), 'A4');
  Assert.AreEqual(1, Integer(Db_5.PitchClass), 'Db5');
end;

procedure TTestNotes.Setup;
begin
  C_neg1 := TNote.Create(C_neg1_pitch);
  Gb_neg1 := TNote.Create(Gb_neg1_pitch);
  G_neg1 := TNote.Create(G_neg1_pitch);
  Ab_neg1 := TNote.Create(Ab_neg1_pitch);
  C_0 := TNote.Create(C_0_pitch);
  C_1 := TNote.Create(C_1_pitch);
  Gb_2 := TNote.Create(Gb_2_pitch);
  C_4 := TNote.Create(C_4_pitch);
  G_4 := TNote.Create(G_4_pitch);
  A_4 := TNote.Create(A_4_pitch);
  Db_5 := TNote.Create(Db_5_pitch);
  E_7 := TNote.Create(E_7_pitch);
  E_7_dup := TNote.Create(E_7_pitch);
  Bb_7:= TNote.Create(Bb_7_pitch);
  B_7 := TNote.Create(B_7_pitch);
  C_8 := TNote.Create(C_8_pitch);
  C_9 := TNote.Create(C_9_pitch);
  G_9 := TNote.Create(G_9_pitch);
  Ab_9 := TNote.Create(Ab_9_pitch);
end;

procedure TTestNotes.TearDown;
begin
end;

procedure TTestNotes.Value_prop_is_correct;
begin
  var N := TNote.Create(A_4_pitch);
  N.Value := TNoteValue.Create(TNoteValue.Breve);
  Assert.AreEqual(TNoteValue.Breve, N.Value.Ticks);
  N.Value := TNoteValue.Create(TNoteValue.Semiquaver);
  Assert.AreEqual(TNoteValue.Semiquaver, N.Value.Ticks);
end;

initialization

TDUnitX.RegisterTestFixture(TTestNoteValues);
TDUnitX.RegisterTestFixture(TTestNotes);

end.

