{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 1996-2000, Eugene Roshal                      }
{ Copyright (C) 2000-2018, Far Group                          }
{ Copyright (C) 1995-2018, Yegor Mialyk. All Rights Reserved. }
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
