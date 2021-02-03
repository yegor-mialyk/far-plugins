//
// Far Manager SDK
//
// Copyright (C) 1995-2021, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

unit Far.Plugin;

{$INCLUDE Compiler.pas}
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

{$INCLUDE Far.Plugin.FarColor.g.pas}
{$INCLUDE Far.Plugin.Plugin.g.pas}
{$INCLUDE Far.Plugin.Guids.Far.g.pas}
{$INCLUDE Far.Plugin.Guids.Dialogs.g.pas}
{$INCLUDE Far.Plugin.Guids.Plugins.g.pas}
{$INCLUDE Far.Plugin.Helpers.g.pas}
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

function MakeFarVersion(const Major, Minor, Revision, Build: DWORD; const Stage: VERSION_STAGE = VS_RELEASE): VersionInfo;
procedure InitStartupInfo(const StartupInfo: PluginStartupInfo);

var
  FarAPI: PluginStartupInfo;
  FSF: FarStandardFunctions;

implementation

function MakeFarVersion;
begin
  Result.Major := Major;
  Result.Minor := Minor;
  Result.Revision := Revision;
  Result.Build := Build;
  Result.Stage := Stage;
end;

procedure InitStartupInfo;
begin
  FarAPI := StartupInfo;
  FSF := StartupInfo.FSF^;
  FarAPI.FSF := @FSF;
end;

{$DEFINE _FAR_IMPLEMENTATION_}
{$INCLUDE Far.Plugin.Helpers.g.pas}
{$INCLUDE Far.Plugin.Settings.pas}
{$UNDEF _FAR_IMPLEMENTATION_}

end.
