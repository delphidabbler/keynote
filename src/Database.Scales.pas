unit Database.Scales;

interface

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections,

  Music.Scales;

type
  TNamedScale = record
  strict private
    var
      fScale: TScale;
      fName: string;
    function GetName: string;
  public
    type
      ///  <summary>Comparer object for <c>TNamedScale</c>.</summary>
      ///  <remarks>Only scale names are considered when comparing, so two
      ///  different scales with same name are considered equal. Comparison of
      ///  scale names is case insensitive.</remarks>
      TComparer = class(TComparer<TNamedScale>)
      public
        function Compare(const Left, Right: TNamedScale): Integer; override;
      end;
  public
    constructor Create(const AScale: TScale; const AName: string = '');
    property Scale: TScale read fScale write fScale;
    property Name: string read GetName write fName;
  end;

  TScaleCategory = class
  strict private
    var
      fName: string;
      fScales: TList<TNamedScale>;
    procedure SetName(const AName: string);
    function IndexOfScaleName(const AName: string): Integer;
  public
    type
      ///  <summary>Comparer object for <c>TScaleCategory</c>.</summary>
      ///  <remarks>Only category names are considered when comparing, so two
      ///  categories with the same name are considered equal even if they
      ///  contain different named scales. Comparison of category names is case
      ///  insensitive.</remarks>
      TComparer = class(TComparer<TScaleCategory>)
      public
        function Compare(const Left, Right: TScaleCategory): Integer; override;
      end;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
    property Name: string read fName write SetName;
    function GetEnumerator: TEnumerator<TNamedScale>;
    procedure Add(const AScale: TNamedScale);
    function TryFindScale(const AScaleName: string;
      out AScale: TScale): Boolean;
    procedure CopyTo(const ADest: TScaleCategory);
    procedure Clear;
  end;

  EScaleCategory = class(Exception);

  TScaleCategories = class(TObject)
  strict private
    var
      fCategories: TObjectList<TScaleCategory>;
    function IndexOfCatName(const ACatName: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CopyTo(const ADest: TScaleCategories);
    ///  <summary>Attempts to add given category to list. If category with same
    ///  as <c>Cat</c> is already in list then the cataegory name is adjusted
    ///  so that it is unique.</summary>
    ///  <param name="Cat">Category to be added [in].</param>
    ///  <returns><c>Boolean</c>. True if <c>Cat</c> was added to list, False if
    ///  not.</returns>
    function Add(const Cat: TScaleCategory): Boolean;
    procedure Clear;
    function TryFindScale(const ACatName, AScaleName: string;
      out AScale: TScale): Boolean;
    function GetEnumerator: TEnumerator<TScaleCategory>;
  end;

implementation

uses
  Core.StringUtils;

{ TNamedScale }

constructor TNamedScale.Create(const AScale: TScale; const AName: string);
begin
  fScale := AScale;
  fName := AName;
end;

function TNamedScale.GetName: string;
begin
  if fName <> '' then
    Result := fName
  else
    Result := fScale.ScaleNumber.ToString;
end;

{ TNamedScale.TComparer }

function TNamedScale.TComparer.Compare(const Left, Right: TNamedScale): Integer;
begin
  Result := TStringUtils.CompareText(Left.Name, Right.Name);
end;

{ TScaleCategory }

procedure TScaleCategory.Add(const AScale: TNamedScale);
begin
  if fScales.IndexOf(AScale) >= 0 then
    raise EScaleCategory.CreateFmt(
      'Scale "%s" is already in this category', [AScale.Name]
    );
  fScales.Add(AScale);
end;

procedure TScaleCategory.Clear;
begin
  fScales.Clear;
end;

procedure TScaleCategory.CopyTo(const ADest: TScaleCategory);
begin
  ADest.Clear;
  ADest.Name := fName;
  for var NamedScale in fScales do
    ADest.Add(NamedScale);
end;

constructor TScaleCategory.Create(const AName: string);
begin
  inherited Create;
  fScales := TList<TNamedScale>.Create(TNamedScale.TComparer.Create);
  SetName(AName);
end;

destructor TScaleCategory.Destroy;
begin
  fScales.Free;
  inherited;
end;

function TScaleCategory.GetEnumerator: TEnumerator<TNamedScale>;
begin
  Result := fScales.GetEnumerator;
end;

function TScaleCategory.IndexOfScaleName(const AName: string): Integer;
begin
  var DummyScale: TScale;
  // Following search uses only scale name, scale itself is ignored.
  Result := fScales.IndexOf(TNamedScale.Create(DummyScale, AName));
end;

procedure TScaleCategory.SetName(const AName: string);
begin
  if AName = '' then
    raise EScaleCategory.Create('Scale category name cannot be empty');
  fName := AName;
end;

function TScaleCategory.TryFindScale(const AScaleName: string;
  out AScale: TScale): Boolean;
begin
  var Idx := IndexOfScaleName(AScaleName);
  if Idx = -1 then
    Exit(False);
  Result := True;
  AScale := fScales[Idx].Scale;
end;

{ TScaleCategory.TComparer }

function TScaleCategory.TComparer.Compare(const Left,
  Right: TScaleCategory): Integer;
begin
  Result := TStringUtils.CompareText(Left.Name, Right.Name);
end;

{ TScaleCategories }

function TScaleCategories.Add(const Cat: TScaleCategory): Boolean;
begin
  Result := IndexOfCatName(Cat.Name) = -1;
  if Result then
    fCategories.Add(Cat);
end;

procedure TScaleCategories.Clear;
begin
  fCategories.Clear;
end;

procedure TScaleCategories.CopyTo(const ADest: TScaleCategories);
begin
  ADest.Clear;
  for var Cat in fCategories do
  begin
    var CatCopy := TScaleCategory.Create(Cat.Name);
    Cat.CopyTo(CatCopy);
    ADest.Add(CatCopy);
  end;
end;

constructor TScaleCategories.Create;
begin
  inherited;
  fCategories := TObjectList<TScaleCategory>.Create(
    TScaleCategory.TComparer.Create, True
  );
end;

destructor TScaleCategories.Destroy;
begin
  fCategories.Free;   // frees owned objects
  inherited;
end;

function TScaleCategories.GetEnumerator: TEnumerator<TScaleCategory>;
begin
  Result := fCategories.GetEnumerator;
end;

function TScaleCategories.IndexOfCatName(const ACatName: string): Integer;
begin
  for var Idx := 0 to Pred(fCategories.Count) do
    if TStringUtils.SameText(ACatName, fCategories[Idx].Name) then
      Exit(Idx);
  Result := -1;
end;

function TScaleCategories.TryFindScale(const ACatName, AScaleName: string;
  out AScale: TScale): Boolean;
begin
  var CatIdx := IndexOfCatName(ACatName);
  if CatIdx < 0 then
    Exit(False);
  var Cat := fCategories[CatIdx];
  Result := Cat.TryFindScale(AScaleName, AScale);
end;

end.
