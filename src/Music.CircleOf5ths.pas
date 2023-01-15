unit Music.CircleOf5ths;

{$WriteableConst Off}
{$RangeChecks On}
{$ScopedEnums On}

interface

uses
  Music.Notes;

type
  TCircleOf5ths = record
  public

    type
      TPitchInfo = record
        Name: string;
        PitchClass: TPitchClass;
        Accidental: TAccidentals.TKeyKind;
      end;

    const
      Pitches: array[-7..7] of TPitchInfo = (
        // C♭ ( = B )
        (
          Name: 'C' + TAccidentals.FlatSymbol;
          PitchClass: 11;
          Accidental: TAccidentals.TKeyKind.Flat;
        ),
        // G♭ ( = F♯ )
        (
          Name: 'G' + TAccidentals.FlatSymbol;
          PitchClass: 6;
          Accidental: TAccidentals.TKeyKind.Flat;
        ),
        // D♭ ( = C♯ )
        (
          Name: 'D' + TAccidentals.FlatSymbol;
          PitchClass: 1;
          Accidental: TAccidentals.TKeyKind.Flat;
        ),
        // A♭
        (
          Name: 'A' + TAccidentals.FlatSymbol;
          PitchClass: 8;
          Accidental: TAccidentals.TKeyKind.Flat;
        ),
        // E♭
        (
          Name: 'E' + TAccidentals.FlatSymbol;
          PitchClass: 3;
          Accidental: TAccidentals.TKeyKind.Flat;
        ),
        // B♭
        (
          Name: 'B' + TAccidentals.FlatSymbol;
          PitchClass: 10;
          Accidental: TAccidentals.TKeyKind.Flat;
        ),
        // F
        (
          Name: 'F';
          PitchClass: 5;
          Accidental: TAccidentals.TKeyKind.Natural;
        ),
        // C
        (
          Name: 'C';
          PitchClass: 0;
          Accidental: TAccidentals.TKeyKind.Natural;
        ),
        // G
        (
          Name: 'G';
          PitchClass: 7;
          Accidental: TAccidentals.TKeyKind.Natural;
        ),
        // D
        (
          Name: 'D';
          PitchClass: 2;
          Accidental: TAccidentals.TKeyKind.Natural;
        ),
        // A
        (
          Name: 'A';
          PitchClass: 9;
          Accidental: TAccidentals.TKeyKind.Natural;
        ),
        // E
        (
          Name: 'E';
          PitchClass: 4;
          Accidental: TAccidentals.TKeyKind.Natural;
        ),
        // B  ( = C♭ )
        (
          Name: 'B';
          PitchClass: 11;
          Accidental: TAccidentals.TKeyKind.Natural;
        ),
        // F♯ ( = G♭ )
        (
          Name: 'F' + TAccidentals.SharpSymbol;
          PitchClass: 6;
          Accidental: TAccidentals.TKeyKind.Sharp;
        ),
        // C♯ ( = D♭ )
        (
          Name: 'C' + TAccidentals.SharpSymbol;
          PitchClass: 1;
          Accidental: TAccidentals.TKeyKind.Sharp;
        )
      );

    class function IsCentre(const APitch: TPitchInfo): Boolean; static; inline;
  end;

implementation

{ TCircleOf5ths }

class function TCircleOf5ths.IsCentre(const APitch: TPitchInfo): Boolean;
begin
  Result := APitch.PitchClass = TNote.PitchClassOfC;
end;

end.
