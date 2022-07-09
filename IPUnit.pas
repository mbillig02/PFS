unit IPUnit;

interface

  function MaskToBits(MaskStr: String): Byte;
  procedure SplitIpAddressSubnet(IPAddressStrIn: String; var IPAddressStr: String; var SubnetBitsStr: String);
  function IsParentIP(ChildIPStr, ParentIPStr: String): Boolean;

implementation

uses
  PerlRegEx, SysUtils;

{========================================================================}
function IPAddressToString(const IPAddress: Cardinal): String;
begin
  Result := IntToStr((IPAddress shr (8*3)) and $FF)+'.'+
            IntToStr((IPAddress shr (8*2)) and $FF)+'.'+
            IntToStr((IPAddress shr (8*1)) and $FF)+'.'+
            IntToStr((IPAddress shr (8*0)) and $FF);
end;
{========================================================================}
function BitsToMask(Bits: Byte): String;
  {Convert bits to mask "24 to 255.255.255.0"}
begin
  Result := IPAddressToString(Trunc($FFFFFFFF shl (32-Bits)));
end;
{========================================================================}
function MaskToBits(MaskStr: String): Byte;
  {Convert mask to bits "255.255.255.0 to 24"}
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to 32 do if BitsToMask(i) = MaskStr then Result := i;
end;
{========================================================================}
procedure SplitIpAddressSubnet(IPAddressStrIn: String; var IPAddressStr: String; var SubnetBitsStr: String);
var
  RegEx: TPerlRegEx;
begin
  Regex := TPerlRegEx.Create;
  Regex.Options := [];
  Regex.Subject := AnsiToUTF8(IPAddressStrIn);
  RegEx.RegEx := '((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])/(3[0-2]|2[0-9]|1[0-9]|[0-9]))';
  if RegEx.Match and (RegEx.MatchedLength = Length(RegEx.Subject)) then
  begin
    IPAddressStr := Copy(IPAddressStrIn, 1, Pos('/', IPAddressStrIn) - 1);
    SubnetBitsStr := Copy(IPAddressStrIn, Pos('/', IPAddressStrIn) + 1, 2);
  end;
  RegEx.RegEx := '((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])) ' + '((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]))';
  if RegEx.Match and (RegEx.MatchedLength = Length(RegEx.Subject)) then
  begin
    IPAddressStr := Copy(IPAddressStrIn, 1, Pos(' ', IPAddressStrIn) - 1);
    SubnetBitsStr := Copy(IPAddressStrIn, Pos(' ', IPAddressStrIn) + 1);
  end;
  RegEx.RegEx := '((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]))';
  if RegEx.Match and (RegEx.MatchedLength = Length(RegEx.Subject)) then
  begin
    IPAddressStr := IPAddressStrIn;
    SubnetBitsStr := '';
  end;
  RegEx.Free;
end;
{========================================================================}
function StringToIPAddress(const IPAddress: String): Cardinal;
var
  Str: String;
  Answer: Cardinal;
  i, Pz: Integer;
  Tmp: Integer;
begin
  Str := IPAddress;
  Answer := 0;
  try
    for i := 0 to 3 do
    begin
      Pz := Pos('.',Str);
      if Pz <= 0 then Pz := Length(Str)+1;
      if PZ = 1 then Raise EConvertError.Create(IPAddress+' is not a valid IP address');
      Tmp := StrToInt(Copy(Str,1,Pz-1));
      Delete(Str,1,Pz);
      if (Tmp < 0) or (Tmp > 255) then Raise EConvertError.Create(IPAddress+' is not a valid IP address');
      Answer := (Answer shl 8) + Byte(Tmp);
    end;
  except
    Raise EConvertError.Create(IPAddress+ ' is not a valid IP address' );
  end;
  StringToIPAddress := Answer;
end;
{========================================================================}
function IsParentIP(ChildIPStr, ParentIPStr: String): Boolean;
var
  SubNetBitsStrC, IPAddressStrC: String;
  SubNetBitsStrP, IPAddressStrP: String;
  ParentCard, ChildCard: Cardinal;
begin
  SplitIPAddressSubnet(ChildIPStr, IPAddressStrC, SubNetBitsStrC);
  SplitIPAddressSubnet(ParentIPStr, IPAddressStrP, SubNetBitsStrP);
  ParentCard := StringToIPAddress(IPAddressStrP);
  ChildCard := StringToIPAddress(IPAddressStrC);
  Result := (ParentCard = (ChildCard and Trunc(4294967295 shl (32-StrToInt(SubNetBitsStrP))))) and
            (StrToInt(SubNetBitsStrP) < StrToInt(SubNetBitsStrC));
end;
{========================================================================}
function GetParentIP(ChildIPStr: String): String;
var
  SubNetBitsStr, IPAddressStr: String;
  IPAddressCardinal, TmpCard: Cardinal;
begin
  SplitIPAddressSubnet(ChildIPStr, IPAddressStr, SubNetBitsStr);
  IPAddressCardinal := StringToIPAddress(IPAddressStr);
  TmpCard := IPAddressCardinal and Trunc(4294967295 shl (32-(StrToInt(SubNetBitsStr)-1)));
  Result := IPAddressToString(TmpCard)+'/'+IntToStr(StrToInt(SubNetBitsStr)-1);
end;
{========================================================================}
procedure GetChildIP(ParentIPStr: String; var Child1, Child2: String);
var
  SubNetBitsStr, IPAddressStr: String;
  TmpCard: Cardinal;
begin
  SplitIPAddressSubnet(ParentIPStr, IPAddressStr, SubNetBitsStr);
  Child1 := IPAddressStr + '/' + IntToStr(StrToInt(SubNetBitsStr)+1);
  TmpCard := StringToIPAddress(IPAddressStr)-Trunc(4294967295 shl (32-(StrToInt(SubNetBitsStr)+1)));
  Child2 := IPAddressToString(TmpCard) + '/' + IntToStr(StrToInt(SubNetBitsStr)+1);
end;
{========================================================================}
end.
