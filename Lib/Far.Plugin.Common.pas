{*************************************************************}
{                                                             }
{ Delphi Runtime Library                                      }
{                                                             }
{ Copyright (C) 1995-2020, Yegor Mialyk. All Rights Reserved. }
{                                                             }
{ Licensed under the MIT License. See LICENSE for details.    }
{                                                             }
{*************************************************************}

function GetMsg(const MsgId: TFarMessage): PChar;
begin
  Result := FarAPI.GetMsg(PluginGuid, Integer(MsgId));
end;

function ShowMessage(const Message: PChar): Integer;
var
  MessArr: array [0..1] of PChar;
begin
  MessArr[0] := GetMsg(MPluginName);
  MessArr[1] := Message;
  Result := FarAPI.Message(PluginGuid, PluginGuid, FMSG_WARNING or FMSG_MB_OK, NULL, @MessArr, High(MessArr) + 1, 0);
end;
