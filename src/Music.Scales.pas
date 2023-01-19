unit Music.Scales;

{$WriteableConst Off}
{$RangeChecks On}
{$ScopedEnums On}

{
  ACKNOWLEDGEMENTS

  Many of the concepts and explanations used in this unit are based on, and
  sometimes quote from, the following resources:

  [1] A Study of Scales, https://ianring.com/musictheory/scales/ by Ian Ring.
  [2] All The Scales, https://allthescales.org/index.php by William Zeitler.
  [3] Interval Class Vectors, on music-theory-practice.com at
      https://tinyurl.com/5fpfru7n.
  [4] Details of Abstract Complements, Wikipedia, https://tinyurl.com/bdcru32t

  References to these works are indicated by including the reference number in
  square brackets in comments.
}


interface

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections,
  Music.Notes,
  Core.Enumerators;

type
  ///  <summary>Pitch class set.</summary>
  TPitchClassSet = set of TPitchClass;

  ///  <summary>Range of intervals in a scale.</summary>
  TInterval = 1 .. TNote.NotesPerOctave;

  ///  <summary>Array of interval patterns.</summary>
  TIntervalPattern = array of TInterval;

  ///  <summary>Set of rotational symmetries of a scale.</summary>
  ///  <remarks>Rotational symmetry is the symmetry that occurs by transposing a
  ///  scale up or down by an interval, and observing whether the transposition
  ///  and the original have an identical pattern of steps [1].</remarks>
  TRotationalSymmetry = set of TInterval;

  ///  <summary>A vector whose values describe the number of occurences of each
  ///  interval of the scale, read from left to right, for each interval size
  ///  from 1 to 6 semitones.</summary>
  TIntervalVector = array[1..6] of Cardinal;

  ///  <summary>Encapsulates a musical scale in the Western 12 tone
  ///  equally-tempered tuning system.</summary>
  ///  <remarks>
  ///  <para>Scales must start with a tonic (or root tone).</para>
  ///  <para>Octaves are considered equivalent.</para>
  ///  <para>The modes of a scale are considered to be separate scales.</para>
  ///  </remarks>
  TScale = record
  public
    const
      // Largest interval permitted for Zeitler's scales [2].
      ZeitlersConstant = 4; // major 3rd

      // Major scale pitch class set.
      MajorPitchClassSet: TPitchClassSet = [0,2,4,5,7,9,11];

  public
    type
      ///  <summary>Comparer class for TScale.</summary>
      TScaleComparer = class(TComparer<TScale>, IComparer<TScale>)
      public
        function Compare(const Left, Right: TScale): Integer; override;
      end;

  strict private
    const
      // ID for chromatic scale
      ChromaticScaleNumber = 4095;
      // pitch class of a root note
      RootPitchClass = 0;

    var
      ///  Representation of a scale as a bit set of 12 bits, where each pitch
      ///  class, X, in the scale's pitch class set is represented by bit X
      ///  being set. This is the scheme described by Ian Ring [1].
      fScaleNumber: UInt16;

    ///  Returns a copy of BitSet with bit at Offset set to true
    class function SetBit(const BitSet: UInt16; const Offset: Cardinal):
      UInt16; static; inline;

    ///  Checks if bit at given offset in given bit set is set
    class function IsBitSet(const BitSet: UInt16; const Offset: Cardinal):
      Boolean; static; inline;

    ///  Returns a bit set representing a two octave version of the given single
    ///  octave scale number. Eg if N has bits 0000abcdefghijkl then
    ///  00000000abcdefghijklabcdefghijkl is returned.
    class function DoubleOctaveScaleNumber(const N: UInt16): UInt32; static;
      inline;

    ///  Rotate scale number right one bit.
    class function RotateScaleNumber(const N: UInt16): UInt16; static;

    ///  Returns the next sibling scale for scale number SN. If SN has no
    ///  sibling scales then SN is itself returned.
    class function NextSiblingScaleNumber(const SN: UInt16): UInt16; static;

    ///  Write accessor for ScaleNumber property. Validates ANumber before
    ///  assigning it to the fScaleNumber field. Raise exception if ANumber is
    ///  not valid.
    procedure SetScaleNumber(const ANumber: UInt16);

    ///  Read accessor for PitchClassSet property. Calculates the scale's pitch
    ///  class set from fIntervalPattern and returns the set.
    function GetPitchClassSet: TPitchClassSet;

    ///  Write accessor for PitchClassSet property. Validates ASet before
    ///  converting the data into a scale number and assigning that to the
    ///  ScaleNumber property.
    procedure SetPitchClassSet(const ASet: TPitchClassSet);

    ///  Read accessor for IntervalPattern property. Returns a copy of
    ///  fIntervalPattern.
    function GetIntervalPattern: TIntervalPattern;

    ///  Write accessor for IntervalPattern property. Validates APattern before
    ///  converting it to a scale number and assigning that to the ScaleNumber
    ///  property.
    procedure SetIntervalPattern(const APattern: TIntervalPattern);

    ///  Append all modes of AScale to AList. AScale itself is NOT added to the
    ///  list.
    class procedure AppendModesToList(const AScale: TScale;
      const AList: TList<TScale>); static;

  public

    ///  <summary>Checks if the given scale number represents a valid scale.
    ///  </summary>
    ///  <remarks>A valid scale number uses only the lower 12 bits of a UInt16
    ///  AND requires the presence of the root note</remarks>
    class function IsValidScaleNumber(const ANumber: UInt16): Boolean; static;
      inline;

    ///  <summary>Gets the scale number that uniquely identifies the scale when
    ///  read and updates the scale to have the given scale number when assigned
    ///  to.</summary>
    ///  <exception>EScale is raided if an invalid scale number is assigned.
    ///  </exception>
    ///  <remarks>A scale number is a bit set representing a scale. Bits are
    ///  interpreted as described by Ian Ring [1].</remarks>
    property ScaleNumber: UInt16
      read fScaleNumber write SetScaleNumber;

    ///  <summary>Constructs scale from given scale number.</summary>
    ///  <exception>EScale raised in case of invalid scale number.</exception>
    constructor CreateFromScaleNumber(const ANumber: UInt16);

    ///  Default constructor. Sets scale to Chromatic.
    class operator Initialize(out Dest: TScale);

    // Equality / Inequality operators
    class operator Equal(const Left, Right: TScale): Boolean; inline;
    class operator NotEqual(const Left, Right: TScale): Boolean; inline;

    ///  <summary>Returns the cardinality of the scale.</summary>
    ///  <remarks>The cardinality of a scale is the number of tones in the
    ///  scale.</remarks>
    function Cardinality: Cardinal;

    ///  <summary>Checks if the given pitch class set represents a valid scale.
    ///  </summary>
    ///  <remarks>A valid pitch class set must contain the root pitch class.
    ///  </remarks>
    class function IsValidPitchClassSet(const ASet: TPitchClassSet): Boolean;
      static; inline;

    ///  <summary>Gets the scale's current pitch class set when read and updates
    ///  the scale according to the given pitch class set when assigned to.
    ///  </summary>
    ///  <exception>EScale is raised if an invalid pitch class set is assigned.
    ///  </exception>
    property PitchClassSet: TPitchClassSet
      read GetPitchClassSet write SetPitchClassSet;

    ///  <summary>Constructs scale from given pitch class set.</summary>
    ///  <exception>EScale raisesd in case of invalid pitch class set.
    ///  </exception>
    constructor CreateFromPitchClassSet(const APitchClassSet: TPitchClassSet);

    ///  <summary>Checks if given interval pattern represents a valid scale.
    ///  </summary>
    ///  <remarks>The sum of a intervals in an interval pattern must equal the
    ///  number of notes in an octave (i.e. 12).</remarks>
    class function IsValidIntervalPattern(const APattern: TIntervalPattern):
      Boolean; static;

    ///  <summary>Gets the scale's interval pattern when read and updates the
    ///  scale according to the given interval pattern when assigned to.
    ///  </summary>
    ///  <exception>EScale is raised if an invalid interval pattern is assigned.
    ///  </exception>
    property IntervalPattern: TIntervalPattern
      read GetIntervalPattern write SetIntervalPattern;

    ///  <summary>Constructs scale from given interval pattern.</summary>
    ///  <exception>EScale raised in case of invalid interval pattern.
    ///  </exception>
    constructor CreateFromIntervalPattern(
      const AIntervalPattern: TIntervalPattern);

    ///  <summary>Returns the hemitonia of the scale.</summary>
    function Hemitonia: Cardinal;

    ///  <summary>Returns the cohemitonia of the scale.</summary>
    function Cohemitonia: Cardinal;

    ///  <summary>Returns the largest interval in between the notes of the
    ///  scale.</summary>
    function Leap: TInterval;

    ///  <summary>Checks if the scale is a valid Zeitler scale.</summary>
    ///  <remarks>A Zeitler scale is one where the largest interval is 4
    ///  semitones [2].</remarks>
    function IsZeitlerScale: Boolean; inline;

    ///  <summary>Calculates the scale number as defined by William Zeitler,
    ///  if it exists.</summary>
    ///  <param name="Ascending">Flag that determines whether an ascending
    ///  (True) or descending (False) scale number is generated.</param>
    ///  <returns>UInt16. The required scale number or 0 if the scale is not a
    ///  valid Zeitler scale.</returns>
    ///  <remarks>Zeitler defines the ascending scale number as big-ending and
    ///  the descending scale number as little ending [2].</remarks>
    function ZeitlerNumber(const Ascending: Boolean = True): UInt16;

    ///  <summary>Returns the inverse scale of this scale.</summary>
    ///  <remarks>The inverse of a scale its reflection using the root as its
    ///  axis. The inverse always exists but may be the scale itself.</remarks>
    function Inverse: TScale;

    ///  <summary>Checks if the scale is palidromic.</summary>
    ///  <remarks>A palindromic scale is one that has the same pattern of
    ///  intervals both ascending and descending.</remarks
    function IsPalindromic: Boolean; inline;

    ///  <summary>Returns an array of all the scales that are modes of this
    ///  scale.</summary>
    ///  <returns>Array of all the scales that are modes of this scale. May be
    ///  empty if this scale has no modes.</returns>
    ///  <remarks>Does not include the scale itself.</remarks>
    function Modes: TArray<TScale>;

    ///  <summary>Returns an array of the modal family of this list, sorted on
    ///  ascending scale number.</summary>
    ///  <returns>Array of all the scales in the modal family.</returns>
    ///  <remarks>Contains at least one element, which is this scale itself.
    ///  </remarks>
    function ModalFamily: TArray<TScale>;

    ///  <summary>Returns the number of modes of this scale, including the scale
    ///  itself.</summary>
    function ModeCount: Cardinal; inline;

    ///  <summary>Checks if this scale is a mode of the given scale.
    ///  </summary>
    ///  <param name="AScale">Scale for which this scale may be a mode.
    ///  </param>
    ///  <returns><c>Boolean</c>. True if scale is a mode of given scale or
    ///  False otherwise.</returns>
    ///  <remarks>A scale is not considered to be a mode of itself.</remarks>
    function IsModeOf(const AScale: TScale): Boolean; inline;

    ///  <summary>Check if this scale is contained in the given array of scales.
    ///  </summary>
    function IsContainedIn(const AScales: array of TScale): Boolean;

    ///  <summary>Calculates the number of perfections in this scale.</summary>
    ///  <returns><c>Cardinal</c>. The number of perfections.</returns>
    ///  <remarks>See [2] for a definition of a perfection.</remarks>
    function Perfections: Cardinal;

    ///  <summary>Calculates the number of imperfections in this scale.
    ///  </summary>
    ///  <returns><c>Cardinal</c>. The number of imperfections.</returns>
    ///  <remarks>See [2] for a definition of an imperfection.</remarks>
    function Imperfections: Cardinal; inline;

    ///  <summary>Calculates and returns the set of rotational symmetries of the
    ///  scale.</summary>
    ///  <remarks>Rotational symmetry is the symmetry that occurs by transposing
    ///  a scale up or down by an interval, and observing whether the
    ///  transposition and the original have an identical pattern of steps [1].
    ///  </remarks>
    function RotationalSymmetry: TRotationalSymmetry;

    ///  <summary>Returns the number of rotational symmetries of this scale.
    ///  </summary>
    function RotationalSymmetryCount: Cardinal; inline;

    ///  <summary>Checks if the scale is chiral.</summary>
    ///  <remarks>A scale is chiral if it exhibits handedness. A chiral scale is
    ///  distinguishable from its mirror image (i.e. it is not palindromic) and
    ///  it cannot be transformed into its mirror image by rotation (i.e. its
    ///  inverse is not one of its modes).</remarks>
    function IsChiral: Boolean;

    ///  <summary>Returns the scale which is the prime form of this scale.
    ///  </summary>
    ///  <remarks>The scale which has Rahn prime form is that which has the
    ///  smallest scale number in the scale's modal family AND the modal family
    ///  of the scale's inverse [1].</remarks>
    function RahnPrime: TScale;

    ///  <summary>Checks if the scale is prime.</summary>
    ///  <remarks>For the scale to be prime it must have the scale number in the
    ///  scale's modal family AND the modal family of the scale's inverse [1].
    ///  </remarks>
    function IsPrime: Boolean; inline;

    ///  <summary>Returns the interval vector for the scale.</summary>
    ///  <returns>TIntervalVector. The required vector as an array.</returns>
    ///  <remarks>
    ///  <para>Describes the intervallic content of the scale, read from
    ///  left to right as the number of occurences of each interval size from
    ///  semitone, up to six semitones (quoted from [1]).</para>
    ///  <para>The algorithm used in this method is based on that presented in
    ///  [3].</para>
    ///  </remarks>
    function IntervalVector: TIntervalVector;

    ///  <summary>Checks whether the scale is deep.</summary>
    ///  <remarks>A deep scale is one where the interval vector has 6 different
    ///  digits [1].</remarks>
    function IsDeep: Boolean;

    ///  <summary>Calculates the modal family containing scales that are
    ///  abstract complements of this scale.</summary>
    ///  <remarks>
    ///  <para>Scales are abstract complements of each other if the two scales'
    ///  pitch class sets are complements, i.e. each contains all the notes not
    ///  in the other.</para>
    ///  <para>Since the complement of a scale is equivalent to the complement
    ///  of a scale's inverse [4] then we choose the complement with the
    ///  smallest scale number.</para>
    ///  </remarks>
    function Complement: TArray<TScale>;

    { TODO: More research needed (may require complex numbers to detect)
    function IsBalanced: Boolean; }

  end;

  EScale = class(Exception);

