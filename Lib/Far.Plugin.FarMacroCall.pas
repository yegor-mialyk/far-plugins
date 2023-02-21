//
// Far Manager SDK
//
// Copyright (C) 1995-2023, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

  TFarMacroCallCallback = procedure (CallbackData: Pointer; Value: PFarMacroValue; Count: UIntPtr); stdcall;
  
  FarMacroCall = record
    StructSize: UIntPtr;
    Count: UIntPtr;
    Values: PFarMacroValue;
    Callback: TFarMacroCallCallback;
    CallbackData: Pointer;
  end;
