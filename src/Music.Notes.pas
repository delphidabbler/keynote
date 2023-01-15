unit Music.Notes;


{$SCOPEDENUMS ON}

interface

uses
  System.Types;

type

  ///  <summary>Encapsulation of various accidentals.</summary>
  TAccidentals = record
  public
    type
      ///  <summary>Enumeration of accidentals.</summary>
      TKind = (Sharp, Flat, Natural, DoubleSharp, DoubleFlat);
      ///  <summary>Set of TKind enumerations.</summary>
      TKindSet = set of TKind;
      ///  <summary>Accidentals used in key signatures.</summary>
      TKeyKind = (Natural, Sharp, Flat);
    const
      ///  <summary>Symbol for sharp notes.</summary>
      SharpSymbol = #$266F;
      ///  <summary>Symbol for flat notes.</summary>
      FlatSymbol = #$266D;
      ///  <summary>Symbol for natural notes.</summary>
      NaturalSymbol = #$266E;
      ///  <summary>Symbol for double sharp notes.</summary>
      DoubleSharpSymbol = #$1D12A;
      ///  <summary>Symbol for double flat notes.</summary>
      DoubleFlatSymbol = #$1D12B;
      ///  <summary>Accidentals used on note names.</summary>
      NoteNameAccidentals: TKindSet = [TKind.Sharp, TKind.Flat];
      ///  <summary>Map of Accidental kinds to symbols.</summary>
      Symbols: array[TKind] of string = (
        SharpSymbol, FlatSymbol, NaturalSymbol,
        DoubleSharpSymbol, DoubleFlatSymbol
      );
      /// <summary>Accidentals used in key signatures.</summary>
      KeySymbols: array[TKeyKind] of string = ('', SharpSymbol, FlatSymbol);
  end;

  ///  <summary>Encapsulates the relative duration of a note.</summary>
  ///  <remarks>In music notation, a note value indicates the relative duration
  ///  of a note (see https://en.wikipedia.org/wiki/Note_value).</remarks>
  TNoteValue = record
  strict private
    const
      TicksPerWholeNote = 4096;
  public
    const
      // Names of note lengths
      Maxima = 8 * TicksPerWholeNote;
      DuplexLonga = Maxima;
      OctupleWholeNote = DuplexLonga;
      Longa = 4 * TicksPerWholeNote;
      QuadrupleWholeNote = Longa;
      Breve = 2 * TicksPerWholeNote;
      DoubleWholeNote = Breve;
      Semibreve = 1 * TicksPerWholeNote;
      WholeNote = Semibreve;
      Minim = TicksPerWholeNote div 2;
      HalfNote = Minim;
      Crotchet = TicksPerWholeNote div 4;
      QuarterNote = Crotchet;
      Quaver = TicksPerWholeNote div 8;
      EighthNote = Quaver;
      Semiquaver = TicksPerWholeNote div 16;
      SixteenthNote = Semiquaver;
      Demisemiquaver = TicksPerWholeNote div 32;
      ThirtySecondNote = Demisemiquaver;
      Hemidemisemiquaver = TicksPerWholeNote div 64;
      SixtyFourthNote = Hemidemisemiquaver;
      Semihemidemisemiquaver = TicksPerWholeNote div 128;
      OnHundredAndTwentyEighthNote = Semihemidemisemiquaver;
      Demisemihemidemisemiquaver = TicksPerWholeNote div 256;
      TwoHundredAndFiftySixthNote = Demisemihemidemisemiquaver;
    type
      ///  <summary>Valid number of dot modifiers for use calculating dotted
      ///  length of a note</summary>
      TDots = 0..3;
  strict private
    var
      fTicks: UInt16;
    procedure SetTicks(ATicks: UInt16);
    function GetRelativeValue: Double;
  public
    constructor Create(ATicks: UInt16);

    ///  <summary>Note value expressed in ticks.</summary>
    ///  <remarks>A tick 1/4096 of a semibreve (whole note). Initial value can
    ///  be passed in constructor. Default value is Crotchet.
    ///  </remarks>
    property Ticks: UInt16 read fTicks write SetTicks;

    ///  <summary>Note value expressed as a fraction or multiple of a semibreve
    ///  (whole note).</summary>
    property RelativeValue: Double read GetRelativeValue;

    ///  <summary>Duration of note in milliseconds when played at the given
    ///  number of crotchets per minute.</summary>
    function DurationMS(CrotchetsPerMinute: UInt16): UInt32;

    ///  <summary>Returns the augmented value of the given note after applying
    ///  the given number of dot modifiers to the value.</summary>
    ///  <exception>Exceptions are raised if ATicks is greater than
    ///  <c>Maxima</c>, is smaller than a 1/512th note or is not divisible by
    ///  2 ^ Dots.</exception>
    class function DottedValueInTicks(ATicks: UInt16; Dots: TDots): UInt16;
      static;

    ///  <summary>Compares two TNoteValue records.</summary>
    ///  <remarks>Comparison is based on the natural ordering of the Ticks
    ///  property, so that longer notes are considered to be greater than than
    ///  shorter notes.</remarks>
    class function Compare(const Left, Right: TNoteValue): TValueRelationship;
      static;

    class operator Initialize(out Dest: TNoteValue);
    class operator Equal(const Left, Right: TNoteValue): Boolean;
    class operator NotEqual(const Left, Right: TNoteValue): Boolean;
    class operator GreaterThan(const Left, Right: TNoteValue): Boolean;
    class operator GreaterThanOrEqual(const Left, Right: TNoteValue): Boolean;
    class operator LessThan(const Left, Right: TNoteValue): Boolean;
    class operator LessThanOrEqual(const Left, Right: TNoteValue): Boolean;
  end;

  // TODO: Decide if TMIDINote is required
  // TODO: Move TMIDINote to MIDI.Consts unit or similar?
