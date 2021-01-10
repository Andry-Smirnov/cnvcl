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

unit CnLockFree;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����
* ��Ԫ���ƣ��漰���������Ƶ�һЩԭ�Ӳ�����װ�Լ��������ݽṹ��ʵ��
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע����װ�� CnAtomicCompareAndSet �� CAS ʵ�֣���Ӧ 32 λ�� 64 λ
*           �����ڴ�ʵ����������
* ����ƽ̨��PWin2000 + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/ 10.3������ Win32/64
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2021.01.10 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, {$IFDEF MSWINDOWS} Windows, {$ENDIF} Classes;

type
{$IFDEF WIN64}
  TCnSpinLockRecord = NativeInt;
{$ELSE}
  TCnSpinLockRecord = Integer;
{$ENDIF}
  {* ��������ֵΪ 1 ʱ��ʾ�б�����������0 ��ʾ����}

  PCnLockFreeLinkedNode = ^TCnLockFreeLinkedNode;

  TCnLockFreeLinkedNode = packed record
  {* ����������ڵ�}
    Key: TObject;
    Value: TObject;
    Next: PCnLockFreeLinkedNode;
  end;

  TCnLockFreeLinkedList = class
  {* ����������ʵ��}
  private
    FHead: PCnLockFreeLinkedNode; // �̶���ͷ�ڵ�ָ��
    FNode: TCnLockFreeLinkedNode; // ���ص�ͷ�ڵ㣬������ͳ�ơ�������ɾ����
    function GetTailNode: PCnLockFreeLinkedNode;
  protected
    function CreateNode: PCnLockFreeLinkedNode;
    procedure FreeNode(Node: PCnLockFreeLinkedNode);
  public
    constructor Create;
    destructor Destroy; override;

    function GetCount: Integer;
    {* ������ȡ�ж��ٸ��ڵ㣬���������ؽڵ�}
    procedure Clear;
    {* ȫ�����}
    procedure Append(Key, Value: TObject);
    {* ������β��ֱ������½ڵ㣬�����������б�֤ Key �������������з������������}
    procedure Add(Key, Value: TObject);
    {* �������и��� Key ���ҽڵ㲢�滻���粻��������β������½ڵ�}
    function Remove(Key: TObject): Boolean;
    {* ����δʵ�֣��������и��� Key ���ҽڵ㲢ɾ���������Ƿ�ɾ���ɹ�}
    function HasKey(Key: TObject): Boolean;
    {* ������������ָ�� Key �Ƿ����}
  end;

//------------------------------------------------------------------------------
// ԭ�Ӳ�����װ
//------------------------------------------------------------------------------

function CnAtomicIncrement32(var Addend: Integer): Integer;
{* ԭ�Ӳ�����һ 32 λֵ�� 1}

function CnAtomicDecrement32(var Addend: Integer): Integer;
{* ԭ�Ӳ�����һ 32 λֵ�� 1}

function CnAtomicExchange32(var Target: Integer; Value: Integer): Integer;
{* ԭ�Ӳ������� 32 λֵ����}

function CnAtomicExchangeAdd32(var Addend: LongInt; Value: LongInt): Longint;
{* ԭ�Ӳ����� 32 λֵ Addend := Addend + Value������ Addend ԭʼֵ}

function CnAtomicCompareExchange(var Target: Pointer; NewValue: Pointer; Comperand: Pointer): Pointer;
{* ԭ�Ӳ����Ƚ� Target �� Comperand ��ֵ�����ʱ�� NewValue ��ֵ�� Target�����ؾɵ� Target ֵ
  32 λ��֧�� 32 λֵ��64 λ��֧�� 64 λֵ}

