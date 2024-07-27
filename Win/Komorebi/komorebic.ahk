#SingleInstance Force

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
  Run "komorebic focus-follows-mouse disable", ,"Hide"

  ;; From
  ;; https://github.com/LGUG2Z/komorebi/blob/master/komorebi.sample.ahk
  ; Always float IntelliJ popups, matching on class
  Run "komorebic float-rule class SunAwtDialog", , "Hide"
  ; Always float Control Panel, matching on title
  Run "komorebic float-rule title 'Control Panel'", , "Hide"
  ; Always float Task Manager, matching on class
  Run "komorebic float-rule class TaskManagerWindow", , "Hide"
  ; Always float Wally, matching on executable name
  Run "komorebic float-rule exe Wally.exe", , "Hide"
  Run "komorebic float-rule exe wincompose.exe", , "Hide"
  ; Always float Calculator app, matching on window title
  Run "komorebic float-rule title Calculator", , "Hide"
  Run "komorebic float-rule exe 1Password.exe", , "Hide"

  ;; For BandZip annoying updater
  Run "komorebic float-rule exe Updater.exe", ,"Hide"
  Run "komorebic float-rule exe ScreenToGif.exe", ,"Hide"
  ;; No tiling for Settings
  Run "komorebic float-rule title Settings", ,"Hide"

  Run "komorebic identify-tray-application exe Discord.exe", ,"Hide"
  Run "komorebic identify-tray-application exe Telegram.exe", ,"Hide"
  Run "komorebic identify-tray-application exe cloudmusic.exe", ,"Hide"
  Run "komorebic identify-tray-application exe everything.exe", ,"Hide"
  Run "komorebic identify-tray-application exe GoldenDict.exe", ,"Hide"
  Run "komorebic identify-tray-application exe 'Clash for Windows.exe'", ,"Hide"

  ;; Fix for the infamous TIM
  Run("komorebic identify-tray-application exe TIM.exe",,"Hide")
  Run("komorebic float-rule title TXMenuWindow", ,"Hide")
  Run("komorebic manage-rule class TXGuiFoundation",,"Hide")
  
  ;; Infamous WeChat from Microsoft Store
  Run("komorebic identify-tray-application exe WeChatStore.exe",,"Hide")
  Run("komorebic manage-rule exe WeChatStore.exe", ,"Hide")
  Run("komorebic float-rule class SetMenuWnd",,"Hide")
  Run("komorebic float-rule class CefWebViewWnd",,"Hide")

  ;; IDM can't not be handle properly 
  ;; I don't like it tiling anyway. So I just comment it
  ;; Run("komorebic manage-rule exe IDMan.exe",,"Hide")
  run("komorebic ensure-workspaces 0 " . workspacenumber, ,"hide")

  ; set the padding to all the workspaces
  for num in numbers{
    runwait("komorebic workspace-padding 0 " . num . " 10",,"hide")
    RunWait("komorebic container-padding 0 " . num . " 8",,"Hide")
  }
}

;; run init function at start
init()


; Change the focused window, Alt + Vim direction keys
!h::{ 
  Run "komorebic focus left", , "Hide"
}

!j::{ 
  Run "komorebic focus down", , "Hide"
}

!k::{ 
  Run "komorebic focus up", , "Hide"
}

!l::{ 
  Run "komorebic focus right", , "Hide"
}

; Move the focused window in a given direction, Alt + Shift + Vim direction keys
!+h::{ 
  Run "komorebic move left", ,"Hide"
}

!+j::{ 
  Run "komorebic move down", ,"Hide"
}

!+k::{ 
  Run "komorebic move up", ,"Hide"
}

!+l::{ 
  Run "komorebic move right", ,"Hide"
}

;; Stack feels buggy here. 
;; Personally I don't use it So I just comment it
; Stack the focused window in a given direction, ,Alt + direction keys
; !Left::{ 
;   Run "komorebic stack left", ,"Hide"
; }

; !Down::{ 
;   Run "komorebic stack down", ,"Hide"
; }

; !Up::{ 
;   Run "komorebic stack up", ,"Hide"
; }

; !Right::{ 
;   Run "komorebic stack right", ,"Hide"
; }

; !]::{ 
;   Run "komorebic cycle-stack next", , "Hide"
; }

; ![::{ 
;   Run "komorebic cycle-stack previous", , "Hide"
; }
; ; Unstack the focused window
; !d::{ 
;   Run "komorebic unstack", ,"Hide"
; }

; Promote the focused window to the top of the tree, ,Alt + Shift + Enter
!+Enter::{ 
  Run "komorebic promote", ,"Hide"
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
  Run "komorebic change-layout rows", ,"Hide"
}

; Switch to an equal-width
; max-height column layout on the main workspace, Alt + Shift + C
; -------------
; |   |   |   |
; |   |   |   |
; -------------
!+c::{ 
  Run "komorebic change-layout columns", ,"Hide"
}

; Switch to the default bsp tiling layout on the main workspace, Alt + Shift + T
; famous binary space partition
; --------------
; |    |       |
; |    |--------
; |    |   |   |
; --------------

!+b::{ 
  Run "komorebic change-layout bsp", ,"Hide"
}

; Toggle the Monocle layout for the focused window, ,Alt + Shift + F
; Monocle is similar to maximizing, but it will pinned the focused
; window down
!+f::
{ 
  Run "komorebic toggle-monocle", ,"Hide"
}

; Use Alt + F to toggle maximize window
; You should always use this shortcut to maximize
; or komorebi won't handle it like issue #12
; https://github.com/LGUG2Z/komorebi/issues/12
!f::{
  RunWait("komorebic toggle-maximize",,"Hide")
}

; Flip horizontally, ,Alt + Shift + X
!+x::{ 
  Run "komorebic flip-layout horizontal", ,"Hide"
}

; Flip vertically, ,Alt + Shift + Y
!+y::{ 
  Run "komorebic flip-layout vertical", ,"Hide"
}

; Float the focused window Alt + T
!t::{ 
  Run "komorebic toggle-float", ,"Hide"
}
; Toggle Tiling for workspace. Alt + Shift + T
!+t::{ 
  Run "komorebic toggle-tiling", ,"Hide"
}

; Pause responding to any window events or komorebic commands Alt + P
!p::{ 
  Run "komorebic toggle-pause", ,"Hide"
}

; Switch to workspace
; Alt + 1~9
; Equal to bind key !1 to !9 to workspace 0 ~ 8
For num in numbers{
  Hotkey("!" . (num+1), (key) => Run("komorebic focus-workspace " . Integer(SubStr(key, 2))-1, ,"Hide"))
}

; Move window to workspace
; Alt + Shift + 1~9
; Equal to bind key !+1 to !+9 to workspace 0 ~ 8
For num in numbers{
  Hotkey("!+" . (num+1), (key) => Run("komorebic move-to-workspace " . Integer(SubStr(key, 3))-1, ,"Hide"))
}

; Force a retile if things get janky Ctrl + Shift + R
^+r::{ 
  Run "komorebic retile", ,"Hide"
}

;; Native (AHK) Windows Key Rebinding

;; Close Focused Window Alt + X
!x::{
  WinClose("A")
}

;; Restart komorebi in a hard way
!+q::{
  RunWait("komorebic restore-windows",,"Hide")
  RunWait("powershell " . "Stop-Process -Name 'komorebi'",,"Hide")
  RunWait("komorebic start") ;; intend to not hide it
  ;; Delay 1000 milisecond
  Sleep(1000)
  init()
}

;; Get Window Info
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