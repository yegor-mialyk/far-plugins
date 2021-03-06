//
// Far Manager SDK
//
// Copyright (C) 1995-2021, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

  FarColor = record
    Flags: FARCOLORFLAGS;
    Foreground: record case Integer of
      0: (ForegroundColor: COLORREF);
      1: (ForegroundRGBA: rgba);
    end;
    Background: record case Integer of
      0: (BackgroundColor: COLORREF);
      1: (BackgroundRGBA: rgba);
    end;
    Reserved: array [0..1] of DWORD;
  end;
