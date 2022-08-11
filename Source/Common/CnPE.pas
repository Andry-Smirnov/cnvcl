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

unit CnPE;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����
* ��Ԫ���ƣ����� PE �ļ��Ĺ��ߵ�Ԫ
* ��Ԫ���ߣ���Х��liuxiao@cnpack.org��
* ��    ע���õ�Ԫʵ���˲��� PE ��ʽ����
*           ����ļ���һ������λ��������ļ�ͷ��һ���ֽڵ�ƫ�Ƴ�Ϊ��Ե�ַ��RA��
*                 ���ؽ��ڴ��һ����������ڳ���ʼ����ƫ�Ƴ�Ϊ��������ַ��RVA��
*           PE �ļ��д󲿷�ƫ�ƶ��� RVA���ٲ��ֺͼ����޹ص�ʹ�� RA
*           PE �ļ��ĸ�ʽ���������£�
*           +------------------------------------------------------------------+
*           | IMAGE_DOS_HEADER  64 �ֽڡ�MZ��e_lfanew �� PE ͷ���ļ�ƫ��
*           +------------------------------------------------------------------+
*           | IMAGE_NT_HEADERS  -- Signature 4 �ֽ�
*           |                   -- IMAGE_FILE_HEADER 40 �ֽ�
*           |                      -- ���� x86/x64��Section ��������������ѡ��Ĵ�С
*           |                   -- IMAGE_OPTIONAL_HEADER 32/64 λ�� $E0/$F0 �ֽ�
*           |                      -- ������ַ����ڡ��汾�š��������Ŀ¼���
*           |                      -- ����Ŀ¼���е��������ܶ�������������Ϣ��
*           +------------------------------------------------------------------+
*           | IMAGE_SECTION_HEADER[] ���飬ÿ�� 40 �ֽ�
*           |                   -- �������֡�����ַ����С���ļ�ƫ�ơ�Section ���Ե�
*           +------------------------------------------------------------------+
*           | ��϶�������� RA �� RVA �Ĳ��죩
*           +------------------------------------------------------------------+
*           | ���� Section ����
*           +------------------------------------------------------------------+
*           | ���� Section ����
*           +------------------------------------------------------------------+
* ����ƽ̨��PWin7 + Delphi 5
* ���ݲ��ԣ�Win32/Win64
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2022.08.07
*               ������Ԫ,ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, CnNative;

