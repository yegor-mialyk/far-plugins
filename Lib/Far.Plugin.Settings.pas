{$IFNDEF _FAR_IMPLEMENTATION_}
type
  TFarSettings = record
    Handle: THandle;
    CurrentRoot: UIntPtr;

    procedure Init(const Guid: TGUID; const RootValue: UIntPtr = 0);
    procedure Done;
    procedure OpenRoot; inline;
    function CreateKey(const Name: string): UIntPtr;
    function OpenKey(const Name: string): UIntPtr;
    function GetValue(const Name, DefaultValue: string): PChar; overload;
    function GetValue(const Name: string; const DefaultValue: UInt64): UInt64; overload;
    function SetValue(const Name, Value: string): Boolean; overload;
    function SetValue(const Name: string; const Value: UInt64): Boolean; overload;
  end;

{$ELSE}

procedure TFarSettings.Init;
var
  settings: FarSettingsCreate;
begin
  Handle := INVALID_HANDLE_VALUE;
  CurrentRoot := RootValue;

  settings.Init;
  settings.Guid := Guid;
  if FarAPI.SettingsControl(INVALID_HANDLE_VALUE, SCTL_CREATE, 0, Pointer(@settings)) <> 0 then
    Handle := settings.Handle;
end;

procedure TFarSettings.OpenRoot;
begin
  CurrentRoot := 0;
end;

procedure TFarSettings.Done;
begin
  if Handle = INVALID_HANDLE_VALUE then
    Exit;

  FarAPI.SettingsControl(Handle, SCTL_FREE, 0, nil);
  Handle := INVALID_HANDLE_VALUE;
end;

function TFarSettings.CreateKey;
var
  value: FarSettingsValue;
begin
  value.Init;
  value.Root := CurrentRoot;
  value.Value := Pointer(Name);
  Result := FarAPI.SettingsControl(Handle, SCTL_CREATESUBKEY, 0, Pointer(@value));
  CurrentRoot := Result;
end;

function TFarSettings.OpenKey;
var
  value: FarSettingsValue;
begin
  value.Init;
  value.Root := CurrentRoot;
  value.Value := Pointer(Name);
  Result := FarAPI.SettingsControl(Handle, SCTL_OPENSUBKEY, 0, Pointer(@value));
  CurrentRoot := Result;
end;

function TFarSettings.GetValue(const Name, DefaultValue: string): PChar;
var
  item: FarSettingsItem;
begin
  item.Init;
  item.Root := CurrentRoot;
  item.Name := Pointer(Name);
  item.&Type := FST_STRING;
  if FarAPI.SettingsControl(Handle, SCTL_GET, 0, Pointer(@item)) <> 0 then
    Result := item.Value.&String
  else
    Result := Pointer(DefaultValue);
end;

function TFarSettings.GetValue(const Name: string; const DefaultValue: UInt64): UInt64;
var
  item: FarSettingsItem;
begin
  item.Init;
  item.Root := CurrentRoot;
  item.Name := Pointer(Name);
  item.&Type := FST_QWORD;
  if FarAPI.SettingsControl(Handle, SCTL_GET, 0, Pointer(@item)) <> 0 then
    Result := item.Value.Number
  else
    Result := DefaultValue;
end;

function TFarSettings.SetValue(const Name, Value: string): Boolean;
var
  item: FarSettingsItem;
begin
  item.Init;
  item.Root := CurrentRoot;
  item.Name := Pointer(Name);
  item.&Type := FST_STRING;
  item.Value.&String := Pointer(Value);
  Result := FarAPI.SettingsControl(Handle, SCTL_SET, 0, Pointer(@item)) <> 0;
end;

function TFarSettings.SetValue(const Name: string; const Value: UInt64): Boolean;
var
  item: FarSettingsItem;
begin
  item.Init;
  item.Root := CurrentRoot;
  item.Name := Pointer(Name);
  item.&Type := FST_QWORD;
  item.Value.Number := Value;
  Result := FarAPI.SettingsControl(Handle, SCTL_SET, 0, Pointer(@item)) <> 0;
end;

{$ENDIF}
