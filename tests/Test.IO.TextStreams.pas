unit Test.IO.TextStreams;

interface

uses
  DUnitX.TestFramework,

  System.SysUtils,
  System.Classes,

  IO.TextStreams;

type
  [TestFixture]
  TTestTextStreamReader = class
  strict private
    const
      ASCIIText = 'One'#13'Two'#13'Three';
      UnicodeText = 'Copyright'#10'©'#10'2023';
      TrailingEOLText = 'One'#13#10'Two'#13#10'Three'#13#10;
    var
      Stream: TStream;
      Reader: TTextStreamReader;
    // Clears Stream, write bytes of text in given encoding to it then sets
    // position to start.
    procedure WriteTextToStream(const Text: string; const Encoding: TEncoding);
    procedure CheckLines(const Expected, Got: array of string;
      const Msg: string = '');
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure ctor_with_nil_stream_fails_assertion;

    [Test]
    procedure Encoding_prop_default_is_UTF8;
    [Test]
    procedure Encoding_prop_sets_and_gets_properly;
    [Test]
    procedure Encoding_prop_set_to_nil_uses_UTF8;

    [Test]
    procedure ReadLines_default_processing_ASCII_encoding;
    [Test]
    procedure ReadLines_default_processing_UTF8_encoding;
    [Test]
    procedure ReadLines_default_processing_UTF16BE_encoding;
    [Test]
    procedure ReadLines_default_processing_trailing_EOL;

    [Test]
    procedure ReadLines_trim_spaces;
    [Test]
    procedure ReadLines_skip_lines_containing_marker;
    [Test]
    procedure ReadLines_trim_spaces_and_skip_empty_and_lines_starting_with_hash;

    [Test]
    procedure ReadLines_starting_mid_stream;
  end;

  [TestFixture]
  TTestTextStreamWriter = class
  strict private
    const
      OneLine = 'Lorem ipsum dolor sit amet';
      EmbeddedLineBreaks = 'Lorem'#10'ipsum'#13'dolor'#13#10'sit amet';
      ExpectedWriteEmbeddedLineBreaksDefaultNewLine = 'Lorem'+sLineBreak+'ipsum'+sLineBreak+'dolor'+sLineBreak+'sit amet';
      ExpectedWriteEmbeddedLineBreaksSpecifiedNewLine = 'Lorem#ipsum#dolor#sit amet';
      Line1 = 'Lorem ipsum dolor sit amet,';
      Line2 = 'consectetur adipiscing elit.';
      Line3 = 'Sed orci elit';
      ExpectedWriteLnEmbeddedLineBreaksDefaultNewLine =
        ExpectedWriteEmbeddedLineBreaksDefaultNewLine + sLineBreak;
      ExpectedWriteLnEmbeddedLineBreaksSpecifiedNewLine = 'Lorem[EOL]ipsum[EOL]dolor[EOL]sit amet[EOL]';
      ExpectedWriteLn3LinesDefaultNewLine = 'Lorem ipsum dolor sit amet,' + sLineBreak
        + 'consectetur adipiscing elit.' + sLineBreak
        + 'Sed orci elit' + sLineBreak;
      ExpectedWriteLn3LinesSpecifiedNewLine = 'Lorem ipsum dolor sit amet,[EOL]'
        + 'consectetur adipiscing elit.[EOL]'
        + 'Sed orci elit[EOL]';
      PriorContent = 'PRIOR CONTENT';
    var
      Stream1, Stream2: TStringStream;
      Writer1, Writer2: TTextStreamWriter;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure ctor_with_nil_stream_fails_assertion;

    [Test]
    procedure writing_nothing_leaves_stream_unchanged;

    [Test]
    procedure EOLString_prop_sets_and_gets_properly;

    [Test]
    procedure Encoding_prop_default_is_UTF8;
    [Test]
    procedure Encoding_prop_sets_and_gets_properly;
    [Test]
    procedure Encoding_prop_set_to_nil_uses_UTF8;

    [Test]
    procedure Write_text_with_no_embedded_newlines_writes_literally;
    [Test]
    procedure Write_text_with_embedded_newlines_converts_them_to_default;
    [Test]
    procedure Write_text_with_embedded_newlines_converts_them_to_specified;

    [Test]
    procedure Write_text_in_ascii_all_chars_valid;
    [Test]
    procedure Write_text_in_ascii_one_char_invalid;

    [Test]
    procedure WriteLn_one_line_writes_literal_line_and_default_newline;
    [Test]
    procedure WriteLn_one_line_writes_literal_line_and_specified_newline;
    [Test]
    procedure WriteLn_text_with_embedded_new_lines_writes_with_expected_default_newlines;
    [Test]
    procedure WriteLn_text_with_embedded_new_lines_writes_with_expected_specified_newlines;
    [Test]
    procedure WriteLn_3_lines_write_with_expected_default_newlines;
    [Test]
    procedure WriteLn_3_lines_write_with_expected_specified_newlines;
  end;

