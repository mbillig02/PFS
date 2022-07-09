{$I ..\..\JEDI.INC}  { Standard defines } // https://github.com/project-jedi/jedi/blob/master/jedi.inc
unit UtlUnit;

interface

uses Classes, Windows, Controls;

type
  {
   Value              Meaning
   DRIVE_UNKNOWN      The drive type cannot be determined.
   DRIVE_NO_ROOT_DIR  The root path is invalid. For example, no volume is mounted at the path.
   DRIVE_REMOVABLE    The disk can be removed from the drive.
   DRIVE_FIXED        The disk cannot be removed from the drive.
   DRIVE_REMOTE       The drive is a remote (network) drive.
   DRIVE_CDROM        The drive is a CD-ROM drive.
   DRIVE_RAMDISK      The drive is a RAM disk.
  }
  TDriveType = (dtUnknown, dtNoDrive, dtFloppy, dtFixed, dtNetwork, dtCDROM, dtRAM);

  function GetCompilerName(CompilerVer: Extended): String;
  function GetTempDir: String;
  function GetVersionInfoStr(const FileName: String): String;
  function LPad(InString: String; Noc: Byte; Value: Char): String;
  procedure Parse(const StrToParse: String; const Delimiter: Char; var Words: TStringList);
  function RStr(InString: String; Noc: Byte): String;
  function StripDelimiterFromEnd(const StrToStrip: String; const Delimiter: Char): String;

implementation

uses SysUtils;

function GetCompilerName(CompilerVer: Extended): String;
begin
  case Trunc(CompilerVer) of
     8: Result := 'Delphi 1';
     9: Result := 'Delphi 2';
    10: Result := 'Delphi 3';
    12: Result := 'Delphi 4';
    13: Result := 'Delphi 5';
    14: Result := 'Delphi 6';
    15: Result := 'Delphi 7';
    16: Result := 'Delphi 8 .NET';
    17: Result := 'Delphi 2005';
    18: if Frac(CompilerVer) = 0 then Result := 'Delphi 2006' else Result := 'Delphi 2007';
    19: Result := 'Delphi 2007 .NET';
    20: Result := 'Delphi 2009';
    21: Result := 'Delphi 2010';
    22: Result := 'Delphi XE';
    23: Result := 'Delphi XE2';
    24: Result := 'Delphi XE3';
    25: Result := 'Delphi XE4';
    26: Result := 'Delphi XE5';
    27: Result := 'Delphi XE6';
    28: Result := 'Delphi XE7';
    29: Result := 'Delphi XE8';
    30: Result := 'Delphi 10 Seattle';
    31: Result := 'Delphi 10.1 Berlin';
    32: Result := 'Delphi 10.2 Tokyo';
    33: Result := 'Delphi 10.3 Rio';
    34: Result := 'Delphi 10.4 Sydney';
    35: Result := 'Delphi 11 Alexandria';
  else Result := '';
  end;
end;

function GetTempDir: String;
var
  Len: Integer;
  S: String;
begin
  Result := '';
  Len := Windows.GetTempPath(0, nil);
  if Len > 0 then
  begin
    SetLength(S, Len);
    Len := Windows.GetTempPath(Len, PChar(S));
    SetLength(S, Len);
    Result := S;
  end;
end;

function GetVersionInfo(const FileName: String; var V1, V2, V3, V4: Word): Boolean;
var
  VerInfoSize, VerValueSize, Dummy: DWord;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
begin
  Result := false;
  V1 := 0; V2 := 0; V3 := 0; V4 := 0;
  try
    VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
    GetMem(VerInfo, VerInfoSize);
    try
      FillChar(VerInfo^, VerInfoSize, 0);
      GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, VerInfo);
      if VerInfo <> nil then
      begin
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        with VerValue^ do
        begin
          V1 := dwFileVersionMS shr 16;
          V2 := dwFileVersionMS and $FFFF;
          V3 := dwFileVersionLS shr 16;
          V4 := dwFileVersionLS and $FFFF;
        end;
        Result := true;
      end;
    finally
      FreeMem(VerInfo, VerInfoSize);
    end;
  except
    Result := false;
  end;
end;

function GetVersionInfoStr(const FileName: String): String;
var
  V1, V2, V3, V4: Word;
begin
  Result := '';
  if GetVersionInfo(FileName, V1, V2, V3, V4) then
    Result := IntToStr(V1) + '.' + IntToStr(V2) + '.' + IntToStr(V3) + '.' + IntToStr(V4);
end;

function LPad(InString: String; Noc: Byte; Value: Char): String;
var
  Pad: String;
  i: Integer;
begin
  Pad := '';
  for i := 1 to Noc do Pad := Pad + Value;
  Result := RStr(String(Pad) + InString, Noc);
end;

procedure Parse(const StrToParse: String; const Delimiter: Char; var Words: TStringList);
var
  TmpInStr: String;
begin
  TmpInStr := StripDelimiterFromEnd(StrToParse, Delimiter);
  Words.Clear;
  if Length(TmpInStr) > 0 then
  begin
    while Pos(Delimiter,TmpInStr) > 0 do
    begin
      Words.Append(Copy(TmpInStr, 1, Pos(Delimiter, TmpInStr)-1));
      Delete(TmpInStr, 1, Pos(Delimiter, TmpInStr));
    end;
    Words.Append(TmpInStr);
  end;
end;

function RStr(InString: String; Noc: Byte): String;
begin
  Result := Copy(InString, Length(InString)-(Noc-1), Noc);
end;

function StripDelimiterFromEnd(const StrToStrip: String; const Delimiter: Char): String;
var
  TmpInStr: String;
begin
  TmpInStr := StrToStrip;
  if Length(TmpInStr) > 0 then while Copy(TmpInStr, 1, 1) = Delimiter do Delete(TmpInStr, 1, 1);
  if Length(TmpInStr) > 0 then while Copy(TmpInStr, Length(TmpInStr), 1) = Delimiter do Delete(TmpInStr, Length(TmpInStr), 1);
  Result := TmpInStr;
end;

end.