function CnAtomicCompareAndSet(var Target: Pointer; NewValue: Pointer; Comperand: Pointer): Boolean;
{* ԭ�Ӳ���ִ�����´��룬�Ƚ� Target �� Comperand ��ֵ�����ʱ�� NewValue ��ֵ�� Target��
  32 λ��֧�� 32 λֵ��64 λ��֧�� 64 λֵ��δ������ֵ����ʱ���� False����ֵʱ���� True
  ע�� NewValue ��Ҫ���� Target�������޷������Ƿ�ִ���˸�ֵ��������Ϊ�����Ƿ�ֵ��һ��
  if Comperand = Target then
  begin
    Target := NewValue;
    Result := True;
  end
  else
    Result := False;
}

//------------------------------------------------------------------------------
// ������
//------------------------------------------------------------------------------

procedure CnInitSpinLockRecord(var Critical: TCnSpinLockRecord);
{* ��ʼ��һ������������ʵ���Ǹ�ֵΪ 0�������ͷ�}

procedure CnSpinLockEnter(var Critical: TCnSpinLockRecord);
{* ����������}

procedure CnSpinLockLeave(var Critical: TCnSpinLockRecord);
{* �뿪������}

implementation

function CnAtomicIncrement32(var Addend: Integer): Integer;
begin
{$IFDEF SUPPORT_ATOMIC}
  AtomicIncrement(Addend);
{$ELSE}
  Result := InterlockedIncrement(Addend);
{$ENDIF}
end;

function CnAtomicDecrement32(var Addend: Integer): Integer;
begin
{$IFDEF SUPPORT_ATOMIC}
  AtomicDecrement(Addend);
{$ELSE}
  Result := InterlockedDecrement(Addend);
{$ENDIF}
end;

function CnAtomicExchange32(var Target: Integer; Value: Integer): Integer;
begin
{$IFDEF SUPPORT_ATOMIC}
  AtomicExchange(Target, Value);
{$ELSE}
  Result := InterlockedExchange(Target, Value);
{$ENDIF}
end;

function CnAtomicExchangeAdd32(var Addend: LongInt; Value: LongInt): LongInt;
begin
{$IFDEF WIN64}
  Result := InterlockedExchangeAdd(Addend, Value);
{$ELSE}
  Result := InterlockedExchangeAdd(@Addend, Value);
{$ENDIF}
end;

function CnAtomicCompareExchange(var Target: Pointer; NewValue: Pointer; Comperand: Pointer): Pointer;
begin
{$IFDEF SUPPORT_ATOMIC}
  Result := AtomicCmpExchange(Target, NewValue, Comperand);
{$ELSE}
  Result := InterlockedCompareExchange(Target, NewValue, Comperand);
{$ENDIF}
end;

{$IFDEF SUPPORT_ATOMIC}

function CnAtomicCompareAndSet(var Target: Pointer; NewValue: Pointer;
  Comperand: Pointer): Boolean;
begin
  AtomicCmpExchange(Target, NewValue, Comperand, Result);
end;

{$ELSE}

{$IFDEF WIN64}

// XE2 �� Win64 ��û�� Atomic ϵ�к���
function CnAtomicCompareAndSet(var Target: Pointer; NewValue: Pointer;
  Comperand: Pointer): Boolean; assembler;
asm
  // API ��� InterlockedCompareExchange ���᷵���Ƿ�ɹ������ò��û�����
  MOV  RAX,  R8
  LOCK CMPXCHG [RCX], RDX
  SETZ AL
  AND RAX, $FF
end;

{$ELSE}

// XE2 �����°汾�� Win32 ʵ��
function CnAtomicCompareAndSet(var Target: Pointer; NewValue: Pointer;
  Comperand: Pointer): Boolean; assembler;
asm
  // API ��� InterlockedCompareExchange ���᷵���Ƿ�ɹ������ò��û�����
  // ���� @Target �� EAX, NewValue �� EDX��Comperand �� ECX��
  // Ҫ��һ�� ECX �� EAX �Ļ������ܵ��� LOCK CMPXCHG [ECX], EDX����������� AL ��
  XCHG  EAX, ECX
  LOCK CMPXCHG [ECX], EDX
  SETZ AL
  AND EAX, $FF
