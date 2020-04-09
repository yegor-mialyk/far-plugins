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
