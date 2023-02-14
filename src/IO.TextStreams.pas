unit IO.TextStreams;

interface

uses
  System.SysUtils,
  System.Classes;

type

  ///  <summary>Base class for all text stream readers and writers.</summary>
  ///  <remarks>Provides functionality common to all reader and writer classes.
  ///  </remarks>
  TAbstractTextStream = class abstract
  strict private
    var
      fStream: TStream;
      fEncoding: TEncoding;
      fOwnsStream: Boolean;
    procedure SetEncoding(const AEncoding: TEncoding);
    procedure FreeEncoding;
  strict protected
    ///  <summary>Access to the stream being processed.</summary>
    property Stream: TStream read fStream;
  public
    const
      LF = #10;
      CR = #13;
      CRLF = CR + LF;
  public
    ///  <summary>Creates object to process <c>AStream</c>. If, and only if,
    ///  <c>AOwnsStream</c> is True then <c>AStream</c> is freed when this
    ///  object is destroyed.</summary>
    constructor Create(const AStream: TStream;
      const AOwnsStream: Boolean = True);
    ///  <summary>Destroys object, and stream if owened.</summary>
    destructor Destroy; override;
    ///  <summary>Text encoding to be used when reading/writing text from/to the
    ///  stream. Defaults to UTF-8.</summary>
    property Encoding: TEncoding
      read fEncoding write SetEncoding;
  end;

  ///  <summary>Reads lines of text from a given stream. Text can be
  ///  pre-processed by providing callbacks.</summary>
  ///  <remarks>Lines of text can be separated by any or all of LF, CRLF or CR.
  ///  </remarks>
  TTextStreamReader = class(TAbstractTextStream)
  public
    type
      ///  <summary>Type of callback used to optionally modify text lines before
      ///  inclusion in output of <c>ReadLines</c> method.</summary>
      ///  <param name="ALine">Line to be modified.</param>
      ///  <returns><c>string</c>. Line to be included in output.</returns>
      ///  <remarks>Return <c>ALine</c> if no modification is required.
      ///  </remarks>
      TTextLineModifyCallback = reference to function(const ALine: string):
        string;
      ///  <summary>Type of callback used to determine whether a text line
      ///  should be included in output  of <c>ReadLines</c> method.</summary>
      ///  <param name="ALine">Line for which decision is required.</param>
      ///  <returns><c>Boolean</c>. False to include line in output or True to
      ///  ignore (skip) it.</returns>
      TTextLineSkipCallback = reference to function(const ALine: string):
        Boolean;
  strict private
    var
      fLineModifyCallback: TTextLineModifyCallback;
      fSkipLineCallback: TTextLineSkipCallback;
    procedure SetLineModifyCallback(const ACallback: TTextLineModifyCallback);
    procedure SetSkipLineCallback(const ACallback: TTextLineSkipCallback);
  public
    ///  <summary>Creates object to read text from <c>AStream</c>. If, and only
    ///  if, <c>AOwnsStream</c> is True then <c>AStream</c> is freed when this
    ///  object is destroyed.</summary>
    constructor Create(const AStream: TStream;
      const AOwnsStream: Boolean = True);
    ///  <summary>Text encoding to be used when reading stream. Default is
    ///  UTF-8.</summary>
    property Encoding;
    ///  <summary>Callback called for each line used to enable user to modify
    ///  the line. User returns require line from the callback function. Default
    ///  is to leave the line unchanged.</summary>
    property ModifyLineCallback: TTextLineModifyCallback
      read fLineModifyCallback write SetLineModifyCallback;
    ///  <summary>Callback called for each line, after it has been processed by
    ///  <c>ModifyLineCallback</c>, to enable user to determine whether the line
    ///  is included in output or not. User must return False to keep the line
    ///  or True to skip it. Default is not to skip the line.</summary>
    property SkipLineCallback: TTextLineSkipCallback
      read fSkipLineCallback write SetSkipLineCallback;
    ///  <summary>Reads lines of text from the stream and returns an array with
    ///  an element for each line. The text is read using the encoding specified
    ///  by the <c>Encoding</c> property. Lines may have been modified by the
    ///  <c>ModifyLineCallback</c>. Lines skipped by the <c>SkipLineCallback</c>
    ///  are excluded from the result.</summary>
    function ReadLines: TArray<string>;
  end;

  ///  <summary>Class that writes text to a stream in a given encoding with
  ///  lines delimited by a specified end of line character or string.</summary>
  ///  <remarks>If any string contains LF, CR or CRLF pairs then they are
  ///  assumed to be end of line delimiters and are replaced by the specified
  ///  end of line string.</remarks>
  TTextStreamWriter = class(TAbstractTextStream)
  strict private
    var
      fEOLString: string;
    ///  Converts CR, LF and CRLF to line endings per EOLString.
    function NormaliseLineEndings(const AText: string): string;
    ///  Writes raw bytes to the stream
    procedure WriteBytes(const Bytes: TBytes);
  public
    ///  <summary>Creates object to write text to <c>AStream</c>. If, and only
    ///  if, <c>AOwnsStream</c> is True then <c>AStream</c> is freed when this
    ///  object is destroyed.</summary>
    constructor Create(const AStream: TStream;
      const AOwnsStream: Boolean = True);
    ///  <summary>Text encoding to be used when writing stream. Default is
    ///  UTF-8.</summary>
    property Encoding;
    ///  <summary>String used to signify end of lines in the output.</summary>
    ///  <remarks>This string is appended to lines written by <c>WriteLn</c> and
    ///  is also used to replace any CR, LF or CRLF pairs in any string being
    ///  written.</remarks>
    property EOLString: string read fEOLString write fEOLString;
    ///  <summary>Writes the text <c>AText</c> to the stream in the encoding
    ///  specified by the <c>Encoding</c> property. The default is the system
    ///  default line ending as specified by the RTL's <c>sLineBreak</c>
    ///  constant.</summary>
    ///  <remarks>Any LF, CR or CRLF pairs contained in <c>AText</c> are
    ///  replaced by <c>EOLString</c> before writing.</summary>
    procedure Write(const AText: string);
    ///  <summary>Writes the text <c>AText</c> to the stream in the encoding
    ///  specified by the <c>Encoding</c> property, followed by the end of line
    ///  character string specified by <c>EOLString</c>.</summary>
    ///  <remarks>Any LF, CR or CRLF pairs contained in <c>AText</c> are
    ///  replaced by <c>EOLString</c> before writing.</summary>
    procedure WriteLn(const AText: string);
  end;


