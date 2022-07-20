//
// Far Manager SDK
//
// Copyright (C) 1995-2022, Yegor Mialyk. All Rights Reserved.
//
// Licensed under the MIT License. See the LICENSE file for details.
//

%PP_HEADER
%MACRO GenerateHelper
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

%END
%RUN GenerateHelper FarListUpdate
%RUN GenerateHelper FarListInsert
%RUN GenerateHelper FarListGetItem
%RUN GenerateHelper FarListPos
%RUN GenerateHelper FarListFind
%RUN GenerateHelper FarListDelete
%RUN GenerateHelper FarListInfo
%RUN GenerateHelper FarListItemData
%RUN GenerateHelper FarList
%RUN GenerateHelper FarListTitles
%RUN GenerateHelper FarDialogItemColors
%RUN GenerateHelper FarDialogItemData
%RUN GenerateHelper FarDialogEvent
%RUN GenerateHelper OpenDlgPluginData
%RUN GenerateHelper DialogInfo
%RUN GenerateHelper FarGetDialogItem
%RUN GenerateHelper FarPanelItemFreeInfo
%RUN GenerateHelper FarGetPluginPanelItem
%RUN GenerateHelper PanelInfo
%RUN GenerateHelper PanelRedrawInfo
%RUN GenerateHelper CmdLineSelect
%RUN GenerateHelper FarPanelDirectory
%RUN GenerateHelper MacroParseResult
%RUN GenerateHelper MacroSendMacroText
%RUN GenerateHelper MacroAddMacro
%RUN GenerateHelper FarMacroCall
%RUN GenerateHelper FarGetValue
%RUN GenerateHelper MacroExecuteString
%RUN GenerateHelper FarMacroLoad
%RUN GenerateHelper FarSetColors
%RUN GenerateHelper WindowInfo
%RUN GenerateHelper WindowType
%RUN GenerateHelper ProgressValue
%RUN GenerateHelper ViewerSetMode
%RUN GenerateHelper ViewerSelect
%RUN GenerateHelper ViewerSetPosition
%RUN GenerateHelper ViewerInfo
%RUN GenerateHelper EditorSetParameter
%RUN GenerateHelper EditorUndoRedo
%RUN GenerateHelper EditorGetString
%RUN GenerateHelper EditorSetString
%RUN GenerateHelper EditorInfo
%RUN GenerateHelper EditorBookmarks
%RUN GenerateHelper EditorSetPosition
%RUN GenerateHelper EditorSelect
%RUN GenerateHelper EditorConvertPos
%RUN GenerateHelper EditorColor
%RUN GenerateHelper EditorDeleteColor
%RUN GenerateHelper EditorSaveFile
%RUN GenerateHelper EditorChange
%RUN GenerateHelper EditorSubscribeChangeEvent
%RUN GenerateHelper FarSettingsCreate
%RUN GenerateHelper FarSettingsItem
%RUN GenerateHelper FarSettingsEnum
%RUN GenerateHelper FarSettingsValue
%RUN GenerateHelper FarStandardFunctions
%RUN GenerateHelper PluginStartupInfo
%RUN GenerateHelper ArclitePrivateInfo
%RUN GenerateHelper NetBoxPrivateInfo
%RUN GenerateHelper MacroPrivateInfo
%RUN GenerateHelper GlobalInfo
%RUN GenerateHelper PluginInfo
%RUN GenerateHelper FarGetPluginInformation
%RUN GenerateHelper FarSetKeyBarTitles
%RUN GenerateHelper OpenPanelInfo
%RUN GenerateHelper AnalyseInfo
%RUN GenerateHelper OpenAnalyseInfo
%RUN GenerateHelper OpenMacroInfo
%RUN GenerateHelper OpenShortcutInfo
%RUN GenerateHelper OpenCommandLineInfo
%RUN GenerateHelper OpenInfo
%RUN GenerateHelper SetDirectoryInfo
%RUN GenerateHelper SetFindListInfo
%RUN GenerateHelper PutFilesInfo
%RUN GenerateHelper ProcessHostFileInfo
%RUN GenerateHelper MakeDirectoryInfo
%RUN GenerateHelper CompareInfo
%RUN GenerateHelper GetFindDataInfo
%RUN GenerateHelper FreeFindDataInfo
%RUN GenerateHelper GetFilesInfo
%RUN GenerateHelper DeleteFilesInfo
%RUN GenerateHelper ProcessPanelInputInfo
%RUN GenerateHelper ProcessEditorInputInfo
%RUN GenerateHelper ProcessConsoleInputInfo
%RUN GenerateHelper ExitInfo
%RUN GenerateHelper ProcessPanelEventInfo
%RUN GenerateHelper ProcessEditorEventInfo
%RUN GenerateHelper ProcessDialogEventInfo
%RUN GenerateHelper ProcessSynchroEventInfo
%RUN GenerateHelper ProcessViewerEventInfo
%RUN GenerateHelper ClosePanelInfo
%RUN GenerateHelper CloseAnalyseInfo
%RUN GenerateHelper ConfigureInfo
%RUN GenerateHelper GetContentFieldsInfo
%RUN GenerateHelper GetContentDataInfo
%RUN GenerateHelper ErrorInfo
