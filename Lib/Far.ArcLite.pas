{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 1999-2018, Igor Pavlov.                       }
{ Copyright (C) 1995-2018, Yegor Mialyk. All Rights Reserved. }
{                                                             }
{*************************************************************}

unit Far.ArcLite;

{$INCLUDE compiler.inc}
{$WEAKPACKAGEUNIT}

interface

uses
  Winapi.Windows,
  Winapi.ActiveX;

{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}

type
  PUInt32 = ^UInt32;

type
  NFileTimeType = record
    const
      kWindows = 0;
      kUnix = 1;
      kDOS = 2;
  end;

type
  NArchive = record
    const
      kName = 0;
      kClassID = 1;
      kExtension = 2;
      kAddExtension = 3;
      kUpdate = 4;
      kKeepName = 5;
      kStartSignature = 6;
      kFinishSignature = 7;
      kAssociate = 8;
    type
      NExtract = record
        type
          NAskMode = record
            const
              kExtract = 0;
              kTest = 1;
              kSkip = 2;
          end;
        type
          NOperationResult = record
            const
              kOK = 0;
              kUnSupportedMethod = 1;
              kDataError = 2;
              kCRCError = 3;
          end;
      end;
    type
      NUpdate = record
        type
          NOperationResult = record
            const
              kOK = 0;
              kError = 1;
          end;
      end;
  end;

const
  kpidNoProperty = 0;
  kpidMainSubfile = 1;
  kpidHandlerItemIndex = 2;
  kpidPath = 3;
  kpidName = 4;
  kpidExtension = 5;
  kpidIsDir = 6;
  kpidSize = 7;
  kpidPackSize = 8;
  kpidAttrib = 9;
  kpidCTime = 10;
  kpidATime = 11;
  kpidMTime = 12;
  kpidSolid = 13;
  kpidCommented = 14;
  kpidEncrypted = 15;
  kpidSplitBefore = 16;
  kpidSplitAfter = 17;
  kpidDictionarySize = 18;
  kpidCRC = 19;
  kpidType = 20;
  kpidIsAnti = 21;
  kpidMethod = 22;
  kpidHostOS = 23;
  kpidFileSystem = 24;
  kpidUser = 25;
  kpidGroup = 26;
  kpidBlock = 27;
  kpidComment = 28;
  kpidPosition = 29;
  kpidPrefix = 30;
  kpidNumSubDirs = 31;
  kpidNumSubFiles = 32;
  kpidUnpackVer = 33;
  kpidVolume = 34;
  kpidIsVolume = 35;
  kpidOffset = 36;
  kpidLinks = 37;
  kpidNumBlocks = 38;
  kpidNumVolumes = 39;
  kpidTimeType = 40;
  kpidBit64 = 41;
  kpidBigEndian = 42;
  kpidCpu = 43;
  kpidPhySize = 44;
  kpidHeadersSize = 45;
  kpidChecksum = 46;
  kpidCharacts = 47;
  kpidVa = 48;
  kpidId = 49;
  kpidShortName = 50;
  kpidCreatorApp = 51;
  kpidSectorSize = 52;
  kpidPosixAttrib = 53;
  kpidLink = 54;
  kpidError = 55;

  kpidTotalSize = $1100;
  kpidFreeSpace = 4353;
  kpidClusterSize = 4354;
  kpidVolumeName = 4355;

  kpidLocalName = $1200;
  kpidProvider = 4609;

  kpidUserDefined = $10000;

const
  IID_IInArchive: TGUID = '{23170F69-40C1-278A-0000-000600600000}';
  IID_IOutArchive: TGUID = '{23170F69-40C1-278A-0000-000600A00000}';

type
  ISequentialInStream = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000300010000}']
    function Read(data: Pointer; size: UInt32; processedSize: PUInt32): HRESULT; stdcall;
  end;

  ISequentialOutStream = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000300020000}']
    function Write(data: Pointer; size: UInt32; processedSize: PUInt32): HRESULT; stdcall;
  end;

  IInStream = interface(ISequentialInStream)
    ['{23170F69-40C1-278A-0000-000300030000}']
    function Seek(offset: Int64; seekOrigin: UInt32; newPosition: PUInt64): HRESULT; stdcall;
  end;

  IOutStream = interface(ISequentialOutStream)
    ['{23170F69-40C1-278A-0000-000300040000}']
    function Seek(offset: Int64; seekOrigin: UInt32; newPosition: PUInt64): HRESULT; stdcall;
    function SetSize(newSize: UInt64): HRESULT; stdcall;
  end;

  IStreamGetSize = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000300060000}']
    function GetSize(out size: UInt64): HRESULT; stdcall;
  end;

  IOutStreamFinish = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000300070000}']
    function OutStreamFinish: HRESULT; stdcall;
  end;

type
  IProgress = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000000050000}']
    function SetTotal(total: UInt64): HRESULT; stdcall;
    function SetCompleted(const completeValue: PUInt64): HRESULT; stdcall;
  end;
  
