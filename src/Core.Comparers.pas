unit Core.Comparers;

interface

uses
  System.Generics.Defaults;

type
  ///  <summary>
  ///  Case insenstive string equality comparer.
  ///  </summary>
  TTextEqualityComparer = class(TEqualityComparer<string>,
    IEqualityComparer<string>
  )
  public
    ///  <summary>Checks if two strings are equal, ignoring case.</summary>
    function Equals(const Left, Right: string): Boolean; override;
    ///  <summary>Gets hash of lower case version of given string.</summary>
    function GetHashCode(const Value: string): Integer; override;
  end;


implementation

uses
  System.SysUtils,
  System.Hash,
  UStrUtils;


{ TTextEqualityComparer }

function TTextEqualityComparer.Equals(const Left, Right: string): Boolean;
begin
  Result := TStringUtils.SameText(Left, Right);
end;

function TTextEqualityComparer.GetHashCode(const Value: string): Integer;
begin
  // Comparison takes place (i.e. Equals gets called) only if hashes are same.
  // So we must ignore case in hash if two strings that differ only in case are
  // to be considered same.
  Result := THashBobJenkins.GetHashValue(Value.ToLower);
end;

end.
