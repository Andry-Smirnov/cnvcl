{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2016 CnPack ������                       }
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

unit CnNetDecls;
{* |<PRE>
================================================================================
* ������ƣ�����ͨѶ�����
* ��Ԫ���ƣ�����ͨѶ���������ṹ���嵥Ԫ
* ��Ԫ���ߣ�CnPack������ Liu Xiao
* ��    ע��
* ����ƽ̨��PWinXP + Delphi XE
* ���ݲ��ԣ�PWinXP/7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2016.10.05 V1.0
*                ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows;

const
  {* IP ��ͷ�еİ汾�ֶεĶ���}
  CN_IP_VERSION_V4               = 4;
  CN_IP_VERSION_V6               = 6;

  {* IP ��ͷ�� Type of Service �ֶ��е� Precedence ����}
  CN_IP_TOS_PRECEDENCE_ROUTINE              = 0;
  CN_IP_TOS_PRECEDENCE_PRIORITY             = 1;
  CN_IP_TOS_PRECEDENCE_IMMEDIATE            = 2;
  CN_IP_TOS_PRECEDENCE_FLASH                = 3;
  CN_IP_TOS_PRECEDENCE_FLASH_OVERRIDE       = 4;
  CN_IP_TOS_PRECEDENCE_CRITIC_ECP           = 5;
  CN_IP_TOS_PRECEDENCE_INTERNETWORK_CONTROL = 6;
  CN_IP_TOS_PRECEDENCE_NETWORK_CONTROL      = 7;

  CN_IP_TOS_PRECEDENCE_MASK                 = 7;

  {* IP ��ͷ�� Type of Service �ֶ��е������������ͱ�Ƕ���}
  CN_IP_TOS_DELAY_NORMAL         = 0;
  CN_IP_TOS_DELAY_LOW            = $8;
  CN_IP_TOS_THROUGHPUT_NORMAL    = 0;
  CN_IP_TOS_THROUGHPUT_HIGH      = $10;
  CN_IP_TOS_RELIBILITY_NORMAL    = 0;
  CN_IP_TOS_RELIBILITY_HIGH      = $20;

  CN_IP_TOS_DELAY_MASK           = $8;
  CN_IP_TOS_THROUGHPUT_MASK      = $10;
  CN_IP_TOS_RELIBILITY_MASK      = $20;

  {* IP ��ͷ�� Fragment Flag �ֶ��еķ�Ƭ��Ƕ���}
  CN_IP_FLAG_MAY_FRAGMENT        = 0;
  CN_IP_FLAG_DONT_FRAGMENT       = 2;
  CN_IP_FLAG_LAST_FRAGMENT       = 0;
  CN_IP_FLAG_MORE_FRAGMENT       = 4;

  CN_IP_FLAG_DONT_FRAGMENT_MASK  = 2;
  CN_IP_FLAG_MORE_FRAGMENT_MASK  = 4;

  {* IP ��ͷ��Э���ֶεĶ��壬�ο���ά���ٿ�}
  CN_IP_PROTOCOL_HOPOPT          = $00; // IPv6 Hop-by-Hop Option
  CN_IP_PROTOCOL_ICMP            = $01; // *** Internet Control Message Protocol
  CN_IP_PROTOCOL_IGMP            = $02; // *** Internet Group Management Protocol
  CN_IP_PROTOCOL_GGP             = $03; // Gateway-to-Gateway Protocol
  CN_IP_PROTOCOL_IP_IN_IP        = $04; // IP in IP?(encapsulation)
  CN_IP_PROTOCOL_ST              = $05; // Internet Stream Protocol
  CN_IP_PROTOCOL_TCP             = $06; // *** Transmission Control Protocol
  CN_IP_PROTOCOL_CBT             = $07; // Core-based trees
  CN_IP_PROTOCOL_EGP             = $08; // Exterior Gateway Protocol
  CN_IP_PROTOCOL_IGP             = $09; // Interior Gateway Protocol
  CN_IP_PROTOCOL_BBN_RCC_MON     = $0A; // BBN RCC Monitoring
  CN_IP_PROTOCOL_NVP_II          = $0B; // Network Voice Protocol
  CN_IP_PROTOCOL_PUP             = $0C; // Xerox PUP
  CN_IP_PROTOCOL_ARGUS           = $0D; // ARGUS
  CN_IP_PROTOCOL_EMCON           = $0E; // EMCON
  CN_IP_PROTOCOL_XNET            = $0F; // Cross Net Debugger
  CN_IP_PROTOCOL_CHAOS           = $10; // Chaos
  CN_IP_PROTOCOL_UDP             = $11; // *** User Datagram Protocol
  CN_IP_PROTOCOL_MUX             = $12; // Multiplexing
  CN_IP_PROTOCOL_DCN_MEAS        = $13; // DCN Measurement Subsystems
  CN_IP_PROTOCOL_HMP             = $14; // Host Monitoring Protocol
  CN_IP_PROTOCOL_PRM             = $15; // Packet Radio Measurement
  CN_IP_PROTOCOL_XNS_IDP         = $16; // XEROX NS IDP
  CN_IP_PROTOCOL_TRUNK_1         = $17; // Trunk-1
  CN_IP_PROTOCOL_TRUNK_2         = $18; // Trunk-2
  CN_IP_PROTOCOL_LEAF_1          = $19; // Leaf-1
  CN_IP_PROTOCOL_LEAF_2          = $1A; // Leaf-2
  CN_IP_PROTOCOL_RDP             = $1B; // Reliable Datagram Protocol
  CN_IP_PROTOCOL_IRTP            = $1C; // Internet Reliable Transaction Protocol
  CN_IP_PROTOCOL_ISO_TP4         = $1D; // ISO Transport Protocol Class 4
  CN_IP_PROTOCOL_NETBLT          = $1E; // Bulk Data Transfer Protocol
  CN_IP_PROTOCOL_MFE_NSP         = $1F; // MFE Network Services Protocol
  CN_IP_PROTOCOL_MERIT_INP       = $20; // MERIT Internodal Protocol
  CN_IP_PROTOCOL_DCCP            = $21; // Datagram Congestion Control Protocol
  CN_IP_PROTOCOL_3PC             = $22; // Third Party Connect Protocol
  CN_IP_PROTOCOL_IDPR            = $23; // Inter-Domain Policy Routing Protocol
  CN_IP_PROTOCOL_XTP             = $24; // Xpress Transport Protocol
  CN_IP_PROTOCOL_DDP             = $25; // Datagram Delivery Protocol
  CN_IP_PROTOCOL_IDPR_CMTP       = $26; // IDPR Control Message Transport Protocol
  CN_IP_PROTOCOL_TP_PP           = $27; // TP++ Transport Protocol
  CN_IP_PROTOCOL_IL              = $28; // IL Transport Protocol
  CN_IP_PROTOCOL_IPV6            = $29; // IPv6 Encapsulation
  CN_IP_PROTOCOL_SDRP            = $2A; // Source Demand Routing Protocol
  CN_IP_PROTOCOL_IPV6_ROUTE      = $2B; // Routing Header for?IPv6
  CN_IP_PROTOCOL_IPV6_FRAG       = $2C; // Fragment Header for?IPv6
  CN_IP_PROTOCOL_IDRP            = $2D; // Inter-Domain Routing Protocol
  CN_IP_PROTOCOL_RSVP            = $2E; // Resource Reservation Protocol
  CN_IP_PROTOCOL_GRE             = $2F; // Generic Routing Encapsulation
  CN_IP_PROTOCOL_MHRP            = $30; // Mobile Host Routing Protocol
  CN_IP_PROTOCOL_BNA             = $31; // BNA
  CN_IP_PROTOCOL_ESP             = $32; // Encapsulating Security Payload
  CN_IP_PROTOCOL_AH              = $33; // Authentication Header
  CN_IP_PROTOCOL_I_NLSP          = $34; // Integrated Net Layer Security Protocol
  CN_IP_PROTOCOL_SWIPE           = $35; // SwIPe
  CN_IP_PROTOCOL_NARP            = $36; // NBMA Address Resolution Protocol
  CN_IP_PROTOCOL_MOBILE          = $37; // IP Mobility?(Min Encap)
  CN_IP_PROTOCOL_TLSP            = $38; // Transport Layer Security Protocol
  CN_IP_PROTOCOL_SKIP            = $39; // Simple Key-Management for Internet Protocol
  CN_IP_PROTOCOL_IPV6_ICMP       = $3A; // ICMP for IPv6
  CN_IP_PROTOCOL_IPV6_NONXT      = $3B; // No Next Header for?IPv6
  CN_IP_PROTOCOL_IPV6_OPTS       = $3C; // Destination Options for?IPv6
  CN_IP_PROTOCOL_ANY_HOST        = $3D; // Any host internal protocol
  CN_IP_PROTOCOL_CFTP            = $3E; // CFTP
  CN_IP_PROTOCOL_ANY_LOCAL       = $3F; // Any local network
  CN_IP_PROTOCOL_SAT_EXPAK       = $40; // SATNET and Backroom EXPAK
  CN_IP_PROTOCOL_KRYPTOLAN       = $41; // Kryptolan
  CN_IP_PROTOCOL_RVD             = $42; // MIT?Remote Virtual Disk Protocol
  CN_IP_PROTOCOL_IPPC            = $43; // Internet Pluribus Packet Core
  CN_IP_PROTOCOL_ANY_DFS         = $44; // Any distributed file system
  CN_IP_PROTOCOL_SAT_MON         = $45; // SATNET Monitoring
  CN_IP_PROTOCOL_VISA            = $46; // VISA Protocol
  CN_IP_PROTOCOL_IPCU            = $47; // Internet Packet Core Utility
  CN_IP_PROTOCOL_CPNX            = $48; // Computer Protocol Network Executive
  CN_IP_PROTOCOL_CPHB            = $49; // Computer Protocol Heart Beat
  CN_IP_PROTOCOL_WSN             = $4A; // Wang Span Network
  CN_IP_PROTOCOL_PVP             = $4B; // Packet Video Protocol
  CN_IP_PROTOCOL_BR_SAT_MON      = $4C; // Backroom SATNET Monitoring
  CN_IP_PROTOCOL_SUN_ND          = $4D; // SUN ND PROTOCOL-Temporary
  CN_IP_PROTOCOL_WB_MON          = $4E; // WIDEBAND Monitoring
  CN_IP_PROTOCOL_WB_EXPAK        = $4F; // WIDEBAND EXPAK
  CN_IP_PROTOCOL_ISO_IP          = $50; // International Organization for Standardization Internet Protocol
  CN_IP_PROTOCOL_VMTP            = $51; // Versatile Message Transaction Protocol
  CN_IP_PROTOCOL_SECURE_VMTP     = $52; // Secure Versatile Message Transaction Protocol
  CN_IP_PROTOCOL_VINES           = $53; // VINES
  CN_IP_PROTOCOL_TTP             = $54; // TTP
  CN_IP_PROTOCOL_IPTM            = $54; // Internet Protocol Traffic Manager
  CN_IP_PROTOCOL_NSFNET_IGP      = $55; // NSFNET-IGP
  CN_IP_PROTOCOL_DGP             = $56; // Dissimilar Gateway Protocol
  CN_IP_PROTOCOL_TCF             = $57; // TCF
  CN_IP_PROTOCOL_EIGRP           = $58; // EIGRP
  CN_IP_PROTOCOL_OSPF            = $59; // Open Shortest Path First
  CN_IP_PROTOCOL_SPRITE_RPC      = $5A; // Sprite RPC Protocol
  CN_IP_PROTOCOL_LARP            = $5B; // Locus Address Resolution Protocol
  CN_IP_PROTOCOL_MTP             = $5C; // Multicast Transport Protocol
  CN_IP_PROTOCOL_AX_25           = $5D; // AX.25
  CN_IP_PROTOCOL_OS              = $5E; // KA9Q NOS compatible IP over IP tunneling
  CN_IP_PROTOCOL_MICP            = $5F; // Mobile Internetworking Control Protocol
  CN_IP_PROTOCOL_SCC_SP          = $60; // Semaphore Communications Sec. Pro
  CN_IP_PROTOCOL_ETHERIP         = $61; // Ethernet-within-IP Encapsulation
  CN_IP_PROTOCOL_ENCAP           = $62; // Encapsulation Header
  CN_IP_PROTOCOL_ANY_PRIVATE     = $63; // Any private encryption scheme
  CN_IP_PROTOCOL_GMTP            = $64; // GMTP
  CN_IP_PROTOCOL_IFMP            = $65; // Ipsilon Flow Management Protocol
  CN_IP_PROTOCOL_PNNI            = $66; // PNNI over IP
  CN_IP_PROTOCOL_PIM             = $67; // Protocol Independent Multicast
  CN_IP_PROTOCOL_ARIS            = $68; // IBM's ARIS (Aggregate Route IP Switching) Protocol
  CN_IP_PROTOCOL_SCPS            = $69; // SCPS (Space Communications Protocol Standards)
  CN_IP_PROTOCOL_QNX             = $6A; // QNX
  CN_IP_PROTOCOL_A_N             = $6B; // Active Networks
  CN_IP_PROTOCOL_IPCOMP          = $6C; // IP Payload Compression Protocol
  CN_IP_PROTOCOL_SNP             = $6D; // Sitara Networks Protocol
  CN_IP_PROTOCOL_COMPAQ_PEER     = $6E; // Compaq Peer Protocol
  CN_IP_PROTOCOL_IPX_IN_IP       = $6F; // IPX in IP
  CN_IP_PROTOCOL_VRRP            = $70; // Virtual Router Redundancy Protocol,?Common Address Redundancy Protocol?(not?IANAassigned)
  CN_IP_PROTOCOL_PGM             = $71; // PGM Reliable Transport Protocol
  CN_IP_PROTOCOL_ANY_0HOP        = $72; // Any 0-hop protocol
  CN_IP_PROTOCOL_L2TP            = $73; // Layer Two Tunneling Protocol Version 3
  CN_IP_PROTOCOL_DDX             = $74; // D-II Data Exchange (DDX)
  CN_IP_PROTOCOL_IATP            = $75; // Interactive Agent Transfer Protocol
  CN_IP_PROTOCOL_STP             = $76; // Schedule Transfer Protocol
  CN_IP_PROTOCOL_SRP             = $77; // SpectraLink Radio Protocol
  CN_IP_PROTOCOL_UTI             = $78; // Universal Transport Interface Protocol
  CN_IP_PROTOCOL_SMP             = $79; // Simple Message Protocol
  CN_IP_PROTOCOL_SM              = $7A; // Simple Multicast Protocol
  CN_IP_PROTOCOL_PTP             = $7B; // Performance Transparency Protocol
  CN_IP_PROTOCOL_IS_IS_OVER_IPV4 = $7C; // Intermediate System to Intermediate System (IS-IS) Protocol?over?IPv4
  CN_IP_PROTOCOL_FIRE            = $7D; // Flexible Intra-AS Routing Environment
  CN_IP_PROTOCOL_CRTP            = $7E; // Combat Radio Transport Protocol
  CN_IP_PROTOCOL_CRUDP           = $7F; // Combat Radio User Datagram
  CN_IP_PROTOCOL_SSCOPMCE        = $80; // Service-Specific Connection-Oriented Protocol in a Multilink and Connectionless Environment
  CN_IP_PROTOCOL_IPLT            = $81; // IPLT
  CN_IP_PROTOCOL_SPS             = $82; // Secure Packet Shield
  CN_IP_PROTOCOL_PIPE            = $83; // Private IP Encapsulation within IP
  CN_IP_PROTOCOL_SCTP            = $84; // Stream Control Transmission Protocol
  CN_IP_PROTOCOL_FC              = $85; // Fibre Channel
  CN_IP_PROTOCOL_RSVP_E2E_IGNORE = $86; // Reservation Protocol (RSVP) End-to-End Ignore                                              
  CN_IP_PROTOCOL_MOBILITY_HEADER = $87; // Mobility Extension Header for IPv6                                                         
  CN_IP_PROTOCOL_UDPLITE         = $88; // Lightweight User Datagram Protocol
  CN_IP_PROTOCOL_MPLS_IN_IP      = $89; // Multiprotocol Label Switching?Encapsulated in IP
  CN_IP_PROTOCOL_MANET           = $8A; // MANET?Protocols
  CN_IP_PROTOCOL_HIP             = $8B; // Host Identity Protocol
  CN_IP_PROTOCOL_SHIM6           = $8C; // Site Multihoming by IPv6 Intermediation
  CN_IP_PROTOCOL_WESP            = $8D; // Wrapped Encapsulating Security Payload
  CN_IP_PROTOCOL_ROHC            = $8E; // Robust Header Compression
  CN_IP_PROTOCOL_RESERVE         = $FF; // Reserved

  {* TCP ��ͷ�еı���ֶεĶ���}
  CN_TCP_FLAG_URG = $0;
  CN_TCP_FLAG_ACK = $2;
  CN_TCP_FLAG_PSH = $4;
  CN_TCP_FLAG_RST = $8;
  CN_TCP_FLAG_SYN = $10;
  CN_TCP_FLAG_FYN = $20;

type

{*
  IP ��ͷʾ��ͼ���ֽ�������Ǹ�λ���ұ��ǵ�λ��
  �ֽ�֮����� Big-Endian �������ֽ�˳�򣬸�λ�ڵ͵�ַ�������Ķ�ϰ�ߡ�

   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |Version|  IHL  |Type of Service|          Total Length         |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |         Identification        |Flags|      Fragment Offset    |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  Time to Live |    Protocol   |         Header Checksum       |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |                     Source IP Address                         |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |                  Destination IP Address                       |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |                    Options                    |    Padding    |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
}

  TCnIPHeader = packed record
    VerionHeaderLength: Byte;           // �汾�Ͱ�ͷ����
    TypeOfService:      Byte;           // ��������
    TotalLength:        Word;           // �ܳ��ȣ���� 65535
    Identification:     Word;           // ��ʶ
    FlagOffset:         Word;           // ��־��Ƭƫ��
    TTL:                Byte;           // ����ʱ��
    Protocol:           Byte;           // Э��
    CheckSum:           Word;           // ��ͷУ���
    SourceIp:           LongWord;       // Դ IP ��ַ
    DestIp:             LongWord;       // Ŀ�� IP ��ַ
  end;

  PCnIPHeader = ^TCnIPHeader;

{*
  TCP ��ͷʾ��ͼ���ֽ�������Ǹ�λ���ұ��ǵ�λ��
  �ֽ�֮����� Big-Endian �������ֽ�˳�򣬸�λ�ڵ͵�ַ�������Ķ�ϰ�ߡ�

   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |          Source Port          |       Destination Port        |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |                        Sequence Number                        |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |                    Acknowledgment Number                      |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |  Data |           |U|A|P|R|S|F|                               |
  | Offset| Reserved  |R|C|S|S|Y|I|            Window             |
  |       |           |G|K|H|T|N|N|                               |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |           Checksum            |         Urgent Pointer        |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |                    Options                    |    Padding    |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |                             Data                              |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
}

  TCnTCPHeader = packed record
    SourcePort:            Word;        // Դ�˿�
    DestPort:              Word;        // Ŀ�Ķ˿�
    SequenceNumber:        LongWord;    // ���к�
    AcknowledgementNumber: LongWord;    // ��Ӧ���к�
    Offset:                Byte;        // ����ƫ�ƣ������� 4 bit
    Flags:                 Byte;        // TCP ��ͷ���
    Window:                Word;        // ���ڴ�С
    Checksum:              Word;        // У���
    UrgentPointer:         Word;        // ����ָ��
  end;

  PCnTCPHeader = ^TCnTCPHeader;

function CnGetIPVersion(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵ� IP �汾��}

function CnGetIPHeaderLength(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵ� IP ��ͷ���ȣ���λΪ 4 �ֽ�}

function CnGetIPTypeOfServicePrecedence(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵ� Type of Service �ֶ��е� Precedence ֵ}

function CnGetIPTypeOfServiceDelay(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵ� Type of Service �ֶ��е� Delay ֵ}

function CnGetIPTypeOfServiceThroughput(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵ� Type of Service �ֶ��е� Throughput ֵ}

function CnGetIPTypeOfServiceRelibility(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵ� Type of Service �ֶ��е� Relibility ֵ}

function CnGetIPTotalLength(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵİ��ܳ��ȣ����������ֽ�ת��}

function CnGetIPFlagDontFragment(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵ��Ƿ�ֶα��}

function CnGetIPFlagMoreFragment(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵ��Ƿ��и���ֶα��}

function CnGetIPFragmentOffset(const IPHeader: PCnIPHeader): Integer;
{* ��� IP ��ͷ�ڵķֶ�ƫ�ƣ����������ֽ�ת��}

implementation

function CnGetIPVersion(const IPHeader: PCnIPHeader): Integer;
begin
  Result := (IPHeader^.VerionHeaderLength and $F0) shr 4;
end;

function CnGetIPHeaderLength(const IPHeader: PCnIPHeader): Integer;
begin
  Result := IPHeader^.VerionHeaderLength and $0F;
end;

function CnGetIPTypeOfServicePrecedence(const IPHeader: PCnIPHeader): Integer;
begin
  Result := IPHeader^.TypeOfService and CN_IP_TOS_PRECEDENCE_MASK;
end;

function CnGetIPTypeOfServiceDelay(const IPHeader: PCnIPHeader): Integer;
begin
  Result := IPHeader^.TypeOfService and CN_IP_TOS_DELAY_MASK;
end;

function CnGetIPTypeOfServiceThroughput(const IPHeader: PCnIPHeader): Integer;
begin
  Result := IPHeader^.TypeOfService and CN_IP_TOS_THROUGHPUT_MASK;
end;

function CnGetIPTypeOfServiceRelibility(const IPHeader: PCnIPHeader): Integer;
begin
  Result := IPHeader^.TypeOfService and CN_IP_TOS_RELIBILITY_MASK;
end;

function CnGetIPTotalLength(const IPHeader: PCnIPHeader): Integer;
begin
  Result := ((IPHeader^.TotalLength and $00FF) shl 8) or
    ((IPHeader^.TotalLength and $FF00) shr 8);
end;

function CnGetIPFlagDontFragment(const IPHeader: PCnIPHeader): Integer;
begin
  Result := IPHeader^.FlagOffset and CN_IP_FLAG_DONT_FRAGMENT_MASK;
end;

function CnGetIPFlagMoreFragment(const IPHeader: PCnIPHeader): Integer;
begin
  Result := IPHeader^.FlagOffset and CN_IP_FLAG_MORE_FRAGMENT_MASK;
end;

function CnGetIPFragmentOffset(const IPHeader: PCnIPHeader): Integer;
begin
  Result := IPHeader^.FlagOffset shl 0;
end;

end.
