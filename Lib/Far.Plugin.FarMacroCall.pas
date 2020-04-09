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

  TFarMacroCallCallback = procedure (CallbackData: Pointer; Value: PFarMacroValue; Count: UIntPtr); stdcall;
  
  FarMacroCall = record
    StructSize: UIntPtr;
    Count: UIntPtr;
    Values: PFarMacroValue;
    Callback: TFarMacroCallCallback;
    CallbackData: Pointer;
  end;
