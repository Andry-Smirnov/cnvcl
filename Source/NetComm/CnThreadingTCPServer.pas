{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2022 CnPack ������                       }
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
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnThreadingTCPServer;
{* |<PRE>
================================================================================
* ������ƣ�����ͨѶ�����
* ��Ԫ���ƣ�����ͨѶ��������߳����� TCP Server ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ Liu Xiao
* ��    ע��һ�����׵Ķ��߳�����ʽ TCP Server���¿ͻ�������ʱ�����̣߳�������
*           �� OnAccept �¼���ѭ�� Recv/Send ���������ɣ��˳��¼���Ͽ����ӣ�
*           ���̳߳ػ���
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2020.02.21 V1.0
*                ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs, SyncObjs,
{$IFDEF MSWINDOWS}
  Windows,  WinSock,
{$ELSE}
  System.Net.Socket, Posix.NetinetIn, Posix.SysSocket, Posix.Unistd, Posix.ArpaInet,
{$ENDIF}
  CnConsts, CnNetConsts, CnClasses, CnNetwork;

type
  ECnServerSocketError = class(Exception);

  TCnThreadingTCPServer = class;

  TCnClientSocket = class
  {* ��ÿһ�������ͻ���ͨ�ŵ� Socket ��װ}
  private
    FSocket: TSocket;
    FRemoteIP: string;
    FRemotePort: Word;
    FServer: TCnThreadingTCPServer;
    FBytesReceived: Cardinal;
    FBytesSent: Cardinal;
    FLocalIP: string;
    FLocalPort: Word;
    FTag: TObject;
  protected
    procedure DoShutdown; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Shutdown; virtual;
    {* ��װ�Ĺر� Socket �Ĳ���}

    // send/recv �շ����ݷ�װ
    function Send(var Buf; Len: Integer; Flags: Integer = 0): Integer;
    function Recv(var Buf; Len: Integer; Flags: Integer = 0): Integer;
    // ע�� Recv ���� 0 ʱ˵����ǰ�����ѶϿ�����������Ҫ���ݷ���ֵ���Ͽ�����

    property Server: TCnThreadingTCPServer read FServer write FServer;
    {* ������ TCnThreadingTCPServer ʵ������}
    property Socket: TSocket read FSocket write FSocket;
    {* �Ϳͻ���ͨѶ��ʵ�� Socket}
    property LocalIP: string read FLocalIP write FLocalIP;
    {* �ͻ���������ʱ�ı��� IP}
    property LocalPort: Word read FLocalPort write FLocalPort;
    {* �ͻ���������ʱ�ı��ض˿�}
    property RemoteIP: string read FRemoteIP write FRemoteIP;
    {* Զ�̿ͻ��˵� IP}
    property RemotePort: Word read FRemotePort write FRemotePort;
    {* Զ�̿ͻ��˵Ķ˿�}
    property Tag: TObject read FTag write FTag;
    {* Tag ����������Ķ���}

    property BytesSent: Cardinal read FBytesSent;
    {* ���ͻ��˵ķ����ֽ������� Send �Żᱻͳ��}
    property BytesReceived: Cardinal read FBytesReceived;
    {* ���ͻ��˵���ȡ�ֽ������� Recv �Żᱻͳ��}
  end;

  TCnServerSocketErrorEvent = procedure (Sender: TObject; SocketError: Integer) of object;

  TCnSocketAcceptEvent = procedure (Sender: TObject; ClientSocket: TCnClientSocket) of object;

  TCnTCPAcceptThread = class(TThread)
  {* �����̣߳�һ�� TCPServer ֻ��һ�������� Accept}
  private
    FServer: TCnThreadingTCPServer;
    FServerSocket: TSocket;
  protected
    procedure Execute; override;
  public
    property ServerSocket: TSocket read FServerSocket write FServerSocket;
    {* �����߳����õ� Socket ����}
    property Server: TCnThreadingTCPServer read FServer write FServer;
    {* �����߳������� TCPServer ����}
  end;

  TCnTCPClientThread = class(TThread)
  {* Accept �ɹ������ÿ���¿ͻ������Ĵ����̣߳������ж����ÿ����Ӧһ�� ClientSocket ��װ}
  private
    FClientSocket: TCnClientSocket;
  protected
    procedure Execute; override;
    procedure DoAccept; virtual;

    function DoGetClientSocket: TCnClientSocket; virtual;
    {* ���������ʹ����չ���ݵ� ClientSocket}
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    property ClientSocket: TCnClientSocket read FClientSocket;
    {* ��װ�Ĺ�����ͻ���ʹ�õ��������}
  end;

  TCnThreadingTCPServer = class(TCnComponent)
  {* �򵥵Ķ��߳� TCP Server}
  private
    FSocket: TSocket;            // ������ Socket
    FAcceptThread: TCnTCPAcceptThread;
    FListLock: TCriticalSection;
    FClientThreads: TObjectList; // �洢 Accept ����ÿ���� Client ͨѶ���߳�
    FActive: Boolean;
    FListening: Boolean;
    FActualLocalPort: Word;
    FLocalPort: Word;
    FLocalIP: string;
    FOnError: TCnServerSocketErrorEvent;
    FOnAccept: TCnSocketAcceptEvent;
    FCountLock: TCriticalSection;
    FBytesReceived: Cardinal;
    FBytesSent: Cardinal;
    FOnShutdownClient: TNotifyEvent;
    FMaxConnections: Cardinal;
    procedure SetActive(const Value: Boolean);
    procedure SetLocalIP(const Value: string);
    procedure SetLocalPort(const Value: Word);
    function GetClientCount: Integer;
    function GetClient(Index: Integer): TCnClientSocket;
    function GetActualLocalPort: Word;
  protected
    procedure GetComponentInfo(var AName, Author, Email, Comment: string); override;

    function CheckSocketError(ResultCode: Integer): Integer;
    function DoGetClientThread: TCnTCPClientThread; virtual;
    {* ���������ʹ��������Ϊ�� ClientThread}

    procedure DoShutdownClient(Client: TCnClientSocket); virtual;

    procedure ClientThreadTerminate(Sender: TObject);
    procedure IncRecv(C: Integer);
    procedure IncSent(C: Integer);

    function Bind: Boolean;
    function Listen: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Open;
    {* ��ʼ��������ͬ�� Active := True}
    procedure Close; virtual;
    {* �ر����пͻ������Ӳ�ֹͣ��������ͬ�� Active := False}
    function KickAll: Integer; virtual;
    {* �ر����пͻ�������}

    property ClientCount: Integer read GetClientCount;
    {* ��Ŀͻ�������}
    property Clients[Index: Integer]: TCnClientSocket read GetClient;
    {* ��Ŀͻ��˷�װ����}

    property BytesSent: Cardinal read FBytesSent;
    {* ���͸����ͻ��˵����ֽ���}
    property BytesReceived: Cardinal read FBytesReceived;
    {* �Ӹ��ͻ�����ȡ�����ֽ���}
    property Listening: Boolean read FListening;
    {* �Ƿ����ڼ���}
    property ActualLocalPort: Word read GetActualLocalPort;
    {* LocalPort Ϊ 0 ʱ���ѡ��һ���˿ڼ��������ظö˿�ֵ}
  published
    property Active: Boolean read FActive write SetActive;
    {* �Ƿ�ʼ����}
    property LocalIP: string read FLocalIP write SetLocalIP;
    {* �����ı��� IP}
    property LocalPort: Word read FLocalPort write SetLocalPort;
    {* �����ı��ض˿�}
    property MaxConnections: Cardinal read FMaxConnections write FMaxConnections;
    {* �ܹ����������������������� Accept ʱֱ�ӹر��½�������}

    property OnError: TCnServerSocketErrorEvent read FOnError write FOnError;
    {* �����¼�}
    property OnAccept: TCnSocketAcceptEvent read FOnAccept write FOnAccept;
    {* �¿ͻ���������ʱ�������¼�����������ѭ�����ա�������˳��¼���Ͽ�����}
    property OnShutdownClient: TNotifyEvent read FOnShutdownClient write FOnShutdownClient;
    {* ���� ClientSocket.Shutdown �ر�ĳ�ͻ���ʱ��������ʹ���߶���رտͻ���������ص�������Դ}
  end;

implementation

{$IFDEF MSWINDOWS}
var
  WSAData: TWSAData;
{$ENDIF}

{ TCnThreadingTCPServer }

function TCnThreadingTCPServer.Bind: Boolean;
var
  SockAddress, ConnAddr: TSockAddr;
  Len, Ret: Integer;
begin
  Result := False;
  if FActive then
  begin
    SockAddress.sin_family := AF_INET;
    if FLocalIP <> '' then
      SockAddress.sin_addr.s_addr := inet_addr(PAnsiChar(AnsiString(FLocalIP)))
    else
      SockAddress.sin_addr.S_addr := INADDR_ANY;

    SockAddress.sin_port := ntohs(FLocalPort);
{$IFDEF MSWINDOWS}
    Result := CheckSocketError(WinSock.bind(FSocket, SockAddress, SizeOf(SockAddress))) = 0;
{$ELSE}
    Result := CheckSocketError(Posix.SysSocket.bind(FSocket, sockaddr(SockAddress), SizeOf(SockAddress))) = 0;
{$ENDIF}

    FActualLocalPort := FLocalPort;
    if FActualLocalPort = 0 then
    begin
      Len := SizeOf(ConnAddr);
{$IFDEF MSWINDOWS}
      Ret := CheckSocketError(WinSock.getsockname(FSocket, ConnAddr, Len));
{$ELSE}
      Ret := CheckSocketError(getsockname(FSocket, sockaddr(ConnAddr), Cardinal(Len)));
{$ENDIF}
      if Ret = 0 then
        FActualLocalPort := ntohs(ConnAddr.sin_port);
    end;
  end;
end;

function TCnThreadingTCPServer.CheckSocketError(ResultCode: Integer): Integer;
begin
  Result := ResultCode;
  if ResultCode = SOCKET_ERROR then
  begin
    if Assigned(FOnError) then
    begin
{$IFDEF MSWINDOWS}
      FOnError(Self, WSAGetLastError);
{$ELSE}
      FOnError(Self, GetLastError);
{$ENDIF};
    end;
  end;
end;

procedure TCnThreadingTCPServer.ClientThreadTerminate(Sender: TObject);
begin
  // �ͻ����߳̽����������߳���ɾ����Ч�� Socket ���߳����á�Sender �� Thread ʵ��
  FListLock.Enter;
  try
    FClientThreads.Remove(Sender);
  finally
    FListLock.Leave;
  end;
end;

procedure TCnThreadingTCPServer.Close;
begin
  if not FActive then
    Exit;

  if FActive then
  begin
    // ֹ֪ͨͣ Accept �̣߳���ֹ������ Client ����
{$IFDEF MSWINDOWS}
    WinSock.shutdown(FSocket, 2); // SD_BOTH������δ����ʱ�ĳ���
    CheckSocketError(WinSock.closesocket(FSocket)); // intterupt accept call
{$ELSE}
    shutdown(FSocket, 2); // SD_BOTH������δ����ʱ�ĳ���
    CheckSocketError(Posix.Unistd.__close(FSocket)); // intterupt accept call
{$ENDIF}

    FSocket := INVALID_SOCKET;
    FAcceptThread.Terminate;
    try
      FAcceptThread.WaitFor;
    except
      ;  // WaitFor ʱ�����Ѿ� Terminated�����³������Ч�Ĵ�
    end;
    FAcceptThread := nil;

    // �ߵ����пͻ���
    KickAll;

    FActualLocalPort := 0;
    FListening := False;
    FActive := False;
  end;
end;

constructor TCnThreadingTCPServer.Create(AOwner: TComponent);
begin
  inherited;
  FListLock := TCriticalSection.Create;
  FCountLock := TCriticalSection.Create;
  FClientThreads := TObjectList.Create(False);
end;

destructor TCnThreadingTCPServer.Destroy;
begin
  Close;
  FClientThreads.Free;
  FCountLock.Free;
  FListLock.Free;
  inherited;
end;

function TCnThreadingTCPServer.DoGetClientThread: TCnTCPClientThread;
begin
  Result := TCnTCPClientThread.Create(True);
end;

procedure TCnThreadingTCPServer.DoShutdownClient(Client: TCnClientSocket);
begin
  if Assigned(FOnShutdownClient) then
    FOnShutdownClient(Client);
end;

function TCnThreadingTCPServer.GetActualLocalPort: Word;
begin
  Result := FActualLocalPort;
end;

function TCnThreadingTCPServer.GetClient(Index: Integer): TCnClientSocket;
begin
  if (Index >= 0) and (Index < FClientThreads.Count) then
    Result := TCnTCPClientThread(FClientThreads[Index]).ClientSocket
  else
    Result := nil;
end;

function TCnThreadingTCPServer.GetClientCount: Integer;
begin
  Result := FClientThreads.Count;
end;

procedure TCnThreadingTCPServer.GetComponentInfo(var AName, Author, Email,
  Comment: string);
begin
  AName := SCnThreadingTCPServerName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnThreadingTCPServerComment;
end;

procedure TCnThreadingTCPServer.IncRecv(C: Integer);
begin
  FCountLock.Enter;
  Inc(FBytesReceived, C);
  FCountLock.Leave;
end;

procedure TCnThreadingTCPServer.IncSent(C: Integer);
begin
  FCountLock.Enter;
  Inc(FBytesSent, C);
  FCountLock.Leave;
end;

function TCnThreadingTCPServer.KickAll: Integer;
var
  CT: TCnTCPClientThread;
begin
  Result := 0;

  // �ر����пͻ�������
  while FClientThreads.Count > 0 do
  begin
    FListLock.Enter;
    try
      if FClientThreads.Count = 0 then
        Exit;

      CT := TCnTCPClientThread(FClientThreads[0]);
      CT.ClientSocket.ShutDown;
      CT.Terminate;

      try
        CT.WaitFor;
        // �ȴ��߳̽�����ע�Ⲣ���ȴ��������߳���� OnTerminate ����
      except
        ; // WaitFor ʱ���ܾ����Ч����Ϊ�Ѿ�������
      end;
    finally
      FListLock.Leave;
    end;

    // �߳̽���ʱ�߳�ʵ���Ѿ��� FClientThreads ���޳���
    Inc(Result);
  end;
  FClientThreads.Clear;
end;

function TCnThreadingTCPServer.Listen: Boolean;
begin
  if FActive and not FListening then
  begin
{$IFDEF MSWINDOWS}
    FListening := CheckSocketError(WinSock.listen(FSocket, SOMAXCONN)) = 0;
{$ELSE}
    FListening := CheckSocketError(Posix.SysSocket.listen(FSocket, SOMAXCONN)) = 0;
{$ENDIF}
  end;

  Result := FListening;
end;

procedure TCnThreadingTCPServer.Open;
begin
  if FActive then
    Exit;

  FSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  FActive := FSocket <> INVALID_SOCKET;
  if FActive then
  begin
    if Bind then
    begin
      if Listen then
      begin
        // ���� Accept �̣߳����µĿͻ�������
        if FAcceptThread = nil then
        begin
          FAcceptThread := TCnTCPAcceptThread.Create(True);
          FAcceptThread.FreeOnTerminate := True;
        end;

        FAcceptThread.Server := Self;
        FAcceptThread.ServerSocket := FSocket;
        FAcceptThread.Resume;
      end;
    end;
  end;
end;

procedure TCnThreadingTCPServer.SetActive(const Value: Boolean);
begin
  if Value <> FActive then
  begin
    if not (csLoading in ComponentState) and not (csDesigning in ComponentState) then
    begin
      if Value then
        Open
      else
        Close;
    end
    else
      FActive := Value;
  end;
end;

procedure TCnThreadingTCPServer.SetLocalIP(const Value: string);
begin
  FLocalIP := Value;
end;

procedure TCnThreadingTCPServer.SetLocalPort(const Value: Word);
begin
  FLocalPort := Value;
end;

{ TCnAcceptThread }

procedure TCnTCPAcceptThread.Execute;
var
  Sock: TSocket;
  SockAddress, ConnAddr: TSockAddr;
  Len, Ret: Integer;
  ClientThread: TCnTCPClientThread;
begin
  FServer.FBytesReceived := 0;
  FServer.FBytesSent := 0;

  while not Terminated do
  begin
    Len := SizeOf(SockAddress);
    FillChar(SockAddress, SizeOf(SockAddress), 0);
    try
{$IFDEF MSWINDOWS}
      Sock := WinSock.accept(FServerSocket, @SockAddress, @Len);
{$ELSE}
      Sock := accept(FServerSocket, sockaddr(SockAddress), Cardinal(Len));
{$ENDIF}
    except
      Sock := INVALID_SOCKET;
    end;

    // �µĿͻ���������
    if Sock <> INVALID_SOCKET then
    begin
      // ���������������ֱ�Ӷϵ�
      if (FServer.MaxConnections > 0) and (FServer.ClientCount >= FServer.MaxConnections) then
      begin
{$IFDEF MSWINDOWS}
        WinSock.closesocket(Sock);
{$ELSE}
        Posix.Unistd.__close(Sock);
{$ENDIF}
        Continue;
      end;

      // ���µĿͻ��̣߳�������һ���ͻ��̳߳أ��治����̣߳�
      ClientThread := FServer.DoGetClientThread;
      ClientThread.FreeOnTerminate := True;
      ClientThread.OnTerminate := FServer.ClientThreadTerminate;

      ClientThread.ClientSocket.Socket := Sock;
      ClientThread.ClientSocket.Server := FServer;

      Len := SizeOf(ConnAddr);
{$IFDEF MSWINDOWS}
      Ret := FServer.CheckSocketError(WinSock.getsockname(Sock, ConnAddr, Len));
{$ELSE}
      Ret := FServer.CheckSocketError(getsockname(Sock, sockaddr(ConnAddr), Cardinal(Len)));
{$ENDIF}

      if Ret = 0 then
      begin
        // �ø� Socket �ı�����Ϣ
        ClientThread.ClientSocket.LocalIP := inet_ntoa(ConnAddr.sin_addr);
        ClientThread.ClientSocket.LocalPort := ntohs(ConnAddr.sin_port);
      end
      else // ���û�õ��������ü����� Socket �ı�����Ϣ��ע�� IP �����ǿ�
      begin
        ClientThread.ClientSocket.LocalIP := FServer.LocalIP;
        ClientThread.ClientSocket.LocalPort := FServer.ActualLocalPort;
      end;

      // �ø� Socket �ĶԶ˿ͻ�����Ϣ
      ClientThread.ClientSocket.RemoteIP := inet_ntoa(SockAddress.sin_addr);
      ClientThread.ClientSocket.RemotePort := ntohs(SockAddress.sin_port);

      FServer.FListLock.Enter;
      try
        FServer.FClientThreads.Add(ClientThread);
      finally
        FServer.FListLock.Leave;
      end;
      ClientThread.Resume;
    end;
  end;
end;

{ TCnTCPClientThread }

constructor TCnTCPClientThread.Create(CreateSuspended: Boolean);
begin
  inherited;
  FClientSocket := DoGetClientSocket;
end;

destructor TCnTCPClientThread.Destroy;
begin
  FClientSocket.Free;
  inherited;
end;

procedure TCnTCPClientThread.DoAccept;
begin
  if Assigned(FClientSocket.Server.OnAccept) then
    FClientSocket.Server.OnAccept(FClientSocket.Server, FClientSocket);
end;

function TCnTCPClientThread.DoGetClientSocket: TCnClientSocket;
begin
  Result := TCnClientSocket.Create;
end;

procedure TCnTCPClientThread.Execute;
begin
  // �ͻ����������ϣ��¼����в����ɱ���
  DoAccept;

  // �ͻ���������ˣ����ԶϿ������ˣ�����¼���ͷû�����Ͽ��Ļ�
  FClientSocket.Shutdown;
end;

{ TCnClientSocket }

constructor TCnClientSocket.Create;
begin

end;

destructor TCnClientSocket.Destroy;
begin
  inherited;

end;

procedure TCnClientSocket.DoShutdown;
begin
  FServer.DoShutdownClient(Self);
end;

function TCnClientSocket.Recv(var Buf; Len: Integer; Flags: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := FServer.CheckSocketError(WinSock.recv(FSocket, Buf, Len, Flags));
{$ELSE}
  Result := FServer.CheckSocketError(Posix.SysSocket.recv(FSocket, Buf, Len, Flags));
{$ENDIF}

  if Result <> SOCKET_ERROR then
  begin
    Inc(FBytesReceived, Result);
    FServer.IncRecv(Result);
  end;
end;

function TCnClientSocket.Send(var Buf; Len: Integer; Flags: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := FServer.CheckSocketError(WinSock.send(FSocket, Buf, Len, Flags));
{$ELSE}
  Result := FServer.CheckSocketError(Posix.SysSocket.send(FSocket, Buf, Len, Flags));
{$ENDIF}

  if Result <> SOCKET_ERROR then
  begin
    Inc(FBytesSent, Result);
    FServer.IncSent(Result);
  end;
end;

{$IFDEF MSWINDOWS}

procedure Startup;
var
  ErrorCode: Integer;
begin
  ErrorCode := WSAStartup($0101, WSAData);
  if ErrorCode <> 0 then
    raise ECnServerSocketError.Create('WSAStartup');
end;

procedure Cleanup;
var
  ErrorCode: Integer;
begin
  ErrorCode := WSACleanup;
  if ErrorCode <> 0 then
    raise ECnServerSocketError.Create('WSACleanup');
end;

{$ENDIF}

procedure TCnClientSocket.Shutdown;
begin
  if FSocket <> INVALID_SOCKET then
  begin
{$IFDEF MSWINDOWS}
    FServer.CheckSocketError(WinSock.shutdown(FSocket, 2)); // SD_BOTH
    FServer.CheckSocketError(WinSock.closesocket(FSocket));
{$ELSE}
    FServer.CheckSocketError(Posix.SysSocket.shutdown(FSocket, 2)); // SD_BOTH
    FServer.CheckSocketError(Posix.Unistd.__close(FSocket));
{$ENDIF}

    FSocket := INVALID_SOCKET;

    DoShutdown;
  end;
end;

{$IFDEF MSWINDOWS}

initialization
  Startup;

finalization
  Cleanup;

{$ENDIF}

end.
