unit Core.StringUtils;

interface

uses
  System.SysUtils;

type
  TStringUtils = record
  strict private
    ///  <summary>Trims characters from both ends of a string.</summary>
    ///  <remarks>Anonymous function TrimFn determines whether a character is to
    ///  be trimmed.</remarks>
    class function InternalTrim(const Str: UnicodeString;
      const TrimFn: TFunc<Char,Boolean>): UnicodeString; static;
    ///  <summary>Checks if character at position Idx in Str can be trimmed from
    ///  string.</summary>
    ///  <remarks>Character can be trimmed if it's not part of a multi-character
    ///  sequence and TrimFn returns True for the character.</remarks>
    class function IsTrimmableChar(const Str: UnicodeString; const Idx: Integer;
      const TrimFn: TFunc<Char,Boolean>): Boolean; static;
    ///  <summary>Checks if string Haystack contains string Needle. Case
    ///  sensitive.</summary>
    class function ContainsStr(const Needle, Haystack: UnicodeString): Boolean;
      static;
  public
    ///  <summary>Compares Left and Right strings, ignoring case. Returns 0 if
    ///  both strings are the same, -ve if Left is less than Right or +ve if
    ///  Left is greater than Right.</summary>
    class function CompareText(const Left, Right: UnicodeString): Integer;
      static;

    ///  <summary>Checks if Left and Right strings are equivalent when case is
    ///  ignored.</summary>
    class function SameText(const Left, Right: UnicodeString): Boolean; static;

    ///  <summary>Checks if string Haystack contains string Needle. Case
    ///  sensitive.</summary>
    class function ContainsText(const Needle, Haystack: UnicodeString): Boolean;
      static;

    ///  <summary>Checks if string Str begins with sub string SubStr. Case
    ///  insensitive.</summary>
    ///  <remarks>False is returned if SubStr = ''.</remarks>
    class function StartsText(const SubStr, Str: UnicodeString): Boolean;
      static;

    ///  <summary>Converts a string to lower case.</summary>
    class function ToLower(const Str: UnicodeString): UnicodeString; static;

    ///  <summary>Splits string Str at the first occurence of Delim setting Left
    ///  to the string preceeding Delim and Right to the string following Delim.
    ///  Returns True if Delim was found in Str, False if not.</summary>
    ///  <remarks>Either Left or Right will be empty if Delim is found at the
    ///  start or end of Str respectively.</remarks>
    class function Split(const Str: UnicodeString; const Delim: UnicodeString;
      out Left, Right: UnicodeString): Boolean; static;

    ///  <summary>Joins all strings from a string list together into a single
    ///  string with each list element being separated by Delim. Empty string
    ///  list elements are included in the output string only if AllowEmpty is
    ///  True.</summary>
    ///  <summary>Joins all strings from an array of string together into a
    ///  single string with each array element being separated by Delim. Empty
    ///  string list elements are included in the output string only if
    ///  AllowEmpty is True.</summary>
    class function Join(const Strs: array of string; const Delim: UnicodeString;
      const AllowEmpty: Boolean = True): UnicodeString; static;

    ///  <summary>Trims leading and trailing white space characters from a
    ///   string.</summary>
    ///  <remarks>White space is considered to be any character from #0..#32.
    ///  </remarks>
    class function Trim(const Str: UnicodeString): UnicodeString; static;

    ///  <summary>Escapes all characters from string S that are included in
    ///  Escapable with the backslash character followed by the matching
    ///  character in Escapes.</summary>
    ///  <remarks>Escapable and Escapes must be the same length.</remarks>
    class function BackslashEscape(const S, Escapable, Escapes: string): string;
      static;

    ///  <summary>Returns a copy of string S where each C-style escape sequence,
    ///  introduced by '\' and followed by a character from Escaped, is replaced
    ///  by the corresponding character from Replacements.</summary>
    ///  <remarks>
    ///  <para>If an unrecognised escape character is found it is copied
    ///  literally, stripped of its preceeding '\'.</para>
    ///  <para>Escaped and Replacements must be the same length.</para>
    ///  </remarks>
    class function BackslashUnEscape(const S, Escaped, Replacements: string):
      string; static;
  end;

implementation

uses
  System.StrUtils,
  System.Character;

{ TStringUtils }

class function TStringUtils.BackslashEscape(const S, Escapable,
  Escapes: string): string;
const
  EscChar = '\';        // the C escape character
begin
  Assert(Escapable.Length = Escapes.Length);
  // Check for empty string and treat specially (empty string crashes main code)
  if S = '' then
  begin
    Result := '';
    Exit;
  end;
  // Count escapable characters in string
  var EscCount := 0;
  for var Ch in S do
  begin
    if ContainsStr(Ch, Escapable) then
      Inc(EscCount);
  end;
  // Set size of result string and get pointer to it
  SetLength(Result, Length(S) + EscCount);
  var PRes := PChar(Result);
  // Replace escapable chars with the escaped version
  for var Ch in S do
  begin
    var EscCharPos := AnsiPos(Ch, Escapable);
    if EscCharPos > 0 then
    begin
      PRes^ := EscChar;
      Inc(PRes);
      PRes^ := Escapes[EscCharPos];
    end
    else
      PRes^ := Ch;
    Inc(PRes);
  end;
