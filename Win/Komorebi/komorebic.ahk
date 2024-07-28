#Requires AutoHotkey v2.0.2
#SingleInstance Force

; Contents of komorebic.lib.ahk
; https://github.com/LGUG2Z/komorebi/blob/master/komorebic.lib.ahk
Start(ffm := "", await_configuration := "", tcp_port := "") {
    ; Construct the command with optional arguments
    command := "komorebic.exe start"
    if (ffm != "") {
        command .= " " ffm
    }
    if (await_configuration != "") {
        command .= " --await-configuration " await_configuration
    }
    if (tcp_port != "") {
        command .= " --tcp-port " tcp_port
    }
    ; Run the command
    RunWait(command, , "Hide")
}

Stop() {
    RunWait("komorebic.exe stop", , "Hide")
}

State() {
    RunWait("komorebic.exe state", , "Hide")
}

Query(state_query) {
    RunWait("komorebic.exe query " state_query, , "Hide")
}

Subscribe(named_pipe) {
    RunWait("komorebic.exe subscribe " named_pipe, , "Hide")
}

Unsubscribe(named_pipe) {
    RunWait("komorebic.exe unsubscribe " named_pipe, , "Hide")
}

Log() {
    RunWait("komorebic.exe log", , "Hide")
}

QuickSaveResize() {
    RunWait("komorebic.exe quick-save-resize", , "Hide")
}

QuickLoadResize() {
    RunWait("komorebic.exe quick-load-resize", , "Hide")
}

SaveResize(path) {
    RunWait("komorebic.exe save-resize " path, , "Hide")
}

LoadResize(path) {
    RunWait("komorebic.exe load-resize " path, , "Hide")
}

Focus(operation_direction) {
    RunWait("komorebic.exe focus " operation_direction, , "Hide")
}

Move(operation_direction) {
    RunWait("komorebic.exe move " operation_direction, , "Hide")
}

Minimize() {
    RunWait("komorebic.exe minimize", , "Hide")
}

Close() {
    RunWait("komorebic.exe close", , "Hide")
}

ForceFocus() {
    RunWait("komorebic.exe force-focus", , "Hide")
}

CycleFocus(cycle_direction) {
    RunWait("komorebic.exe cycle-focus " cycle_direction, , "Hide")
}

CycleMove(cycle_direction) {
    RunWait("komorebic.exe cycle-move " cycle_direction, , "Hide")
}

Stack(operation_direction) {
    RunWait("komorebic.exe stack " operation_direction, , "Hide")
}

Resize(edge, sizing) {
    RunWait("komorebic.exe resize " edge " " sizing, , "Hide")
}

ResizeAxis(axis, sizing) {
    RunWait("komorebic.exe resize-axis " axis " " sizing, , "Hide")
}

Unstack() {
    RunWait("komorebic.exe unstack", , "Hide")
}

CycleStack(cycle_direction) {
    RunWait("komorebic.exe cycle-stack " cycle_direction, , "Hide")
}

MoveToMonitor(target) {
    RunWait("komorebic.exe move-to-monitor " target, , "Hide")
}

CycleMoveToMonitor(cycle_direction) {
    RunWait("komorebic.exe cycle-move-to-monitor " cycle_direction, , "Hide")
}

MoveToWorkspace(target) {
    RunWait("komorebic.exe move-to-workspace " target, , "Hide")
}

MoveToNamedWorkspace(workspace) {
    RunWait("komorebic.exe move-to-named-workspace " workspace, , "Hide")
}

CycleMoveToWorkspace(cycle_direction) {
    RunWait("komorebic.exe cycle-move-to-workspace " cycle_direction, , "Hide")
}

SendToMonitor(target) {
    RunWait("komorebic.exe send-to-monitor " target, , "Hide")
}

CycleSendToMonitor(cycle_direction) {
    RunWait("komorebic.exe cycle-send-to-monitor " cycle_direction, , "Hide")
}

SendToWorkspace(target) {
    RunWait("komorebic.exe send-to-workspace " target, , "Hide")
}

