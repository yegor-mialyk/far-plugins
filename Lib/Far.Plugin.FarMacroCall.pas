{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 1996-2000, Eugene Roshal                      }
{ Copyright (C) 2000-2018, Far Group                          }
{ Copyright (C) 1995-2018, Yegor Mialyk. All Rights Reserved. }
{                                                             }
{*************************************************************}

  FarMacroCall = record
    StructSize: UIntPtr;
    Count: UIntPtr;
    Values: PFarMacroValue;
    Callback: procedure (CallbackData: Pointer; Value: PFarMacroValue; Count: UIntPtr);
    CallbackData: Pointer;
  end;
