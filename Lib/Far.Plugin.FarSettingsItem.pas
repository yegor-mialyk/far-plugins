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