implementation

uses
  System.Math,
  Core.StringUtils;

{ TScale }

class procedure TScale.AppendModesToList(const AScale: TScale;
  const AList: TList<TScale>);
begin
  var NextSN := NextSiblingScaleNumber(AScale.fScaleNumber);
  while NextSN <> AScale.fScaleNumber do
  begin
    AList.Add(TScale.CreateFromScaleNumber(NextSN));
    NextSN := NextSiblingScaleNumber(NextSN);
  end;
end;

function TScale.Cardinality: Cardinal;
begin
  Result := 0;
  // Count 1 bits in fScaleNumber
  for var Offset := 0 to Pred(TNote.NotesPerOctave) do
    if IsBitSet(fScaleNumber, Offset) then
      Inc(Result);
end;

function TScale.Cohemitonia: Cardinal;
const
  Semitone = 1;
begin
  // In a scale number, 3 consecutive 1 bits repesent 3 consecutive semitones.
  // If we extend the scale number to include the octaves of the root and flat 2
  // then we can search of sequences of three one bits.
  // (In fact we just double up the scale number one octave higher for ease of
  // coding, because the resulting 24 bit number includes the desired extra
  // bits.)
  var SNEx: UInt32 := DoubleOctaveScaleNumber(fScaleNumber);
  var Mask: UInt16 := %111;
  Result := 0;
  for var I := 0 to TNote.NotesPerOctave - 1 do
  begin
    if SNEx and Mask = Mask then
      Inc(Result);
    Mask := Mask shl 1;
  end;
  Assert(Result <= TNote.NotesPerOctave);
