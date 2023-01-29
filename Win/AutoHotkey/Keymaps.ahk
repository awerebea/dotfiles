#Requires AutoHotkey v2.0
Insert::End
LShift & RShift::Capslock

Capslock::Esc

; Use Capslock as Ctrl/Ecs
; SetCapsLockState("alwaysoff")
; Capslock::
; {
; Send("{LControl Down}")
; KeyWait("CapsLock")
; Send("{LControl Up}")
; if ( A_PriorKey = "CapsLock" )
; {
;     Send("{Esc}")
; }
; return
; }