SendToNamedWorkspace(workspace) {
    RunWait("komorebic.exe send-to-named-workspace " workspace, , "Hide")
}

CycleSendToWorkspace(cycle_direction) {
    RunWait("komorebic.exe cycle-send-to-workspace " cycle_direction, , "Hide")
}

SendToMonitorWorkspace(target_monitor, target_workspace) {
    RunWait("komorebic.exe send-to-monitor-workspace " target_monitor " " target_workspace, , "Hide")
}

FocusMonitor(target) {
    RunWait("komorebic.exe focus-monitor " target, , "Hide")
}

FocusWorkspace(target) {
    RunWait("komorebic.exe focus-workspace " target, , "Hide")
}

FocusMonitorWorkspace(target_monitor, target_workspace) {
    RunWait("komorebic.exe focus-monitor-workspace " target_monitor " " target_workspace, , "Hide")
}

FocusNamedWorkspace(workspace) {
    RunWait("komorebic.exe focus-named-workspace " workspace, , "Hide")
}

CycleMonitor(cycle_direction) {
    RunWait("komorebic.exe cycle-monitor " cycle_direction, , "Hide")
}

CycleWorkspace(cycle_direction) {
    RunWait("komorebic.exe cycle-workspace " cycle_direction, , "Hide")
}

MoveWorkspaceToMonitor(target) {
    RunWait("komorebic.exe move-workspace-to-monitor " target, , "Hide")
}

NewWorkspace() {
    RunWait("komorebic.exe new-workspace", , "Hide")
}

ResizeDelta(pixels) {
    RunWait("komorebic.exe resize-delta " pixels, , "Hide")
}

InvisibleBorders(left, top, right, bottom) {
    RunWait("komorebic.exe invisible-borders " left " " top " " right " " bottom, , "Hide")
}

GlobalWorkAreaOffset(left, top, right, bottom) {
    RunWait("komorebic.exe global-work-area-offset " left " " top " " right " " bottom, , "Hide")
}

MonitorWorkAreaOffset(monitor, left, top, right, bottom) {
    RunWait("komorebic.exe monitor-work-area-offset " monitor " " left " " top " " right " " bottom, , "Hide")
}

AdjustContainerPadding(sizing, adjustment) {
    RunWait("komorebic.exe adjust-container-padding " sizing " " adjustment, , "Hide")
}

AdjustWorkspacePadding(sizing, adjustment) {
    RunWait("komorebic.exe adjust-workspace-padding " sizing " " adjustment, , "Hide")
}

ChangeLayout(default_layout) {
    RunWait("komorebic.exe change-layout " default_layout, , "Hide")
}

CycleLayout(operation_direction) {
    RunWait("komorebic.exe cycle-layout " operation_direction, , "Hide")
}

LoadCustomLayout(path) {
    RunWait("komorebic.exe load-custom-layout " path, , "Hide")
}

FlipLayout(axis) {
    RunWait("komorebic.exe flip-layout " axis, , "Hide")
}

Promote() {
    RunWait("komorebic.exe promote", , "Hide")
}

PromoteFocus() {
    RunWait("komorebic.exe promote-focus", , "Hide")
}

Retile() {
    RunWait("komorebic.exe retile", , "Hide")
}

MonitorIndexPreference(index_preference, left, top, right, bottom) {
    RunWait("komorebic.exe monitor-index-preference " index_preference " " left " " top " " right " " bottom, , "Hide")
}

EnsureWorkspaces(monitor, workspace_count) {
    RunWait("komorebic.exe ensure-workspaces " monitor " " workspace_count, , "Hide")
}

EnsureNamedWorkspaces(monitor, names) {
    RunWait("komorebic.exe ensure-named-workspaces " monitor " " names, , "Hide")
}

ContainerPadding(monitor, workspace, size) {
    RunWait("komorebic.exe container-padding " monitor " " workspace " " size, , "Hide")
}

NamedWorkspaceContainerPadding(workspace, size) {
    RunWait("komorebic.exe named-workspace-container-padding " workspace " " size, , "Hide")
}