end;

function TScale.Complement: TArray<TScale>;

  function ComplementOf(const S: TScale): TArray<TScale>;
  begin
    Assert(S.ScaleNumber <> ChromaticScaleNumber);
    var ComplementSN: UInt16 := (S.ScaleNumber xor $FFFF) and $0FFF;
    Assert(ComplementSN <> 0);
    while not Odd(ComplementSN) do
      ComplementSN := RotateScaleNumber(ComplementSN);
    Result := TScale.CreateFromScaleNumber(ComplementSN).ModalFamily;
    Assert(Length(Result) > 0);
  end;

begin
  var Inversion := Inverse;
  if Self.ScaleNumber = ChromaticScaleNumber then
    SetLength(Result, 0)
  else if Self = Inversion then
    Result := ComplementOf(Self)
  else
  begin
    var SelfComp := ComplementOf(Self);
    var InvComp := ComplementOf(Inversion);
    if SelfComp[0].ScaleNumber > InvComp[0].ScaleNumber then
      Result := InvComp
    else
      Result := SelfComp;
  end;
end;

constructor TScale.CreateFromIntervalPattern(
  const AIntervalPattern: TIntervalPattern);
begin
  SetIntervalPattern(AIntervalPattern);
end;

constructor TScale.CreateFromPitchClassSet(
  const APitchClassSet : TPitchClassSet);
