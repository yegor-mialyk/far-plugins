<%GenerateHelper
{$IFNDEF _FAR_IMPLEMENTATION_}
type
  %1Helper = record helper for %1
    procedure Init; inline;
  end;
{$ELSE}
procedure %1Helper.Init;
begin
  FillChar(Self, SizeOf(%1), 0);
  StructSize := SizeOf(%1);
end;
{$ENDIF}

%>
%GenerateHelper FarListUpdate
%GenerateHelper FarListInsert
%GenerateHelper FarListGetItem
%GenerateHelper FarListPos
%GenerateHelper FarListFind
%GenerateHelper FarListDelete
%GenerateHelper FarListInfo
%GenerateHelper FarListItemData
%GenerateHelper FarList
%GenerateHelper FarListTitles
%GenerateHelper FarDialogItemColors
%GenerateHelper FarDialogItemData
%GenerateHelper FarDialogEvent
%GenerateHelper OpenDlgPluginData
%GenerateHelper DialogInfo
%GenerateHelper FarGetDialogItem
%GenerateHelper FarPanelItemFreeInfo
%GenerateHelper FarGetPluginPanelItem
%GenerateHelper PanelInfo
%GenerateHelper PanelRedrawInfo
%GenerateHelper CmdLineSelect
%GenerateHelper FarPanelDirectory
%GenerateHelper MacroParseResult
%GenerateHelper MacroSendMacroText
%GenerateHelper MacroAddMacro
%GenerateHelper FarMacroCall
%GenerateHelper FarGetValue
%GenerateHelper MacroExecuteString
%GenerateHelper FarMacroLoad
%GenerateHelper FarSetColors
%GenerateHelper WindowInfo
%GenerateHelper WindowType
%GenerateHelper ProgressValue
%GenerateHelper ViewerSetMode
%GenerateHelper ViewerSelect
%GenerateHelper ViewerSetPosition
%GenerateHelper ViewerInfo
%GenerateHelper EditorSetParameter
%GenerateHelper EditorUndoRedo
%GenerateHelper EditorGetString
%GenerateHelper EditorSetString
%GenerateHelper EditorInfo
%GenerateHelper EditorBookmarks
%GenerateHelper EditorSetPosition
%GenerateHelper EditorSelect
%GenerateHelper EditorConvertPos
%GenerateHelper EditorColor
%GenerateHelper EditorDeleteColor
%GenerateHelper EditorSaveFile
%GenerateHelper EditorChange
%GenerateHelper EditorSubscribeChangeEvent
%GenerateHelper FarSettingsCreate
%GenerateHelper FarSettingsItem
%GenerateHelper FarSettingsEnum
%GenerateHelper FarSettingsValue
%GenerateHelper FarStandardFunctions
%GenerateHelper PluginStartupInfo
%GenerateHelper ArclitePrivateInfo
%GenerateHelper NetBoxPrivateInfo
%GenerateHelper MacroPrivateInfo
%GenerateHelper GlobalInfo
%GenerateHelper PluginInfo
%GenerateHelper FarGetPluginInformation
%GenerateHelper FarSetKeyBarTitles
%GenerateHelper OpenPanelInfo
%GenerateHelper AnalyseInfo
%GenerateHelper OpenAnalyseInfo
%GenerateHelper OpenMacroInfo
%GenerateHelper OpenShortcutInfo
%GenerateHelper OpenCommandLineInfo
%GenerateHelper OpenInfo
%GenerateHelper SetDirectoryInfo
%GenerateHelper SetFindListInfo
%GenerateHelper PutFilesInfo
%GenerateHelper ProcessHostFileInfo
%GenerateHelper MakeDirectoryInfo
%GenerateHelper CompareInfo
%GenerateHelper GetFindDataInfo
%GenerateHelper FreeFindDataInfo
%GenerateHelper GetFilesInfo
%GenerateHelper DeleteFilesInfo
%GenerateHelper ProcessPanelInputInfo
%GenerateHelper ProcessEditorInputInfo
%GenerateHelper ProcessConsoleInputInfo
%GenerateHelper ExitInfo
%GenerateHelper ProcessPanelEventInfo
%GenerateHelper ProcessEditorEventInfo
%GenerateHelper ProcessDialogEventInfo
%GenerateHelper ProcessSynchroEventInfo
%GenerateHelper ProcessViewerEventInfo
%GenerateHelper ClosePanelInfo
%GenerateHelper CloseAnalyseInfo
%GenerateHelper ConfigureInfo
%GenerateHelper GetContentFieldsInfo
%GenerateHelper GetContentDataInfo
%GenerateHelper ErrorInfo
