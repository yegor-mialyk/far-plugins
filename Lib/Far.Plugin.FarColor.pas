//
// Far Manager SDK
//
// Copyright (C) 1995-2026, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

  FarColor = record
    Flags: FARCOLORFLAGS;
    Foreground: record case Integer of
      0: (ForegroundColor: COLORREF);
      1: (ForegroundIndex: color_index);
      2: (ForegroundRGBA: rgba);
    end;
    Background: record case Integer of
      0: (BackgroundColor: COLORREF);
      1: (BackgroundIndex: color_index);
      2: (BackgroundRGBA: rgba);
    end;
    Underline: record case Integer of
      0: (UnderlineColor: COLORREF);
      1: (UnderlineIndex: color_index);
      2: (UnderlineRGBA: rgba);
    end;
    Reserved: DWORD;

    class operator Equal(const Left, Right: FarColor): Boolean;
    class operator NotEqual(const Left, Right: FarColor): Boolean;

    function IsBgIndex: Boolean;
    function IsFgIndex: Boolean;
    function IsUnderlineIndex: Boolean;

    function IsBgDefault: Boolean;
    function IsFgDefault: Boolean;
    function IsUnderlineDefault: Boolean;

    function GetUnderline: Integer;

    procedure SetBgIndex(const Value: Boolean);
    procedure SetFgIndex(const Value: Boolean);
    procedure SetUnderlineIndex(const Value: Boolean);

    procedure SetBgDefault;
    procedure SetFgDefault;
    procedure SetUnderlineDefault;

    procedure SetUnderline(const UnderlineStyle: Integer);

    function IsBg4Bit: Boolean;
    function IsFg4Bit: Boolean;

    procedure SetBg4Bit(const Value: Boolean);
    procedure SetFg4Bit(const Value: Boolean);
  end;
