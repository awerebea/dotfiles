#Requires AutoHotkey v2.0

SwitchToApp(appTitle, appPath)
{
  appTitle := "ahk_exe " . appTitle
  windowHandleId := WinExist(appTitle)
  windowExistsAlready := windowHandleId > 0
  ; If the Windows Terminal is already open, determine if we should put it in focus or minimize it.
  if (windowExistsAlready = true)
  {
    activeWindowHandleId := WinExist("A")
    windowIsAlreadyActive := activeWindowHandleId == windowHandleId
    if (windowIsAlreadyActive)
    {
      ; Minimize the window.
      WinMinimize("`"ahk_id " windowHandleId "`"")
    }
    else
    {
      ; Put the window in focus.
      WinActivate("`"ahk_id " windowHandleId "`"")
      WinShow("`"ahk_id " windowHandleId "`"")
    }
  }
  ; Else it's not already open, so launch it.
  else
  {
    Run(appPath)
  }
}

; Hotkeys:
; Windows Terminal
<#x::SwitchToApp("WindowsTerminal.exe", "wt")
; KeePass
<#k::SwitchToApp("KeePass.exe", "D:\Distrib\_Personal Software\KeePass\KeePass.exe")
; Chrome
<#c::SwitchToApp("chrome.exe", "C:\Program Files\Google\Chrome\Application\chrome.exe")
; Slack
<#s::SwitchToApp("slack.exe", "C:\Users\Andrei\AppData\Local\slack\slack.exe")
; Notepad++
<#n::SwitchToApp("notepad++.exe", "C:\Program Files\Notepad++\notepad++.exe")
; Telegram
<#g::SwitchToApp("Telegram.exe", "D:\Distrib\_Personal Software\Telegram\Telegram.exe")
; Firefox
<#f::SwitchToApp("firefox.exe", "C:\Program Files\Mozilla Firefox\firefox.exe")
; Qalculate
<#q::SwitchToApp("qalculate-gtk.exe", "D:\Distrib\_Personal Software\qalculate\qalculate-gtk.exe")
