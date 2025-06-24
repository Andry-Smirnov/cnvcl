{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2025 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��https://www.cnpack.org                                  }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnOTAUtils;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����
* ��Ԫ���ƣ�Delphi/Lazarus �������������ߵ�Ԫ�������� CnWizUtils
* ��Ԫ���ߣ�CnPack ������ CnPack ������ (master@cnpack.org)
* ��    ע���õ�Ԫʵ����һЩ����ڵ� Delphi OTA �� Lazarus ��غ���
* ����ƽ̨��PWinXP + Delphi 5.0
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* �޸ļ�¼��2025.06.24 V1.1
*               ʵ��һ���� Lazarus �������ڹ���
*           2006.08.19 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Windows, Messages, SysUtils, Classes, Forms, {$IFDEF FPC} LazIDEIntf, ProjectIntf,
  CompOptsIntf, SrcEditorIntf, {$ELSE}
  ToolsAPI, {$IFDEF COMPILER6_UP} Variants, {$ENDIF} {$ENDIF}
  CnCommon;

{$IFDEF FPC}

function CnOtaGetCurrentProject: TLazProject;
{* ȡ��ǰ���� }

{$ELSE}

function CnOtaGetProjectGroup: IOTAProjectGroup;
{* ȡ��ǰ������ }

function CnOtaGetCurrentProject: IOTAProject;
{* ȡ��ǰ���� }

{$ENDIF}

function CnOtaGetCurrentProjectFileName: string;
{* ȡ��ǰ�����ļ����� }

{$IFDEF FPC}

function CnOtaGetActiveProjectOptions: TLazCompilerOptions;
{* ȡ��ǰ����ѡ�� }

{$ELSE}

function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
{* ȡ��ǰ����ѡ�� }

function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
{* ȡ��ǰ����ָ��ѡ�� }

{$ENDIF}

function CnOtaGetOutputDir: string;
{* ȡ��ǰ�������Ŀ¼ }

{$IFNDEF FPC}

function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean = False): string;
{* ȡָ��ģ���ļ�����GetSourceEditorFileName ��ʾ�Ƿ񷵻��ڴ���༭���д򿪵��ļ�}

function CnOtaGetCurrentModule: IOTAModule;
{* ȡ��ǰģ��}

{$ENDIF}

function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean = False): string;
{* ȡ��ǰģ���ļ���}

function GetIdeRootDirectory: string;
{* ȡ�� IDE ��Ŀ¼}

function CnOtaIsFileOpen(const FileName: string): Boolean;
{* �ж��ļ��Ƿ�� }

function IsCpp(const FileName: string): Boolean;
{* �ж��Ƿ�.Cpp�ļ�}

function CnOtaReplaceToActualPath(const Path: string): string;
{* �� $(DELPHI) �����ķ����滻Ϊ Delphi ����·��}

{$IFNDEF FPC}
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
function CnOtaGetActiveProjectOptionsConfigurations(Project: IOTAProject = nil): IOTAProjectOptionsConfigurations;
{* ȡ��ǰ��������ѡ�2009 �����Ч}
{$ENDIF}
{$ENDIF}

implementation

{ Other DesignTime Utils Routines }

const
  SCnIDEPathMacro = '{$DELPHI}';

{$IFDEF FPC}

function CnOtaGetCurrentProject: TLazProject;
begin
  if Assigned(LazarusIDE) then
    Result := LazarusIDE.ActiveProject
  else
    Result := nil;
end;

{$ELSE}

// ȡ��ǰ������
function CnOtaGetProjectGroup: IOTAProjectGroup;
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  I: Integer;
begin
  Result := nil;
  Supports(BorlandIDEServices, IOTAModuleServices, IModuleServices);
  if IModuleServices <> nil then
  begin
    for I := 0 to IModuleServices.ModuleCount - 1 do
    begin
      IModule := IModuleServices.Modules[I];
      if Supports(IModule, IOTAProjectGroup, Result) then
        Break;
    end;
  end;
end;

// ȡ��ǰ����
function CnOtaGetCurrentProject: IOTAProject;
var
  IProjectGroup: IOTAProjectGroup;
begin
  Result := nil;

  IProjectGroup := CnOtaGetProjectGroup;
  if not Assigned(IProjectGroup) then
    Exit;

  try
    Result := IProjectGroup.ActiveProject;
  except
    Result := nil;
  end;
end;

{$ENDIF}

// ȡ��ǰ�����ļ�����
function CnOtaGetCurrentProjectFileName: string;
{$IFNDEF FPC}
var
  CurrentProject: IOTAProject;
{$ENDIF}
begin
{$IFDEF FPC}
  if Assigned(LazarusIDE) and Assigned(LazarusIDE.ActiveProject) then
    Result := LazarusIDE.ActiveProject.ProjectInfoFile
  else
    Result := '';
{$ELSE}
  CurrentProject := CnOtaGetCurrentProject;
  if Assigned(CurrentProject) then
    Result := CurrentProject.FileName
  else
    Result := '';
{$ENDIF}
end;