WorkspacePadding(monitor, workspace, size) {
    RunWait("komorebic.exe workspace-padding " monitor " " workspace " " size, , "Hide")
}

NamedWorkspacePadding(workspace, size) {
    RunWait("komorebic.exe named-workspace-padding " workspace " " size, , "Hide")
}

WorkspaceLayout(monitor, workspace, value) {
    RunWait("komorebic.exe workspace-layout " monitor " " workspace " " value, , "Hide")
}

NamedWorkspaceLayout(workspace, value) {
    RunWait("komorebic.exe named-workspace-layout " workspace " " value, , "Hide")
}

WorkspaceCustomLayout(monitor, workspace, path) {
    RunWait("komorebic.exe workspace-custom-layout " monitor " " workspace " " path, , "Hide")
}

NamedWorkspaceCustomLayout(workspace, path) {
    RunWait("komorebic.exe named-workspace-custom-layout " workspace " " path, , "Hide")
}

WorkspaceLayoutRule(monitor, workspace, at_container_count, layout) {
    RunWait("komorebic.exe workspace-layout-rule " monitor " " workspace " " at_container_count " " layout, , "Hide")
}

NamedWorkspaceLayoutRule(workspace, at_container_count, layout) {
    RunWait("komorebic.exe named-workspace-layout-rule " workspace " " at_container_count " " layout, , "Hide")
}

WorkspaceCustomLayoutRule(monitor, workspace, at_container_count, path) {
    RunWait("komorebic.exe workspace-custom-layout-rule " monitor " " workspace " " at_container_count " " path, , "Hide")
}

NamedWorkspaceCustomLayoutRule(workspace, at_container_count, path) {
    RunWait("komorebic.exe named-workspace-custom-layout-rule " workspace " " at_container_count " " path, , "Hide")
}

ClearWorkspaceLayoutRules(monitor, workspace) {
    RunWait("komorebic.exe clear-workspace-layout-rules " monitor " " workspace, , "Hide")
}

ClearNamedWorkspaceLayoutRules(workspace) {
    RunWait("komorebic.exe clear-named-workspace-layout-rules " workspace, , "Hide")
}

WorkspaceTiling(monitor, workspace, value) {
    RunWait("komorebic.exe workspace-tiling " monitor " " workspace " " value, , "Hide")
}

NamedWorkspaceTiling(workspace, value) {
    RunWait("komorebic.exe named-workspace-tiling " workspace " " value, , "Hide")
}

WorkspaceName(monitor, workspace, value) {
    RunWait("komorebic.exe workspace-name " monitor " " workspace " " value, , "Hide")
}

ToggleWindowContainerBehaviour() {
    RunWait("komorebic.exe toggle-window-container-behaviour", , "Hide")
}

TogglePause() {
    RunWait("komorebic.exe toggle-pause", , "Hide")
}

ToggleTiling() {
    RunWait("komorebic.exe toggle-tiling", , "Hide")
}

ToggleFloat() {
    RunWait("komorebic.exe toggle-float", , "Hide")
}

ToggleMonocle() {
    RunWait("komorebic.exe toggle-monocle", , "Hide")
}

ToggleMaximize() {
    RunWait("komorebic.exe toggle-maximize", , "Hide")
}

RestoreWindows() {
    RunWait("komorebic.exe restore-windows", , "Hide")
}

Manage() {
    RunWait("komorebic.exe manage", , "Hide")
}

Unmanage() {
    RunWait("komorebic.exe unmanage", , "Hide")
}

ReloadConfiguration() {
    RunWait("komorebic.exe reload-configuration", , "Hide")
}

WatchConfiguration(boolean_state) {
    RunWait("komorebic.exe watch-configuration " boolean_state, , "Hide")
}

CompleteConfiguration() {
    RunWait("komorebic.exe complete-configuration", , "Hide")
}

AltFocusHack(boolean_state) {
    RunWait("komorebic.exe alt-focus-hack " boolean_state, , "Hide")
}

