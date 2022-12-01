unit Music.Notes;


{$SCOPEDENUMS ON}

interface

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

  ///  <summary>Valid MIDI note numbers.</summary>
  TMIDINote = 0..127;   // TODO: move to MIDI.UConsts unit?

  ///  <summary>Range of supported note pitches.</summary>
  TNotePitch = TMIDINote;

  ///  <summary>Array of supported note pitches.</summary>
  TNotePitches = TArray<TNotePitch>;

  ///  <summary>Natural note numbers.</summary>
  ///  <remarks>1 = A through to 7 = G</remarks>
  TNaturalNoteNumber = 1..7;

  // TODO: consider adding Length property to TNote
  ///  <summary>Encapsulation of a musical note.</summary>
  TNote = record
  strict private
    var
      fPitch: TNotePitch;
    function GetOctaveOffset: Byte;
    function GetOctaveNumber: Int8;
  public
    const
      /// <summary>Number of notes in an octave.</summary>
      NotesPerOctave = 12;
      /// <summary>Number of lowest supported octave.</summary>
      LowestOctave = -1;
      ///  <summary>Pitch of middle C.</summary>
      MiddleC: TNotePitch = 60;
      ///  <summary>Pitch of concert A.</summary>
      ConcertA: TNotePitch = 69;
  public
    ///  <summary>Initantiates a new record for the given pitch.</summary>
    constructor Create(const APitch: TNotePitch);

    ///  <summary>Pitch of the note.</summary>
    property Pitch: TNotePitch read fPitch;

    ///  <summary>Offset of note within its octave.</summary>
    ///  <remarks>Octaves start at C, with offset 0, and end at B with offset
    ///  11.</remarks>
    property OctaveOffset: Byte read GetOctaveOffset;

    ///  <summary>Number of the octave containing the note.</summary>
    ///  <remarks>Octave numbering starts at <c>LowestOctave</c>.</remarks>
    property OctaveNumber: Int8 read GetOctaveNumber;

    ///  <summary>Returns the name of a given note.</summary>
    ///  <param name="NaturalNote">Natural note number where 1=A through to 7=G.
    ///  </param>
    ///  <param name="Acc">Accidental that qualifies note. Defaults to natural.
    ///  [in]</param>
    ///  <param name="HideNatural">Wether natural notes should include
    ///  accidental (False) or not (True). [in]</param>
    ///  <returns>string. Required note name.</returns>
    ///  <remarks>Octave is not included in note name.</remarks>
    class function GetNameOf(const NaturalNote: TNaturalNoteNumber;
      const Acc: TAccidentals.TKind = TAccidentals.TKind.Natural;
      const HideNatural: Boolean = True): string; static;

    ///  <summary>Returns the full name of the note, with octave number.
    ///  </summary>
    ///  <param name="UseSharps">Determines whether to use sharps or flats in
    ///  note names that require accidentals. [in]</param>
    ///  <returns>string. Full note name.</returns>
    function GetFullName(const UseSharps: Boolean): string;

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
  System.SysUtils;

{ TNote }

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

class operator TNote.Equal(const Left, Right: TNote): Boolean;
begin
  Result := Left.fPitch = Right.fPitch;
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
  var Offset := GetOctaveOffset;
  var Nat: TNaturalNoteNumber;
  var Acc: TAccidentals.TKind;
  if UseSharps then
  begin
    Nat := OffsetToNatSharp[Offset];
    Acc := OffsetToAccSharp[Offset];
  end
  else
  begin
    Nat := OffsetToNatFlat[Offset];
    Acc := OffsetToAccFlat[Offset];
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
  Result := (fPitch div NotesPerOctave) + LowestOctave;
end;

function TNote.GetOctaveOffset: Byte;
begin
  Result := fPitch mod NotesPerOctave;
end;

class operator TNote.GreaterThan(const Left, Right: TNote): Boolean;
begin
  Result := Left.fPitch > Right.fPitch;
end;

class operator TNote.GreaterThanOrEqual(const Left, Right: TNote): Boolean;
begin
  Result := Left.fPitch >= Right.fPitch;
end;

class operator TNote.Initialize(out Dest: TNote);
begin
  // Initialise pitch to lowest value (= lowest MIDI note = 0)
  Dest.fPitch := Low(TNotePitch);
end;

class operator TNote.LessThan(const Left, Right: TNote): Boolean;
begin
  Result := Left.fPitch < Right.fPitch;
end;

class operator TNote.LessThanOrEqual(const Left, Right: TNote): Boolean;
begin
  Result := Left.fPitch <= Right.fPitch;
end;

class operator TNote.NotEqual(const Left, Right: TNote): Boolean;
begin
  Result := Left.fPitch <> Right.fPitch;
end;

end.


