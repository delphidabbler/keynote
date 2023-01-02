unit Test.Music.Notes;

interface

uses
  DUnitX.TestFramework,

  Music.Notes;

type

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
    var
      N0, N6, N7, N8, N42, N100, N100Dup, N127: TNote;
      NMinus1: TNote;
      NC0: TNote;
      NC9: TNote;
      NG9: TNote;
      NBb7: TNote;
      NB7: TNote;
      NC8: TNote;
      NA4: TNote;
      NDb5: TNote;
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
  end;

implementation

uses
  System.SysUtils;

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
  NC9 := TNote.Create(C9);
  NG9 := TNote.Create(G9);
  NBb7:= TNote.Create(Bb7);
  NB7 := TNote.Create(B7);
  NC8 := TNote.Create(C8);
  NA4 := TNote.Create(A4);
  NDb5:= TNote.Create(Db5);
end;

procedure TTestNotes.TearDown;
begin
end;

initialization

TDUnitX.RegisterTestFixture(TTestNotes);

end.