//  ///  <summary>Valid MIDI note numbers.</summary>
  //  TMIDINote = 0..127;

  ///  <summary>Range of supported note pitches.</summary>
  TNotePitch = -60..68;

  ///  <summary>Array of supported note pitches.</summary>
  TNotePitches = TArray<TNotePitch>;

  ///  <summary>Natural note numbers.</summary>
  ///  <remarks>1 = A through to 7 = G</remarks>
  TNaturalNoteNumber = 1..7;

  ///  <summary>Pitch class of note.
  TPitchClass = 0..11;

  ///  <summary>Encapsulation of a musical note.</summary>
  TNote = record
  strict private
    var
      fPitch: TNotePitch;
      fValue: TNoteValue;
    function GetPitchClass: TPitchClass;
    function GetOctaveNumber: Int8;
    function GetFrequency: Single;
    function SemitonesFromConcertA: Int8; inline;
    function SemitonesFromMiddleC: Int8; inline;
    function TryTransposeBy(const ASemitones: Integer;
      out ATransposedNote: TNote): Boolean;
    class function GetPitchFromPitchClassAndOctave(const PC: TPitchClass;
      const Octave: Int8): TNotePitch; static;
    class function TryGetPitchFromPitchClassAndOctave(const PC: TPitchClass;
      const Octave: Int8; out APitch: TNotePitch): Boolean; static;

  public
    const
      ///  <summary>Number of notes in an octave.</summary>
      NotesPerOctave = High(TPitchClass) - Low(TPitchClass) + 1;
      ///  <summary>Number of lowest supported octave.</summary>
      LowestOctave = -1;
      ///  <summary>Number of highest supported octave.</summary>
      HighestOctave = (High(TNotePitch) - Low(TNotePitch))
        div NotesPerOctave + LowestOctave;
      ///  <summary>Pitch of middle C.</summary>
      MiddleC: TNotePitch = 0;
      ///  <summary>Pitch of concert A.</summary>
      ConcertA: TNotePitch = 9;
      ///  <summary>Frequency of concert A.</summary>
      ConcertAFrequency: Single = 440.0;
      //  <summary>Pitch class of C.</summary>
      PitchClassOfC: TPitchClass = 0;
  public
    ///  <summary>Instantiates a new record for the given pitch, with default
    ///  note value.</summary>
    constructor Create(const APitch: TNotePitch); overload;

    ///  <summary>Instantiates a new record for the note pitch and value.
    ///  </summary>
    constructor Create(const APitch: TNotePitch; const AValue: TNoteValue);
      overload;

    ///  <summary>Instantiates a new record for the note with given pitch class
    ///  in the same octave as middle C (i.e. octave 4) and default note value.
    ///  </summary>
    ///  <exception><c>ENotSupportedException</c> raised if the pitch of the
    ///  resulting note is not supported.</exception>
    constructor CreateFromPitchClass(const APitchClass: TPitchClass); overload;

    ///  <summary>Instantiates a new record for the note with given pitch class
    ///  and octave and default note value.</summary>
    ///  <exception><c>EArgumentOutOfRangeException</c> raised if AOctave is
    ///  out of range.</exception>
    ///  <exception><c>ENotSupportedException</c> raised if the pitch of the
    ///  resulting note is not supported.</exception>
    constructor CreateFromPitchClass(const APitchClass: TPitchClass;
      const AOctave: Int8); overload;

    ///  <summary>Checks if given octave is within range of valid octaves.
    ///  </summary>
    class function IsOctaveInRange(const AOctave: Int8): Boolean; static;
      inline;

    ///  <summary>Checks if note with given pitch class and octave is in range
    ///  of supported notes.</summary>
    class function IsNoteInRange(const APitchClass: TPitchClass;
      const AOctave: Int8): Boolean; static;

    ///  <summary>Pitch of the note.</summary>
    property Pitch: TNotePitch read fPitch;

    ///  <summary>Pitch class of note.</summary>
    ///  <remarks>Pitch class of C is 0, and runs through to B with pitch class
    ///  of 11. The pitch class of a note is effectively the number of semitones
    ///  the note is from the closest C below it, except that the pitch class of
    ///  C is always 0. See https://en.wikipedia.org/wiki/Pitch_class.</remarks>
    property PitchClass: TPitchClass read GetPitchClass;

    ///  <summary>Number of the octave containing the note.</summary>
    ///  <remarks>Octave numbering starts at <c>LowestOctave</c>.</remarks>
    property OctaveNumber: Int8 read GetOctaveNumber;

    ///  <summary>Frequency of note.</summary>
    ///  <remarks>Frequency is relative to concert A = 440Hz</remarks>
    property Frequency: Single read GetFrequency;

    ///  <summary>Value (i.e. length) of note.</summary>
    property Value: TNoteValue read fValue write fValue;

    ///  <summary>Returns the name of a given note.</summary>
    ///  <param name="NaturalNote">Natural note number where 1=A through to 7=G.
    ///  </param>
    ///  <param name="Acc">Accidental that qualifies note. Defaults to natural.
    ///  [in]</param>
    ///  <param name="HideNatural">Whether natural notes should include
    ///  accidental (False) or not (True). [in]</param>
    ///  <returns><c>string</c>. Required note name.</returns>
    ///  <remarks>Octave is not included in note name.</remarks>
    class function GetNameOf(const NaturalNote: TNaturalNoteNumber;
      const Acc: TAccidentals.TKind = TAccidentals.TKind.Natural;
      const HideNatural: Boolean = True): string; static;

    ///  <summary>Returns the full name of the note, with octave number.
    ///  </summary>
    ///  <param name="UseSharps">Determines whether to use sharps or flats in
    ///  note names that require accidentals. [in]</param>
    ///  <returns><c>string</c>. Full note name.</returns>
    function GetFullName(const UseSharps: Boolean): string;

    ///  <summary>Compares two notes and returns a value indicating their
    ///  respective ordering.</summary>
    ///  <remarks>The pitch of a note is considered higher priority than the
    ///  note value (length). A note with a higher pitch is considered greater
    ///  than a note with a lower pitch, regardless of length. Where pitches are
    ///  equal the the note values are compared and notes with larger values
    ///  (longer notes) are considered greater than shorter notes.</remarks>
    class function Compare(const Left, Right: TNote): TValueRelationship;
      static;

    ///  <summary>Compares the pitch of two notes and returns a value indicating
    ///  their respective ordering.</summary>
    ///  <remarks>Notes with higher pitch are considered greater than notes with
    ///  lower pitch.</remarks>
    class function ComparePitch(const Left, Right: TNote): TValueRelationship;
      static;

    ///  <summary>Compares the value of two notes and returns a value indicating
    ///  their respective ordering.</summary>
    ///  <remarks>Longer notes are considered greater than shorter notes.
    ///  </remarks>
    class function CompareValue(const Left, Right: TNote): TValueRelationship;
      static;

    ///  <summary>Creates and returns a new note, that is transposed by the
    ///  given number of semitones from this note. The Value property is not
    ///  changed.</summary>
    ///  <exception><c>EArgumentException</c> raised if note can't be transposed
    ///  by the given number of semitones.</exception>
    function TransposeBy(const ASemitones: Integer): TNote;

    ///  <summary>Checks if this note can be transposed by the given number of
    ///  semitones.</summary>
    function CanTransposeBy(const ASemitones: Integer): Boolean;

    class operator Initialize(out Dest: TNote);
    class operator Equal(const Left, Right: TNote): Boolean;
    class operator NotEqual(const Left, Right: TNote): Boolean;
    class operator GreaterThan(const Left, Right: TNote): Boolean;
    class operator GreaterThanOrEqual(const Left, Right: TNote): Boolean;
    class operator LessThan(const Left, Right: TNote): Boolean;
    class operator LessThanOrEqual(const Left, Right: TNote): Boolean;
  end;