implementation

uses
  WinApi.Windows;

{ TTestTextStreamReader }

procedure TTestTextStreamReader.CheckLines(const Expected,
  Got: array of string; const Msg: string);
begin
  var Same: Boolean;
  if Length(Expected) <> Length(Got) then
    Same := False
  else
  begin
    Same := True;
    for var I := Low(Got) to High(Got) do
      if Expected[I] <> Got[I] then
      begin
        Same := False;
        Break;
      end;
  end;
  Assert.IsTrue(Same, Msg);
end;

procedure TTestTextStreamReader.ctor_with_nil_stream_fails_assertion;
begin
  Assert.WillRaise(
    procedure
    begin
      TTextStreamReader.Create(nil);
    end,
    EAssertionFailed
  );
end;

procedure TTestTextStreamReader.Encoding_prop_default_is_UTF8;
begin
  Assert.AreEqual(CP_UTF8, Reader.Encoding.CodePage);
end;

procedure TTestTextStreamReader.Encoding_prop_sets_and_gets_properly;
begin
  Reader.Encoding := TMBCSEncoding.Create(GetACP);
  Assert.AreEqual(GetACP, Reader.Encoding.CodePage);
end;

procedure TTestTextStreamReader.Encoding_prop_set_to_nil_uses_UTF8;
begin
  Reader.Encoding := TMBCSEncoding.Create(GetACP);
  Assert.AreEqual(GetACP, Reader.Encoding.CodePage, '(setup)');
  Reader.Encoding := nil;
  Assert.AreEqual(CP_UTF8, Reader.Encoding.CodePage, '(test Encoding := nil)');
end;

procedure TTestTextStreamReader.ReadLines_default_processing_ASCII_encoding;
begin
  WriteTextToStream(ASCIIText, TEncoding.ASCII);
  Reader.Encoding := TEncoding.UTF8;
  CheckLines(['One','Two','Three'], Reader.ReadLines);
end;

procedure TTestTextStreamReader.ReadLines_default_processing_trailing_EOL;
begin
  WriteTextToStream(TrailingEOLText, TEncoding.UTF8);
  CheckLines(['One','Two','Three', ''], Reader.ReadLines);
end;

procedure TTestTextStreamReader.ReadLines_default_processing_UTF16BE_encoding;
begin
  WriteTextToStream(UnicodeText, TEncoding.BigEndianUnicode);
  Reader.Encoding := TEncoding.BigEndianUnicode;
  CheckLines(['Copyright', '©', '2023'], Reader.ReadLines);
end;

procedure TTestTextStreamReader.ReadLines_default_processing_UTF8_encoding;
begin
  WriteTextToStream(UnicodeText, TEncoding.UTF8);
  Reader.Encoding := TEncoding.UTF8;
  CheckLines(['Copyright', '©', '2023'], Reader.ReadLines);
end;

procedure TTestTextStreamReader.ReadLines_skip_lines_containing_marker;
const
  Original: array of string = ['One[MARKER]', ' Two ', 'Three [MARKER]', '[MARKER]', 'Five', '[MARKER]Six'];
  Expected: array of string = [               ' Two ',                               'Five'               ];
begin
  WriteTextToStream(string.Join(sLineBreak, Original), TEncoding.UTF8);
  Reader.SkipLineCallback :=
    function(const ALine: string): Boolean
    begin
      Result := ALine.Contains('[MARKER]');
    end;
  CheckLines(Expected, Reader.ReadLines);