type
  IArchiveOpenCallback = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000600100000}']
    function SetTotal(const files: PUInt64; const bytes: PUInt64): HRESULT; stdcall;
    function SetCompleted(const files: PUInt64; const bytes: PUInt64): HRESULT; stdcall;
  end;

  IArchiveExtractCallback = interface(IProgress)
    ['{23170F69-40C1-278A-0000-000600200000}']
    function GetStream(index: UInt32; out outStream: ISequentialOutStream; askExtractMode: Integer): HRESULT; stdcall;
    function PrepareOperation(askExtractMode: Integer): HRESULT; stdcall;
    function SetOperationResult(opRes: Integer): HRESULT; stdcall;
  end;

  IArchiveOpenVolumeCallback = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000600300000}']
    function GetProperty(propID: PROPID; out value: PROPVARIANT): HRESULT; stdcall;
    function GetStream(const name: PChar; out inStream: IInStream): HRESULT; stdcall;
  end;

  IInArchiveGetStream = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000600400000}']
    function GetStream(index: UInt32; out stream: ISequentialInStream): HRESULT; stdcall;
  end;

  IArchiveOpenSetSubArchiveName = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000600500000}']
    function SetSubArchiveName(const name: PChar): HRESULT; stdcall;
  end;

  IInArchive = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000600600000}']
    function Open(stream: IInStream; const maxCheckStartPosition: PUInt64; openArchiveCallback: IArchiveOpenCallback): HRESULT; stdcall;
    function Close: HRESULT; stdcall;
    function GetNumberOfItems(out numItems: UInt32): HRESULT; stdcall;
    function GetProperty(index: UInt32; propID: PROPID; out value: PROPVARIANT): HRESULT; stdcall;
    function Extract(const indices: PUInt32; numItems: UInt32; testMode: Integer; extractCallback: IArchiveExtractCallback): HRESULT; stdcall;
    function GetArchiveProperty(propID: PROPID; out value: PROPVARIANT): HRESULT; stdcall;
    function GetNumberOfProperties(out numProperties: UInt32): HRESULT; stdcall;
    function GetPropertyInfo(index: UInt32; out name: TBStr; out propID: PROPID; out varType: TVarType): HRESULT; stdcall;
    function GetNumberOfArchiveProperties(out numProperties: UInt32): HRESULT; stdcall;
    function GetArchivePropertyInfo(index: UInt32; out name: TBStr; out propID: PROPID; out varType: TVarType): HRESULT; stdcall;
  end;

  IArchiveUpdateCallback = interface(IProgress)
    ['{23170F69-40C1-278A-0000-000600800000}']
    function GetUpdateItemInfo(index: UInt32; var newData, newProperties: Integer; var indexInArchive: UInt32): HRESULT; stdcall;
    function GetProperty(index: UInt32; propID: PROPID; out value: PROPVARIANT): HRESULT; stdcall;
    function GetStream(index: UInt32; out inStream: ISequentialInStream): HRESULT; stdcall;
    function SetOperationResult(operationResult: Integer): HRESULT; stdcall;
  end;

  IArchiveUpdateCallback2 = interface(IArchiveUpdateCallback)
    ['{23170F69-40C1-278A-0000-000600820000}']
    function GetVolumeSize(index: UInt32; size: PUInt64): HRESULT; stdcall;
    function GetVolumeStream(index: UInt32; out volumeStream: ISequentialOutStream): HRESULT; stdcall;
  end;

  IOutArchive = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000600A00000}']
    function UpdateItems(outStream: ISequentialOutStream; NumItems: UInt32; updateCallback: IArchiveUpdateCallback): HRESULT; stdcall;
    function GetFileTimeType(out AType: UInt32): HRESULT; stdcall;
  end;

  ISetProperties = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000600030000}']
    function SetProperties(const names: PPChar; const values: PPropVariant; numProperties: Integer): HRESULT; stdcall;
  end;

type
  ICryptoGetTextPassword = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000500100000}']
    function CryptoGetTextPassword(out password: TBStr): HRESULT; stdcall;
  end;

  ICryptoGetTextPassword2 = interface(IUnknown)
    ['{23170F69-40C1-278A-0000-000500110000}']
    function CryptoGetTextPassword2(out passwordIsDefined: Integer; out password: TBStr): HRESULT; stdcall;
  end;

{
function CreateObject(class_id: PGUID; interface_id: PGUID; out Obj: IUnknown): HRESULT; stdcall;
function GetNumberOfFormats(out numFormats: UInt32): HRESULT; stdcall;
function GetNumberOfMethods(out numMethods: UInt32): HRESULT; stdcall;
function GetHandlerProperty(prop_id: PROPID; out value: PROPVARIANT): HRESULT; stdcall;
function GetHandlerProperty2(index: UInt32; prop_id: PROPID; out value: PROPVARIANT): HRESULT; stdcall;
function GetMethodProperty(index: UInt32; prop_id: PROPID; out value: PROPVARIANT): HRESULT; stdcall;
}

implementation

end.