begin
  SetPitchClassSet(APitchClassSet);
end;

constructor TScale.CreateFromScaleNumber(const ANumber: UInt16);
begin
  SetScaleNumber(ANumber);
end;

class function TScale.DoubleOctaveScaleNumber(const N: UInt16): UInt32;
begin
  Result := N or (N shl TNote.NotesPerOctave);
end;

class operator TScale.Equal(const Left, Right: TScale): Boolean;
begin
  Result := Left.fScaleNumber = Right.fScaleNumber;
end;

function TScale.GetIntervalPattern: TIntervalPattern;
begin
  SetLength(Result, Cardinality);
  var SNEx: UInt16 := RotateScaleNumber(fScaleNumber);
  var IntervalIdx := 0;
  var Interval: Cardinal := 0;
  for var BitOffset := 0 to Pred(TNote.NotesPerOctave) do
  begin
    Inc(Interval);
    if IsBitSet(SNEx, BitOffset) then
    begin
      Result[IntervalIdx] := Interval;
      Inc(IntervalIdx);
      Interval := 0;
    end;
  end;
  Assert(IntervalIdx = Length(Result));
end;

function TScale.GetPitchClassSet: TPitchClassSet;
begin
  Result := [];
  for var Pitch := Low(TPitchClass) to High(TPitchClass) do
  begin
    if IsBitSet(fScaleNumber, Pitch) then
      Include(Result, Pitch);
  end;
