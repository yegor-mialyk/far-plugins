//
// Far Manager SDK
//
// Copyright (C) 1995-2026, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

unit Far.Plugin;

{$INCLUDE Compiler.pas}

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

class operator FarColor.Equal(const Left, Right: FarColor): Boolean;
begin
  Result := (Left.Flags = Right.Flags)
    and (Left.Foreground.ForegroundColor = Right.Foreground.ForegroundColor)
    and (Left.Background.BackgroundColor = Right.Background.BackgroundColor)
    and (Left.Underline.UnderlineColor = Right.Underline.UnderlineColor)
    and (Left.Reserved = Right.Reserved);
end;

class operator FarColor.NotEqual(const Left, Right: FarColor): Boolean;
begin
  Result := not (Left = Right);
end;

function FarColor.IsBgIndex: Boolean;
begin
  Result := (Flags and FCF_BG_INDEX) <> 0;
end;

function FarColor.IsFgIndex: Boolean;
begin
  Result := (Flags and FCF_FG_INDEX) <> 0;
end;

function FarColor.IsUnderlineIndex: Boolean;
begin
  Result := (Flags and FCF_FG_UNDERLINE_INDEX) <> 0;
end;

function FarColor.IsBgDefault: Boolean;
begin
  Result := IsBgIndex and ((Background.BackgroundColor and COLORMASK) = $00800000);
end;

function FarColor.IsFgDefault: Boolean;
begin
  Result := IsFgIndex and ((Foreground.ForegroundColor and COLORMASK) = $00800000);
end;

function FarColor.IsUnderlineDefault: Boolean;
begin
  Result := IsUnderlineIndex and ((Underline.UnderlineColor and COLORMASK) = $00800000);
end;

function FarColor.GetUnderline: Integer;
var
  UnderlineFlags: FARCOLORFLAGS;
begin
  UnderlineFlags := Flags and FARCOLORFLAGS(FCF_FG_UNDERLINE_MASK);

  if UnderlineFlags = FARCOLORFLAGS(FCF_FG_U_DATA0) then
    Result := UNDERLINE_SINGLE
  else if UnderlineFlags = FARCOLORFLAGS(FCF_FG_U_DATA1) then
    Result := UNDERLINE_DOUBLE
  else if UnderlineFlags = (FARCOLORFLAGS(FCF_FG_U_DATA1) or FARCOLORFLAGS(FCF_FG_U_DATA0)) then
    Result := UNDERLINE_CURLY
  else if UnderlineFlags = FARCOLORFLAGS(FCF_FG_U_DATA2) then
    Result := UNDERLINE_DOT
  else if UnderlineFlags = (FARCOLORFLAGS(FCF_FG_U_DATA2) or FARCOLORFLAGS(FCF_FG_U_DATA0)) then
    Result := UNDERLINE_DASH
  else
    Result := UNDERLINE_NONE;
end;

procedure FarColor.SetBgIndex(const Value: Boolean);
begin
  if Value then
    Flags := Flags or FCF_BG_INDEX
  else
    Flags := Flags and not FCF_BG_INDEX;
end;

procedure FarColor.SetFgIndex(const Value: Boolean);
begin
  if Value then
    Flags := Flags or FCF_FG_INDEX
  else
    Flags := Flags and not FCF_FG_INDEX;
end;

procedure FarColor.SetUnderlineIndex(const Value: Boolean);
begin
  if Value then
    Flags := Flags or FCF_FG_UNDERLINE_INDEX
  else
    Flags := Flags and not FCF_FG_UNDERLINE_INDEX;
end;

procedure FarColor.SetBgDefault;
begin
  SetBgIndex(True);
  Background.BackgroundColor := (Background.BackgroundColor and COLORREF(not COLORMASK)) or COLORREF($00800000);
end;

procedure FarColor.SetFgDefault;
begin
  SetFgIndex(True);
  Foreground.ForegroundColor := (Foreground.ForegroundColor and COLORREF(not COLORMASK)) or COLORREF($00800000);
end;

procedure FarColor.SetUnderlineDefault;
begin
  SetUnderlineIndex(True);
  Underline.UnderlineColor := (Underline.UnderlineColor and COLORREF(not COLORMASK)) or COLORREF($00800000);
end;

procedure FarColor.SetUnderline(const UnderlineStyle: Integer);
begin
  Flags := Flags and not FARCOLORFLAGS(FCF_FG_UNDERLINE_MASK);

  case UnderlineStyle of
    UNDERLINE_SINGLE:
      Flags := Flags or FARCOLORFLAGS(FCF_FG_U_DATA0);
    UNDERLINE_DOUBLE:
      Flags := Flags or FARCOLORFLAGS(FCF_FG_U_DATA1);
    UNDERLINE_CURLY:
      Flags := Flags or (FARCOLORFLAGS(FCF_FG_U_DATA1) or FARCOLORFLAGS(FCF_FG_U_DATA0));
    UNDERLINE_DOT:
      Flags := Flags or FARCOLORFLAGS(FCF_FG_U_DATA2);
    UNDERLINE_DASH:
      Flags := Flags or (FARCOLORFLAGS(FCF_FG_U_DATA2) or FARCOLORFLAGS(FCF_FG_U_DATA0));
  end;
end;

function FarColor.IsBg4Bit: Boolean;
begin
  Result := IsBgIndex;
end;

function FarColor.IsFg4Bit: Boolean;
begin
  Result := IsFgIndex;
end;

procedure FarColor.SetBg4Bit(const Value: Boolean);
begin
  SetBgIndex(Value);
end;

procedure FarColor.SetFg4Bit(const Value: Boolean);
begin
  SetFgIndex(Value);
end;

{$DEFINE _FAR_IMPLEMENTATION_}
{$INCLUDE Far.Plugin.Helpers.g.pas}
{$INCLUDE Far.Plugin.Settings.pas}
{$UNDEF _FAR_IMPLEMENTATION_}

end.