type
  ECnPEException = class(Exception);

  TCnPEParseMode = (ppmInvalid, ppmFile, ppmMemoryModule);
  {* ���� PE ��ģʽ���Ƿ������ļ����ڴ�ģ�飨�Ѽ������ڴ沢�ض�λ���ģ�}

  TCnPEExportItem = packed record
  {* ����һ���������������֡��������ʵ��ַ}
    Name: string;
    Ordinal: DWORD;
    Address: Pointer;
  end;
  PCnPEExportItem = ^TCnPEExportItem;

  TCnPE = class
  {* ����һ�� PE �ļ����࣬���� 32 λ�� 64 λ PE �ļ�������ҲҪ 32 λ�� 64 λ������}
  private
    FMode: TCnPEParseMode;
    FPEFile: string;
    FModule: HMODULE;
    FFileHandle: THandle;
    FMapHandle: THandle;
    FBaseAddress: Pointer;
    // �ļ�ģʽʱ�Ǳ� Map ���ڴ�ĵ͵�ַ���ڴ�ģʽʱ�� HModule���� PE ����չ����Ļ���ַ

    FDosHeader: PImageDosHeader;
    FNtHeaders: PImageNtHeaders;
    FFileHeader: PImageFileHeader;
    FOptionalHeader: Pointer;
    // 32 λ PE �ļ�ʱָ�������� PImageOptionalHeader��64 λʱָ�������� PImageOptionalHeader64
    FSectionHeader: PImageSectionHeader; // ������ OptionalHeader ��

    FDirectoryExport: PImageExportDirectory; // �����Ľṹ
    FExportItems: array of TCnPEExportItem;  // ��������������

    FOptionalMajorLinkerVersion: Byte;
    FOptionalMinorLinkerVersion: Byte;
    FOptionalCheckSum: DWORD;
    FOptionalSizeOfInitializedData: DWORD;
    FOptionalSizeOfStackReserve: DWORD;
    FOptionalSizeOfUninitializedData: DWORD;
    FOptionalBaseOfData: DWORD;
    FOptionalSizeOfHeapReserve: DWORD;
    FOptionalLoaderFlags: DWORD;
    FFileTimeDateStamp: DWORD;
    FOptionalSizeOfStackCommit: DWORD;
    FOptionalImageBase: DWORD;
    FOptionalAddressOfEntryPoint: DWORD;
    FOptionalNumberOfRvaAndSizes: DWORD;
    FOptionalSizeOfImage: DWORD;
    FFileNumberOfSymbols: DWORD;
    FOptionalSectionAlignment: DWORD;
    FOptionalSizeOfHeaders: DWORD;
    FOptionalSizeOfCode: DWORD;
    FOptionalSizeOfHeapCommit: DWORD;
    FOptionalBaseOfCode: DWORD;
    FFilePointerToSymbolTable: DWORD;
    FOptionalWin32VersionValue: DWORD;
    FOptionalFileAlignment: DWORD;
    FDosLfanew: LongInt;
    FDosSs: Word;
    FOptionalMagic: Word;
    FDosCblp: Word;
    FDosCrlc: Word;
    FDosSp: Word;
    FFileCharacteristics: Word;
    FDosOeminfo: Word;
    FDosMinalloc: Word;
    FDosMaxalloc: Word;
    FDosLfarlc: Word;
    FOptionalMinorOperatingSystemVersion: Word;
    FOptionalMinorSubsystemVersion: Word;
    FDosCs: Word;
    FOptionalMajorImageVersion: Word;
    FOptionalSubsystem: Word;
    FOptionalDllCharacteristics: Word;
    FFileSizeOfOptionalHeader: Word;
    FOptionalMinorImageVersion: Word;
    FDosIp: Word;
    FOptionalMajorOperatingSystemVersion: Word;
    FDosOvno: Word;
    FFileNumberOfSections: Word;
    FDosMagic: Word;
    FDosCparhdr: Word;
    FDosOemid: Word;
    FDosCp: Word;
    FFileMachine: Word;
    FDosCsum: Word;
    FOptionalMajorSubsystemVersion: Word;
    FSignature: DWORD;
    FOptionalSizeOfHeapCommit64: TUInt64;
    FOptionalSizeOfStackCommit64: TUInt64;
    FOptionalSizeOfStackReserve64: TUInt64;
    FOptionalSizeOfHeapReserve64: TUInt64;
    FOptionalImageBase64: TUInt64;
    FExportName: AnsiString;
    FExportNumberOfNames: DWORD;
    FExportNumberOfFunctions: DWORD;
    FExportBase: DWORD;
    function GetDataDirectorySize(Index: Integer): DWORD;
    function GetDataDirectory(Index: Integer): PImageDataDirectory;
    function GetDataDirectoryVirtualAddress(Index: Integer): DWORD;
    function GetDataDirectoryContent(Index: Integer): Pointer;
    function GetSectionHeader(Index: Integer): PImageSectionHeader;
    function GetIsDll: Boolean;
    function GetIsExe: Boolean;
    function GetIsWin32: Boolean;
    function GetIsWin64: Boolean;
    function GetIsSys: Boolean;
    function GetDataDirectoryCount: Integer;
    function GetSectionCount: Integer;
    function GetSectionCharacteristics(Index: Integer): DWORD;
    function GetSectionContent(Index: Integer): Pointer;
    function GetSectionVirtualSize(Index: Integer): DWORD;
    function GetSectionName(Index: Integer): AnsiString;
    function GetSectionNumberOfLinenumbers(Index: Integer): Word;
    function GetSectionNumberOfRelocations(Index: Integer): Word;
    function GetSectionPointerToLinenumbers(Index: Integer): DWORD;
    function GetSectionPointerToRawData(Index: Integer): DWORD;
    function GetSectionPointerToRelocations(Index: Integer): DWORD;
    function GetSectionSizeOfRawData(Index: Integer): DWORD;
    function GetSectionVirtualAddress(Index: Integer): DWORD;
    function GetSectionContentSize(Index: Integer): DWORD;
    function GetExportFunctionItem(Index: Integer): PCnPEExportItem;

  protected
    function RvaToActual(Rva: DWORD): Pointer;
    {* RVA ת�����ڴ��е���ʵ��ַ������ֱ�ӷ���}
    function GetSectionHeaderFromRva(Rva: DWORD): PImageSectionHeader;
    {* ���� RVA �ҵ��������ĸ� Section ������� SectionHeader}

    procedure ParseHeaders;
    procedure ParseExports;
  public
    constructor Create(const APEFileName: string); overload;
    constructor Create(AModuleHandle: HMODULE); overload;

    destructor Destroy; override;

    procedure Parse;
    {* ���� PE �ļ������óɹ������ʹ���ڲ�������}

    property Mode: TCnPEParseMode read FMode;
    {* PE ����ģʽ}

    // Dos ��ͷ�����Ա�ʾ�� DosHeader �е�
    property DosMagic: Word read FDosMagic;
    {* EXE��־���ַ� MZ}
    property DosCblp: Word read FDosCblp;
    {* ���һҳ�е��ֽ���}
    property DosCp: Word read FDosCp;
    {* �ļ��е�ҳ��}
    property DosCrlc: Word read FDosCrlc;
    {* �ض�λ���е�ָ����}
    property DosCparhdr: Word read FDosCparhdr;
    {* ͷ���ߴ磬�Զ�Ϊ��λ}
    property DosMinalloc: Word read FDosMinalloc;
    {* �������С���Ӷ�}
    property DosMaxalloc: Word read FDosMaxalloc;
    {* �������󸽼Ӷ�}
    property DosSs: Word read FDosSs;
    {* ��ʼ�� SS ֵ�����ƫ������}
    property DosSp: Word read FDosSp;
    {* ��ʼ�� SP ֵ�����ƫ������}
    property DosCsum: Word read FDosCsum;
    {* У���                         }
    property DosIp: Word read FDosIp;
    {* ��ʼ�� IP ֵ}
    property DosCs: Word read FDosCs;
    {* ��ʼ�� CS ֵ}
    property DosLfarlc: Word read FDosLfarlc;
    {* �ض�λ����ֽ�ƫ����}
    property DosOvno: Word read FDosOvno;
    {* ���Ǻ�}
    // DosRes: array [0..3] of Word;    { Reserved words}
    property DosOemid: Word read FDosOemid;
    {* OEM ��ʶ��}
    property DosOeminfo: Word read FDosOeminfo;
    {* OEM ��Ϣ}
    // DosRes2: array [0..9] of Word;   { Reserved words}
    property DosLfanew: LongInt read FDosLfanew;
    {* PE ͷ������ļ���ƫ�Ƶ�ַ��Ҳ����ָ�� NtHeader}

    property Signature: DWORD read FSignature;
    {* PE �ļ���ʶ��PE00}

    // File ��ͷ�����Ա�ʾ�� NtHeader �е� FileHeader �е�
    property FileMachine: Word read FFileMachine;
    {* ����ƽ̨}
    property FileNumberOfSections: Word read FFileNumberOfSections;
    {* Section ������}
    property FileTimeDateStamp: DWORD read FFileTimeDateStamp;
    {* �ļ��������ں�ʱ��}
    property FilePointerToSymbolTable: DWORD read FFilePointerToSymbolTable;
    {* ָ����ű�}
    property FileNumberOfSymbols: DWORD read FFileNumberOfSymbols;
    {* ���ű��еķ�������}
    property FileSizeOfOptionalHeader: Word read FFileSizeOfOptionalHeader;
    {* OptionalHeader �ṹ�ĳ���}
    property FileCharacteristics: Word read FFileCharacteristics;
    {* �ļ�����}

    // Optional ��ͷ�����Ա�ʾ�� NtHeader �е� OptionalHeader �е�
    { Standard fields. }
    property OptionalMagic: Word read FOptionalMagic;
    property OptionalMajorLinkerVersion: Byte read FOptionalMajorLinkerVersion;
    property OptionalMinorLinkerVersion: Byte read FOptionalMinorLinkerVersion;
    property OptionalSizeOfCode: DWORD read FOptionalSizeOfCode;
    property OptionalSizeOfInitializedData: DWORD read FOptionalSizeOfInitializedData;
    property OptionalSizeOfUninitializedData: DWORD read FOptionalSizeOfUninitializedData;
    property OptionalAddressOfEntryPoint: DWORD read FOptionalAddressOfEntryPoint;
    property OptionalBaseOfCode: DWORD read FOptionalBaseOfCode;
    property OptionalBaseOfData: DWORD read FOptionalBaseOfData;
    { NT additional fields. }
    property OptionalImageBase: DWORD read FOptionalImageBase;
    property OptionalImageBase64: TUInt64 read FOptionalImageBase64;
    {* 64 λ���� UInt64}
    property OptionalSectionAlignment: DWORD read FOptionalSectionAlignment;
    property OptionalFileAlignment: DWORD read FOptionalFileAlignment;
    property OptionalMajorOperatingSystemVersion: Word read FOptionalMajorOperatingSystemVersion;
    property OptionalMinorOperatingSystemVersion: Word read FOptionalMinorOperatingSystemVersion;
    property OptionalMajorImageVersion: Word read FOptionalMajorImageVersion;
    property OptionalMinorImageVersion: Word read FOptionalMinorImageVersion;
    property OptionalMajorSubsystemVersion: Word read FOptionalMajorSubsystemVersion;
    property OptionalMinorSubsystemVersion: Word read FOptionalMinorSubsystemVersion;
    property OptionalWin32VersionValue: DWORD read FOptionalWin32VersionValue;
    property OptionalSizeOfImage: DWORD read FOptionalSizeOfImage;
    property OptionalSizeOfHeaders: DWORD read FOptionalSizeOfHeaders;
    property OptionalCheckSum: DWORD read FOptionalCheckSum;
    property OptionalSubsystem: Word read FOptionalSubsystem;
    property OptionalDllCharacteristics: Word read FOptionalDllCharacteristics;
    property OptionalSizeOfStackReserve: DWORD read FOptionalSizeOfStackReserve;
    property OptionalSizeOfStackReserve64: TUInt64 read FOptionalSizeOfStackReserve64;
    {* 64 λ���� UInt64}
    property OptionalSizeOfStackCommit: DWORD read FOptionalSizeOfStackCommit;
    property OptionalSizeOfStackCommit64: TUInt64 read FOptionalSizeOfStackCommit64;
    {* 64 λ���� UInt64}
    property OptionalSizeOfHeapReserve: DWORD read FOptionalSizeOfHeapReserve;
    property OptionalSizeOfHeapReserve64: TUInt64 read FOptionalSizeOfHeapReserve64;
    {* 64 λ���� UInt64}
    property OptionalSizeOfHeapCommit: DWORD read FOptionalSizeOfHeapCommit;
    property OptionalSizeOfHeapCommit64: TUInt64 read FOptionalSizeOfHeapCommit64;
    {* 64 λ���� UInt64}
    property OptionalLoaderFlags: DWORD read FOptionalLoaderFlags;
    property OptionalNumberOfRvaAndSizes: DWORD read FOptionalNumberOfRvaAndSizes;
    {* DataDirectory �� Size��һ��Ϊ 16}

    // �������� DataDirectory ��Ϣ
    property DataDirectoryCount: Integer read GetDataDirectoryCount;
    {* DataDirectory ���������ڲ��� NumberOfRvaAndSizes}
    property DataDirectory[Index: Integer]: PImageDataDirectory read GetDataDirectory;
    {* �� Index �� DataDirectory ��ָ�룬0 �� 15}
    property DataDirectoryContent[Index: Integer]: Pointer read GetDataDirectoryContent;
    {* �� Index �� DataDirectory ��ʵ�ʵ�ַ��ͨ���˵�ַ����ֱ�ӷ���������}

    property DataDirectoryVirtualAddress[Index: Integer]: DWORD read GetDataDirectoryVirtualAddress;
    {* �� Index �� DataDirectory ��ƫ�Ƶ�ַ}
    property DataDirectorySize[Index: Integer]: DWORD read GetDataDirectorySize;
    {* �� Index �� DataDirectory �ĳߴ磬��λ�ֽ�}

    // Sections ��Ϣ������ PE ������Ӧ�ý� Section �������ļ�ƫ�� PointerToRawData ��������ӳ�����ڴ�� VritualAddress ��
    property SectionCount: Integer read GetSectionCount;
    {* Section ���������ڲ��� NumberOfSections}
    property SectionHeader[Index: Integer]: PImageSectionHeader read GetSectionHeader;
    {* �� Index �� SectionHeader ��ָ�룬0 ��ʼ}
    property SectionContent[Index: Integer]: Pointer read GetSectionContent;
    {* �� Index �� Section ��ʵ�ʵ�ַ��ͨ���˵�ַ����ֱ�ӷ��������ݣ��ڲ�Ҫ�����ļ�ģʽ�����ڴ����ģʽ}
    property SectionContentSize[Index: Integer]: DWORD read GetSectionContentSize;
    {* �� Index �� Section ��ʵ�ʴ�С��ȡ VirtualSize �� SizeOfRawData �еĽ�С��}

    property SectionName[Index: Integer]: AnsiString read GetSectionName;
    {* �� Index �� Section ������}
    property SectionVirtualSize[Index: Integer]: DWORD read GetSectionVirtualSize;
    {* �� Index �� Section �� Misc �����ֶε����ݣ�һ���� VirtualSize��
      ָ���ؽ��ڴ���ʵ�ʴ�С}
    property SectionVirtualAddress[Index: Integer]: DWORD read GetSectionVirtualAddress;
    {* �� Index �� Section �� RVA ƫ�ƣ�Ҳ���� PE ���ؽ��ڴ��ý���Ի�ַ��ƫ�ƣ�RVA��}
    property SectionSizeOfRawData[Index: Integer]: DWORD read GetSectionSizeOfRawData;
    {* �� Index �� Section ���ļ��е�ԭʼ�ߴ磬һ�㱻����������ܱ� VirtualSize ����}
    property SectionPointerToRawData[Index: Integer]: DWORD read GetSectionPointerToRawData;
    {* �� Index �� Section ���ļ��е�ƫ������RA��}
    property SectionPointerToRelocations[Index: Integer]: DWORD read GetSectionPointerToRelocations;
    {* �� Index �� Section �� PointerToRelocations}
    property SectionPointerToLinenumbers[Index: Integer]: DWORD read GetSectionPointerToLinenumbers;
    {* �� Index �� Section �� PointerToLinenumbers}
    property SectionNumberOfRelocations[Index: Integer]: Word read GetSectionNumberOfRelocations;
    {* �� Index �� Section �� NumberOfRelocations}
    property SectionNumberOfLinenumbers[Index: Integer]: Word read GetSectionNumberOfLinenumbers;
    {* �� Index �� Section �� NumberOfLinenumbers}
    property SectionCharacteristics[Index: Integer]: DWORD read GetSectionCharacteristics;
    {* �� Index �� Section �� Characteristics}

    // ������ϸ��һЩ�ض����� 32 ���� 64�����ԡ�����������������Ϣ��
    property IsWin32: Boolean read GetIsWin32;
    {* �� PE �ļ��Ƿ� Win32 ��ʽ}
    property IsWin64: Boolean read GetIsWin64;
    {* �� PE �ļ��Ƿ� Win64 ��ʽ}
    property IsExe: Boolean read GetIsExe;
    {* �� PE �ļ��Ƿ�Ϊ�������е� EXE}
    property IsDll: Boolean read GetIsDll;
    {* �� PE �ļ��Ƿ� DLL}
    property IsSys: Boolean read GetIsSys;
    {* �� PE �ļ��Ƿ� SYS �ļ�}

    // �������Ϣ
    property ExportName: AnsiString read FExportName;
    {* ��������ƣ�һ���� DLL �ļ���}
    property ExportBase: DWORD read FExportBase;
    {* �����ĺ��������ʼֵ}
    property ExportNumberOfFunctions: DWORD read FExportNumberOfFunctions;
    {* ����ĺ������������������ֵĺ�û���ֵ�}
    property ExportNumberOfNames: DWORD read FExportNumberOfNames;
    {* �������ַ�ʽ����ĺ�������}
    property ExportFunctionItem[Index: Integer]: PCnPEExportItem read GetExportFunctionItem;
    {* ��ȡ�� Index ����������ļ�¼ָ�룬Index �� 0 �� FExportNumberOfFunctions��ע�� Index ������ Ordinal}
  end;

