unit Test.Database.Scales;

interface

uses
  DUnitX.TestFramework,

  Music.Scales,

  Database.Scales;

type
  [TestFixture]
  TTestNamedScales = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Uses Scale & Name prop getters
    [Test]
    procedure default_ctor;

    // Uses Scale & Name prop getters
    [Test]
    [TestCase('Major scale, named "Major"', '2741,Major')]
    [TestCase('Minor scale, named "Aeolian"', '1453,Aeolian')]
    procedure Create_Scale_and_Name_ctor_non_empty_name(const SN: UInt16;
      const Name: string);
    // Uses Scale & Name prop getters
    [Test]
    [TestCase('Major scale, un-named', '2741')]
    [TestCase('Minor scale, un-named', '1453')]
    procedure Create_Scale_and_Name_ctor_empty_name(const SN: UInt16);

    // Uses Scale prop getter
    [Test]
    procedure Scale_prop_setter;

    // Uses Name prop getter
    [Test]
    procedure Name_prop_setter_non_empty_string;
    // Uses Name prop getter
    [Test]
    procedure Name_prop_setter_empty_string;

    [Test]
    procedure comparer_a_lt_b;

    [Test]
    procedure comparer_a_eq_b;

    [Test]
    procedure comparer_a_gt_b;
  end;

type
  [TestFixture]
  TTestScaleCategory = class
  strict private
    var
      One, Two, Four, Empty: TScaleCategory;
      SIonian, SAeolian, SLocrian, SDorian: TScale;
      NSIonian, NSAeolian, NSLocrian, NSDorian: TNamedScale;
    function ConcatScaleNames(Cat: TScaleCategory): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Constructor(Name: string) - Also tests Name prop getter
    [Test]
    procedure Create_Name_ctor_succeeds_on_non_empty_Name;
    [Test]
    procedure Create_Name_ctor_exception_on_empty_Name;

    // Name property setter - Also tests Name prop getter
    [Test]
    procedure Name_prop_setter_succeeds_on_none_empty_string;
    [Test]
    procedure Name_prop_setter_exception_on_empty_string;

    // Add method - Successful tests also test enumerator
    [Test]
    procedure Add_2_different_scales_to_empty_category_list;
    [Test]
    procedure Add_1_different_scale_to_category_list_of_2_scales;
    [Test]
    procedure Add_same_scale_twice_to_empty_category_raises_exception;
    [Test]
    procedure Add_dup_scale_to_list_of_4_raises_exception;

    // Clear method - also tests enumerator
    [Test]
    procedure Clear_category_of_four_scales;
    [Test]
    procedure Clear_empty_category;

    // CopyTo method - also tests enumerator
    [Test]
    procedure CopyTo_copy_category_of_4_scales_to_empty_category;
    [Test]
    procedure CopyTo_copy_category_of_2_scales_to_category_of_4;

    [Test]
    procedure TryFindScale_succeeds_when_named_scale_exists_in_non_empty_category;
    [Test]
    procedure TryFindScale_fails_when_named_scale_doesnt_exist_in_non_empty_category;
    [Test]
    procedure TryFindScale_fails_when_searching_empty_category;

  end;

  [TestFixture]
  TTestScaleCategories = class
  strict private
    var
      Empty, Two, TwoUnique, Three: TScaleCategories;
    function CreateCategory(Name: string; ScaleCount: Cardinal): TScaleCategory;
    function ConcatCategoryNames(Cats: TScaleCategories): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    // Add method - tests also test enumerator
    [Test]
    procedure Add_2_different_categories_to_empty_list_succeeds;
    [Test]
    procedure Add_same_category_twice_to_empty_list_adds_1;
    [Test]
    procedure Add_duplicate_category_to_2_entry_list_is_noop;

    // Clear method - also tests enumerator
    [Test]
    procedure Clear_list_of_3_categories;
    [Test]
    procedure Clear_empty_list;

    // CopyTo method - also tests enumerator
    [Test]
    procedure CopyTo_copy_list_of_3_categories_to_empty_list;
    [Test]
    procedure CopyTo_copy_list_of_3_categories_to_list_of_2;
    [Test]
    procedure CopyTo_copy_empty_list_to_list_of_2;

    [Test]
    procedure TryFindScale_succeeds_when_named_cat_and_scale_exists;
    [Test]
    procedure TryFindScale_fails_when_named_cat_doesnt_exist;
    [Test]
    procedure TryFindScale_fails_when_cat_exists_but_doesnt_contain_scale;
    [Test]
    procedure TryFindScale_fails_when_searching_empty_list;
  end;


implementation

uses
  System.SysUtils;

