//
// Far Manager SDK
//
// Copyright (C) 1995-2025, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

function GetMsg(const MsgId: TFarMessage): PChar;
begin
  Result := FarAPI.GetMsg(PluginGuid, IntPtr(MsgId));
end;

function ShowMessage(const Message: PChar;
  Flags: FARMESSAGEFLAGS = FMSG_WARNING or FMSG_MB_OK;
  HelpTopic: PChar = NULL): Integer;
var
  Items: array [0..1] of PChar;
begin
  Items[0] := GetMsg(MPluginName);
  Items[1] := Message;
  Result := FarAPI.Message(PluginGuid, PluginGuid, Flags, HelpTopic, @Items, High(Items) + 1, 0);
end;