implementation

resourcestring
  SCnPEOpenErrorFmt = 'Can NOT Open File ''%s''';
  SCnPEFormatError = 'NOT a Valid PE File';
  SCnPEDataDirectoryIndexErrorFmt = 'Data Directory Out Of Index %d';
  SCnPESectionIndexErrorFmt = 'Section Out Of Index %d';
  SCnPEExportIndexErrorFmt = 'Export Item Out Of Index %d';

const
  IMAGE_FILE_MACHINE_IA64                  = $0200;  { Intel 64 }
  IMAGE_FILE_MACHINE_AMD64                 = $8664;  { AMD64 (K8) }

  IMAGE_NT_OPTIONAL_HDR32_MAGIC            = $010B;
  IMAGE_NT_OPTIONAL_HDR64_MAGIC            = $020B;

type
{$IFDEF SUPPORT_32_AND_64}
  PImageOptionalHeader = PImageOptionalHeader32;
{$ENDIF}

  PImageOptionalHeader64 = ^TImageOptionalHeader64;
  TImageOptionalHeader64 = record
    { Standard fields. }
    Magic: Word;
    MajorLinkerVersion: Byte;
    MinorLinkerVersion: Byte;
    SizeOfCode: DWORD;
    SizeOfInitializedData: DWORD;
    SizeOfUninitializedData: DWORD;
    AddressOfEntryPoint: DWORD;
    BaseOfCode: DWORD;
    { NT additional fields. }
    ImageBase: TUInt64;
    SectionAlignment: DWORD;
    FileAlignment: DWORD;
    MajorOperatingSystemVersion: Word;
    MinorOperatingSystemVersion: Word;
    MajorImageVersion: Word;
    MinorImageVersion: Word;
    MajorSubsystemVersion: Word;
    MinorSubsystemVersion: Word;
    Win32VersionValue: DWORD;
    SizeOfImage: DWORD;
    SizeOfHeaders: DWORD;
    CheckSum: DWORD;
    Subsystem: Word;
    DllCharacteristics: Word;
    SizeOfStackReserve: TUInt64;
    SizeOfStackCommit: TUInt64;
    SizeOfHeapReserve: TUInt64;
    SizeOfHeapCommit: TUInt64;
    LoaderFlags: DWORD;
    NumberOfRvaAndSizes: DWORD;
    DataDirectory: packed array[0..IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1] of TImageDataDirectory;
  end;