procedure TTestNamedScales.comparer_a_eq_b;
begin
  var Left := TNamedScale.Create(TScale.CreateFromScaleNumber(761), 'Name');
  var Right := TNamedScale.Create(TScale.CreateFromScaleNumber(1761), 'name');
  var C := TNamedScale.TComparer.Create;
  try
    Assert.IsTrue(C.Compare(Left, Right) = 0);
  finally
    C.Free;
  end;
end;

procedure TTestNamedScales.comparer_a_gt_b;
begin
  var Left := TNamedScale.Create(TScale.CreateFromScaleNumber(761), 'z');
  var Right := TNamedScale.Create(TScale.CreateFromScaleNumber(761), 'A');
  var C := TNamedScale.TComparer.Create;
  try
    Assert.IsTrue(C.Compare(Left, Right) > 0);
  finally
    C.Free;
  end;
end;

procedure TTestNamedScales.comparer_a_lt_b;
begin
  var Left := TNamedScale.Create(TScale.CreateFromScaleNumber(761), 'a');
  var Right := TNamedScale.Create(TScale.CreateFromScaleNumber(761), 'Z');
  var C := TNamedScale.TComparer.Create;
  try
    Assert.IsTrue(C.Compare(Left, Right) < 0);
  finally
    C.Free;
  end;
end;

procedure TTestNamedScales.Create_Scale_and_Name_ctor_empty_name(
  const SN: UInt16);
begin
  var S: TScale := TScale.CreateFromScaleNumber(SN);
  var NS := TNamedScale.Create(S);
  Assert.AreEqual(S, NS.Scale, '**Scale**');
  Assert.AreEqual(S.ScaleNumber.ToString, NS.Name, '**Name**');
end;

procedure TTestNamedScales.Create_Scale_and_Name_ctor_non_empty_name(
  const SN: UInt16; const Name: string);
begin
  var S: TScale := TScale.CreateFromScaleNumber(SN);
  var NS := TNamedScale.Create(S, Name);
  Assert.AreEqual(S, NS.Scale, '**Scale**');
  Assert.AreEqual(Name, NS.Name, '**Name**');
end;

procedure TTestNamedScales.default_ctor;
begin
  var S: TScale;          // scale created with its default ctor
  var NS: TNamedScale;    // named scale created with its default ctor
  Assert.IsTrue(S = NS.Scale, '**Scale**');
  Assert.AreEqual(S.ScaleNumber.ToString, NS.Name, '**Name**');
end;

procedure TTestNamedScales.Name_prop_setter_empty_string;
begin
  var S := TScale.CreateFromScaleNumber(2741);
  var SN := TNamedScale.Create(S, 'Major');
  Assert.AreEqual('Major', SN.Name, '**Check setup**');
  SN.Name := '';
  Assert.AreEqual('2741', SN.Name, '**Test prop setter**');
end;

procedure TTestNamedScales.Name_prop_setter_non_empty_string;
begin
  var S := TScale.CreateFromScaleNumber(2741);
  var SN := TNamedScale.Create(S, 'Major');
  Assert.AreEqual('Major', SN.Name, '**Check setup**');
  SN.Name := 'Ionian';
  Assert.AreEqual('Ionian', SN.Name, '**Test prop setter**');
end;

procedure TTestNamedScales.Scale_prop_setter;
begin
  var S := TScale.CreateFromScaleNumber(2741);
  var SN := TNamedScale.Create(S, 'Major');
  Assert.AreEqual(2741, SN.Scale.ScaleNumber);
end;

procedure TTestNamedScales.Setup;
begin
end;

procedure TTestNamedScales.TearDown;
begin
end;

{ TTestScaleCategory }

procedure TTestScaleCategory.Add_1_different_scale_to_category_list_of_2_scales;
begin
  Two.Add(NSDorian);
  var Res := ConcatScaleNames(Two);
  Assert.AreEqual(Res, ':Ionian:Aeolian:Dorian:');
end;

procedure TTestScaleCategory.Add_2_different_scales_to_empty_category_list;
begin
  Empty.Add(NSDorian);
  Empty.Add(NSIonian);
  var Res := ConcatScaleNames(Empty);
  Assert.AreEqual(Res, ':Dorian:Ionian:');
end;

procedure TTestScaleCategory.Add_dup_scale_to_list_of_4_raises_exception;
begin
  Assert.WillRaise(
    procedure
    begin
      Four.Add(NSDorian);
    end,
    EScaleCategory
  );
end;

procedure TTestScaleCategory.Add_same_scale_twice_to_empty_category_raises_exception;
begin
  Assert.WillRaise(
    procedure
    begin
      Empty.Add(NSIonian);
      Empty.Add(NSIonian);
    end,
    EScaleCategory
  );
end;

procedure TTestScaleCategory.Clear_category_of_four_scales;
begin
  Four.Clear;
  var Res := ConcatScaleNames(Four);
  Assert.AreEqual(':', Res);
end;

