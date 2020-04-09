{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 1996-2000, Eugene Roshal                      }
{ Copyright (C) 2000-2020, Far Group                          }
{ Copyright (C) 1995-2020, Yegor Mialyk. All Rights Reserved. }
{                                                             }
{ Licensed under the MIT License. See LICENSE for details.    }
{                                                             }
{*************************************************************}

unit Far.Plugin;

{$INCLUDE compiler.inc}
{$WEAKPACKAGEUNIT}

interface

uses
  Winapi.Windows;

{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}

type
  PIntPtr = ^IntPtr;

  TFarStdQSortFunc = function (
    Param1: Pointer;
    Param2: Pointer;
    userparam: Pointer): Integer; stdcall;

  FARSTDQSORT = procedure (
    base: Pointer;
    nelem: UIntPtr;
    width: UIntPtr;
    fcmp: TFarStdQSortFunc;
    userparam: Pointer); stdcall;

  FARSTDBSEARCH = procedure (
    key: Pointer;
    base: Pointer;
    nelem: UIntPtr;
    width: UIntPtr;
    fcmp: TFarStdQSortFunc;
    userparam: Pointer); stdcall;

{$INCLUDE Far.Plugin.Farcolor.Generated.pas}
{$INCLUDE Far.Plugin.Plugin.Generated.pas}
{$INCLUDE Far.Plugin.FarGuid.Generated.pas}
{$INCLUDE Far.Plugin.KnownGuids.Generated.pas}
{$INCLUDE Far.Plugin.DlgGuid.Generated.pas}
{$INCLUDE Far.Plugin.Helpers.Generated.pas}
{$INCLUDE Far.Plugin.Settings.pas}

type
  PluginPanelItemEx = record
    CreationTime: FILETIME;
    LastAccessTime: FILETIME;
    LastWriteTime: FILETIME;
    ChangeTime: FILETIME;
    FileSize: UInt64;
    AllocationSize: UInt64;
    FileName: string;
    AlternateFileName: string;
    Description: string;
    Owner: string;
    CustomColumnData: PPChar;
    CustomColumnNumber: UIntPtr;
    Flags: PLUGINPANELITEMFLAGS;
    UserData: UserDataItem;
    FileAttributes: UIntPtr;
    NumberOfLinks: UIntPtr;
    CRC32: UIntPtr;
    Reserved: array [0..1] of IntPtr;
  end;

function MakeFarVersion(const Major, Minor, Build, Revision: DWORD; const Stage: VERSION_STAGE = VS_RELEASE): VersionInfo;
procedure InitStartupInfo(const StartupInfo: PluginStartupInfo);

var
  FarAPI: PluginStartupInfo;
  FSF: FarStandardFunctions;

implementation

function MakeFarVersion;
begin
  Result.Major := Major;
  Result.Minor := Minor;
  Result.Build := Build;
  Result.Revision := Revision;
  Result.Stage := Stage;
end;

procedure InitStartupInfo;
begin
  FarAPI := StartupInfo;
  FSF := StartupInfo.FSF^;
  FarAPI.FSF := @FSF;
end;

{$DEFINE _FAR_IMPLEMENTATION_}
{$INCLUDE Far.Plugin.Helpers.Generated.pas}
{$INCLUDE Far.Plugin.Settings.pas}
{$UNDEF _FAR_IMPLEMENTATION_}

end.