end;

function TScale.Hemitonia: Cardinal;
const
  Semitone = 1;
begin
  Result := 0;
  for var Interval in GetIntervalPattern do
    if Interval = Semitone then
      Inc(Result);
  Assert(Result <= TNote.NotesPerOctave);
end;

function TScale.Imperfections: Cardinal;
begin
  Result := Cardinality - Perfections;
end;

class operator TScale.Initialize(out Dest: TScale);
begin
  Dest.fScaleNumber := ChromaticScaleNumber;
end;

function TScale.IntervalVector: TIntervalVector;
begin
  // Clear result array
  for var Idx := Low(Result) to High(Result) do
    Result[Idx] := 0;

  // Count intervals between each tone (except highest) and every tone higher
  // than that tone. Treat intervals higher than 6 as equivalent to interval
  // lower than 6 such that the two intervals sum to 12.
  // For example for pitch class set [0, 3, 7, 10] calculate intervals of 0..3,
  // 0..7, 0..10, 3..7, 3..10 & 7..10.
  // This results in interval sizes 3, 7=>5, 10=>2, 4, 7=>5 & 3.
  // Counting the number of intervals of each size 1..6 gives 0 intervals of
  // size 1, 1 of size 2, 2 of size 3, 1 of size 4, 2 of size 5 and 0 of size 6.
  // The Interval Vector is therefore [0,1,2,1,2,0].

  // Scan tones from 1st to last but one
  for var Tone := 0 to 10 do
  begin
    if IsBitSet(fScaleNumber, Tone) then
    begin
      // Found a tone in scale:
      // get intervals to all tones above it
      for var J := Tone + 1 to 11 do
      begin
        if IsBitSet(fScaleNumber, J) then
        begin
          // Found tone J above current Tone.
          // calculate interval from Tone to J & adjust to be in range 1..6
          var Interval := J - Tone;
          var AdjustedInterval := Min(Interval, 12 - Interval);
          // bump the interval's count
          Inc(Result[AdjustedInterval]);
        end;
      end;
    end;
  end;
end;

function TScale.Inverse: TScale;
begin
  var InvSN: UInt16 := 1; // scale always includes root
  // process all notes above root, flipping them about root access
  // e.g. bit 1 => bit 11, bit 10 => bit 2, bit 6 => bit 6;
  for var BitOffset := 1 to Pred(TNote.NotesPerOctave) do
  begin
    if IsBitSet(fScaleNumber, BitOffset) then
      InvSN := SetBit(InvSN, TNote.NotesPerOctave - BitOffset);
  end;
  Result.SetScaleNumber(InvSN);