WindowHidingBehaviour(hiding_behaviour) {
    RunWait("komorebic.exe window-hiding-behaviour " hiding_behaviour, , "Hide")
}

CrossMonitorMoveBehaviour(move_behaviour) {
    RunWait("komorebic.exe cross-monitor-move-behaviour " move_behaviour, , "Hide")
}

ToggleCrossMonitorMoveBehaviour() {
    RunWait("komorebic.exe toggle-cross-monitor-move-behaviour", , "Hide")
}

UnmanagedWindowOperationBehaviour(operation_behaviour) {
    RunWait("komorebic.exe unmanaged-window-operation-behaviour " operation_behaviour, , "Hide")
}

FloatRule(identifier, id) {
    RunWait("komorebic.exe float-rule " identifier " `"" id "`"", , "Hide")
}

ManageRule(identifier, id) {
    RunWait("komorebic.exe manage-rule " identifier " `"" id "`"", , "Hide")
}

WorkspaceRule(identifier, id, monitor, workspace) {
    RunWait("komorebic.exe workspace-rule " identifier " `"" id "`" " monitor " " workspace, , "Hide")
}

NamedWorkspaceRule(identifier, id, workspace) {
    RunWait("komorebic.exe named-workspace-rule " identifier " `"" id "`" " workspace, , "Hide")
}

IdentifyObjectNameChangeApplication(identifier, id) {
    RunWait("komorebic.exe identify-object-name-change-application " identifier " `"" id "`"", , "Hide")
}

IdentifyTrayApplication(identifier, id) {
    RunWait("komorebic.exe identify-tray-application " identifier " `"" id "`"", , "Hide")
}

IdentifyLayeredApplication(identifier, id) {
    RunWait("komorebic.exe identify-layered-application " identifier " `"" id "`"", , "Hide")
}

IdentifyBorderOverflowApplication(identifier, id) {
    RunWait("komorebic.exe identify-border-overflow-application " identifier " `"" id "`"", , "Hide")
}

ActiveWindowBorder(boolean_state) {
    RunWait("komorebic.exe active-window-border " boolean_state, , "Hide")
}

ActiveWindowBorderColour(r, g, b, window_kind) {
    RunWait("komorebic.exe active-window-border-colour " r " " g " " b " --window-kind " window_kind, , "Hide")
}

ActiveWindowBorderWidth(width) {
    RunWait("komorebic.exe active-window-border-width " width, , "Hide")
}

ActiveWindowBorderOffset(offset) {
    RunWait("komorebic.exe active-window-border-offset " offset, , "Hide")
}

FocusFollowsMouse(boolean_state, implementation) {
    RunWait("komorebic.exe focus-follows-mouse " boolean_state " --implementation " implementation, , "Hide")
}

ToggleFocusFollowsMouse(implementation) {
    RunWait("komorebic.exe toggle-focus-follows-mouse  --implementation " implementation, , "Hide")
}

MouseFollowsFocus(boolean_state) {
    RunWait("komorebic.exe mouse-follows-focus " boolean_state, , "Hide")
}

ToggleMouseFollowsFocus() {
    RunWait("komorebic.exe toggle-mouse-follows-focus", , "Hide")
}

AhkLibrary() {
    RunWait("komorebic.exe ahk-library", , "Hide")
}

AhkAppSpecificConfiguration(path, override_path) {
    RunWait("komorebic.exe ahk-app-specific-configuration " path " " override_path, , "Hide")
}

PwshAppSpecificConfiguration(path, override_path) {
    RunWait("komorebic.exe pwsh-app-specific-configuration " path " " override_path, , "Hide")
}

FormatAppSpecificConfiguration(path) {
    RunWait("komorebic.exe format-app-specific-configuration " path, , "Hide")
}

NotificationSchema() {
    RunWait("komorebic.exe notification-schema", , "Hide")
}

SocketSchema() {
    RunWait("komorebic.exe socket-schema", , "Hide")
}
; -------------------------------------------------------------------------------------------------


; Based on contents of komorebic.ahk
; https://gist.github.com/crosstyan/dafacc0778dabf693ce9236c57b201cd#file-komorebic-ahk

WorkspaceNumber := 9

ArrayFromZero(Length){
  temp := []
  Loop Length {
    temp.Push(A_Index-1)
  }
  return temp
}

; Set workspaces (start from 0)
; ArrayFromZero(9) => [0,1,2,3,4,5,6,7,8]
global numbers := ArrayFromZero(WorkspaceNumber)

init(){
  ;; focus-follows-mouse feels buggy
  FocusFollowsMouse("disable", "windows")

  ;; From
  ;; https://github.com/LGUG2Z/komorebi/blob/master/komorebi.sample.ahk
  ; Always float IntelliJ popups, matching on class
  FloatRule("class", "SunAwtDialog")
  ; Always float Control Panel, matching on title
  FloatRule("title", "Control Panel")
  ; Always float Task Manager, matching on class
  FloatRule("class", "TaskManagerWindow")
  ; Always float Wally, matching on executable name
  FloatRule("exe", "Wally.exe")
  FloatRule("exe", "wincompose.exe")
  ; Always float Calculator app, matching on window title
  FloatRule("title", "Calculator")
  ; Always float password managers
  FloatRule("exe", "1Password.exe")
  FloatRule("exe", "KeePass.exe")

  ;; For BandZip annoying updater
  FloatRule("exe", "Updater.exe")
  FloatRule("exe", "ScreenToGif.exe")
  ;; No tiling for Settings
  FloatRule("title", "Settings")

  IdentifyTrayApplication("exe", "Discord.exe")
  IdentifyTrayApplication("exe", "Telegram.exe")
  IdentifyTrayApplication("exe", "cloudmusic.exe")
  IdentifyTrayApplication("exe", "everything.exe")
  IdentifyTrayApplication("exe", "GoldenDict.exe")
  IdentifyTrayApplication("exe", "Clash for Windows.exe")

  ;; Fix for the infamous TIM
  IdentifyTrayApplication("exe", "TIM.exe")
  FloatRule("title", "TXMenuWindow")
  ManageRule("class", "TXGuiFoundation")

  ;; Infamous WeChat from Microsoft Store
  IdentifyTrayApplication("exe", "WeChatStore.exe")
  ManageRule("exe", "WeChatStore.exe")
  FloatRule("class", "SetMenuWnd")
  FloatRule("class", "CefWebViewWnd")

  ;; IDM can't not be handle properly
  ;; I don't like it tiling anyway. So I just comment it
  ; ManageRule("exe", "IDMan.exe")
  EnsureWorkspaces(0, workspacenumber)

  ; set the padding to all the workspaces
  for num in numbers{
    WorkspacePadding(0, num, 10)
    ContainerPadding(0, num, 8)
  }
}

;; run init function at start
init()


; Change the focused window, Alt + Vim direction keys
!h::{
  Focus("left")
}

!j::{
  Focus("down")
}

!k::{
  Focus("up")
}

!l::{
  Focus("right")
}

; Move the focused window in a given direction, Alt + Shift + Vim direction keys
!+h::{
  Move("left")
}

!+j::{
  Move("down")
}

!+k::{
  Move("up")
}

!+l::{
  Move("right")
}

;; Stack feels buggy here.
;; Personally I don't use it So I just comment it
; Stack the focused window in a given direction, ,Alt + direction keys
; !Left::{
;   Stack("left")
; }

; !Down::{
;   Stack("down")
; }

; !Up::{
;   Stack("up")
; }

; !Right::{
;   Stack("right")
; }

; !]::{
;   CycleStack("next")
; }

; ![::{
;   CycleStack("previous")
; }
; ; Unstack the focused window
; !d::{
;   Unstack()
; }

; Promote the focused window to the top of the tree, ,Alt + Shift + Enter
!+Enter::{
  Promote()
}

; Is there any way to parse the state of focused workspace?
; Switch to an equal-height
; max-width column layout on the main workspace, Alt + Shift + C
; ------------
; |          |
; ------------
; |          |
; ------------
!+r::{
  ChangeLayout("rows")
}

; Switch to an equal-width
; max-height column layout on the main workspace, Alt + Shift + C
; -------------
; |   |   |   |
; |   |   |   |
; -------------
!+c::{
  ChangeLayout("columns")
}

; Switch to the default bsp tiling layout on the main workspace, Alt + Shift + T
; famous binary space partition
; --------------
; |    |       |
; |    |--------
; |    |   |   |
; --------------

!+b::{
  ChangeLayout("bsp")
}

; Toggle the Monocle layout for the focused window, ,Alt + Shift + F
; Monocle is similar to maximizing, but it will pinned the focused
; window down
!+f::
{
  ToggleMonocle()
}

; Use Alt + F to toggle maximize window
; You should always use this shortcut to maximize
; or komorebi won't handle it like issue #12
; https://github.com/LGUG2Z/komorebi/issues/12
!f::{
  ToggleMaximize()
}

; Flip horizontally, ,Alt + Shift + X
!+x::{
  FlipLayout("horizontal")
}

; Flip vertically, ,Alt + Shift + Y
!+y::{
  FlipLayout("vertical")
}

; Float the focused window Alt + T
!t::{
  ToggleFloat()
}
; Toggle Tiling for workspace. Alt + Shift + T
!+t::{
  ToggleTiling()
}

; Pause responding to any window events or komorebic commands Alt + P
!p::{
  TogglePause()
}

; Switch to workspace
; Alt + 1~9
; Equal to bind key !1 to !9 to workspace 0 ~ 8
For num in numbers{
  Hotkey("!" . (num+1), (key) => FocusWorkspace(Integer(SubStr(key, 2))-1))
}

; Move window to workspace
; Alt + Shift + 1~9
; Equal to bind key !+1 to !+9 to workspace 0 ~ 8
For num in numbers{
  Hotkey("!+" . (num+1), (key) => MoveToWorkspace(Integer(SubStr(key, 3))-1))
}

; Force a retile if things get janky Ctrl + Shift + R
^+r::{
  Retile()
}

;; Native (AHK) Windows Key Rebinding

;; Close Focused Window Alt + X
!x::{
  WinClose("A")
}

;; Restart komorebi in a hard way Alt + Shift + Q
!+q::{
  RestoreWindows()
  RunWait("powershell " . "Stop-Process -Name 'komorebi'",,"Hide")
  Start("", "", "")
  ;; Delay 1000 milisecond
  Sleep(1000)
  init()
}

;; Get Window Info Alt + Shift + M
;; Helpful for debugging
!+m::{
  window_id := ""
  MouseGetPos(,,&window_id)
  window_title := WinGetTitle(window_id)
  window_class := WinGetClass(window_id)
  MsgBox(window_id "`n" window_class "`n" window_title)
}


;; this is a global state.
;; ? how to moddify it to a functional style?
global minimized_window := ""
;; Window should not be minimized
global FilterOutClass := ["WorkerW", "Shell_TrayWnd", "NotifyIconOverflowWindow"]
;; Alt + M
;; toggle minimize
;; minimize window will be saved until restore
;; useful when a window (especially vscode) get stuck
!m::{
  try {
    ;; If there is a window under the cursor then active it
    window_id := ""
    MouseGetPos(,,&window_id)
    WinActivate(window_id)
    ;; then process
    active_id := WinGetID("A")
    window_state := WinGetMinMax("A")
    if (minimized_window != ""){
      WinRestore(minimized_window)
      global minimized_window := ""
    } else {
      for filter in FilterOutClass{
        if(WinGetClass(active_id) == filter){
          ;; break out of the function
          return
        }
      }
      WinMinimize(active_id)
      global minimized_window := active_id
    }
  } catch as e {
    ;; If there's an error, it likely is cannot find focused window
    ;; this will focus a window under mouse cursor
    ;; I don't think this catch is meaningful
    window_id := ""
    MouseGetPos(,,&window_id)
    WinActivate(window_id)
  }
}