procedure TTestScaleCategory.Clear_empty_category;
begin
  Empty.Clear;
  var Res := ConcatScaleNames(Empty);
  Assert.AreEqual(':', Res);
end;

function TTestScaleCategory.ConcatScaleNames(Cat: TScaleCategory): string;
begin
  Result := ':';
  for var NS in Cat do
    Result := Result + NS.Name + ':';
end;

procedure TTestScaleCategory.CopyTo_copy_category_of_2_scales_to_category_of_4;
begin
  Two.CopyTo(Four);
  var Res := ConcatScaleNames(Four);
  Assert.AreEqual(':Ionian:Aeolian:', Res);
end;

procedure TTestScaleCategory.CopyTo_copy_category_of_4_scales_to_empty_category;
begin
  Four.CopyTo(Empty);
  var Res := ConcatScaleNames(Empty);
  Assert.AreEqual(':Ionian:Aeolian:Locrian:Dorian:', Res);
end;

procedure TTestScaleCategory.Create_Name_ctor_exception_on_empty_Name;
begin
  Assert.WillRaise(
    procedure
    begin
      TScaleCategory.Create('');
    end,
    EScaleCategory
  );
end;

procedure TTestScaleCategory.Create_Name_ctor_succeeds_on_non_empty_Name;
begin
  var Cat := TScaleCategory.Create('test');
  try
    Assert.AreEqual('test', Cat.Name);
  finally
    Cat.Free;
  end;
end;

procedure TTestScaleCategory.Name_prop_setter_exception_on_empty_string;
begin
  Assert.WillRaise(
    procedure
    begin
      var Cat := TScaleCategory.Create('one');
      try
        Cat.Name := '';
      finally
        Cat.Free;
      end;
    end,
    EScaleCategory
  );
end;

procedure TTestScaleCategory.Name_prop_setter_succeeds_on_none_empty_string;
begin
  var Cat := TScaleCategory.Create('one');
  try
    Cat.Name := 'two';
    Assert.AreEqual('two', Cat.Name);
  finally
    Cat.Free;
  end;
end;

procedure TTestScaleCategory.Setup;
begin
  One := TScaleCategory.Create('One');
  Two := TScaleCategory.Create('Two');
  Four := TScaleCategory.Create('Four');
  Empty := TScaleCategory.Create('Empty');

  SIonian := TScale.CreateFromScaleNumber(2741);
  SAeolian := TScale.CreateFromScaleNumber(1453);
  SLocrian := TScale.CreateFromScaleNumber(1387);
  SDorian := TScale.CreateFromScaleNumber(1709);

  NSIonian := TNamedScale.Create(SIonian, 'Ionian');
  NSAeolian := TNamedScale.Create(SAeolian, 'Aeolian');
  NSLocrian := TNamedScale.Create(SLocrian, 'Locrian');
  NSDorian := TNamedScale.Create(SDorian, 'Dorian');

  One.Add(NSIonian);

  Two.Add(NSIonian);
  Two.Add(NSAeolian);

  Four.Add(NSIonian);
  Four.Add(NSAeolian);
  Four.Add(NSLocrian);
  Four.Add(NSDorian);
end;

procedure TTestScaleCategory.TearDown;
begin
  Empty.Free;
  Four.Free;
  Two.Free;
  One.Free;
end;

procedure TTestScaleCategory.TryFindScale_fails_when_named_scale_doesnt_exist_in_non_empty_category;
begin
  var S: TScale;
  Assert.IsFalse(Four.TryFindScale('Forty-Two', S));
end;

procedure TTestScaleCategory.TryFindScale_fails_when_searching_empty_category;
begin
  var S: TScale;
  Assert.IsFalse(Empty.TryFindScale('Locrian', S));
end;

procedure TTestScaleCategory.TryFindScale_succeeds_when_named_scale_exists_in_non_empty_category;
begin
  var S: TScale;
  Assert.IsTrue(Four.TryFindScale('Locrian', S), 'Check return is True');
  Assert.IsTrue(SLocrian = S, 'Check scales equal');
end;

{ TTestScaleCategories }

procedure TTestScaleCategories.Add_2_different_categories_to_empty_list_succeeds;
begin
  var Cat1 := CreateCategory('1', 1);
  var Cat2 := CreateCategory('2', 2);
  var Cats := TScaleCategories.Create;
  try
    Assert.IsTrue(Cats.Add(Cat1), 'Adding 1st category');
    Assert.IsTrue(Cats.Add(Cat2), 'Adding 2nd category');
    Assert.AreEqual(':1:2:', ConcatCategoryNames(Cats), 'Checking list');
  finally
    Cats.Free;
  end;
end;