implementation

uses
  System.Generics.Collections;

{ TAbstractTextStream }

constructor TAbstractTextStream.Create(const AStream: TStream;
  const AOwnsStream: Boolean);
begin
  Assert(Assigned(AStream));
  inherited Create;
  fStream := AStream;
  fOwnsStream := AOwnsStream;
  SetEncoding(nil);
end;

destructor TAbstractTextStream.Destroy;
begin
  FreeEncoding;
  if fOwnsStream then
    fStream.Free;
  inherited;
end;

procedure TAbstractTextStream.FreeEncoding;
begin
  if Assigned(fEncoding) and not TEncoding.IsStandardEncoding(fEncoding) then
    fEncoding.Free;
end;

procedure TAbstractTextStream.SetEncoding(const AEncoding: TEncoding);
begin
  FreeEncoding;
  if Assigned(AEncoding) then
    fEncoding := AEncoding
  else
    fEncoding := TEncoding.UTF8;
end;

{ TTextStreamReader }

constructor TTextStreamReader.Create(const AStream: TStream;
  const AOwnsStream: Boolean);
begin
  inherited Create(AStream, AOwnsStream);
  // set default callbacks
  SetLineModifyCallback(nil);
  SetSkipLineCallback(nil);
end;

function TTextStreamReader.ReadLines: TArray<string>;
begin
  var Bytes: TBytes;
  // Convoluted way of reading bytes from stream. For some reason using
  // TStream.Read(TBytes,Count) overload fails to read anything into Bytes
  var BS := TBytesStream.Create;
  try
    var StmSize := Stream.Size - Stream.Position;
    BS.CopyFrom(Stream, StmSize);
    // TBytesStream.Bytes gets zero padded to Capacity, so we have to truncate
    // Bytes to size.
    Bytes := BS.Bytes;
    SetLength(Bytes, StmSize);
  finally
    BS.Free;
  end;
  // Get all text, standardise CRLF & CR line endings as LF and split into lines
  var Lines := Encoding.GetString(Bytes)
    .Replace(CRLF, LF)
    .Replace(CR, LF)
    .Split([LF]);
  var ProcessedLines := TList<string>.Create;
  try
    for var Line in Lines do
    begin
      var ModifiedLine := fLineModifyCallback(Line);
      if not fSkipLineCallback(ModifiedLine) then
        ProcessedLines.Add(ModifiedLine);
    end;
    Result := ProcessedLines.ToArray;
  finally
    ProcessedLines.Free;
  end;
end;

procedure TTextStreamReader.SetLineModifyCallback(
  const ACallback: TTextLineModifyCallback);
begin
  if Assigned(ACallback) then
    fLineModifyCallback := ACallback
  else
    fLineModifyCallback := function(const ALine: string): string
      begin
        Result := ALine;
      end;
end;

procedure TTextStreamReader.SetSkipLineCallback(
  const ACallback: TTextLineSkipCallback);
begin
  if Assigned(ACallback) then
    fSkipLineCallback := ACallback
  else
    fSkipLineCallback := function(const ALine: string): Boolean
      begin
        Result := False;
      end;
end;

{ TTextStreamWriter }

constructor TTextStreamWriter.Create(const AStream: TStream;
  const AOwnsStream: Boolean);
begin
  inherited Create(AStream, AOwnsStream);
  fEOLString := sLineBreak;
end;

function TTextStreamWriter.NormaliseLineEndings(const AText: string): string;
begin
  Result := AText.Replace(CRLF, LF).Replace(CR, LF);
  if fEOLString <> LF then
    Result := Result.Replace(LF, fEOLString);
end;

procedure TTextStreamWriter.Write(const AText: string);
begin
  WriteBytes(Encoding.GetBytes(NormaliseLineEndings(AText)));
end;

procedure TTextStreamWriter.WriteBytes(const Bytes: TBytes);
begin
  Stream.Write(Bytes, Length(Bytes));
end;

procedure TTextStreamWriter.WriteLn(const AText: string);
begin
  Write(AText);
  if fEOLString <> '' then
    WriteBytes(Encoding.GetBytes(fEOLString));
end;

end.