implementation

uses
  System.SysUtils,
  System.Math;

{ TNoteValue }

class function TNoteValue.Compare(const Left, Right: TNoteValue):
  TValueRelationship;
begin
  if Left.fTicks = Right.fTicks then
    Result := EqualsValue
  else if Left.fTicks < Right.fTicks then
    Result := LessThanValue
  else
    Result := GreaterThanValue
end;

constructor TNoteValue.Create(ATicks: UInt16);
begin
  SetTicks(ATicks);
end;

class function TNoteValue.DottedValueInTicks(ATicks: UInt16; Dots: TDots):
  UInt16;
const
  One512thNote = TicksPerWholeNote div 512;
begin
  var TwoToPowerOfDots := 1 shl Dots;

  // Apply limits to ensure calculations in range and are not truncated
  if (ATicks > Maxima) or (ATicks < One512thNote) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Value in ticks must be in range %d to %d to find dotted value',
      [One512thNote, Maxima]
    );
  if ATicks mod TwoToPowerOfDots <> 0 then
    raise EArgumentException.CreateFmt(
      'Value in ticks must be divisible by 2 ^ %d', [Dots]
    );

  if Dots = 0 then
    // No dots => no-op
    Exit(ATicks);

  // If n is number of dots then note value is increased by (2^n-1)/2^n
  var Numerator: UInt16 := TwoToPowerOfDots - 1;
  var Denominator: UInt16 := TwoToPowerOfDots;
  Result := ATicks + ATicks div Denominator * Numerator;