{$IFDEF FPC}

function CnOtaGetActiveProjectOptions: TLazCompilerOptions;
var
  BMs: TLazProjectBuildModes;
  BM: TLazProjectBuildMode;
  ID: string;
  Idx: Integer;
begin
  Result := nil;
  if Assigned(LazarusIDE) and Assigned(LazarusIDE.ActiveProject) then
  begin
    BMs := LazarusIDE.ActiveProject.LazBuildModes;
    ID := LazarusIDE.ActiveProject.ActiveBuildModeID;
    Idx := BMs.IndexOf(ID);
    if Idx >= 0 then
    begin
      BM := BMs.BuildModes[Idx];
      if BM <> nil then
        Result := BM.LazCompilerOptions;
    end;
  end;
end;

{$ELSE}

// ȡ��ǰ����ѡ��
function CnOtaGetActiveProjectOptions(Project: IOTAProject = nil): IOTAProjectOptions;
begin
  Result := nil;
  if Assigned(Project) then
  begin
    Result:=Project.ProjectOptions;
    Exit;
  end;

  Project := CnOtaGetCurrentProject;
  if Assigned(Project) then
    Result := Project.ProjectOptions;
end;

// ȡ��ǰ����ָ��ѡ��
function CnOtaGetActiveProjectOption(const Option: string; var Value: Variant): Boolean;
var
  ProjectOptions: IOTAProjectOptions;
begin
  Result := False;
  Value := '';

  ProjectOptions := CnOtaGetActiveProjectOptions;
  if Assigned(ProjectOptions) then
  begin
    Value := ProjectOptions.Values[Option];
    Result := True;
  end;
end;

{$ENDIF}

// ȡ��ǰ�������Ŀ¼
function CnOtaGetOutputDir: string;
var
  ProjectDir: string;
{$IFDEF FPC}
  Options: TLazCompilerOptions;
{$ELSE}
  OutputDir: Variant;
{$ENDIF}
begin
  ProjectDir := _CnExtractFileDir(CnOtaGetCurrentProjectFileName);

{$IFDEF FPC}
  Options := CnOtaGetActiveProjectOptions;
  if Assigned(Options) then
    Result := LinkPath(ProjectDir, Options.UnitOutputDirectory) 
  else
    Result := ProjectDir;
{$ELSE}
  if CnOtaGetActiveProjectOption('OutputDir', OutputDir) then
    Result := LinkPath(ProjectDir, OutputDir)
  else
    Result := ProjectDir;
{$ENDIF}
end;

{$IFNDEF FPC}

// ȡָ��ģ���ļ�����GetSourceEditorFileName ��ʾ�Ƿ񷵻��ڴ���༭���д򿪵��ļ�
function CnOtaGetFileNameOfModule(Module: IOTAModule;
  GetSourceEditorFileName: Boolean): string;
var
  I: Integer;
  Editor: IOTAEditor;
  SourceEditor: IOTASourceEditor;
begin
  Result := '';
  if Assigned(Module) then
  begin
    if not GetSourceEditorFileName then
      Result := Module.FileName
    else
    begin
      for I := 0 to Module.GetModuleFileCount - 1 do
      begin
        Editor := Module.GetModuleFileEditor(I);
        if Supports(Editor, IOTASourceEditor, SourceEditor) then
        begin
          Result := Editor.FileName;
          Break;
        end;
      end;
    end;
  end;
end;

// ȡ��ǰģ��
function CnOtaGetCurrentModule: IOTAModule;
var
  iModuleServices: IOTAModuleServices;
begin
  Result := nil;
  Supports(BorlandIDEServices, IOTAModuleServices, iModuleServices);
  if iModuleServices <> nil then
    Result := iModuleServices.CurrentModule;
end;

{$ENDIF}

// ȡ��ǰģ���ļ�����ע�� Lazarus ��ֻ֧��Դ�ļ���
function CnOtaGetFileNameOfCurrentModule(GetSourceEditorFileName: Boolean): string;
{$IFDEF FPC}
var
  Editor: TSourceEditorInterface;
{$ENDIF}
begin
{$IFDEF FPC}
  Result := '';
  if SourceEditorManagerIntf = nil then Exit;

  Editor := SourceEditorManagerIntf.ActiveEditor;
  
  if Assigned(Editor) then
    Result := Editor.FileName;
{$ELSE}
  Result := CnOtaGetFileNameOfModule(CnOtaGetCurrentModule, GetSourceEditorFileName);
{$ENDIF}
end;

// ȡ�� IDE ��Ŀ¼
function GetIdeRootDirectory: string;
begin
  Result := _CnExtractFilePath(_CnExtractFileDir(Application.ExeName));
end;

{$IFNDEF FPC}

