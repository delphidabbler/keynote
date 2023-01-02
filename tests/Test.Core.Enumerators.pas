unit Test.Core.Enumerators;

interface

uses
  DUnitX.TestFramework,

  Core.Enumerators,
  Music.Notes;

type
  [TestFixture]
  TTestEnumerators = class
  private
    var
      SA: TArray<string>;
      NA: TArray<TNote>;
      IA: TArray<Integer>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure enum_5_element_string_array;
    [Test]
    procedure enum_3_element_note_array;
    [Test]
    procedure enum_empty_int_array;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

{ TTestEnumerators }

procedure TTestEnumerators.enum_3_element_note_array;
begin
  var NL: string := '';
  var Enum := TArrayEnumerator<TNote>.Create(NA);
  try
    while Enum.MoveNext do
      NL := NL + Integer(Enum.Current.Pitch).ToString;
    Assert.AreEqual('305060', NL);
  finally
    Enum.Free;
  end;

end;

procedure TTestEnumerators.enum_5_element_string_array;
begin
  var SL := TStringList.Create;
  try
    var Enum := TArrayEnumerator<string>.Create(SA);
    try
      while Enum.MoveNext do
        SL.Add(Enum.Current);
      Assert.AreEqual('Lorem,ipsum,dolor,sit,amet', SL.CommaText);
    finally
      Enum.Free;
    end;
  finally
    SL.Free;
  end;
end;

procedure TTestEnumerators.enum_empty_int_array;
begin
  var S: string := '';
  var Enum := TArrayEnumerator<Integer>.Create(IA);
  try
    while Enum.MoveNext do
      S := S + Enum.Current.ToString;
    Assert.AreEqual('', S);
  finally
    Enum.Free;
  end;
end;

procedure TTestEnumerators.Setup;
begin
  SA := TArray<string>.Create('Lorem', 'ipsum', 'dolor', 'sit', 'amet');
  NA := TArray<TNote>.Create(
    TNote.Create(30), TNote.Create(50), TNote.Create(60)
  );
  IA := TArray<Integer>.Create();
end;

procedure TTestEnumerators.TearDown;
begin
end;

initialization

TDUnitX.RegisterTestFixture(TTestEnumerators);

end.