function ExtractNewString(Ptr: Pointer; MaxLen: Integer = 0): AnsiString;
var
  L: Integer;
begin
  Result := '';
  if Ptr <> nil then
  begin
    L := StrLen(PAnsiChar(Ptr));
    if L > 0 then
      Result := StrNew(PAnsiChar(Ptr));
  end;
end;

function MapFileToPointer(const FileName: string; out FileHandle, MapHandle: THandle;
  out Address: Pointer): Boolean;
begin
  // ���ļ�������ӳ�䡢ӳ���ַ
  Result := False;
  FileHandle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ or
                FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or
                FILE_FLAG_SEQUENTIAL_SCAN, 0);

  if FileHandle <> INVALID_HANDLE_VALUE then
  begin
    MapHandle := CreateFileMapping(FileHandle, nil, PAGE_READONLY, 0, 0, nil);
    if MapHandle <> 0 then
    begin
      Address := MapViewOfFile(MapHandle, FILE_MAP_READ, 0, 0, 0);
      if Address <> nil then
      begin
        Result := True; // �ɹ�����ʱ������ֵ������Ч��
        Exit;
      end
      else // �������ӳ��ɹ�������ַӳ��ʧ�ܣ�����Ҫ�رմ���ӳ��
      begin
        CloseHandle(MapHandle);
        MapHandle := INVALID_HANDLE_VALUE;
      end;
    end
    else // ������ļ��ɹ���������ӳ��ʧ�ܣ�����Ҫ�ر��ļ�
    begin
      CloseHandle(FileHandle);
      MapHandle := INVALID_HANDLE_VALUE;
    end;
  end;
