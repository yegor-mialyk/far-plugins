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
    Reserved: Pointer;
  end;
