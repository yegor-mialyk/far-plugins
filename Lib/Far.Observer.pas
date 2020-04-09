{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 2009-2020, Ariman                             }
{ Copyright (C) 1995-2020, Yegor Mialyk. All Rights Reserved. }
{                                                             }
{ Licensed under the MIT License. See LICENSE for details.    }
{                                                             }
{*************************************************************}

unit Far.Observer;

{$INCLUDE compiler.inc}
{$ALIGN 4}
{$WEAKPACKAGEUNIT}

interface

uses
  Winapi.Windows;

{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}

{$INCLUDE Far.Observer.ModuleDef.Generated.pas}

function MakeModuleVersion(const Major, Minor: DWORD): DWORD;

implementation

function MakeModuleVersion;
begin
  Result := Major shl 16 or Minor;
end;

end.
