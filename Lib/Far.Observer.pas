//
// Far Manager SDK
//
// Copyright (C) 1995-2021, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

unit Far.Observer;

{$INCLUDE Compiler.pas}
{$ALIGN 4}
{$WEAKPACKAGEUNIT}

interface

uses
  Winapi.Windows;

{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}

{$INCLUDE Far.Observer.ModuleDef.g.pas}

function MakeModuleVersion(const Major, Minor: DWORD): DWORD;

implementation

function MakeModuleVersion;
begin
  Result := Major shl 16 or Minor;
end;

end.
