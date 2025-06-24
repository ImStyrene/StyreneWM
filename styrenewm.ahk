#SingleInstance Force
defaultPadding := 10
defaultAnimationSpeed := 10
defaultSnapResizeAmount := 20
defaultWindowTransparency := 255
defaultSnapThreshold := 15
defaultMaximizedPadding := 5
defaultAutoMaximizeOnOpen := 0

; Config file path
configFile := A_ScriptDir "\styrene.ini"

  ; If config file exists, read values, else create default config
if FileExist(configFile)
{
  IniRead, padding, %configFile%, Settings, Padding, %padding%
  IniRead, animationSpeed, %configFile%, Settings, AnimationSpeed, %animationSpeed%
  IniRead, resizeAmount, %configFile%, Settings, SnapResizeAmount, %resizeAmount%
  IniRead, padding, %configFile%, Settings, Padding, 10
  IniRead, animationSpeed, %configFile%, Settings, AnimationSpeed, 10
  IniRead, snapResizeAmount, %configFile%, Settings, SnapResizeAmount, 20
  IniRead, windowTransparency, %configFile%, Settings, WindowTransparency, 255
  IniRead, snapThreshold, %configFile%, Settings, SnapThreshold, 15
  IniRead, maximizedPadding, %configFile%, Settings, MaximizedPadding, 5
  IniRead, autoMaximizeOnOpen, %configFile%, Settings, AutoMaximizeOnOpen, 0
}
else
{
    FileAppend,
    (
    [Settings]
    Padding=5
    AnimationSpeed=10
    SnapResizeAmount=20
    ), %configFile%
}

; ----------------------
; Helper: Move/Resize Window
; ----------------------
MoveWindow(x := "", y := "", w := "", h := "") {
    global padding
    WinGetPos, winX, winY, winW, winH, A
    
    if (x = "")
        x := winX
    if (y = "")
        y := winY
    if (w = "")
        w := winW
    if (h = "")
        h := winH

    WinMove, A, , x + padding, y + padding, w - (padding * 2), h - (padding * 2)
}

ResizeWindow(dw := 0, dh := 0) {
    WinGetPos, x, y, w, h, A
    w += dw
    h += dh
    WinMove, A, , x, y, w, h
}

; ----------------------
; Screen Dimensions
; ----------------------
screenWidth := A_ScreenWidth
screenHeight := A_ScreenHeight

; ----------------------
; Arrow Snap (Win + Arrows)
; ----------------------
#Left::MoveWindow(0, 0, screenWidth // 2, screenHeight)
#Right::MoveWindow(screenWidth // 2, 0, screenWidth // 2, screenHeight)
#Up::MoveWindow(0, 0, screenWidth, screenHeight // 2)
#Down::MoveWindow(0, screenHeight // 2, screenWidth, screenHeight // 2)

; ----------------------
; Resize with Ctrl (Win + Ctrl + Arrows)
; ----------------------
#^Left::ResizeWindow(-20, 0)
#^Right::ResizeWindow(20, 0)
#^Up::ResizeWindow(0, -20)
#^Down::ResizeWindow(0, 20)

; ----------------------
; Maximize / Restore
; ----------------------
#m::
    WinGet, winState, MinMax, A
    if (winState = 1)
        WinRestore, A
    else
        WinMaximize, A
return

; ----------------------
; Window History
; ----------------------
#IfWinActive
#z::
    WinGet, currentWin, ID, A
    if (LastWindow && LastWindow != currentWin)
        WinActivate, ahk_id %LastWindow%
    LastWindow := currentWin
return
#IfWinActive

; ----------------------
; Window Tagging
; ----------------------
#!0::TagWindow(0)
#!1::TagWindow(1)
#!2::TagWindow(2)
#!3::TagWindow(3)
#!4::TagWindow(4)
#!5::TagWindow(5)
#!6::TagWindow(6)
#!7::TagWindow(7)
#!8::TagWindow(8)
#!9::TagWindow(9)

#^0::ActivateTaggedWindow(0)
#^1::ActivateTaggedWindow(1)
#^2::ActivateTaggedWindow(2)
#^3::ActivateTaggedWindow(3)
#^4::ActivateTaggedWindow(4)
#^5::ActivateTaggedWindow(5)
#^6::ActivateTaggedWindow(6)
#^7::ActivateTaggedWindow(7)
#^8::ActivateTaggedWindow(8)
#^9::ActivateTaggedWindow(9)

TagWindow(index) {
    global WindowTags
    WinGet, id, ID, A

    if (WindowTags.HasKey(index)) {
        hwnd := WindowTags[index]
        WinGetTitle, oldTitle, ahk_id %hwnd%
        MsgBox, 4, Slot %index% Occupied, Already tagged: "%oldTitle%"`nReplace it?
        IfMsgBox, No
            return
    }

    WindowTags[index] := id
    WinGetTitle, title, ahk_id %id%
    ToolTip, Tagged [%index%]: %title%
    SetTimer, RemoveToolTip, -1000
}

ActivateTaggedWindow(index) {
    global WindowTags

    if (!WindowTags.HasKey(index)) {
        TrayTip, Slot Empty, No window is tagged to [%index%], 1000
        return
    }

    hwnd := WindowTags[index]

    if !WinExist("ahk_id " . hwnd) {
        TrayTip, Invalid HWND, Tagged window no longer exists. Clearing slot., 1000
        WindowTags.Delete(index)
        return
    }

    WinGetTitle, title, ahk_id %hwnd%
    TrayTip, Switching, [%index%] → "%title%", 1000
    WinActivate, ahk_id %hwnd%
}

RemoveToolTip:
ToolTip
return

; ----------------------
; Window Pinning
; ----------------------
#p::
    WinGet, style, ExStyle, A
    if (style & 0x8)
        WinSet, AlwaysOnTop, Off, A
    else
        WinSet, AlwaysOnTop, On, A
return

; ----------------------
; Multi-Monitor Support (future use)
; ----------------------
GetActiveMonitorWorkArea(ByRef x, ByRef y, ByRef w, ByRef h) {
    hwnd := WinExist("A")
    SysGet, monitor, MonitorWorkArea, %hwnd%
    x := monitorLeft
    y := monitorTop
    w := monitorRight - monitorLeft
    h := monitorBottom - monitorTop
}

; ----------------------
; Close Active Window (with confirmation)
; ----------------------
#q::
    WinGetTitle, activeTitle, A
    MsgBox, 4,, Are you sure you want to close this window?`n%activeTitle%
    IfMsgBox, Yes
        WinClose, A
return

; ----------------------
; Reload Script
; ----------------------
#!s::Reload
