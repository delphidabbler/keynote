unit Test.Core.StringUtils;

interface

uses
  DUnitX.TestFramework,

  Core.StringUtils;

type
  [TestFixture]
  TTestStringUtils = class
  private
    var
      SA: TArray<string>;
      EmptySA: TArray<string>;
      SAGaps: TArray<string>;
      SAAllGaps: TArray<string>;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // CompareText

    [Test]
    [TestCase('foo=foo','foo,foo')]
    [TestCase('FOO=foo','FOO,foo')]
    [TestCase('bar=Bar','bar,Bar')]
    [TestCase('<empty>=<empty>',',')]
    procedure CompareText_a_eq_b(const A, B: string);

    [Test]
    [TestCase('bar<foo','bar,foo')]
    [TestCase('BAR<foo','BAR,foo')]
    [TestCase('bar<FOOL','bar,FOOL')]
    [TestCase('Barf<Foo','Barf,Foo')]
    [TestCase('<empty> < foo',',foo')]
    procedure CompareText_a_lt_b(const A, B: string);

    [Test]
    [TestCase('foo>bar', 'foo,bar')]
    [TestCase('barf>BAR', 'barf,BAR')]
    [TestCase('F>barf', 'F,barf')]
    [TestCase('FOOL>Foo', 'FOOL,Foo')]
    [TestCase('foo > <empty>', 'foo,')]
    procedure CompareText_a_gt_b(const A, B: string);

    // SameText

    [Test]
    [TestCase('bar=bar','bar,bar')]
    [TestCase('BAR=bar','BAR,bar')]
    [TestCase('foo=Foo','foo,Foo')]
    [TestCase('<empty>=<empty>',',')]
    [TestCase('<space>=<space>',' , ')]
    procedure SameText_true(const A, B: string);

    [Test]
    [TestCase('foo<>bar','foo,bar')]
    [TestCase('FOO<>Bar','FOO,Bar')]
    [TestCase('<empty> <> anything',',anything')]
    [TestCase('anything <> <empty>','anything,')]
    procedure SameText_false(const A, B: string);

    // ContainsText

    [Test]
    [TestCase('Needle @ start same case', 'Lorem,Lorem ipsum dolor')]
    [TestCase('Needle @ start diff case', 'lOREM,Lorem ipsum dolor')]
    [TestCase('Needle @ mid same case', 'm ip,LOREM ipsum dolor')]
    [TestCase('Needle @ mid diff case', 'IPSUM,Lorem Ipsum dolor')]
    [TestCase('Needle @ end same case', 'dolor,Lorem ipsum dolor')]
    [TestCase('Needle @ end diff case', 'OLOR,Lorem ipsum dolor')]
    procedure ContainsText_true(const Needle, Haystack: string);

    [Test]
    [TestCase('non-empty needle', 'mipsumd,Lorem ipsum dolor')]
    [TestCase('single char needle', 'x,Lorem ipsum dolor')]
    [TestCase('empty needle', ',Lorem ipsum dolor')]
    [TestCase('empty haystack', 'Lorem,')]
    [TestCase('both params empty', ',')]
    [TestCase('', 'x,Lorem ipsum dolor')]
    procedure ContainsText_false(const Needle, Haystack: string);

    // StartsText

    [Test]
    [TestCase('Same case','Lorem,Lorem ipsum dolor')]
    [TestCase('Diff case','LOREM,Lorem ipsum dolor')]
    procedure StartsText_true(const Needle, Haystack: string);

    [Test]
    [TestCase('Same case','ipsum,Lorem ipsum dolor')]
    [TestCase('Diff case','OREM,Lorem ipsum dolor')]
    [TestCase('Empty needle',',Lorem ipsum dolor')]
    [TestCase('Empty haystack','LOREM,')]
    [TestCase('Empty both',',')]
    procedure StartsText_false(const Needle, Haystack: string);

    // ToLower

    [Test]
    [TestCase('FOO','FOO,foo')]
    [TestCase('bar','bar,bar')]
    [TestCase('12-34','12-34,12-34')]
    [TestCase('ÊŎ','ÊŎ,êŏ')]
    [TestCase('<empty>',',')]
    procedure ToLower(const Str, LoStr: string);

    // Split

    [Test]
    [TestCase('foo|bar','foo|bar,|,foo,bar,True')]
    [TestCase('|foo','|foo,|,,foo,True')]
    [TestCase('<empty>',',|,,,False')]
    [TestCase('foo\\bar\\42','foo\\bar\\42,\\,foo,bar\\42,True')]
    [TestCase('bar\\42','bar\\42,\\,bar,42,True')]
    [TestCase('42','42,\\,42,,False')]
    procedure Split(const Str, Delim, ExpLeft, ExpRight: string;
      ExpRes: Boolean);

    // Join

    [Test]
    [TestCase('Pipe-delim', '|,True,Lorem|dipsom|sit|amet')]
    [TestCase('Double-dash-delim', '--,True,Lorem--dipsom--sit--amet')]
    [TestCase('empty-delim', ',True,Loremdipsomsitamet')]
    procedure Join_non_empty_array(const Delim: string;
      const AllowEmpty: Boolean; const Expected: string);

    [Test]
    [TestCase('AllowEmpty','|,True,Lorem|||amet')]
    [TestCase('not AllowEmpty','|,False,Lorem|amet')]
    procedure Join_array_with_gaps(const Delim: string;
      const AllowEmpty: Boolean; const Expected: string);

    [Test]
    [TestCase('AllowEmpty','|,True,|||')]
    [TestCase('not AllowEmpty','|,False,')]
    procedure Join_array_with_all_gaps(const Delim: string;
      const AllowEmpty: Boolean; const Expected: string);

    [Test]
    [TestCase('AllowEmpty','|,True')]
    [TestCase('not AllowEmpty','|,False')]
    procedure Join_empty_array(const Delim: string; const AllowEmpty: Boolean);

    // Trim

    [Test]
    [TestCase('both ends', '    Lorem  ipsum dolor    ,Lorem  ipsum dolor')]
    [TestCase('left end only', '    Lorem  ipsum dolor,Lorem  ipsum dolor')]
    [TestCase('right end only', 'Lorem  ipsum dolor    ,Lorem  ipsum dolor')]
    [TestCase('nothing to do', 'Lorem  ipsum dolor,Lorem  ipsum dolor')]
    [TestCase('only spaces', '      ,')]
    [TestCase('empty', ',')]
    procedure Trim_space_chars_only(const S, Expected: string);

    [Test]
    procedure Trim_non_space_char_whitesapce;

    // BackslashEscape

    [Test]
    [TestCase('no escapes','foo bar,xz,12,foo bar')]
    [TestCase('xz => 12 (a)','foo xz bar,xz,12,foo \1\2 bar')]
    [TestCase('xz => 12 (b)','foo xz \bar,xz,12,foo \1\2 \bar')]
    [TestCase('no replacements','foo xz bar,,,foo xz bar')]
    [TestCase('empty string',',xz,12,')]
    procedure BackslashEscape(const S, Escapable, Escapes, Expected: string);

    // BackslashUnEscape

    [Test]
    [TestCase('no-escapes','foo bar,12,xz,foo bar')]
    [TestCase('escapes-1','foo\1 \2ar\2,12,sb,foos barb')]
    [TestCase('escapes-2a','foo \\ \q (\o.\t) \,\qot,\Q12,foo \ Q (1.2) \')]
    [TestCase('escapes-2b','foo \\ \q (\o.\t) \,qot,Q12,foo \ Q (1.2) \')]
    [TestCase('escapes-3','foo \bar,,,foo bar')]
    [TestCase('empty-1',',xy,12,')]
    [TestCase('empty-2',',,,')]
    procedure BackslashUnEscape(const S, Escaped, Replacements,
      Expected: string);
  end;

implementation

uses
  System.SysUtils;

{ TTestStrUtils }

procedure TTestStringUtils.BackslashEscape(const S, Escapable, Escapes,
  Expected: string);
begin
  var Res := TStringUtils.BackslashEscape(S, Escapable, Escapes);
  Assert.AreEqual(Expected, Res);
end;

procedure TTestStringUtils.BackslashUnEscape(const S, Escaped, Replacements,
  Expected: string);
begin
  var Res := TStringUtils.BackslashUnEscape(S, Escaped, Replacements);
  Assert.AreEqual(Expected, Res);
end;

procedure TTestStringUtils.CompareText_a_eq_b(const A, B: string);
begin
  Assert.IsTrue(TStringUtils.CompareText(A, B) = 0);
end;

procedure TTestStringUtils.CompareText_a_gt_b(const A, B: string);
begin
  Assert.IsTrue(TStringUtils.CompareText(A, B) > 0);
end;

procedure TTestStringUtils.CompareText_a_lt_b(const A, B: string);
begin
  Assert.IsTrue(TStringUtils.CompareText(A, B) < 0);
end;

procedure TTestStringUtils.ContainsText_false(const Needle, Haystack: string);
begin
  Assert.IsFalse(
    TStringUtils.ContainsText(Needle, Haystack),
    Format('<%s> <%s>', [Needle, Haystack])
  );
end;

procedure TTestStringUtils.ContainsText_true(const Needle, Haystack: string);
begin
  Assert.IsTrue(
    TStringUtils.ContainsText(Needle, Haystack),
    Format('<%s> <%s>', [Needle, Haystack])
  );
end;

procedure TTestStringUtils.Join_array_with_all_gaps(const Delim: string;
  const AllowEmpty: Boolean; const Expected: string);
begin
  var S := TStringUtils.Join(SAAllGaps, Delim, AllowEmpty);
  Assert.AreEqual(Expected, S);
end;

procedure TTestStringUtils.Join_array_with_gaps(const Delim: string;
  const AllowEmpty: Boolean; const Expected: string);
begin
  var S := TStringUtils.Join(SAGaps, Delim, AllowEmpty);
  Assert.AreEqual(Expected, S);
end;

procedure TTestStringUtils.Join_empty_array(const Delim: string;
  const AllowEmpty: Boolean);
begin
  var S := TStringUtils.Join(EmptySA, Delim, AllowEmpty);
  Assert.AreEqual('', S);
end;

procedure TTestStringUtils.Join_non_empty_array(const Delim: string;
  const AllowEmpty: Boolean; const Expected: string);
begin
  var Str := TStringUtils.Join(SA, Delim, AllowEmpty);
  Assert.AreEqual(Expected, Str);
end;

procedure TTestStringUtils.SameText_false(const A, B: string);
begin
  Assert.IsFalse(TStringUtils.SameText(A, B))
end;

procedure TTestStringUtils.SameText_true(const A, B: string);
begin
  Assert.IsTrue(TStringUtils.SameText(A, B))
end;

procedure TTestStringUtils.Setup;
begin
  SA := TArray<string>.Create('Lorem','dipsom','sit','amet');
  EmptySA := TArray<string>.Create();
  SAGaps := TArray<string>.Create('Lorem','','','amet');
  SAAllGaps := TArray<string>.Create('','','','');
end;

procedure TTestStringUtils.Split(const Str, Delim, ExpLeft, ExpRight: string;
  ExpRes: Boolean);
begin
  var Left, Right: string;
  var Res := TStringUtils.Split(Str, Delim, Left, Right);
  Assert.AreEqual(ExpLeft, Left, 'Split: Left');
  Assert.AreEqual(ExpRight, Right, 'Split: Right');
  Assert.AreEqual(ExpRes, Res, 'Split: Result');
end;

procedure TTestStringUtils.StartsText_false(const Needle, Haystack: string);
begin
  Assert.IsFalse(
    TStringUtils.StartsText(Needle, Haystack),
    Format('<%s> <%s>', [Needle, Haystack])
  );
end;

procedure TTestStringUtils.StartsText_true(const Needle, Haystack: string);
begin
  Assert.IsTrue(
    TStringUtils.StartsText(Needle, Haystack),
    Format('<%s> <%s>', [Needle, Haystack])
  );
end;

procedure TTestStringUtils.TearDown;
begin
end;

procedure TTestStringUtils.ToLower(const Str, LoStr: string);
begin
  Assert.AreEqual(LoStr, TStringUtils.ToLower(Str));
end;

procedure TTestStringUtils.Trim_non_space_char_whitesapce;
begin
  const S: string = #13#9#11'FOO  '#13#10;
  var Res := TStringUtils.Trim(S);
  Assert.AreEqual('FOO', Res);
end;

procedure TTestStringUtils.Trim_space_chars_only(const S, Expected: string);
begin
  var Res := TStringUtils.Trim(S);
  Assert.AreEqual(Expected, Res);
end;

initialization

TDUnitX.RegisterTestFixture(TTestStringUtils);

end.