end;

function TNoteValue.DurationMS(CrotchetsPerMinute: UInt16): UInt32;
const
  MSPerMinute = 60000;
begin
  var Numerator: UInt32 := MSPerMinute * fTicks;
  var Denominator: UInt32 := CrotchetsPerMinute * Crotchet;
  Result := Numerator div Denominator;
end;

class operator TNoteValue.Equal(const Left, Right: TNoteValue): Boolean;
begin
  Result := Compare(Left, Right) = EqualsValue;
end;

function TNoteValue.GetRelativeValue: Double;
begin
  Result := fTicks / TicksPerWholeNote;
end;

class operator TNoteValue.GreaterThan(const Left, Right: TNoteValue): Boolean;
begin
  Result := Compare(Left, Right) = GreaterThanValue;
end;

class operator TNoteValue.GreaterThanOrEqual(const Left, Right: TNoteValue):
  Boolean;
begin
  Result := Compare(Left, Right) <> LessThanValue;
end;

class operator TNoteValue.Initialize(out Dest: TNoteValue);
begin
  // Default note Ticks is crochet
  Dest.fTicks := Crotchet;
end;

class operator TNoteValue.LessThan(const Left, Right: TNoteValue): Boolean;
begin
  Result := Compare(Left, Right) = LessThanValue;
end;

class operator TNoteValue.LessThanOrEqual(const Left, Right: TNoteValue):
  Boolean;
begin
  Result := Compare(Left, Right) <> GreaterThanValue;
end;

class operator TNoteValue.NotEqual(const Left, Right: TNoteValue): Boolean;
begin
  Result := Compare(Left, Right) <> EqualsValue;
end;

procedure TNoteValue.SetTicks(ATicks: UInt16);
begin
  if ATicks = 0 then
    raise EArgumentOutOfRangeException.Create('A note value must be positive');
  fTicks := ATicks;
end;

{ TNote }

function TNote.CanTransposeBy(const ASemitones: Integer): Boolean;
begin
  var Dummy: TNote;
  Result := TryTransposeBy(ASemitones, Dummy);
end;

class function TNote.Compare(const Left, Right: TNote): TValueRelationship;
begin
  var PitchComparison := ComparePitch(Left, Right);
  if PitchComparison = EqualsValue then
    Result := CompareValue(Left, Right)
  else
    Result := PitchComparison;
