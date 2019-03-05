{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 1996-2000, Eugene Roshal                      }
{ Copyright (C) 2000-2019, Far Group                          }
{ Copyright (C) 1995-2019, Yegor Mialyk. All Rights Reserved. }
{                                                             }
{ Licensed under the MIT License. See LICENSE for details.    }
{                                                             }
{*************************************************************}

  FarMacroCall = record
    StructSize: UIntPtr;
    Count: UIntPtr;
    Values: PFarMacroValue;
    Callback: procedure (CallbackData: Pointer; Value: PFarMacroValue; Count: UIntPtr);
    CallbackData: Pointer;
  end;