// ȡģ��༭��
function CnOtaGetFileEditorForModule(Module: IOTAModule; Index: Integer): IOTAEditor;
begin
  Result := nil;
  if not Assigned(Module) then Exit;
  try
    // BCB 5 ��Ϊһ���򵥵ĵ�Ԫ���� GetModuleFileEditor(1) �����
    {$IFDEF BCB5}
    if IsCpp(Module.FileName) and (Module.GetModuleFileCount = 2) and (Index = 1) then
      Index := 2;
    {$ENDIF}
    Result := Module.GetModuleFileEditor(Index);
  except
    Result := nil; // �� IDE �ͷ�ʱ�����ܻ����쳣����
  end;
end;

{$ENDIF}

// �ж��ļ��Ƿ��
function CnOtaIsFileOpen(const FileName: string): Boolean;
var
{$IFDEF FPC}
  Editor: TSourceEditorInterface;
{$ELSE}
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
  FileEditor: IOTAEditor;
{$ENDIF}
  I: Integer;
begin
  Result := False;

{$IFDEF FPC}
  if (LazarusIDE = nil) or (SourceEditorManagerIntf = nil) then Exit;

  // �������д򿪵ı༭��
  for I := 0 to SourceEditorManagerIntf.SourceEditorCount - 1 do
  begin
    Editor := SourceEditorManagerIntf.SourceEditors[I];
    
    // �Ƚ��ļ�·������ƽ̨��ȫ��
    if CompareText(FileName, Editor.FileName) = 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
{$ELSE}
  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  if ModuleServices = nil then Exit;

  Module := ModuleServices.FindModule(FileName);
  if Assigned(Module) then
  begin
    for I := 0 to Module.GetModuleFileCount-1 do
    begin
      FileEditor := CnOtaGetFileEditorForModule(Module, I);
      Assert(Assigned(FileEditor));

      Result := CompareText(FileName, FileEditor.FileName) = 0;
      if Result then
        Exit;
    end;
  end;
{$ENDIF}
end;

// �ж��Ƿ�.Cpp�ļ�
function IsCpp(const FileName: string): Boolean;
var
  FileExt: string;
begin
  FileExt := UpperCase(_CnExtractFileExt(FileName));
  Result := (FileExt = '.CPP');
end;

{$IFNDEF FPC}
{$IFDEF SUPPORT_OTA_PROJECT_CONFIGURATION}
// * ȡ��ǰ��������ѡ�2009 �����Ч
function CnOtaGetActiveProjectOptionsConfigurations
  (Project: IOTAProject): IOTAProjectOptionsConfigurations;
var
  ProjectOptions: IOTAProjectOptions;
begin
  ProjectOptions := CnOtaGetActiveProjectOptions(Project);
  if ProjectOptions <> nil then
    if Supports(ProjectOptions, IOTAProjectOptionsConfigurations, Result) then
      Exit;

  Result := nil;
end;
{$ENDIF}
{$ENDIF}

// �� $(DELPHI) �����ķ����滻Ϊ Delphi ����·��
function CnOtaReplaceToActualPath(const Path: string): string;
var
{$IFDEF FPC}
  Options: TLazCompilerOptions;
{$ELSE}
{$IFDEF COMPILER6_UP}
  Vars: TStringList;
  I: Integer;
{$IFDEF DELPHI2011_UP}
  BC: IOTAProjectOptionsConfigurations;
{$ENDIF}
{$ENDIF}
{$ENDIF}
begin
{$IFDEF COMPILER6_UP}
  Result := Path;
  Vars := TStringList.Create;
  try
    GetEnvironmentVars(Vars, True);
    for I := 0 to Vars.Count - 1 do
      Result := StringReplace(Result, '$(' + Vars.Names[I] + ')',
        Vars.Values[Vars.Names[I]], [rfReplaceAll, rfIgnoreCase]);
    {$IFDEF DELPHI2011_UP}
      BC := CnOtaGetActiveProjectOptionsConfigurations(nil);
      if BC <> nil then
      begin
        if BC.GetActiveConfiguration <> nil then
        begin
          Result := StringReplace(Result, '$(Config)',
            BC.GetActiveConfiguration.GetName, [rfReplaceAll, rfIgnoreCase]);
    {$IFDEF DELPHI2012_UP}
          Result := StringReplace(Result, '$(Platform)',
            BC.GetActiveConfiguration.GetPlatform, [rfReplaceAll, rfIgnoreCase]);
    {$ENDIF}
        end;
      end;
    {$ENDIF}
  finally
    Vars.Free;
  end;   
{$ELSE}
  {$IFDEF FPC}
  Result := Path;
  Options := CnOtaGetActiveProjectOptions;
  if Options <> nil then
  begin
    Result := StringReplace(Result, '$(TargetOS)',
      Options.TargetOS, [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '$(TargetCPU)',
      Options.TargetCPU, [rfReplaceAll, rfIgnoreCase]);
  end;
  {$ELSE}
  // Delphi5 �²�֧�ֻ�������
  Result := StringReplace(Path, SCnIDEPathMacro, MakeDir(GetIdeRootDirectory),
    [rfReplaceAll, rfIgnoreCase]);
  {$ENDIF}
{$ENDIF}
end;

end.
