//
// Far Manager SDK
//
// Copyright (C) 1995-2021, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

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
