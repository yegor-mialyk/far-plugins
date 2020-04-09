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

  FarSettingsItem = record
    StructSize: UIntPtr;
    Root: UIntPtr;
    Name: PChar;
    &Type: FARSETTINGSTYPES;
    Value: record case Integer of
      0: (Number: UInt64);
      1: (&String: PChar);
      2: (Data: record
            Size: UIntPtr;
            Data: Pointer;
          end;);
    end;
  end;
