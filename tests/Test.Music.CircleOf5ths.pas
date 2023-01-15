unit Test.Music.CircleOf5ths;

interface

uses
  DUnitX.TestFramework,

  Music.Notes,
  Music.CircleOf5ths;

type
  [TestFixture]
  TTestCircleOf5ths = class
  public

    [Test]
    procedure IsCentre_is_correct;

  end;

implementation

procedure TTestCircleOf5ths.IsCentre_is_correct;
begin
  for var Pitch in TCircleOf5ths.Pitches do
    if Pitch.Name = 'C' then
      Assert.IsTrue(TCircleOf5ths.IsCentre(Pitch), 'C')
    else
      Assert.IsFalse(TCircleOf5ths.IsCentre(Pitch), Pitch.Name);
end;

initialization

  TDUnitX.RegisterTestFixture(TTestCircleOf5ths);

end.