end;

function UnMapFileFromPointer(var FileHandle, MapHandle: THandle;
  var Address: Pointer): Boolean;
begin
  UnmapViewOfFile(Address);
  Address := nil;

  CloseHandle(MapHandle);
  MapHandle := INVALID_HANDLE_VALUE;

  CloseHandle(FileHandle);
  FileHandle := INVALID_HANDLE_VALUE;

  Result := True;
end;

{ TCnPE }

constructor TCnPE.Create(const APEFileName: string);
begin
  inherited Create;
  FFileHandle := INVALID_HANDLE_VALUE;
  FMapHandle := INVALID_HANDLE_VALUE;

  FPEFile := APEFileName;
  FMode := ppmFile;
end;

constructor TCnPE.Create(AModuleHandle: HMODULE);
begin
  inherited Create;
  FFileHandle := INVALID_HANDLE_VALUE;
  FMapHandle := INVALID_HANDLE_VALUE;

  FModule := AModuleHandle;
  FMode := ppmMemoryModule;
end;

destructor TCnPE.Destroy;
begin
  if FMode = ppmFile then
    UnMapFileFromPointer(FFileHandle, FMapHandle, FBaseAddress);
  inherited;
end;

function TCnPE.GetIsDll: Boolean;
begin
  Result := (FFileHeader^.Characteristics and IMAGE_FILE_DLL) <> 0;
end;

function TCnPE.GetIsExe: Boolean;
begin
  Result := ((FFileHeader^.Characteristics and IMAGE_FILE_EXECUTABLE_IMAGE) <> 0) // ������ָ���Ǵ������ˣ�û���Ӵ��󣬲�����ָ EXE
    and not GetIsDll and not GetIsSys;
end;

function TCnPE.GetIsSys: Boolean;
begin
  Result := (FFileHeader^.Characteristics and IMAGE_FILE_SYSTEM) <> 0;
end;

function TCnPE.GetIsWin32: Boolean;
begin
  Result := ((FFileHeader^.Machine and IMAGE_FILE_MACHINE_I386) <> 0) and
    (FOptionalMagic = IMAGE_NT_OPTIONAL_HDR32_MAGIC);
end;

function TCnPE.GetIsWin64: Boolean;
begin
  Result := ((FFileHeader^.Machine = IMAGE_FILE_MACHINE_IA64) or
    (FFileHeader^.Machine = IMAGE_FILE_MACHINE_AMD64)) and
    (FOptionalMagic = IMAGE_NT_OPTIONAL_HDR64_MAGIC);
end;

function TCnPE.GetSectionHeader(Index: Integer): PImageSectionHeader;
begin
  if (Index < 0) or (Index >= Integer(FFileNumberOfSections)) then
    raise ECnPEException.CreateFmt(SCnPESectionIndexErrorFmt, [Index]);

  Result := PImageSectionHeader(TCnNativeInt(FSectionHeader) + Index * SizeOf(TImageSectionHeader));
end;

procedure TCnPE.Parse;
begin
  if FMode = ppmFile then
  begin
    if not MapFileToPointer(FPEFile, FFileHandle, FMapHandle, FBaseAddress) then
      raise ECnPEException.CreateFmt(SCnPEOpenErrorFmt, [FPEFile]);
  end
  else if FMode = ppmMemoryModule then
  begin
    FBaseAddress := Pointer(FModule);
  end;

  // ������ͷ
  ParseHeaders;

  // ���������
  ParseExports;
