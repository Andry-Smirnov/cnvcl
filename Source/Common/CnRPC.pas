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

unit CnRPC;
{* |<PRE>
================================================================================
* ������ƣ�������������
* ��Ԫ���ƣ�JSON-RPC 2.0 ��������װ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע������ CnJSON �� JSON-RPC 2.0 �����ݰ���������װ��Ԫ
* ����ƽ̨��PWin7 + Delphi 7
* ���ݲ��ԣ�PWin7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.06.14 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

{$I CnPack.inc}

interface

uses
  SysUtils, Classes, Contnrs, CnJSON;

const
  CN_JSON_RPC_ERROR_PARSE_ERROR        = -32700;
  CN_JSON_RPC_ERROR_INVALID_REQUEST    = -32600;
  CN_JSON_RPC_ERROR_METHOD_NOT_FOUND   = -32601;
  CN_JSON_RPC_ERROR_INVALID_PARAMS     = -32602;
  CN_JSON_RPC_ERROR_INTERNAL_ERROR     = -32603;

  CN_JSON_RPC_ERROR_SERVER_ERROR_BEGIN = -32000;
  CN_JSON_RPC_ERROR_SERVER_ERROR_END   = -32099;

type
  TCnJSONRPCBase = class(TPersistent)
  {* JSON-RPC ���ݰ�����}
  private
    FVersion: string;
    FID: Integer;
  protected
    procedure DoToJSON(Root: TCnJSONObject); virtual; abstract;
    {* �������Ҫ��������ݹ�����ת���� JSON}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToJSON(UseFormat: Boolean = True; Indent: Integer = 0): AnsiString;
    {* ���� UTF8 ��ʽ�� JSON �ַ���}

    property Version: string read FVersion write FVersion;
    {* �汾���ַ�����Ĭ�� 2.0}
    property ID: Integer read FID write FID;
    {* ��ʶ�����ڹ�������ͻ�Ӧ}
  end;

  TCnJSONRPCRequest = class(TCnJSONRPCBase)
  {* JSON-RPC ������}
  private
    FMethod: string;
    FParams: TCnJSONValue;
    procedure SetParams(const Value: TCnJSONValue);
  protected
    procedure DoToJSON(Root: TCnJSONObject); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    property Method: string read FMethod write FMethod;
    {* ���õķ�����}
    property Params: TCnJSONValue read FParams write SetParams;
    {* ������������ TCnJSONObject}
  end;

  TCnJSONRPCResponse = class(TCnJSONRPCBase)
  {* JSON-RPC ��Ӧ��}
  private
    FRPCResult: TCnJSONValue;
    procedure SetRPCResult(const Value: TCnJSONValue);
  protected
    procedure DoToJSON(Root: TCnJSONObject); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    property RPCResult: TCnJSONValue read FRPCResult write SetRPCResult;
    {* ����������� TCnJSONObject}
  end;

  TCnJSONRPCError = class(TCnJSONRPCBase)
  {* JSON-RPC ������}
  private
    FErrorData: TCnJSONValue;
    FErrorCode: Integer;
    FErrorMessage: string;
    procedure SetErrorData(const Value: TCnJSONValue);
  protected
    procedure DoToJSON(Root: TCnJSONObject); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    property ErrorCode: Integer read FErrorCode write FErrorCode;
    {* ������}
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
    {* ������Ϣ}
    property ErrorData: TCnJSONValue read FErrorData write SetErrorData;
    {* �������ݣ������� TCnJSONObject}
  end;

  TCnJSONRPCNoficiation = class(TCnJSONRPCBase)
  {* JSON-RPC ֪ͨ��}
  private
    FMethod: string;
    FParams: TCnJSONValue;
    procedure SetParams(const Value: TCnJSONValue);
  protected
    procedure DoToJSON(Root: TCnJSONObject); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    property Method: string read FMethod write FMethod;
    {* ���õķ�����}
    property Params: TCnJSONValue read FParams write SetParams;
    {* ������������ TCnJSONObject}
  end;

function CnParseJSONRPC(const JsonStr: AnsiString): TCnJSONRPCBase;
{* ���� UTF8 ��ʽ�� JSON �ַ���Ϊһ�� JSONRPC ʵ������ method ��Ϊ
  Request �� Notification���� ID ��Ϊǰ�߷���Ϊ���ߣ��� error ���Ǵ���
  �� result ���� Response}

function CnParseJSONRPCs(const JsonStr: AnsiString; RPCs: TObjectList): Boolean;
{* ��� JSON �ַ����� [ ��ͷ ] ��β���򱾺������������鷽ʽ�����ɶ�� JSONRPC ����
  ������ RPCs �б��У����ؽ����Ƿ�ɹ�������ַ��������� [ ��ͷ���򷵻� False}

implementation

const
  SCN_JSONRPC_VERSION       = 'jsonrpc';
  SCN_JSONRPC_METHOD        = 'method';
  SCN_JSONRPC_PARAMS        = 'params';
  SCN_JSONRPC_RESULT        = 'result';
  SCN_JSONRPC_ID            = 'id';
  SCN_JSONRPC_ERROR         = 'error';
  SCN_JSONRPC_ERRORMESSAGE  = 'message';
  SCN_JSONRPC_ERRORCODE     = 'code';
  SCN_JSONRPC_ERRORDATA     = 'data';

  SCN_JSONRPC_VERSION_VALUE = '2.0';
  CN_INVALID_ID             = -1;

function ParseJSONObjectToRPC(Obj: TCnJSONObject): TCnJSONRPCBase;
var
  Tmp: TCnJSONObject;
begin
  Result := nil;
  if Obj <> nil then
  begin
    if Obj[SCN_JSONRPC_RESULT] <> nil then
    begin
      Result := TCnJSONRPCResponse.Create;
      TCnJSONRPCResponse(Result).RPCResult := Obj[SCN_JSONRPC_RESULT].Clone;
    end
    else if (Obj[SCN_JSONRPC_ERROR] <> nil) and (Obj[SCN_JSONRPC_ERROR] is TCnJSONObject) then
    begin
      Result := TCnJSONRPCError.Create;
      Tmp := TCnJSONObject(Obj[SCN_JSONRPC_ERROR]);

      if Tmp[SCN_JSONRPC_ERRORCODE] <> nil then
        TCnJSONRPCError(Result).ErrorCode := Tmp[SCN_JSONRPC_ERRORCODE].AsInteger;
      if Tmp[SCN_JSONRPC_ERRORMESSAGE] <> nil then
        TCnJSONRPCError(Result).ErrorMessage := Tmp[SCN_JSONRPC_ERRORMESSAGE].AsString;

      if Tmp[SCN_JSONRPC_ERRORDATA] <> nil then
        TCnJSONRPCError(Result).ErrorData := Tmp[SCN_JSONRPC_ERRORDATA].Clone;
    end
    else if Obj[SCN_JSONRPC_METHOD] <> nil then
    begin
      if Obj[SCN_JSONRPC_ID] <> nil then
      begin
        Result := TCnJSONRPCRequest.Create;
        TCnJSONRPCRequest(Result).Method := Obj[SCN_JSONRPC_METHOD].AsString;

        if Obj[SCN_JSONRPC_PARAMS] <> nil then
          TCnJSONRPCRequest(Result).Params := Obj[SCN_JSONRPC_PARAMS].Clone
        else
          TCnJSONRPCRequest(Result).Params := nil;
      end
      else
      begin
        Result := TCnJSONRPCNoficiation.Create;
        TCnJSONRPCNoficiation(Result).Method := Obj[SCN_JSONRPC_METHOD].AsString;

        if Obj[SCN_JSONRPC_PARAMS] <> nil then
          TCnJSONRPCNoficiation(Result).Params := Obj[SCN_JSONRPC_PARAMS].Clone
        else
          TCnJSONRPCNoficiation(Result).Params := nil;
      end;
    end;

    // ����ͨ������
    if Result <> nil then
    begin
      if Obj[SCN_JSONRPC_VERSION] <> nil then
        Result.Version := Obj[SCN_JSONRPC_VERSION].AsString;
      if Obj[SCN_JSONRPC_ID] <> nil then
        Result.ID := Obj[SCN_JSONRPC_ID].AsInteger;
    end;
  end;
end;

function CnParseJSONRPC(const JsonStr: AnsiString): TCnJSONRPCBase;
var
  Obj: TCnJSONObject;
  S: AnsiString;
begin
  Result := nil;
  S := Trim(JsonStr);
  if (Length(S) > 2) and (S[1] = '{') then
  begin
    Obj := CnJSONParse(S);
    try
      Result := ParseJSONObjectToRPC(Obj);
    finally
      Obj.Free;
    end;
  end;  
end;

function CnParseJSONRPCs(const JsonStr: AnsiString; RPCs: TObjectList): Boolean;
var
  I: Integer;
  Arr: TCnJSONArray;
  Rpc: TCnJSONRPCBase;
begin
  Arr := CnJSONParseToArray(JsonStr);
  Result := Arr <> nil;

  if Result and (Arr.Count > 0) then
  begin
    for I := 0 to Arr.Count - 1 do
    begin
      if Arr[I] is TCnJSONObject then
      begin
        Rpc := ParseJSONObjectToRPC(TCnJSONObject(Arr[I]));
        if Rpc <> nil then
          RPCs.Add(Rpc);
      end;
    end;
  end;
end;

{ TCnJSONRPCBase }

constructor TCnJSONRPCBase.Create;
begin
  inherited;
  FVersion := SCN_JSONRPC_VERSION_VALUE;
  FID := CN_INVALID_ID;
end;

destructor TCnJSONRPCBase.Destroy;
begin

  inherited;
end;

function TCnJSONRPCBase.ToJSON(UseFormat: Boolean;
  Indent: Integer): AnsiString;
var
  Root: TCnJSONObject;
begin
  Root := TCnJSONObject.Create;
  try
    Root.AddPair(SCN_JSONRPC_VERSION, FVersion);
    DoToJSON(Root);

    if FID <> CN_INVALID_ID then
      Root.AddPair(SCN_JSONRPC_ID, FID);

    Result := Root.ToJSON(UseFormat, Indent);
  finally
    Root.Free;
  end;
end;

{ TCnJSONRPCError }

constructor TCnJSONRPCError.Create;
begin
  inherited;
  FErrorData := TCnJSONObject.Create;
end;

destructor TCnJSONRPCError.Destroy;
begin
  FreeAndNil(FErrorData);
  inherited;
end;

procedure TCnJSONRPCError.DoToJSON(Root: TCnJSONObject);
var
  Obj: TCnJSONObject;
begin
  Obj := TCnJSONObject.Create;
  Obj.AddPair(SCN_JSONRPC_ERRORCODE, FErrorCode);
  Obj.AddPair(SCN_JSONRPC_ERRORMESSAGE, FErrorMessage);
  Obj.AddPair(SCN_JSONRPC_ERRORDATA, FErrorData.Clone);
  Root.AddPair(SCN_JSONRPC_ERROR, Obj);
end;

procedure TCnJSONRPCError.SetErrorData(const Value: TCnJSONValue);
begin
  if FErrorData <> Value then
  begin
    FreeAndNil(FErrorData);
    FErrorData := Value;
  end;
end;

{ TCnJSONRPCRequest }

constructor TCnJSONRPCRequest.Create;
begin
  inherited;
  FParams := TCnJSONObject.Create;
end;

destructor TCnJSONRPCRequest.Destroy;
begin
  FreeAndNil(FParams);
  inherited;
end;

procedure TCnJSONRPCRequest.DoToJSON(Root: TCnJSONObject);
begin
  Root.AddPair(SCN_JSONRPC_METHOD, FMethod);
  Root.AddPair(SCN_JSONRPC_PARAMS, FParams.Clone);
end;

procedure TCnJSONRPCRequest.SetParams(const Value: TCnJSONValue);
begin
  if FParams <> Value then
  begin
    FreeAndNil(FParams);
    FParams := Value;
  end;
end;

{ TCnJSONRPCResponse }

constructor TCnJSONRPCResponse.Create;
begin
  inherited;
  FRPCResult := TCnJSONObject.Create;
end;

destructor TCnJSONRPCResponse.Destroy;
begin
  FreeAndNil(FRPCResult);
  inherited;
end;

procedure TCnJSONRPCResponse.DoToJSON(Root: TCnJSONObject);
begin
  Root.AddPair(SCN_JSONRPC_RESULT, FRPCResult.Clone);
end;

procedure TCnJSONRPCResponse.SetRPCResult(const Value: TCnJSONValue);
begin
  if FRPCResult <> Value then
  begin
    FreeAndNil(FRPCResult);
    FRPCResult := Value;
  end;
end;

{ TCnJSONRPCNoficiation }

constructor TCnJSONRPCNoficiation.Create;
begin
  inherited;
  FParams := TCnJSONObject.Create;
end;

destructor TCnJSONRPCNoficiation.Destroy;
begin
  FreeAndNil(FParams);
  inherited;
end;

procedure TCnJSONRPCNoficiation.DoToJSON(Root: TCnJSONObject);
begin
  Root.AddPair(SCN_JSONRPC_METHOD, FMethod);
  Root.AddPair(SCN_JSONRPC_PARAMS, FParams.Clone);
end;

procedure TCnJSONRPCNoficiation.SetParams(const Value: TCnJSONValue);
begin
  if FParams <> Value then
  begin
    FreeAndNil(FParams);
    FParams := Value;
  end;
end;

end.