end;

class function TNote.ComparePitch(const Left, Right: TNote): TValueRelationship;
begin
  if Left.Pitch = Right.Pitch then
    Result := EqualsValue
  else if Left.Pitch < Right.Pitch then
    Result := LessThanValue
  else
    Result := GreaterThanValue;
end;

class function TNote.CompareValue(const Left, Right: TNote): TValueRelationship;
begin
  Result := TNoteValue.Compare(Left.Value, Right.Value);
end;

constructor TNote.Create(const APitch: TNotePitch);
begin
  // We need to check this, because compiler will allow an integer variable to
  // be passed to constructor, and will allow assignment even if integer is
  // outside bounds of TNotePitch
  Assert(
    (
      Integer(APitch) >= Integer(Low(TNotePitch)))
      and (Integer(APitch) <= Integer(High(TNotePitch))
    ),
    'TNote.Create: APitch out of bounds'
  );
  fPitch := APitch;
end;

constructor TNote.Create(const APitch: TNotePitch; const AValue: TNoteValue);
begin
  Create(APitch);
  fValue := AValue;
end;

constructor TNote.CreateFromPitchClass(const APitchClass: TPitchClass);
begin
  var MidC := TNote.Create(MiddleC);
  CreateFromPitchClass(APitchClass, MidC.OctaveNumber);
end;

constructor TNote.CreateFromPitchClass(const APitchClass: TPitchClass;
  const AOctave: Int8);
begin
  Create(GetPitchFromPitchClassAndOctave(APitchClass, AOctave));
end;

class operator TNote.Equal(const Left, Right: TNote): Boolean;
begin
  Result := Compare(Left, Right) = EqualsValue;
end;

function TNote.GetFrequency: Single;
begin
  if fPitch = ConcertA then
    // Shortcut calculation to get exact concert A frequency
    Exit(ConcertAFrequency);
  // Frequency calculation per https://newt.phys.unsw.edu.au/jw/notes.html
  Result := Power(Single(2.0), Single(SemitonesFromConcertA / 12.0))
    * ConcertAFrequency;
end;

function TNote.GetFullName(const UseSharps: Boolean): string;
const
  OffsetToNatSharp: array[0..11] of TNaturalNoteNumber = (
    3, 3, 4, 4, 5, 6, 6, 7, 7, 1, 1, 2
  );
  OffsetToNatFlat: array[0..11] of TNaturalNoteNumber = (
    3, 4, 4, 5, 5, 6, 7, 7, 1, 1, 2, 2
  );
  OffsetToAccSharp: array[0..11] of TAccidentals.TKind = (
    TAccidentals.TKind.Natural, TAccidentals.TKind.Sharp,   // C & C#
    TAccidentals.TKind.Natural, TAccidentals.TKind.Sharp,   // D & D#
    TAccidentals.TKind.Natural,                             // E
    TAccidentals.TKind.Natural, TAccidentals.TKind.Sharp,   // F & F#
    TAccidentals.TKind.Natural, TAccidentals.TKind.Sharp,   // G & G#
    TAccidentals.TKind.Natural, TAccidentals.TKind.Sharp,   // A & A#
    TAccidentals.TKind.Natural                              // B
  );
  OffsetToAccFlat: array[0..11] of TAccidentals.TKind = (
    TAccidentals.TKind.Natural,                             // C
    TAccidentals.TKind.Flat, TAccidentals.TKind.Natural,    // Db & D
    TAccidentals.TKind.Flat, TAccidentals.TKind.Natural,    // Eb & E
    TAccidentals.TKind.Natural,                             // F
    TAccidentals.TKind.Flat, TAccidentals.TKind.Natural,    // Gb & G
    TAccidentals.TKind.Flat, TAccidentals.TKind.Natural,    // Ab & A
    TAccidentals.TKind.Flat, TAccidentals.TKind.Natural     // Bb & B
  );
begin
  var Oct := GetOctaveNumber;
  var PitchClass := GetPitchClass;
  var Nat: TNaturalNoteNumber;
  var Acc: TAccidentals.TKind;
  if UseSharps then
  begin
    Nat := OffsetToNatSharp[PitchClass];
    Acc := OffsetToAccSharp[PitchClass];
  end
  else
  begin
    Nat := OffsetToNatFlat[PitchClass];
    Acc := OffsetToAccFlat[PitchClass];
  end;
  Result := GetNameOf(Nat, Acc) + Oct.ToString;
