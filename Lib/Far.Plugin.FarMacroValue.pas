{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 1996-2000, Eugene Roshal                      }
{ Copyright (C) 2000-2018, Far Group                          }
{ Copyright (C) 1995-2018, Yegor Mialyk. All Rights Reserved. }
{                                                             }
{*************************************************************}

  FarMacroValue = record
    &Type: FARMACROVARTYPE;
    Value: record case Integer of
      0: (Integer: Int64);
      1: (Boolean: Int64);
      2: (Double: Double);
      3: (&String: PChar);
      4: (Pointer: Pointer);
      5: (Binary: record
            Data: Pointer;
            Size: UIntPtr
          end;);
      6: (&Array: record
            Values: PFarMacroValue;
            Count: UIntPtr
          end;);
    end;
  end;
