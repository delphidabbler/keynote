unit Music.Keys;

{$WriteableConst Off}
{$RangeChecks On}
{$ScopedEnums On}

interface

uses
  System.SysUtils,

  Music.Notes,
  Music.Scales;

type

  TKey = record
  strict private
    var
      fTonic: TPitchClass;
      fScale: TScale;
  public
    ///  <summary>Default constructor. Sets key to C major.</summary>
    class operator Initialize(out Dest: TKey);

    ///  <summary>Constructs key with given scale and tonic note.</summary>
    constructor Create(const AScale: TScale; const ATonic: TPitchClass);

    ///  <summary>Tonic note of key.</summary>
    property Tonic: TPitchClass read fTonic;

    ///  <summary>Scale of key.</summary>
    property Scale: TScale read fScale;

    ///  <summary>Checks if a the notes of a full scale can be generated
    ///  starting in the given octave.</summary>#
    ///  <remarks>A full scale begins at the key's tonic note in the given
    ///  octave and extends to the tonic note in the octave above.</remarks>
    function CanGenerateFullScaleFromOctave(const AStartOctave: Int8): Boolean;

    ///  <summary>Calculates and returns the notes of the key, beginning at the#
    ///  tonic note in the given octavel.</summary>
    ///  <exception><c>EKey</c> raised if all the notes of the key do not fall
    ///  within the supported range of notes.</exception>
    ///  <remarks>The notes generated start at the key's tonic note in the given
    ///  octave and extend to the tonic note in the octave above.</remarks>
    function Notes(const AStartOctave: Int8): TArray<TNote>;

    ///  <summary>Calculates and returns a key that is transposed up by the
    ///  given interval.</summary>
    ///  <remarks>If the given interval is one octave then the resulting key's
    ///  tonic is the same as this key.</remarks>
    function TransposeBy(const AInterval: TInterval): TKey;

  end;

  EKey = class(Exception);

implementation


{ TKey }

function TKey.CanGenerateFullScaleFromOctave(const AStartOctave: Int8): Boolean;
begin
  if not TNote.IsOctaveInRange(AStartOctave) then
    Exit(False);
  if not TNote.IsNoteInRange(fTonic, AStartOctave + 1) then
    Exit(False);
  Result := True;
end;

constructor TKey.Create(const AScale: TScale; const ATonic: TPitchClass);
begin
  fTonic := ATonic;
  fScale := AScale;
end;

class operator TKey.Initialize(out Dest: TKey);
begin
  Dest.fTonic := TNote.PitchClassOfC;
  Dest.fScale := TScale.CreateFromPitchClassSet(TScale.MajorPitchClassSet);
end;

function TKey.Notes(const AStartOctave: Int8): TArray<TNote>;
begin
  if not CanGenerateFullScaleFromOctave(AStartOctave) then
    raise EKey.CreateFmt(
      'Can''t create scale starting in octave %d', [AStartOctave]
    );
  SetLength(Result, fScale.Cardinality + 1);
  Result[0] := TNote.CreateFromPitchClass(fTonic, AStartOctave);
  var Intervals := fScale.PitchClassSet;
  var Idx := 1;
  for var Interval in fScale.IntervalPattern do
  begin
    Result[Idx] := Result[Idx - 1].TransposeBy(Interval);
    Inc(Idx);
  end;
end;

function TKey.TransposeBy(const AInterval: TInterval): TKey;
begin
  Assert((AInterval >= Low(TInterval)) and (AInterval <= High(TInterval)));
  var TransposeedPitchClass: TPitchClass :=
    (fTonic + AInterval) mod TNote.NotesPerOctave;
  Result := TKey.Create(fScale, TransposeedPitchClass);
end;

end.