end;


function TCnPE.GetDataDirectory(Index: Integer): PImageDataDirectory;
begin
  if (Index < 0) or (DWORD(Index) >= FOptionalNumberOfRvaAndSizes) then
    raise ECnPEException.CreateFmt(SCnPEDataDirectoryIndexErrorFmt, [Index]);

  if IsWin32 then
    Result := @(PImageOptionalHeader(FOptionalHeader)^.DataDirectory[Index])
  else if IsWin64 then
    Result := @(PImageOptionalHeader64(FOptionalHeader)^.DataDirectory[Index])
  else
    Result := nil;
end;

function TCnPE.GetDataDirectoryVirtualAddress(Index: Integer): DWORD;
var
  P: PImageDataDirectory;
begin
  P := DataDirectory[Index];
  if P <> nil then
    Result := P^.VirtualAddress
  else
    Result := 0;
end;

function TCnPE.GetDataDirectorySize(Index: Integer): DWORD;
var
  P: PImageDataDirectory;
begin
  P := DataDirectory[Index];
  if P <> nil then
    Result := P^.Size
  else
    Result := 0;
end;

function TCnPE.GetDataDirectoryContent(Index: Integer): Pointer;
var
  D: DWORD;
begin
  D := GetDataDirectoryVirtualAddress(Index);
  Result := RvaToActual(D);
end;

function TCnPE.GetDataDirectoryCount: Integer;
begin
  Result := FOptionalNumberOfRvaAndSizes;
end;

function TCnPE.GetSectionCount: Integer;
begin
  Result := FFileNumberOfSections;
end;

