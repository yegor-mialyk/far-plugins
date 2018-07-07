{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 2009-2018, Ariman                             }
{ Copyright (C) 1995-2018, Yegor Myalik. All Rights Reserved. }
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