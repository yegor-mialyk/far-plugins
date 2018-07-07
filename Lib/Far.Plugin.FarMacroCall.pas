  FarMacroCall = record
    StructSize: UIntPtr;
    Count: UIntPtr;
    Values: PFarMacroValue;
    Callback: procedure (CallbackData: Pointer; Value: PFarMacroValue; Count: UIntPtr);
    CallbackData: Pointer;
  end;