procedure TTestScaleCategories.Add_duplicate_category_to_2_entry_list_is_noop;
begin
  var Cats := TScaleCategories.Create;
  try
    // Set up 2 entry list
    Cats.Add(CreateCategory('0', 0));
    Cats.Add(CreateCategory('dup', 1));
    Assert.AreEqual(':0:dup:', ConcatCategoryNames(Cats), 'Checking setup');
    var CatFail := CreateCategory('dup', 5);
    try
      Assert.IsFalse(Cats.Add(CatFail), 'Checking .Add() fails');
      Assert.AreEqual(':0:dup:', ConcatCategoryNames(Cats), 'Checking list unchanged after fail');
    finally
      CatFail.Free;
    end;
  finally
    Cats.Free;
  end;
end;

procedure TTestScaleCategories.Add_same_category_twice_to_empty_list_adds_1;
begin
  var Cat := CreateCategory('only', 3);
  var Cats := TScaleCategories.Create;
  try
    Assert.IsTrue(Cats.Add(Cat), 'Adding category 1st time');
    Assert.IsFalse(Cats.Add(Cat), 'Adding same category again');
    Assert.AreEqual(':only:', ConcatCategoryNames(Cats), 'Checking list');
  finally
    Cats.Free;
  end;
end;

procedure TTestScaleCategories.Clear_empty_list;
begin
  Assert.AreEqual(':', ConcatCategoryNames(Empty), 'Setup check');
  Empty.Clear;
  Assert.AreEqual(':', ConcatCategoryNames(Empty), 'After .Clear');
end;

procedure TTestScaleCategories.Clear_list_of_3_categories;
begin
  Assert.AreEqual(':1:2:3:', ConcatCategoryNames(Three), 'Setup check');
  Three.Clear;
  Assert.AreEqual(':', ConcatCategoryNames(Three), 'After .Clear');
end;

function TTestScaleCategories.ConcatCategoryNames(
  Cats: TScaleCategories): string;
begin
  Result := ':';
  for var Cat in Cats do
    Result := Result + Cat.Name + ':';
end;

procedure TTestScaleCategories.CopyTo_copy_empty_list_to_list_of_2;
begin
  Empty.CopyTo(Two);
  Assert.AreEqual(':', ConcatCategoryNames(Empty));
end;

procedure TTestScaleCategories.CopyTo_copy_list_of_3_categories_to_empty_list;
begin
  Three.CopyTo(Empty);
  Assert.AreEqual(':1:2:3:', ConcatCategoryNames(Empty));
end;

procedure TTestScaleCategories.CopyTo_copy_list_of_3_categories_to_list_of_2;
begin
  Three.CopyTo(Two);
  Assert.AreEqual(':1:2:3:', ConcatCategoryNames(Two));
end;

function TTestScaleCategories.CreateCategory(Name: string;
  ScaleCount: Cardinal): TScaleCategory;
begin
  Result := TScaleCategory.Create(Name);
  for var I := 1 to ScaleCount do
    Result.Add(TNamedScale.Create(TScale.CreateFromScaleNumber(10 * I + 1), 'S' + I.ToString));
end;

procedure TTestScaleCategories.Setup;
begin
  Empty := TScaleCategories.Create;

  Two := TScaleCategories.Create;
  for var I := 1 to 2 do
    Two.Add(CreateCategory(I.ToString, I));

  Three := TScaleCategories.Create;
  for var I := 1 to 3 do
    Three.Add(CreateCategory(I.ToString, I));

  TwoUnique := TScaleCategories.Create;
  for var I := 11 to 12 do
    Two.Add(CreateCategory(I.ToString, I - 11));
end;

procedure TTestScaleCategories.TearDown;
begin
  TwoUnique.Free;
  Three.Free;
  Two.Free;
  Empty.Free;
end;

procedure TTestScaleCategories.TryFindScale_fails_when_cat_exists_but_doesnt_contain_scale;
begin
  var S: TScale;
  Assert.IsFalse(Three.TryFindScale('2', 'SBad', S), 'Find succeeds');
end;

procedure TTestScaleCategories.TryFindScale_fails_when_named_cat_doesnt_exist;
begin
  var S: TScale;
  Assert.IsFalse(Three.TryFindScale('BadCat', 'S2', S));
end;

procedure TTestScaleCategories.TryFindScale_fails_when_searching_empty_list;
begin
  var S: TScale;
  Assert.IsFalse(Empty.TryFindScale('2', 'S2', S));
end;

procedure TTestScaleCategories.TryFindScale_succeeds_when_named_cat_and_scale_exists;
begin
  var S: TScale;
  Assert.IsTrue(Three.TryFindScale('2', 'S2', S), 'Find succeeds');
  Assert.IsTrue(21 = S.ScaleNumber, 'Correct scale');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestNamedScales);
  TDUnitX.RegisterTestFixture(TTestScaleCategory);
  TDUnitX.RegisterTestFixture(TTestScaleCategories);
end.