end;

class function TNote.GetNameOf(const NaturalNote: TNaturalNoteNumber;
  const Acc: TAccidentals.TKind; const HideNatural: Boolean): string;
const
  BaseNoteNames: array [TNaturalNoteNumber] of Char = (
    'A', 'B', 'C', 'D', 'E', 'F', 'G'
  );
begin
  Result := BaseNoteNames[NaturalNote];
  if (Acc = TAccidentals.TKind.Natural) and HideNatural then
    Exit;
  Result := Result + TAccidentals.Symbols[Acc];
end;

function TNote.GetOctaveNumber: Int8;
begin
  Result := ((fPitch - Low(TNotePitch)) div NotesPerOctave) + LowestOctave;
end;

function TNote.GetPitchClass: TPitchClass;
begin
  Result := fPitch mod NotesPerOctave;
end;

class function TNote.GetPitchFromPitchClassAndOctave(const PC: TPitchClass;
  const Octave: Int8): TNotePitch;
begin
  if not IsOctaveInRange(Octave) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Octave %d is out of range. Valid range is [%d,%d]',
      [Octave, LowestOctave, HighestOctave]
    );
  if not TryGetPitchFromPitchClassAndOctave(PC, Octave, Result) then
    raise ENotSupportedException.CreateFmt(
      'Pitch is not supported. Valid range is [%d,%d]',
      [Low(TNotePitch), High(TNotePitch)]
    );
end;

class operator TNote.GreaterThan(const Left, Right: TNote): Boolean;
begin
  Result := Compare(Left, Right) = GreaterThanValue;
end;

class operator TNote.GreaterThanOrEqual(const Left, Right: TNote): Boolean;
begin
  Result := Compare(Left, Right) <> LessThanValue;
end;

class operator TNote.Initialize(out Dest: TNote);
begin
  // Initialise pitch to middle C)
  Dest.fPitch := MiddleC;
  // Dest.fValue will be automatically set to crotchet by TNoteValue.Initialize
end;

class function TNote.IsNoteInRange(const APitchClass: TPitchClass;
  const AOctave: Int8): Boolean;
begin
  var Dummy: TNotePitch;
  Result := TryGetPitchFromPitchClassAndOctave(APitchClass, AOctave, Dummy);
end;

class function TNote.IsOctaveInRange(const AOctave: Int8): Boolean;
begin
  Result := (AOctave >= LowestOctave) and (AOctave <= HighestOctave);
end;

class operator TNote.LessThan(const Left, Right: TNote): Boolean;
begin
  Result := Compare(Left, Right) = LessThanValue;
end;

class operator TNote.LessThanOrEqual(const Left, Right: TNote): Boolean;
begin
  Result := Compare(Left, Right) <> GreaterThanValue;
end;

class operator TNote.NotEqual(const Left, Right: TNote): Boolean;
begin
  Result := Compare(Left, Right) <> EqualsValue;
end;

function TNote.SemitonesFromConcertA: Int8;
begin
  Result := fPitch - ConcertA;
end;

function TNote.SemitonesFromMiddleC: Int8;
begin
  Result := fPitch - MiddleC;
end;

function TNote.TransposeBy(const ASemitones: Integer): TNote;
begin
  if not TryTransposeBy(ASemitones, Result) then
    raise EArgumentException.CreateFmt(
      'Can''t transpose note %s by %d semitones: note would by out of range',
      [GetFullName(True), ASemitones]
    );
end;

class function TNote.TryGetPitchFromPitchClassAndOctave(const PC: TPitchClass;
  const Octave: Int8; out APitch: TNotePitch): Boolean;
begin
  var PitchAsInt: Integer := NotesPerOctave * (Octave - LowestOctave)
    + Low(TNotePitch) + PC;
  Result := (PitchAsInt >= Low(TNotePitch))
    and (PitchAsInt <= High(TNotePitch));
  if Result then
    APitch := TPitchClass(PitchAsInt);
end;

function TNote.TryTransposeBy(const ASemitones: Integer;
  out ATransposedNote: TNote): Boolean;
begin
  var NewPitch: Integer := fPitch + ASemitones;
  Result := (NewPitch >= Low(TNotePitch)) and (NewPitch <= High(TNotePitch));
  if Result then
    ATransposedNote := TNote.Create(TNotePitch(NewPitch), fValue);
end;

end.