end;

class function TStringUtils.BackslashUnEscape(const S, Escaped,
  Replacements: string): string;
const
  cEscChar = '\';       // the C escape character
begin
  Assert(Escaped.Length = Replacements.Length);
  // Count escape sequences
  var EscCount := 0;
  var Idx: Integer := 1;
  while Idx < Length(S) do  // don't count '\' if last character
  begin
    if S[Idx] = cEscChar then
    begin
      Inc(EscCount);
      Inc(Idx);
    end;
    Inc(Idx);
  end;
  // Set length of result string and get pointer to it
  SetLength(Result, Length(S) - EscCount);
  var PRes := PChar(Result);
  // Replace escaped chars with literal ones
  Idx := 1;
  while Idx <= Length(S) do
  begin
    // check for escape char (unless last char when treat literally)
    if (S[Idx] = cEscChar) and (Idx <> Length(S)) then
    begin
      // we have an escape char
      Inc(Idx); // skip over '\'
      // get index of escaped char (0 if not valid)
      var EscCharPos := AnsiPos(S[Idx], Escaped);
      if EscCharPos > 0 then
        PRes^ := Replacements[EscCharPos]
      else
        PRes^ := S[Idx];  // invalid escape char: copy literally
    end
    else
      PRes^ := S[Idx];
    Inc(Idx);
    Inc(PRes);
  end;
end;

class function TStringUtils.CompareText(const Left,
  Right: UnicodeString): Integer;
begin
  Result := System.SysUtils.CompareText(Left, Right);
end;

class function TStringUtils.ContainsStr(const Needle,
  Haystack: UnicodeString): Boolean;
begin
  Result := System.StrUtils.ContainsStr(Haystack, Needle);
end;

class function TStringUtils.ContainsText(const Needle,
  Haystack: UnicodeString): Boolean;
begin
  Result := System.StrUtils.ContainsText(Haystack, Needle);
end;

class function TStringUtils.InternalTrim(const Str: UnicodeString;
  const TrimFn: TFunc<Char, Boolean>): UnicodeString;
begin
  var TextEnd := Length(Str);
  var TextStart := 1;
  while (TextStart <= TextEnd)
    and IsTrimmableChar(Str, TextStart, TrimFn) do
    Inc(TextStart);
  if TextStart > TextEnd then
    Exit('');
  while IsTrimmableChar(Str, TextEnd, TrimFn) do
    Dec(TextEnd);
  Result := Copy(Str, TextStart, TextEnd - TextStart + 1);
end;

class function TStringUtils.IsTrimmableChar(const Str: UnicodeString;
  const Idx: Integer; const TrimFn: TFunc<Char, Boolean>): Boolean;
begin
  Result := (ByteType(Str, Idx) = mbSingleByte) and TrimFn(Str[Idx]);
end;

class function TStringUtils.Join(const Strs: array of string;
  const Delim: UnicodeString; const AllowEmpty: Boolean): UnicodeString;
begin
  Result := '';
  var FirstItem := True;
  for var S in Strs do
  begin
    if (S <> '') or AllowEmpty then
    begin
      if FirstItem then
      begin
        Result := S;
        FirstItem := False;
      end
      else
        Result := Result + Delim + S;
    end;
  end;
end;

class function TStringUtils.SameText(const Left, Right: UnicodeString): Boolean;
begin
  Result := System.SysUtils.SameText(Left, Right);
end;

class function TStringUtils.Split(const Str, Delim: UnicodeString; out Left,
  Right: UnicodeString): Boolean;
begin
  // Find position of first occurence of delimiter in string
  var DelimPos := AnsiPos(Delim, Str);
  if DelimPos > 0 then
  begin
    // Delimiter found: split string at delimiter
    Left := Copy(Str, 1, DelimPos - 1);
    Right := Copy(Str, DelimPos + Length(Delim), MaxInt);
    Result := True;
  end
  else
  begin
    // Delimiter not found: set Left to whole string
    Left := Str;
    Right := '';
    Result := False;
  end;
end;

class function TStringUtils.StartsText(const SubStr, Str: UnicodeString):
  Boolean;
begin
  if SubStr = '' then
    Exit(False);
  Result := System.StrUtils.StartsText(SubStr, Str);
end;

class function TStringUtils.ToLower(const Str: UnicodeString): UnicodeString;
begin
  Result := System.SysUtils.LowerCase(Str, loUserLocale);
end;

class function TStringUtils.Trim(const Str: UnicodeString): UnicodeString;
begin
  Result := InternalTrim(
    Str,
    function(Ch: Char): Boolean
    begin
      Result := Ch.IsWhiteSpace;
    end
  );
end;

end.
