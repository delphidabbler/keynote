program KeyNoteTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  Music.Notes in '..\src\Music.Notes.pas',
  Test.Music.Notes in 'Test.Music.Notes.pas',
  Core.Enumerators in '..\src\Core.Enumerators.pas',
  Test.Core.Enumerators in 'Test.Core.Enumerators.pas',
  Core.StringUtils in '..\src\Core.StringUtils.pas',
  Test.Core.StringUtils in 'Test.Core.StringUtils.pas',
  Music.Scales in '..\src\Music.Scales.pas',
  Test.Music.Scales in 'Test.Music.Scales.pas',
  Data.Scales in 'Data.Scales.pas',
  Music.CircleOf5ths in '..\src\Music.CircleOf5ths.pas',
  Test.Music.CircleOf5ths in 'Test.Music.CircleOf5ths.pas',
  Music.Keys in '..\src\Music.Keys.pas',
  Test.Music.Keys in 'Test.Music.Keys.pas',
  Test.Database.Scales in 'Test.Database.Scales.pas',
  Database.Scales in '..\src\Database.Scales.pas',
  IO.TextStreams in '..\src\IO.TextStreams.pas',
  Test.IO.TextStreams in 'Test.IO.TextStreams.pas';

{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  ReportMemoryLeaksOnShutdown := True;
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := True;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
