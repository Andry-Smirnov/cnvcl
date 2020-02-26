{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2020 CnPack ������                       }
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

unit CnTCPForwarder;
{* |<PRE>
================================================================================
* ������ƣ�����ͨѶ�����
* ��Ԫ���ƣ�����ͨѶ����� TCP �˿�ת��ʵ�ֵ�Ԫ
* ��Ԫ���ߣ�CnPack ������ Liu Xiao
* ��    ע��һ��ʹ�� ThreadingTCPServer �Ķ��̶߳˿�ת����������̳߳ػ���
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�PWin7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2020.02.25 V1.0
*                ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, SysUtils, Classes, Contnrs, WinSock, CnConsts, CnNetConsts, CnClasses,
  CnThreadingTCPServer, CnTCPClient;

type
  TCnTCPForwarder = class(TCnThreadingTCPServer)
  {* TCP �˿�ת���������ÿ���ͻ��������������߳�}
  private
    FRemoteHost: string;
    FRemotePort: Word;
    FOnRemoteConnected: TNotifyEvent;
    procedure SetRemoteHost(const Value: string);
    procedure SetRemotePort(const Value: Word);
  protected
    procedure GetComponentInfo(var AName, Author, Email, Comment: string); override;

    function DoGetClientThread: TCnTCPClientThread; override;
    {* ��������ʹ�� TCnTCPForwardThread}

    procedure DoRemoteConnected; virtual;
  published
    property RemoteHost: string read FRemoteHost write SetRemoteHost;
    {* ת����Զ������}
    property RemotePort: Word read FRemotePort write SetRemotePort;
    {* ת����Զ�̶˿�}

    property OnRemoteConnected: TNotifyEvent read FOnRemoteConnected write FOnRemoteConnected;
    {* ������Զ�̷�����ʱ����}
  end;

implementation

const
  FORWARDER_BUF_SIZE = 32 * 1024;

type
  TCnForwarderClientSocket = class(TCnClientSocket)
  {* ��װ�Ĵ���һ�ͻ�������ת���Ķ��󣬰���ǰ����������߳�ʵ����ͨѶ�� Socket}
  private
    FLock: TRTLCriticalSection;
    FTCPClient: TCnTCPClient;
    FBackwardThread: TThread;
    FForwardThread: TThread;
    procedure BackwardThreadTerminate(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Shutdown; override;
    {* �ر�ǰ��������� Socket}

    property TCPClient: TCnTCPClient read FTCPClient write FTCPClient;
    {* ������ͨѶ�� Socket ��װ����ͻ���ͨѶ�� Socket ��װ�ڸ����У�}

    property ForwardThread: TThread read FForwardThread write FForwardThread;
    {* �ӿͻ��˶���д������˵��߳�}
    property BackwardThread: TThread read FBackwardThread write FBackwardThread;
    {* �ӷ���˶���д���ͻ��˵��߳�}
  end;

  TCnTCPForwardThread = class(TCnTCPClientThread)
  {* �пͻ���������ʱ�Ĵ����̣߳��ӿͻ��˶���д�������}
  protected
    function DoGetClientSocket: TCnClientSocket; override;
    procedure Execute; override;
  end;

  TCnTCPBackwardThread = class(TThread)
  {* �ӷ���˶���д���ͻ��˵��̣߳�����Ϊ Accept ������߳�ʹ��}
  private
    FClientSocket: TCnForwarderClientSocket;
  protected
    procedure Execute; override;
  public
    property ClientSocket: TCnForwarderClientSocket read FClientSocket write FClientSocket;
  end;

{ TCnTCPForwarder }

function TCnTCPForwarder.DoGetClientThread: TCnTCPClientThread;
begin
  Result := TCnTCPForwardThread.Create(True);
end;

procedure TCnTCPForwarder.DoRemoteConnected;
begin
  if Assigned(FOnRemoteConnected) then
    FOnRemoteConnected(Self);
end;

procedure TCnTCPForwarder.GetComponentInfo(var AName, Author, Email,
  Comment: string);
begin
  AName := SCnTCPForwarderName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnTCPForwarderComment;
end;

procedure TCnTCPForwarder.SetRemoteHost(const Value: string);
begin
  FRemoteHost := Value;
end;

procedure TCnTCPForwarder.SetRemotePort(const Value: Word);
begin
  FRemotePort := Value;
end;

{ TCnTCPForwardThread }

function TCnTCPForwardThread.DoGetClientSocket: TCnClientSocket;
begin
  Result := TCnForwarderClientSocket.Create;
end;

procedure TCnTCPForwardThread.Execute;
var
  Client: TCnForwarderClientSocket;
  Forwarder: TCnTCPForwarder;
  Buf: array[0..FORWARDER_BUF_SIZE - 1] of Byte;
  Ret: Integer;
begin
  // �ͻ����������ϣ��¼����в����ɱ���
  DoAccept;
  Forwarder := TCnTCPForwarder(ClientSocket.Server);

  Client := TCnForwarderClientSocket(ClientSocket);
  Client.TCPClient := TCnTCPClient.Create(nil);
  Client.TCPClient.RemoteHost := Forwarder.RemoteHost;
  Client.TCPClient.RemotePort := Forwarder.RemotePort;
  Client.ForwardThread := Self;

  // ����Զ������
  Client.TCPClient.Active := True;
  if not Client.TCPClient.Connected then
  begin
    Client.Shutdown;
    Exit;
  end
  else
    Forwarder.DoRemoteConnected;

  // ���ӳɹ��󣬱��̴߳ӿͻ��� ClientSocket ����д������� OutClient
  // ����һ���̴߳ӷ���˶���д���ͻ��ˣ���Ϊû�й涨�����ǿͻ����ȷ�������

  Client.BackwardThread := TCnTCPBackwardThread.Create(True);
  (Client.BackwardThread as TCnTCPBackwardThread).ClientSocket := Client;
  Client.BackwardThread.FreeOnTerminate := True;
  Client.BackwardThread.OnTerminate := Client.BackwardThreadTerminate;
  Client.BackwardThread.Resume;

  try
    while not Terminated do
    begin
      Ret := ClientSocket.Recv(Buf, SizeOf(Buf));
      if Ret <= 0 then
      begin
        // Recv ����˵���ͻ����ѶϿ������жϿ�Զ�����ӣ�֪ͨ��һ�߳�ֹͣ���˳�
        Client.Shutdown;
        if Client.BackwardThread <> nil then
          Client.BackwardThread.Terminate;

        Break;
      end;

      Ret := Forwarder.CheckSocketError(Client.TCPClient.Send(Buf, Ret));
      if Ret <= 0 then
      begin
        // Send ����˵��������ѶϿ���Ҳ���жϿ�Զ�����ӣ�֪ͨ��һ�߳�ֹͣ���˳�����Ͽ��ͻ������ӣ�
        Client.Shutdown;
        if Client.BackwardThread <> nil then
          Client.BackwardThread.Terminate;

        Break;
      end;
    end;
  finally
    Client.ForwardThread := nil; // �Լ�׼���˳����� ForwardThread ��Ϊ nil
  end;
end;

{ TCnTCPBackwardThread }

procedure TCnTCPBackwardThread.Execute;
var
  FForwarder: TCnTCPForwarder;
  Buf: array[0..FORWARDER_BUF_SIZE - 1] of Byte;
  Ret: Integer;
begin
  FForwarder := TCnTCPForwarder(ClientSocket.Server);

  // �ӷ���˶���д���ͻ���
  try
    while not Terminated do
    begin
      Ret := FForwarder.CheckSocketError(ClientSocket.TCPClient.Recv(Buf, SizeOf(Buf)));
      if Ret <= 0 then
      begin
        // Recv ����˵��������ѶϿ������жϿ�Զ�����ӣ�֪ͨ��һ�߳�ֹͣ���˳�
        ClientSocket.Shutdown;
        if ClientSocket.ForwardThread <> nil then
          ClientSocket.ForwardThread.Terminate;

        Break;
      end;

      Ret := ClientSocket.Send(Buf, Ret);
      if Ret <= 0 then
      begin
        // Send ����˵��������ѶϿ���Ҳ���жϿ�Զ�����ӣ�֪ͨ��һ�߳�ֹͣ���˳�
        ClientSocket.Shutdown;
        if ClientSocket.ForwardThread <> nil then
          ClientSocket.ForwardThread.Terminate;

        Break;
      end;
    end;
  finally
    ClientSocket.BackwardThread := nil;
  end;
end;

{ TCnForwarderClientSocket }

procedure TCnForwarderClientSocket.BackwardThreadTerminate(
  Sender: TObject);
begin
  FBackwardThread := nil;
end;

procedure TCnForwarderClientSocket.Shutdown;
begin
  // ���ڿ��ܱ�ǰ��������߳̽�����ã������Ҫ����
  EnterCriticalSection(FLock);
  try
    inherited;

    if FTCPClient <> nil then
      FreeAndNil(FTCPClient);
  finally
    LeaveCriticalSection(FLock);
  end;
end;

constructor TCnForwarderClientSocket.Create;
begin
  inherited;
  InitializeCriticalSection(FLock);
end;

destructor TCnForwarderClientSocket.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

end.