function TCnPE.GetSectionCharacteristics(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.Characteristics
  else
    Result := 0;
end;

function TCnPE.GetSectionContent(Index: Integer): Pointer;
var
  D: DWORD;
begin
  Result := nil;
  if FMode = ppmFile then
  begin
    D := GetSectionPointerToRawData(Index); // ���ļ�ƫ��
    if D = 0 then
      D := GetSectionVirtualAddress(Index); // �����ļ�ƫ��Ϊ 0 �����
    Result := RvaToActual(D);
  end
  else if FMode = ppmMemoryModule then
  begin
    D := GetSectionVirtualAddress(Index);   // ���Ѽ���չ������ڴ�ƫ��
    Result := RvaToActual(D);
  end;
end;

function TCnPE.GetSectionVirtualSize(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.Misc.VirtualSize
  else
    Result := 0;
end;

function TCnPE.GetSectionName(Index: Integer): AnsiString;
var
  P: PImageSectionHeader;
begin
  Result := '';
  P := SectionHeader[Index];
  if P <> nil then
    Result := ExtractNewString(@P^.Name[0]);
end;

function TCnPE.GetSectionNumberOfLinenumbers(Index: Integer): Word;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.NumberOfLinenumbers
  else
    Result := 0;
end;

function TCnPE.GetSectionNumberOfRelocations(Index: Integer): Word;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.NumberOfRelocations
  else
    Result := 0;
end;

function TCnPE.GetSectionPointerToLinenumbers(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.PointerToLinenumbers
  else
    Result := 0;
end;

function TCnPE.GetSectionPointerToRawData(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.PointerToRawData
  else
    Result := 0;
end;

function TCnPE.GetSectionPointerToRelocations(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.PointerToRelocations
  else
    Result := 0;
end;

function TCnPE.GetSectionSizeOfRawData(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.SizeOfRawData
  else
    Result := 0;
end;

function TCnPE.GetSectionVirtualAddress(Index: Integer): DWORD;
var
  P: PImageSectionHeader;
begin
  P := SectionHeader[Index];
  if P <> nil then
    Result := P^.VirtualAddress
  else
    Result := 0;
end;

function TCnPE.GetSectionContentSize(Index: Integer): DWORD;
var
  T: DWORD;
begin
  Result := GetSectionSizeOfRawData(Index);
  T := GetSectionVirtualSize(Index);
  if (T <> 0) and (Result <> 0) and (Result > T) then
    Result := T
  else if Result = 0 then
    Result := T;
end;

function TCnPE.RvaToActual(Rva: DWORD): Pointer;
var
  SH: PImageSectionHeader;
begin
  Result := nil;

  // PE �������ڴ�չ����ȫ�����ϴ˹���
  if FMode = ppmMemoryModule then
    Result := Pointer(TCnNativeUInt(FBaseAddress) + Rva)
  else if FMode = ppmFile then
  begin
    // ������ļ�ģʽ��ͷ�����ϴ˹��򣻸������������̿������ļ���ֱ�ӷ����в��
    SH := GetSectionHeaderFromRva(Rva);
    if SH <> nil then
    begin
      // �ҵ��� RVA �� Section ͷ�� RVA �ľ��룬�ټ��� Section ͷ���ļ�ƫ��
      Result := Pointer(TCnNativeUInt(FBaseAddress) +
        (Rva - SH^.VirtualAddress + SH^.PointerToRawData));
    end;
  end;
end;

function TCnPE.GetSectionHeaderFromRva(Rva: DWORD): PImageSectionHeader;
var
  I: Integer;
  SH: PImageSectionHeader;
  ER: DWORD;
begin
  Result := nil;
  for I := 0 to SectionCount - 1 do
  begin
    SH := GetSectionHeader(I);
    if SH^.SizeOfRawData = 0 then
      ER := SH^.Misc.VirtualSize
    else
      ER := SH^.SizeOfRawData;
    Inc(ER, SH^.VirtualAddress);
    if (SH^.VirtualAddress <= Rva) and (ER >= Rva) then
    begin
      Result := SH;
      Break;
    end;
  end;
end;

procedure TCnPE.ParseExports;
var
  I, J, T: DWORD;
  O: WORD;
  PAddress, PName: PDWORD;
  POrd: PWORD;
begin
  FDirectoryExport := PImageExportDirectory(DataDirectoryContent[IMAGE_DIRECTORY_ENTRY_EXPORT]);
  if FDirectoryExport = nil then
    Exit;

  if FDirectoryExport^.Name <> 0 then
    FExportName := ExtractNewString(RvaToActual(FDirectoryExport^.Name));
  FExportBase := FDirectoryExport^.Base;
  FExportNumberOfNames := FDirectoryExport^.NumberOfNames;
  FExportNumberOfFunctions := FDirectoryExport^.NumberOfFunctions;

  SetLength(FExportItems, FExportNumberOfFunctions);
  if FExportNumberOfFunctions <= 0 then
    Exit;

{
  AddressOfFunctions: ^PDWORD;     ָ���ַ���飬�±�� AddressOfNameOrdinals �л�ȡ��һ�� NumberOfFunctions ��
  AddressOfNames: ^PDWORD;         ָ����������  �±�����������ڵĶ�Ӧ��ֵ�������ַ����� RVA��һ�� NumberOfNames ����
  AddressOfNameOrdinals: ^PWord;   ָ��������飬�±������������ڵĶ�Ӧ��ֵ�� AddressOfFunctions ����±꣬һ�� NumberOfFunctions

  NumberOfFunctions ���ܴ��� NumberOfNames����Ĳ�����û���֡����������ĺ�����
  ����� AddressOfNameOrdinals ���ֵ�� Base
}

  // ���� AddressofFunctions ���˳�����У�ȡ����ַ
  PAddress := PDWORD(RvaToActual(DWORD(FDirectoryExport^.AddressOfFunctions)));
  PName := PDWORD(RvaToActual(DWORD(FDirectoryExport^.AddressOfNames)));
  POrd := PWORD(RvaToActual(DWORD(FDirectoryExport^.AddressOfNameOrdinals)));

  I := 0;
  while I < FExportNumberOfNames do
  begin
    FExportItems[I].Name := ExtractNewString(RvaToActual(PName^));  // ȡ���֡���ź͵�ַ

    O := POrd^;
    FExportItems[I].Ordinal := O + FExportBase;

    T := PDWORD(TCnNativeUInt(PAddress) + O * SizeOf(DWORD))^;
    if T <> 0 then
      FExportItems[I].Address := RvaToActual(T)
    else
      FExportItems[I].Address := nil;

    Inc(PName);
    Inc(POrd);
    Inc(I);
  end;

  J := I;
  I := 0;
  while I < FExportNumberOfFunctions - FExportNumberOfNames do
  begin
    O := POrd^;                                                    // û���ֵģ�ȡ��ź͵�ַ
    FExportItems[J + I].Ordinal := O + FExportBase;

    T := PDWORD(TCnNativeUInt(PAddress) + O * SizeOf(DWORD))^;
    if T <> 0 then
      FExportItems[J + I].Address := RvaToActual(T)
    else
      FExportItems[J + I].Address := nil;

    Inc(POrd);
    Inc(I);
  end;
end;

procedure TCnPE.ParseHeaders;
var
  P: PByte;
  OH32: PImageOptionalHeader;
  OH64: PImageOptionalHeader64;
begin
  FDosHeader := PImageDosHeader(FBaseAddress);
  if FDosHeader^.e_magic <> IMAGE_DOS_SIGNATURE then
    raise ECnPEException.Create(SCnPEFormatError);

  P := PByte(FBaseAddress);
  Inc(P, FDosHeader^._lfanew);

  FNtHeaders := PImageNtHeaders(P);
  if FNtHeaders^.Signature <> IMAGE_NT_SIGNATURE then
    raise ECnPEException.Create(SCnPEFormatError);

  FFileHeader := @FNtHeaders^.FileHeader;
  FOptionalHeader := @FNtHeaders^.OptionalHeader;

  // �ĸ��� Header ��ָ���ˣ���ʼ��ֵ������ DosHeader
  FDosMagic := FDosHeader^.e_magic;
  FDosCblp := FDosHeader^.e_cblp;
  FDosCp := FDosHeader^.e_cp;
  FDosCrlc := FDosHeader^.e_crlc;
  FDosCparhdr := FDosHeader^.e_cparhdr;
  FDosMinalloc := FDosHeader^.e_minalloc;
  FDosMaxalloc := FDosHeader^.e_maxalloc;
  FDosSs := FDosHeader^.e_ss;
  FDosSp := FDosHeader^.e_sp;
  FDosCsum := FDosHeader^.e_csum;
  FDosIp := FDosHeader^.e_ip;
  FDosCs := FDosHeader^.e_cs;
  FDosLfarlc := FDosHeader^.e_lfarlc;
  FDosOvno := FDosHeader^.e_ovno;
  FDosOemid := FDosHeader^.e_oemid;
  FDosOeminfo := FDosHeader^.e_oeminfo;
  FDosLfanew := FDosHeader^._lfanew;

  // Signature
  FSignature := FNtHeaders^.Signature;

  // Ȼ���� FileHeader
  FFileMachine := FFileHeader^.Machine;
  FFileNumberOfSections := FFileHeader^.NumberOfSections;
  FFileTimeDateStamp := FFileHeader^.TimeDateStamp;
  FFilePointerToSymbolTable := FFileHeader^.PointerToSymbolTable;
  FFileNumberOfSymbols := FFileHeader^.NumberOfSymbols;
  FFileSizeOfOptionalHeader := FFileHeader^.SizeOfOptionalHeader;
  FFileCharacteristics := FFileHeader^.Characteristics;

  // Ȼ���� OptionalHeader
  if FFileSizeOfOptionalHeader = SizeOf(TImageOptionalHeader) then // 32 λ
  begin
    OH32 := PImageOptionalHeader(FOptionalHeader);

    FOptionalMagic := OH32^.Magic;
    FOptionalMajorLinkerVersion := OH32^.MajorLinkerVersion;
    FOptionalMinorLinkerVersion := OH32^.MinorLinkerVersion;
    FOptionalSizeOfCode := OH32^.SizeOfCode;
    FOptionalSizeOfInitializedData := OH32^.SizeOfInitializedData;
    FOptionalSizeOfUninitializedData := OH32^.SizeOfUninitializedData;
    FOptionalAddressOfEntryPoint := OH32^.AddressOfEntryPoint;
    FOptionalBaseOfCode := OH32^.BaseOfCode;
    FOptionalBaseOfData := OH32^.BaseOfData;

    FOptionalImageBase := OH32^.ImageBase;
    FOptionalSectionAlignment := OH32^.SectionAlignment;
    FOptionalFileAlignment := OH32^.FileAlignment;
    FOptionalMajorOperatingSystemVersion := OH32^.MajorOperatingSystemVersion;
    FOptionalMinorOperatingSystemVersion := OH32^.MinorOperatingSystemVersion;
    FOptionalMajorImageVersion := OH32^.MajorImageVersion;
    FOptionalMinorImageVersion := OH32^.MinorImageVersion;
    FOptionalMajorSubsystemVersion := OH32^.MajorSubsystemVersion;
    FOptionalMinorSubsystemVersion := OH32^.MinorSubsystemVersion;
    FOptionalWin32VersionValue := OH32^.Win32VersionValue;
    FOptionalSizeOfImage := OH32^.SizeOfImage;
    FOptionalSizeOfHeaders := OH32^.SizeOfHeaders;
    FOptionalCheckSum := OH32^.CheckSum;
    FOptionalSubsystem := OH32^.Subsystem;
    FOptionalDllCharacteristics := OH32^.DllCharacteristics;
    FOptionalSizeOfStackReserve := OH32^.SizeOfStackReserve;
    FOptionalSizeOfStackCommit := OH32^.SizeOfStackCommit;
    FOptionalSizeOfHeapReserve := OH32^.SizeOfHeapReserve;
    FOptionalSizeOfHeapCommit := OH32^.SizeOfHeapCommit;
    FOptionalLoaderFlags := OH32^.LoaderFlags;
    FOptionalNumberOfRvaAndSizes := OH32^.NumberOfRvaAndSizes;
  end
  else if FFileSizeOfOptionalHeader = SizeOf(TImageOptionalHeader64) then // 64 λ
  begin
    OH64 := PImageOptionalHeader64(FOptionalHeader);

    FOptionalMagic := OH64^.Magic;
    FOptionalMajorLinkerVersion := OH64^.MajorLinkerVersion;
    FOptionalMinorLinkerVersion := OH64^.MinorLinkerVersion;
    FOptionalSizeOfCode := OH64^.SizeOfCode;
    FOptionalSizeOfInitializedData := OH64^.SizeOfInitializedData;
    FOptionalSizeOfUninitializedData := OH64^.SizeOfUninitializedData;
    FOptionalAddressOfEntryPoint := OH64^.AddressOfEntryPoint;
    FOptionalBaseOfCode := OH64^.BaseOfCode;
    FOptionalBaseOfData := 0;  // 64 λû�� OH64^.BaseOfData;

    FOptionalImageBase64 := OH64^.ImageBase;
    FOptionalSectionAlignment := OH64^.SectionAlignment;
    FOptionalFileAlignment := OH64^.FileAlignment;
    FOptionalMajorOperatingSystemVersion := OH64^.MajorOperatingSystemVersion;
    FOptionalMinorOperatingSystemVersion := OH64^.MinorOperatingSystemVersion;
    FOptionalMajorImageVersion := OH64^.MajorImageVersion;
    FOptionalMinorImageVersion := OH64^.MinorImageVersion;
    FOptionalMajorSubsystemVersion := OH64^.MajorSubsystemVersion;
    FOptionalMinorSubsystemVersion := OH64^.MinorSubsystemVersion;
    FOptionalWin32VersionValue := OH64^.Win32VersionValue;
    FOptionalSizeOfImage := OH64^.SizeOfImage;
    FOptionalSizeOfHeaders := OH64^.SizeOfHeaders;
    FOptionalCheckSum := OH64^.CheckSum;
    FOptionalSubsystem := OH64^.Subsystem;
    FOptionalDllCharacteristics := OH64^.DllCharacteristics;
    FOptionalSizeOfStackReserve64 := OH64^.SizeOfStackReserve;
    FOptionalSizeOfStackCommit64 := OH64^.SizeOfStackCommit;
    FOptionalSizeOfHeapReserve64 := OH64^.SizeOfHeapReserve;
    FOptionalSizeOfHeapCommit64 := OH64^.SizeOfHeapCommit;
    FOptionalLoaderFlags := OH64^.LoaderFlags;
    FOptionalNumberOfRvaAndSizes := OH64^.NumberOfRvaAndSizes;
  end;

  FSectionHeader := PImageSectionHeader(TCnNativeInt(FOptionalHeader) + FFileSizeOfOptionalHeader);
end;

function TCnPE.GetExportFunctionItem(Index: Integer): PCnPEExportItem;
begin
  if (Index < 0) or (Index >= Length(FExportItems)) then
    raise ECnPEException.CreateFmt(SCnPEExportIndexErrorFmt, [Index]);

  Result := @FExportItems[Index];
end;

end.