end;

class function TScale.IsBitSet(const BitSet: UInt16; const Offset: Cardinal):
  Boolean;
begin
  Result := Bitset and (1 shl Offset) <> 0;
end;

function TScale.IsChiral: Boolean;
begin
  var Inversion := Inverse;
  if Self = Inversion then
    Exit(False);    // scale is palindronic => achiral
  // Not palidromic
  var Rotations := Modes; // all rotations, excl self
  // If any rotation is same as inversion => achiral
  Result := not Inversion.IsContainedIn(Rotations);
end;

function TScale.IsContainedIn(const AScales: array of TScale): Boolean;
begin
  Result := False;
  for var Elem in AScales do
    if Elem = Self then
      Exit(True);
end;

function TScale.IsDeep: Boolean;
begin
  var V := IntervalVector;
  for var I := Low(V) to Pred(High(V)) do
  begin
    for var J := I + 1 to High(V) do
    begin
      if V[I] = V[J] then
        Exit(False);
    end;
  end;
  Result := True;
end;

function TScale.IsModeOf(const AScale: TScale): Boolean;
begin
  Result := IsContainedIn(AScale.Modes);
end;

function TScale.IsPalindromic: Boolean;
begin
  Result := Inverse = Self;
end;

function TScale.IsPrime: Boolean;
begin
  Result := RahnPrime = Self;
end;

class function TScale.IsValidIntervalPattern(const APattern: TIntervalPattern):
  Boolean;
begin
  var Sum: Cardinal := 0;
  for var Interval in APattern do
    Inc(Sum, Interval);
  Result := Sum = TNote.NotesPerOctave;
end;

class function TScale.IsValidPitchClassSet(const ASet: TPitchClassSet): Boolean;
begin
  Result := RootPitchClass in ASet;
end;

class function TScale.IsValidScaleNumber(const ANumber: UInt16): Boolean;
begin
  Result := Odd(ANumber) and ((ANumber and $F000) = 0);
end;

function TScale.IsZeitlerScale: Boolean;
begin
  Result := Leap <= ZeitlersConstant;
end;

function TScale.Leap: TInterval;
begin
  Result := Low(TInterval);
  for var Interval in GetIntervalPattern do
    if Interval > Result then
      Result := Interval;
end;

function TScale.ModalFamily: TArray<TScale>;
begin
  var ModeList := TList<TScale>.Create;
  try
    ModeList.Add(Self);
    AppendModesToList(Self, ModeList);
    ModeList.Sort(TScaleComparer.Create);
    Result := ModeList.ToArray;
  finally
    ModeList.Free;
  end;
end;

function TScale.ModeCount: Cardinal;
begin
  Result := Length(Modes) + 1;
end;

function TScale.Modes: TArray<TScale>;
begin
  var ModeList := TList<TScale>.Create;
  try
    AppendModesToList(Self, ModeList);
    Result := ModeList.ToArray;
  finally
    ModeList.Free;
  end;
end;

class function TScale.NextSiblingScaleNumber(const SN: UInt16): UInt16;
begin
  Result := RotateScaleNumber(SN);
  while not Odd(Result) and (Result <> SN) do
    Result := RotateScaleNumber(Result);
end;

class operator TScale.NotEqual(const Left, Right: TScale): Boolean;
begin
  Result := Left.fScaleNumber <> Right.fScaleNumber;
end;

function TScale.Perfections: Cardinal;
const
  PerfectFifthMask = %0000000010000000;
begin
  var MF := ModalFamily;
  var Mulitplier := Cardinality div Length(MF);
  Result := 0;
  for var Mode in MF do
  begin
    if (Mode.ScaleNumber and PerfectFifthMask) <> 0 then
      // Mode has a perfect fifth from root
      Inc(Result);
  end;
  Result := Mulitplier * Result;
end;

function TScale.RahnPrime: TScale;
begin
  // List of scale, its modes, its inversion and it modes
  // Scale with lowest scale number is considered prime
  var List := TList<TScale>.Create(TScaleComparer.Create);
  try
    // Add this scale and all its modes to the list
    List.Add(Self);
    AppendModesToList(Self, List);
    // Add inversion and its modes only if inversion is not one of this scale's
    // modal family
    var Inversion := Inverse;
    if List.IndexOf(Inversion) = -1 then
    begin
      List.Add(Inversion);
      AppendModesToList(Inversion, List);
    end;
    // Return value is scale in list with smallest scale number: i.e. first scale
    // in sorted list
    List.Sort;
    Assert(List.Count > 0);   // list must have at least 1 element (this scale)
    Result := List[0];
  finally
    List.Free;
  end;
