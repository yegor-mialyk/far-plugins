{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 1996-2000, Eugene Roshal                      }
{ Copyright (C) 2000-2018, Far Group                          }
{ Copyright (C) 1995-2018, Yegor Mialyk. All Rights Reserved. }
{                                                             }
{*************************************************************}

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
