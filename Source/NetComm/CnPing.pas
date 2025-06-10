{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPing;
{* |<PRE>
================================================================================
* ������ƣ�����ͨѶ�����
* ��Ԫ���ƣ�Ping ͨѶ��Ԫ
* ��Ԫ���ߣ�������Sesame (sesamehch@163.com)
* ��    ע�������� TCnPing
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2008.04.04 V1.0
*                ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  {$IFDEF MSWINDOWS} Windows, WinSock, {$ELSE}
  Posix.ArpaInet, Posix.NetinetIn, Posix.SysSocket, Posix.SysTime, {$ENDIF}
  SysUtils, Classes, Controls, StdCtrls,
  CnClasses, CnConsts, CnNetConsts, CnNetwork, CnSocket;

type
  PCnIPOptionInformation = ^TCnIPOptionInformation;
  TCnIPOptionInformation = packed record
    TTL: Byte;              // Time To Live (used for traceroute)
    TOS: Byte;              // Type Of Service (usually 0)
    Flags: Byte;            // IP header flags (usually 0)
    OptionsSize: Byte;      // Size of options data (usually 0, max 40)
    OptionsData: PAnsiChar; // Options data buffer
  end;

  PCnIcmpEchoReply = ^TCnIcmpEchoReply;
  TCnIcmpEchoReply = packed record
    Address: Cardinal; // replying address
    Status: Cardinal;  // IP status value (see below)
    RTT: Cardinal;     // Round Trip Time in milliseconds
    DataSize: Word;    // reply data size
    Reserved: Word;
    Data: Pointer;     // pointer to reply data buffer
    Options: TCnIPOptionInformation; // reply options
  end;

  TCnIpInfo = record
    Address: Int64;
    IP: string;
    Host: string;
  end;

  TOnPingReceive = procedure(Sender: TComponent; IpAddr, HostName: string;
    TTL, TOS: Byte) of object;

  TOnPingError = procedure(Sender: TComponent; IpAddr, HostName: string;
    TTL, TOS: Byte; ErrorMsg: string) of object;

//==============================================================================
// Ping ͨѶ��
//==============================================================================

  { TCnPing }

{$IFDEF SUPPORT_32_AND_64}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
{$ENDIF}
  TCnPing = class(TCnComponent)
  {* ͨ������ ICMP.DLL ���еĺ�����ʵ�� Ping ���ܡ�}
  private
    FRemoteHost: string;
    FRemoteIP: string;
    FIPAddress: Int64;
    FTTL: Byte;
    FTimeOut: Cardinal;
    FPingCount: Integer;
    FDelay: Integer;
    FOnError: TOnPingError;
    FOnReceived: TOnPingReceive;
    FDataString: string;
{$IFDEF MSWINDOWS}
    FHICMP: THandle;
    FWSAData: TWSAData;
{$ENDIF}
    FIP: TCnIpInfo;

    procedure SetPingCount(const Value: Integer);
    procedure SetRemoteHost(const Value: string);
    procedure SetTimeOut(const Value: Cardinal);
    procedure SetTTL(const Value: Byte);
    procedure SetDataString(const Value: string);
    procedure SetRemoteIP(const Value: string);
    function PingIP_Host(const aIP: TCnIpInfo; const Data; Count: Cardinal;
      var aReply: string): Integer;
    {* ���趨������ Data (�����ͻ�����) Ping һ�β����ؽ����Count ��ʾ���ݳ���
      ����ֵΪ SCN_ICMP_ERROR_* ϵ�г��� }
    function GetReplyString(aResult: Integer; aIP: TCnIpInfo;
      pIPE: PCnIcmpEchoReply): string;
    {* ���ؽ���ַ�����}
    function GetDataString: string;
    function GetIPByName(const aName: string; var aIP: string): Boolean;
    {* ͨ���������ƻ�ȡ IP ��ַ}
    function SetIP(aIPAddr, aHost: string; var aIP: TCnIpInfo): Boolean;
    {* ͨ���������ƻ� IP ��ַ������� IP ��Ϣ}
  protected
    procedure GetComponentInfo(var AName, Author, Email, Comment: string); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Ping(var aReply: string): Boolean;
    {* ����ѭ�� Ping��ѭ�������� PingCount ������ָ����}
    function PingOnce(var aReply: string): Boolean; overload;
    {* ���趨������ Ping һ�β����ؽ����}
    function PingOnce(const aIP: string; var aReply: string): Boolean; overload;
    {* ��ָ�� IP ����һ�� Ping �����ؽ����}
    function PingFromBuffer(var Buffer; Count: Integer; var aReply: string):
      Boolean;
    {* �Բ��� Buffer ������ Ping һ�β���ȡ���ؽ����}
  published
    property RemoteIP: string read FRemoteIP write SetRemoteIP;
    {* Ҫ Ping ��Ŀ��������ַ��ֻ֧�� IP}
    property RemoteHost: string read FRemoteHost write SetRemoteHost;
    {* Ҫ Ping ��Ŀ����������������������ʱ�Ḳ�� RemoteIP ������}
    property PingCount: Integer read FPingCount write SetPingCount default 4;
    {* ���� Ping ����ʱ���ж��ٴ����ݷ��ͣ�Ĭ���� 4 �Ρ�}
    property Delay: Integer read FDelay write FDelay default 0;
    {* �������� Ping ���ʱ��������λ���룬Ĭ�� 0 Ҳ���ǲ���ʱ}
    property TTL: Byte read FTTL write SetTTL;
    {* ���õ� TTL ֵ��Time to Live}
    property TimeOut: Cardinal read FTimeOut write SetTimeOut;
    {* ���õĳ�ʱֵ}
    property DataString: string read GetDataString write SetDataString;
    {* �����͵����ݣ����ַ�����ʽ��ʾ��Ĭ��Ϊ"CnPack Ping"��}
    property OnReceived: TOnPingReceive read FOnReceived write FOnReceived;
    {* Ping һ�γɹ�ʱ�����������������¼�}
    property OnError: TOnPingError read FOnError write FOnError;
    {* Ping ����ʱ���ص����ݺ���Ϣ������Ŀ��δ֪�����ɴ��ʱ�ȡ�}
  end;

implementation

{$R-}

uses
  CnIP;

const
  SCnPingData = 'CnPack Ping.';

  SCN_ICMP_ERROR_OK         = 0;
  SCN_ICMP_ERROR_BAD_ADDR   = -1;     // ��ַ����
  SCN_ICMP_ERROR_TIME_OUT   = -2;     // ��ʱ
  SCN_ICMP_ERROR_GENERAL    = -3;     // һ�����
  SCN_ICMP_ERROR_SOCKET     = -4;     // Socket ����
  SCN_ICMP_ERROR_UNKNOWN    = -100;

{$IFDEF MSWINDOWS}
  ICMPDLL = 'icmp.dll';

type

//==============================================================================
// ��������  ��icmp.dll����ĺ���
//==============================================================================

  TIcmpCreateFile = function (): THandle; stdcall;

  TIcmpCloseHandle = function (IcmpHandle: THandle): Boolean; stdcall;

  TIcmpSendEcho = function (IcmpHandle: THandle;
                            DestAddress: DWORD;
                            RequestData: Pointer;
                            RequestSize: Word;
                            RequestOptions: PCnIPOptionInformation;
                            ReplyBuffer: Pointer;
                            ReplySize: DWORD;
                            TimeOut: DWORD): DWORD; stdcall;

var
  IcmpCreateFile: TIcmpCreateFile = nil;
  IcmpCloseHandle: TIcmpCloseHandle = nil;
  IcmpSendEcho: TIcmpSendEcho = nil;

  IcmpDllHandle: THandle = 0;

procedure InitIcmpFunctions;
begin
  IcmpDllHandle := LoadLibrary(ICMPDLL);
  if IcmpDllHandle <> 0 then
  begin
    @IcmpCreateFile := GetProcAddress(IcmpDllHandle, 'IcmpCreateFile');
    @IcmpCloseHandle := GetProcAddress(IcmpDllHandle, 'IcmpCloseHandle');
    @IcmpSendEcho := GetProcAddress(IcmpDllHandle, 'IcmpSendEcho');
  end;
end;

procedure FreeIcmpFunctions;
begin
  if IcmpDllHandle <> 0 then
    FreeLibrary(IcmpDllHandle);
end;

{$ENDIF}

//==============================================================================
// Ping ͨѶ��
//==============================================================================

{ TCnPing }

constructor TCnPing.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF MSWINDOWS}
  if IcmpDllHandle = 0 then
    InitIcmpFunctions;
{$ENDIF}

  FRemoteIP := '127.0.0.1';
  FTTL := 64;
  FPingCount := 4;
  FDelay := 0;
  FTimeOut := 10;
  FDataString := SCnPingData;

{$IFDEF MSWINDOWS}
  FHICMP := IcmpCreateFile(); // ȡ�� DLL ���
  if FHICMP = INVALID_HANDLE_VALUE then
    raise Exception.Create(SICMPRunError);
{$ENDIF}
end;

destructor TCnPing.Destroy;
begin
{$IFDEF MSWINDOWS}
  if FHICMP <> INVALID_HANDLE_VALUE then
    IcmpCloseHandle(FHICMP);
{$ENDIF}
  inherited Destroy;
end;

procedure TCnPing.GetComponentInfo(var AName, Author, Email,
  Comment: string);
begin
  AName := SCnPingName;
  Author := SCnPack_Sesame;
  Email := SCnPack_SesameEmail;
  Comment := SCnPingComment;
end;

procedure TCnPing.SetPingCount(const Value: Integer);
begin
  if Value > 0 then
    FPingCount := Value;
end;

procedure TCnPing.SetRemoteIP(const Value: string);
begin
  if FRemoteIP <> Value then
  begin
    FRemoteIP := Value;
    if SetIP(FRemoteIP, '', FIP) then
    begin
      FRemoteHost := FIP.Host;
      FIPAddress := FIP.Address;
    end;
  end;
end;

procedure TCnPing.SetRemoteHost(const Value: string);
begin
  if FRemoteHost <> Value then
  begin
    // RemoteHost ���ĵĻ���RemoteIP �Զ����
    FRemoteHost := Value;
    if SetIP('', FRemoteHost, FIP) then
    begin
      FRemoteIP := FIP.IP;
      FIPAddress := FIP.Address;
    end;
  end;
end;

procedure TCnPing.SetTimeOut(const Value: Cardinal);
begin
  FTimeOut := Value;
end;

procedure TCnPing.SetTTL(const Value: Byte);
begin
  FTTL := Value;
end;

procedure TCnPing.SetDataString(const Value: string);
begin
  FDataString := Value;
end;

function TCnPing.GetDataString: string;
begin
  if FDataString = '' then
    FDataString := SCnPingData;
  Result := FDataString;
end;

function TCnPing.Ping(var aReply: string): Boolean;
var
  iCount, iResult: Integer;
  sReply: string;
begin
  aReply := '';
  iResult := 0;
  try
    SetIP(RemoteIP, RemoteHost, FIP);
    for iCount := 1 to PingCount do
    begin
      iResult := PingIP_Host(FIP, Pointer(FDataString)^, Length(DataString) * SizeOf(Char),
        sReply);
      aReply := aReply + #13#10 + sReply;
      if iResult < 0 then
        Break;

      if FDelay > 0 then
        Sleep(FDelay);
    end;
  finally
    Result := iResult >= 0;
  end;
end;

function TCnPing.PingOnce(var aReply: string): Boolean;
begin
  SetIP(RemoteIP, RemoteHost, FIP);
  Result := PingIP_Host(FIP, Pointer(FDataString)^, Length(DataString) * SizeOf(Char),
    aReply) >= 0;
end;

function TCnPing.PingOnce(const aIP: string; var aReply: string): Boolean;
begin
  SetIP(aIP, aIP, FIP);
  Result := PingIP_Host(FIP, Pointer(FDataString)^, Length(DataString) * SizeOf(Char),
    aReply) >= 0;
end;

function TCnPing.PingFromBuffer(var Buffer; Count: Integer;
  var aReply: string): Boolean;
begin
  SetIP(RemoteIP, RemoteHost, FIP);
  Result := PingIP_Host(FIP, Buffer, Count, aReply) >= 0;
end;

function TCnPing.PingIP_Host(const aIP: TCnIpInfo; const Data;
  Count: Cardinal; var aReply: string): Integer;
var
  pReqData: PAnsiChar;
{$IFDEF MSWINDOWS}
  pRevData: PAnsiChar;
  IPOpt: TCnIPOptionInformation; // �������ݽṹ
  pCIER: PCnIcmpEchoReply;
{$ELSE}
  P: PAnsiChar;
  Sock: TSocket;
  DestAddr: TSockAddr;
  HIp: PCnIPHeader;
  HIcmp: PCnICMPHeader;
  tv: timeval;
  Buf: array[0..1023] of Byte;
  R, FromLen: Integer;
  ID: Word;
{$ENDIF}
begin
  Result := SCN_ICMP_ERROR_UNKNOWN;

  if Count <= 0 then
  begin
    aReply := GetReplyString(Result, aIP, nil);
    Exit;
  end;

  if aIP.Address = INADDR_NONE then
  begin
    Result := SCN_ICMP_ERROR_BAD_ADDR;
    aReply := GetReplyString(Result, aIP, nil);
    Exit;
  end;

{$IFDEF MSWINDOWS}
  pReqData := nil;
  GetMem(pCIER, SizeOf(TCnICMPEchoReply) + Count);
  GetMem(pRevData, Count);
  try
    FillChar(pCIER^, SizeOf(TCnICMPEchoReply) + Count, 0); // ��ʼ���������ݽṹ
    pCIER^.Data := pRevData;
    GetMem(pReqData, Count);
    Move(Data, pReqData^, Count); // ׼�����͵�����
    FillChar(IPOpt, Sizeof(IPOpt), 0); // ��ʼ���������ݽṹ
    IPOpt.TTL := FTTL;

    try // Ping��ʼ
      if WSAStartup(MAKEWORD(2, 0), FWSAData) <> 0 then
        raise Exception.Create(SInitFailed);

      if IcmpSendEcho(FHICMP, // dll handle
        aIP.Address, // target
        pReqData,    // data
        Count,       // data length
        @IPOpt,      // addree of ping option
        pCIER,
        SizeOf(TCnICMPEchoReply) + Count, // pack size
        FTimeOut     // timeout value
        ) <> 0 then
      begin
        Result := SCN_ICMP_ERROR_OK; // Ping ��������
        if Assigned(FOnReceived) then
          FOnReceived(Self, aIP.IP, aIP.Host, IPOpt.TTL, IPOpt.TOS);
      end
      else
      begin
        Result := SCN_ICMP_ERROR_TIME_OUT; // û����Ӧ
        if Assigned(FOnError) then
          FOnError(Self, aIP.IP, aIP.Host, IPOpt.TTL, IPOpt.TOS, SNoResponse);
      end;
    except
      on E: Exception do
      begin
        Result := SCN_ICMP_ERROR_GENERAL; // ��������
        if Assigned(FOnError) then
          FOnError(Self, aIP.IP, aIP.Host, IPOpt.TTL, IPOpt.TOS, E.Message);
      end;
    end;
  finally
    WSACleanUP;

    aReply := GetReplyString(Result, aIP, pCIER);
    if pRevData <> nil then
    begin
      FreeMem(pRevData); // �ͷ��ڴ�
      pCIER.Data := nil;
    end;
    if pReqData <> nil then
      FreeMem(pReqData); //�ͷ��ڴ�
    FreeMem(pCIER);      //�ͷ��ڴ�
  end;
{$ELSE}
  // POSIX sendto Ping and recvfrom
  Sock := CnNewSocket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
  if Sock = INVALID_SOCKET then
  begin
    Result := SCN_ICMP_ERROR_SOCKET;
    aReply := GetReplyString(Result, aIP, nil);
    Exit;
  end;

  tv.tv_sec := 3;
  tv.tv_usec := 0;
  CnSetSockOpt(Sock, SOL_SOCKET, SO_RCVTIMEO, @tv, SizeOf(tv));

  pReqData := nil;

  try
    GetMem(pReqData, SizeOf(TCnICMPHeader) + Count);

    HIcmp := PCnICMPHeader(pReqData);
    P := pReqData;
    Inc(P, SizeOf(TCnICMPHeader));
    Move(Data, P^, Count); // ׼�����͵�����

    CnSetICMPType(HIcmp, CN_ICMP_TYPE_ECHO);
    CnSetICMPCode(HIcmp, CN_ICMP_CODE_NO_CODE);
    ID := Random($FFFF);
    CnSetICMPIdentifier(HIcmp, ID);
    CnSetICMPSequenceNumber(HIcmp, 0);

    CnFillICMPHeaderCheckSum(HIcmp, Count);

    FillChar(DestAddr, SizeOf(DestAddr), 0);
    DestAddr.sin_family := AF_INET;
    DestAddr.sin_addr.s_addr := inet_addr(PAnsiChar(aIP.IP));

    R := CnSendTo(Sock, HIcmp^, SizeOf(TCnICMPHeader) + Count, 0, DestAddr,
      SizeOf(DestAddr));
    if R = SOCKET_ERROR then
    begin
      Result := SCN_ICMP_ERROR_GENERAL; // ��������
      aReply := IntToStr(CnGetNetErrorNo);
      if Assigned(FOnError) then
        FOnError(Self, aIP.IP, aIP.Host, FTTL, 0, IntToStr(CnGetNetErrorNo));
      Exit;
    end;

    // recvfrom
    FromLen := SizeOf(DestAddr);
    R := CnRecvFrom(Sock, Buf[0], SizeOf(Buf), 0, DestAddr, FromLen);
    if R > SizeOf(TCnIPHeader) + SizeOf(TCnICMPHeader) then
    begin
      HIp := PCnIPHeader(@Buf[0]);
      P := PAnsiChar(HIp);
      Inc(P, CnGetIPHeaderLength(HIp) * 4);
      HIcmp := PCnICMPHeader(P);

      if (HIcmp^.MessageType = CN_ICMP_TYPE_ECHO_REPLY) and (ID = HIcmp^.Identifier) then
        Result := SCN_ICMP_ERROR_OK
      else
      begin
        Result := SCN_ICMP_ERROR_GENERAL;
        if Assigned(FOnError) then
          FOnError(Self, aIP.IP, aIP.Host, FTTL, 0, SICMPRunError);
      end;
    end
    else if R = -1 then
    begin
      Result := SCN_ICMP_ERROR_TIME_OUT;
      if Assigned(FOnError) then
        FOnError(Self, aIP.IP, aIP.Host, FTTL, 0, SNoResponse);
    end
    else
    begin
      Result := SCN_ICMP_ERROR_UNKNOWN;
      if Assigned(FOnError) then
        FOnError(Self, aIP.IP, aIP.Host, FTTL, 0, SICMPRunError);
    end;

    CnCloseSocket(Sock);
  finally
    if aReply = '' then
      aReply := GetReplyString(Result, aIP, nil);
    if pReqData <> nil then
      FreeMem(pReqData); //�ͷ��ڴ�
  end;

{$ENDIF}
end;

function TCnPing.GetReplyString(aResult: Integer; aIP: TCnIpInfo;
  pIPE: PCnIcmpEchoReply): string;
var
  sHost: string;
begin
  Result := SInvalidAddr;
  case aResult of
    SCN_ICMP_ERROR_UNKNOWN: Result := SICMPRunError;
    SCN_ICMP_ERROR_GENERAL: Result := SICMPRunError;
    SCN_ICMP_ERROR_BAD_ADDR: Result := SInvalidAddr;
    SCN_ICMP_ERROR_TIME_OUT: Result := Format(SNoResponse, [RemoteHost]);
    SCN_ICMP_ERROR_SOCKET: Result := SInitFailed;
  else
    if pIPE <> nil then
    begin
      sHost := aIP.IP;
      if aIP.Host <> '' then
        sHost := aIP.Host + ': ' + sHost;
      Result := (Format(SPingResultString, [sHost, pIPE^.DataSize, pIPE^.RTT,
        pIPE^.Options.TTL]));
    end;
  end;
end;

function TCnPing.GetIPByName(const aName: string; var aIP: string): Boolean;
begin
  Result := TCnIp.GetIPByName(aIP, aName);
end;

function TCnPing.SetIP(aIPAddr, aHost: string; var aIP: TCnIpInfo): Boolean;
var
  pIPAddr: PAnsiChar;
begin
  Result := False;
  aIP.Address := INADDR_NONE;
  aIP.IP := aIPAddr;
  aIP.Host := aHost;
  if aIP.IP = '' then
  begin
    if (aIP.Host = '') or (not GetIPByName(aIP.Host, aIP.IP)) then
      Exit;
  end;

  GetMem(pIPAddr, Length(aIP.IP) + 1);
  try
    FillChar(pIPAddr^, Length(aIP.IP) + 1, 0);
    StrPCopy(pIPAddr, {$IFDEF UNICODE}AnsiString{$ENDIF}(aIP.IP));
    aIP.Address := inet_addr(PAnsiChar(pIPAddr)); // IPת�����޵�����
  finally
    FreeMem(pIPAddr); // �ͷ�����Ķ�̬�ڴ�
  end;
  Result := aIP.Address <> INADDR_NONE;
end;

{$IFDEF MSWINDOWS}

initialization

finalization
  FreeIcmpFunctions;

{$ENDIF}

end.