end;

class function TScale.RotateScaleNumber(const N: UInt16): UInt16;
begin
  // Rotate scale number right by 1 bit
  Result := N shr 1;
  // There shouldn't be any 1 bits above bit 11, but make sure
  Result := Result and $0FFF;
  // If N has bit 0 set (i.e was odd) then set bit 11
  if Odd(N) then
    Result := Result or (1 shl 11);
end;

function TScale.RotationalSymmetry: TRotationalSymmetry;
begin
  // Create 2 octave version of scale in binary represention (bits 0 to 23)
  var SNEx: UInt32 := DoubleOctaveScaleNumber(fScaleNumber);
  // We will move the bit representation of one octave along between 1 and 11
  // steps and check to see if that pattern of bits is found in the scale. If so
  // we have found a rotation.
  var Mask: UInt32 := fScaleNumber;
  Result := [];
  for var I: TInterval := Low(TInterval) to Pred(High(TInterval)) do
  begin
    Mask := Mask shl 1;
    if SNEx and Mask = Mask then
      Include(Result, I);
  end;
end;

function TScale.RotationalSymmetryCount: Cardinal;
begin
  // Count number of elements in rotational symmetry
  Result := 0;
  for var Elem in RotationalSymmetry do
    Inc(Result);
end;

class function TScale.SetBit(const BitSet: UInt16; const Offset: Cardinal):
  UInt16;
begin
  Result := BitSet or (1 shl Offset);
end;

procedure TScale.SetIntervalPattern(const APattern: TIntervalPattern);
begin
  if not IsValidIntervalPattern(APattern) then
    raise EScale.Create('Invalid interval pattern');
  // Set root tone
  var SN: UInt16 := 1;
  var BitOffset: Cardinal := 0;
  // Update SN with each interval. This will also set the octave of the root,
  // which is invalid in a scale number.
  for var Interval in APattern do
  begin
    Inc(BitOffset, Interval);
    SN := SetBit(SN, BitOffset);
  end;
  // Normalise scale number (by clearing bit recording actave of root)
  SN := SN and $0FFF;
  SetScaleNumber(SN);
end;

procedure TScale.SetPitchClassSet(const ASet: TPitchClassSet);
begin
  if not IsValidPitchClassSet(ASet) then
    raise EScale.Create('Invalid pitch class set');
  var SN: UInt16 := 0;
  for var Pitch := Low(TPitchClass) to High(TPitchClass) do
  begin
    if Pitch in ASet then
      SN := SetBit(SN, Pitch - Low(TPitchClass));
  end;
  SetScaleNumber(SN);
end;

procedure TScale.SetScaleNumber(const ANumber: UInt16);
begin
  if not IsValidScaleNumber(ANumber) then
    raise EScale.CreateFmt('%d is not a valid scale number', [ANumber]);
  fScaleNumber := ANumber;
end;

function TScale.ZeitlerNumber(const Ascending: Boolean): UInt16;
const
  HiBit = 11;
  HiBitMask = 1 shl HiBit;
  Lo12BitMask = $0FFF;

  function CalculateAscending: UInt16;
  begin
    Result := 0;
    for var Pitch in GetPitchClassSet do
    begin
      var Bit := 1 shl (HiBit - Pitch);
      Result := Result or Bit;
    end;
  end;

  function CalculateDescending: UInt16;
  begin
    Result := (fScaleNumber shr 1) or HiBitMask;
  end;

begin
  if not IsZeitlerScale then
    Exit(0);
  if Ascending then
    Result := CalculateAscending
  else
    Result := CalculateDescending;
  // Post condition checks for valid Zeitler scale number
  Assert((Result and HiBitMask) = HiBitMask); // must have root at bit 11
  Assert(Result = (Result and Lo12BitMask)); // can only have low 12 bits set
end;

{ TScale.TScaleComparer }

function TScale.TScaleComparer.Compare(const Left, Right: TScale): Integer;
begin
  Result := Left.ScaleNumber - Right.ScaleNumber;
end;

end.

