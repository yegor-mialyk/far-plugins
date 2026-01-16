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
  end;
