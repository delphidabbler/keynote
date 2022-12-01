unit Core.Enumerators;

interface

uses
  // Delphi
  System.Generics.Collections;

type

  ///  <summary>Generic enumerator for dynamic arrays.</summary>
  TArrayEnumerator<T> = class(TEnumerator<T>)
  strict private
    var
      ///  <summary>Array being enumerated.</summary>
      fArray: TArray<T>;
      ///  <summary>Index of current array element in enumeration.</summary>
      fIndex: Integer;
  strict protected
    ///  <summary>Gets current array element in enumeration.</summary>
    ///  <returns>T. Content of current array element.</returns>
    function DoGetCurrent: T; override;
    ///  <summary>Moves to next item in enumeration.</summary>
    ///  <returns>Boolean. True if there is a next item, False if at end of
    ///  enumeration.</returns>
    function DoMoveNext: Boolean; override;
  public
    ///  <summary>Creates enumerator for given dynamic array.</summary>
    ///  <param name="A">Array to be enumerated. [in]</param>
    ///  <remarks>Constructor makes a shallow copy of the given array: value
    ///  type elements are copied but reference type elements are simply
    ///  referenced.</remarks>
    constructor Create(const A: array of T);
  end;

implementation

{ TArrayEnumerator<T> }

constructor TArrayEnumerator<T>.Create(const A: array of T);
begin
  inherited Create;
  SetLength(fArray, Length(A));
  for var Idx := Low(A) to High(A) do
    fArray[Idx] := A[Idx];
  fIndex := -1;
end;

function TArrayEnumerator<T>.DoGetCurrent: T;
begin
  Result := fArray[fIndex];
end;

function TArrayEnumerator<T>.DoMoveNext: Boolean;
begin
  if fIndex >= Length(fArray) then
    Exit(False);
  Inc(fIndex);
  Result := fIndex < Length(fArray);
end;

end.