end;

procedure TTestTextStreamReader.ReadLines_starting_mid_stream;
const
  IgnorePart = '######';
begin
  // We want to skip the hashes. Using ASCII encoding to ensure 1 byte per char
  WriteTextToStream(IgnorePart + 'Line 1'#10'Line 2', TEncoding.ASCII);
  // Skip over hashes
  Stream.Position := IgnorePart.Length;
  CheckLines(['Line 1', 'Line 2'], Reader.ReadLines);
end;

procedure TTestTextStreamReader.ReadLines_trim_spaces;
const
  Original: array of string = ['  ', 'Line 1', '  Line 2  ', 'Line 3  ', ' ', 'End'];
  Expected: array of string = ['',   'Line 1', 'Line 2',     'Line 3',   '',  'End'];
begin
  WriteTextToStream(string.Join(sLineBreak, Original), TEncoding.UTF8);
  Reader.ModifyLineCallback :=
    function(const ALine: string): string
    begin
      Result := ALine.Trim;
    end;
  CheckLines(Expected, Reader.ReadLines);
end;

procedure TTestTextStreamReader.ReadLines_trim_spaces_and_skip_empty_and_lines_starting_with_hash;
const
  Original: array of string = ['', '# Comment 1', '  One', 'Two  ', '    ', '  # Comment 2  ', 'Three', '  '];
  Expected: array of string = [                   'One',   'Two',                              'Three'      ];
begin
  WriteTextToStream(string.Join(sLineBreak, Original), TEncoding.UTF8);
  Reader.ModifyLineCallback :=
    function(const ALine: string): string
    begin
      Result := ALine.Trim;
    end;
  Reader.SkipLineCallback :=
    function(const ALine: string): Boolean
    begin
      Result := (ALine = '') or ALine.StartsWith('#');
    end;
  CheckLines(Expected, Reader.ReadLines);
end;

procedure TTestTextStreamReader.Setup;
begin
  Stream := TMemoryStream.Create;
  Reader := TTextStreamReader.Create(Stream);
end;

procedure TTestTextStreamReader.TearDown;
begin
  Reader.Free;
end;

procedure TTestTextStreamReader.WriteTextToStream(const Text: string;
  const Encoding: TEncoding);
begin
  Stream.Size := 0;
  var Bytes := Encoding.GetBytes(Text);
  Stream.WriteData(Bytes, Length(Bytes));
  Stream.Position := 0;
end;

{ TTestTextStreamWriter }

procedure TTestTextStreamWriter.ctor_with_nil_stream_fails_assertion;
begin
  Assert.WillRaise(
    procedure
    begin
      TTextStreamWriter.Create(nil);
    end,
    EAssertionFailed
  );
end;

procedure TTestTextStreamWriter.Encoding_prop_default_is_UTF8;
begin
  Assert.AreEqual(CP_UTF8, Writer1.Encoding.CodePage);
end;

procedure TTestTextStreamWriter.Encoding_prop_sets_and_gets_properly;
begin
  Writer1.Encoding := TEncoding.BigEndianUnicode;
  Assert.AreEqual(1201, Writer1.Encoding.CodePage);
end;

procedure TTestTextStreamWriter.Encoding_prop_set_to_nil_uses_UTF8;
begin
  Writer1.Encoding := TEncoding.Unicode;
  Assert.AreEqual(1200, Writer1.Encoding.CodePage, '(checking setup)');
  Writer1.Encoding := nil;
  Assert.AreEqual(CP_UTF8, Writer1.Encoding.CodePage, '(test nil encoding is UTF8)');
end;

procedure TTestTextStreamWriter.EOLString_prop_sets_and_gets_properly;
begin
  Writer1.EOLString := '[EOL]';
  Assert.AreEqual('[EOL]', Writer1.EOLString);
end;

procedure TTestTextStreamWriter.Setup;
begin
  Stream1 := TStringStream.Create;
  Writer1 := TTextStreamWriter.Create(Stream1, True);
  Stream2 := TStringStream.Create(PriorContent);
  Stream2.Seek(0, TSeekOrigin.soEnd);
  Writer2 := TTextStreamWriter.Create(Stream2, False);
end;

procedure TTestTextStreamWriter.TearDown;
begin
  Writer2.Free;
  Stream2.Free;
  Writer1.Free;
end;

procedure TTestTextStreamWriter.WriteLn_3_lines_write_with_expected_default_newlines;
begin
  Writer1.WriteLn(Line1);
  Writer1.WriteLn(Line2);
  Writer1.WriteLn(Line3);
  Assert.AreEqual(ExpectedWriteLn3LinesDefaultNewLine, Stream1.DataString);
end;

procedure TTestTextStreamWriter.WriteLn_3_lines_write_with_expected_specified_newlines;
begin
  Writer2.EOLString := '[EOL]';
  Writer2.WriteLn(Line1);
  Writer2.WriteLn(Line2);
  Writer2.WriteLn(Line3);
  Assert.AreEqual(PriorContent + ExpectedWriteLn3LinesSpecifiedNewLine, Stream2.DataString);
end;

procedure TTestTextStreamWriter.WriteLn_one_line_writes_literal_line_and_default_newline;
begin
  Writer1.WriteLn(OneLine);
  Assert.AreEqual(OneLine + sLineBreak, Stream1.DataString);
end;

procedure TTestTextStreamWriter.WriteLn_one_line_writes_literal_line_and_specified_newline;
begin
  Writer1.EOLString := '[EOL]';
  Writer1.WriteLn(OneLine);
  Assert.AreEqual(OneLine + '[EOL]', Stream1.DataString);
end;

procedure TTestTextStreamWriter.WriteLn_text_with_embedded_new_lines_writes_with_expected_default_newlines;
begin
  Writer1.WriteLn(EmbeddedLineBreaks);
  Assert.AreEqual(ExpectedWriteLnEmbeddedLineBreaksDefaultNewLine, Stream1.DataString);
end;

procedure TTestTextStreamWriter.WriteLn_text_with_embedded_new_lines_writes_with_expected_specified_newlines;
begin
  Writer1.EOLString := '[EOL]';
  Writer1.WriteLn(EmbeddedLineBreaks);
  Assert.AreEqual(ExpectedWriteLnEmbeddedLineBreaksSpecifiedNewLine, Stream1.DataString);
end;

procedure TTestTextStreamWriter.Write_text_in_ascii_all_chars_valid;
begin
  Writer1.Encoding := TEncoding.ASCII;
  Writer1.Write('abc');
  Assert.AreEqual('abc', Stream1.DataString);
end;

procedure TTestTextStreamWriter.Write_text_in_ascii_one_char_invalid;
begin
  Writer1.Encoding := TEncoding.ASCII;
  Writer1.Write('a©c');
  Assert.AreNotEqual('a©c', Stream1.DataString);
end;

procedure TTestTextStreamWriter.Write_text_with_embedded_newlines_converts_them_to_default;
begin
  Writer1.Write(EmbeddedLineBreaks);
  Assert.AreEqual(Stream1.DataString, ExpectedWriteEmbeddedLineBreaksDefaultNewLine);
end;

procedure TTestTextStreamWriter.Write_text_with_embedded_newlines_converts_them_to_specified;
begin
  Writer1.EOLString := '#';
  Writer1.Write(EmbeddedLineBreaks);
  Assert.AreEqual(Stream1.DataString, ExpectedWriteEmbeddedLineBreaksSpecifiedNewLine);
end;

procedure TTestTextStreamWriter.Write_text_with_no_embedded_newlines_writes_literally;
begin
  Writer1.Write(OneLine);
  Writer2.Write(OneLine);
  Assert.AreEqual(OneLine, Stream1.DataString, '(Empty stream)');
  Assert.AreEqual(PriorContent + OneLine, Stream2.DataString, '(Prior content stream)');
end;

procedure TTestTextStreamWriter.writing_nothing_leaves_stream_unchanged;
begin
  Assert.AreEqual('', Stream1.DataString, '(Empty stream)');
  Assert.AreEqual(PriorContent, Stream2.DataString, '(Prior content stream)');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTextStreamReader);
  TDUnitX.RegisterTestFixture(TTestTextStreamWriter);
end.

