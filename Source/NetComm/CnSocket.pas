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

unit CnSocket;
{* |<PRE>
================================================================================
* ������ƣ�����ͨѶ�����
* ��Ԫ���ƣ�����ͨѶ Socket �����������ƽ̨������װ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��PWin7 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP/7 + Delphi 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.12.06 V1.0
*                ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes {$IFDEF MSWINDOWS}, WinSock {$ELSE}, System.Net.Socket,
  Posix.Base, Posix.NetIf, Posix.SysSocket, Posix.ArpaInet, Posix.NetinetIn
  {$ENDIF};

const
  SD_BOTH = 2;

{$IFNDEF MSWINDOWS}

type
  TSocket = Integer;
  TSockAddr = sockaddr_in;

const
  SOCKET_ERROR   = -1;
  INVALID_SOCKET = -1;

function getifaddrs(var Ifap: pifaddrs): Integer; cdecl; external libc name _PU + 'getifaddrs';

procedure freeifaddrs(Ifap: pifaddrs); cdecl; external libc name _PU + 'freeifaddrs';

{$ENDIF}

function CnNewSocket(Af, Struct, Protocol: Integer): TSocket;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� socket �����ķ�װ}

function CnConnect(S: TSocket; var Name: TSockAddr; NameLen: Integer): Integer;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� connect �����ķ�װ}

function CnBind(S: TSocket; var Addr: TSockAddr; NameLen: Integer): Integer;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� bind �����ķ�װ}

function CnGetSockName(S: TSocket; var Name: TSockAddr; var NameLen: Integer): Integer;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� getsockname �����ķ�װ}

function CnListen(S: TSocket; Backlog: Integer): Integer;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� listen �����ķ�װ}

function CnAccept(S: TSocket; Addr: PSockAddr; AddrLen: PInteger): TSocket;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� accept �����ķ�װ}

function CnSend(S: TSocket; const Buf; Len, Flags: Integer): Integer;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� send �����ķ�װ}

function CnRecv(S: TSocket; var Buf; Len, Flags: Integer): Integer;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� recv �����ķ�װ}

function CnShutdown(S: TSocket; How: Integer): Integer;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� shutdown �����ķ�װ}

function CnCloseSocket(S: TSocket): Integer;
{* �� Windows �Լ� POSIX������ MAC��Linux �ȣ�ƽ̨�ϵ� closesocket �����ķ�װ}

implementation

function CnNewSocket(Af, Struct, Protocol: Integer): TSocket;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.socket(Af, Struct, Protocol);
{$ELSE}
  Result := Posix.SysSocket.socket(Af, Struct, Protocol);
{$ENDIF}
end;

function CnConnect(S: TSocket; var Name: TSockAddr; NameLen: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.connect(S, Name, NameLen);
{$ELSE}
  Result := Posix.SysSocket.connect(S, sockaddr(Name), NameLen);
{$ENDIF}
end;

function CnBind(S: TSocket; var Addr: TSockAddr; NameLen: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.bind(S, Addr, NameLen);
{$ELSE}
  Result := Posix.SysSocket.bind(S, sockaddr(Addr), NameLen);
{$ENDIF}
end;

function CnGetSockName(S: TSocket; var Name: TSockAddr; var NameLen: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.getsockname(S, Name, NameLen);
{$ELSE}
  Result := Posix.SysSocket.getsockname(S, sockaddr(Name), NameLen);
{$ENDIF}
end;

function CnListen(S: TSocket; Backlog: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.listen(S, Backlog);
{$ELSE}
  Result := Posix.SysSocket.listen(S, Backlog);
{$ENDIF}
end;

function CnAccept(S: TSocket; Addr: PSockAddr; AddrLen: PInteger): TSocket;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.accept(S, Addr, AddrLen);
{$ELSE}
  Result := Posix.SysSocket.accept(S, Addr^, AddrLen);
{$ENDIF}
end;

function CnSend(S: TSocket; const Buf; Len, Flags: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.send(S, Buf, Len, Flags);
{$ELSE}
  Result := Posix.SysSocket.send(S, Buf, Len, Flags);
{$ENDIF}
end;

function CnRecv(S: TSocket; var Buf; Len, Flags: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.recv(S, Buf, Len, Flags);
{$ELSE}
  Result := Posix.SysSocket.recv(S, Buf, Len, Flags);
{$ENDIF}
end;

function CnShutdown(S: TSocket; How: Integer): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.shutdown(S, How);
{$ELSE}
  Result := Posix.SysSocket.shutdown(S, How);
{$ENDIF}
end;

function CnCloseSocket(S: TSocket): Integer;
begin
{$IFDEF MSWINDOWS}
  Result := WinSock.closesocket(S);
{$ELSE}
  Result := Posix.Unistd.__close(S);
{$ENDIF}
end;

end.