end;

{$ENDIF}

{$ENDIF}

procedure CnInitSpinLockRecord(var Critical: TCnSpinLockRecord);
begin
  Critical := 0;
end;

procedure CnSpinLockEnter(var Critical: TCnSpinLockRecord);
begin
  repeat
    while Critical <> 0 do
      ;  // �˴�����ĳ� Sleep(0) �ͻ����߳��л��������Ͳ�����������
  until CnAtomicCompareAndSet(Pointer(Critical), Pointer(1), Pointer(0));
end;

procedure CnSpinLockLeave(var Critical: TCnSpinLockRecord);
begin
  while not CnAtomicCompareAndSet(Pointer(Critical), Pointer(0), Pointer(1)) do
    Sleep(0);
end;

{ TCnLockFreeLinkedList }

procedure TCnLockFreeLinkedList.Add(Key, Value: TObject);
var
  P: PCnLockFreeLinkedNode;
begin
  P := FHead.Next;
  while P <> nil do
  begin
    if P^.Key = Key then
    begin
      P^.Value := Value;
      Exit;
    end;
    P := P^.Next;
  end;

  // û�ҵ� Key�����
  Append(Key, Value);
end;

procedure TCnLockFreeLinkedList.Append(Key, Value: TObject);
var
  Node, P: PCnLockFreeLinkedNode;
begin
  Node := CreateNode;
  Node^.Key := Key;
  Node^.Value := Value;

  // ԭ�Ӳ�����������β�� Tail���ж� Tail �� Next �Ƿ��� nil������ Tail �� Next ��Ϊ NewNode
  // ��������߳��޸��� Tail����������ȡ���� Tail ����β�ͣ���ô Tail �� Next �Ͳ�Ϊ nil���͵�����
  repeat
    P := GetTailNode;
  until CnAtomicCompareAndSet(Pointer(P^.Next), Pointer(Node), nil);
end;

procedure TCnLockFreeLinkedList.Clear;
var
  P, N: PCnLockFreeLinkedNode;
begin
  P := FHead.Next;
  while P <> nil do
  begin
    N := P;
    P := P^.Next;
    FreeNode(N);
  end;
  FHead := @FNode;
end;

constructor TCnLockFreeLinkedList.Create;
begin
  inherited;
  FNode.Key := nil;
  FNode.Value := nil;
  FNode.Next := nil;

  FHead := @FNode;
end;

function TCnLockFreeLinkedList.CreateNode: PCnLockFreeLinkedNode;
begin
  New(Result);
  Result^.Next := nil;
end;

destructor TCnLockFreeLinkedList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TCnLockFreeLinkedList.FreeNode(Node: PCnLockFreeLinkedNode);
begin
  Dispose(Node);
end;

function TCnLockFreeLinkedList.GetCount: Integer;
var
  P: PCnLockFreeLinkedNode;
begin
  Result := 0;
  P := FHead.Next;
  while P <> nil do
  begin
    Inc(Result);
    P := P^.Next;
  end;
end;

function TCnLockFreeLinkedList.GetTailNode: PCnLockFreeLinkedNode;
begin
  Result := FHead;
  while Result^.Next <> nil do
    Result := Result^.Next;
end;

function TCnLockFreeLinkedList.HasKey(Key: TObject): Boolean;
var
  P: PCnLockFreeLinkedNode;
begin
  Result := False;
  P := FHead.Next;
  while P <> nil do
  begin
    if P^.Key = Key then
    begin
      Result := True;
      Exit;
    end;
    P := P^.Next;
  end;
end;

function TCnLockFreeLinkedList.Remove(Key: TObject): Boolean;
begin
  // TODO: ����Ƚ���ʵ��
  raise Exception.Create('NOT Implemented');
end;

end.
