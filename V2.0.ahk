#Requires AutoHotkey v2.0
#NoTrayIcon
#SingleInstance Force

; ============================================
; Network Policy Controller v2.3
; Outbound filtering via Windows Firewall COM API
;
; Hotkeys:
;   Ctrl+F9   -> engage filter
;   Ctrl+F12  -> release filter
;   Ctrl+F8   -> quit script (cleans up & exits)
; ============================================

; --- Configuration ---
global RULE_PREFIX   := "SysNetSvc"
global TARGET_ADDR   := Dec("193.82.242.172")
global g_active      := false
global g_currentRule := ""

; --- Elevation ---
if !A_IsAdmin
{
    try
        Run('*RunAs "' A_ScriptFullPath '"')
    catch
        ExitApp
    ExitApp
}

; --- Exit cleanup ---
OnExit(OnExitClean, 1)

; --- Build initial badge ---
UpdateBadge()

; --- Hotkeys ---
^F9::  SetPolicy(true)
^F12:: SetPolicy(false)
^F8::  GracefulExit()

; ============================================
; Status badge — destroy & rebuild each time
; (SetFont color changes are unreliable on
;  existing controls in AHK v2)
; ============================================

global g_badge := ""

UpdateBadge()
{
    global g_badge, g_active

    ; Tear down existing GUI completely
    try
        if IsObject(g_badge)
            g_badge.Destroy()

    ; Rebuild with correct colors
    g_badge := Gui("-Caption +AlwaysOnTop +ToolWindow +LastFound +E0x20")
    g_badge.MarginX := 14
    g_badge.MarginY := 10

    if g_active
    {
        g_badge.BackColor := "0B2A0B"
        g_badge.SetFont("s10 bold cLime", "Segoe UI")
        g_badge.Add("Text", "vDot w18 h18 Center", Chr(9679))
        g_badge.Add("Text", "vLbl xp+24 yp+1 w120 Left", "RUNNING")
    }
    else
    {
        g_badge.BackColor := "1A1A1A"
        g_badge.SetFont("s10 bold cGray", "Segoe UI")
        g_badge.Add("Text", "vDot w18 h18 Center", Chr(9679))
        g_badge.SetFont("s10 bold cSilver", "Segoe UI")
        g_badge.Add("Text", "vLbl xp+24 yp+1 w120 Left", "STOPPED")
    }

    g_badge.Show("Hide w170 h38")
    PosBadge()
    g_badge.Show("NA")
}

PosBadge()
{
    global g_badge
    w := 170, h := 38
    x := 14
    y := 14
    g_badge.Show("x" x " y" y " NA")
}

Notify(text)
{
    ToolTip(text, 14, 60)
    SetTimer(() => ToolTip(), -1500)
}

; ============================================
; Core
; ============================================

SetPolicy(engage)
{
    global g_active, g_currentRule, RULE_PREFIX, TARGET_ADDR

    if engage
    {
        if g_active
        {
            Notify(">>  Already active")
            return
        }

        g_currentRule := RULE_PREFIX "_" RndHex(8)

        try
        {
            fw   := ComObject("HNetCfg.FwPolicy2")
            rule := ComObject("HNetCfg.FwRule")

            rule.Name             := g_currentRule
            rule.Description      := "System network service route"
            rule.Grouping         := "@FirewallAPI.dll,-28502"
            rule.Protocol         := 256
            rule.RemoteAddresses  := TARGET_ADDR
            rule.Direction        := 2
            rule.Action           := 0
            rule.Enabled          := true
            rule.EdgeTraversal    := false

            fw.Rules.Add(rule)
            PurgeStale(fw, g_currentRule)

            g_active := true
            UpdateBadge()
            Notify(">>  Filter engaged")
        }
        catch as e
        {
            g_active := false
            UpdateBadge()
            Notify("!!  Error: " e.Message)
        }
    }
    else
    {
        if !g_active
        {
            Notify(">>  Already inactive")
            return
        }

        try
        {
            fw := ComObject("HNetCfg.FwPolicy2")
            if g_currentRule != ""
                fw.Rules.Remove(g_currentRule)
            PurgeStale(fw, "")
            g_active := false
            g_currentRule := ""
            UpdateBadge()
            Notify(">>  Filter released")
        }
        catch as e
        {
            UpdateBadge()
            Notify("!!  Error: " e.Message)
        }
    }
}

PurgeStale(fw, keep)
{
    global RULE_PREFIX
    pending := []
    for r in fw.Rules
    {
        if InStr(r.Name, RULE_PREFIX "_") = 1 && r.Name != keep
            pending.Push(r.Name)
    }
    for n in pending
    {
        try fw.Rules.Remove(n)
    }
}

GracefulExit()
{
    global g_badge, g_active, g_currentRule

    try
    {
        if IsObject(g_badge)
        {
            g_badge.Destroy()
            g_badge := ""
        }
    }

    try
    {
        if g_active
        {
            fw := ComObject("HNetCfg.FwPolicy2")
            if g_currentRule != ""
                fw.Rules.Remove(g_currentRule)
            PurgeStale(fw, "")
        }
    }

    ExitApp(0)
}

OnExitClean(ExitReason, ExitCode)
{
    global g_badge, g_active, g_currentRule

    try
    {
        if IsObject(g_badge)
        {
            g_badge.Destroy()
            g_badge := ""
        }
    }

    try
    {
        if g_active
        {
            fw := ComObject("HNetCfg.FwPolicy2")
            if g_currentRule != ""
                fw.Rules.Remove(g_currentRule)
        }
    }
}

; ============================================
; Utilities
; ============================================

Dec(s)
{
    out := ""
    for i, oct in StrSplit(s, ".")
    {
        if i > 1
            out .= "."
        out .= (Integer(oct) - 1)
    }
    return out
}

RndHex(n)
{
    hex := "0123456789ABCDEF"
    out := ""
    Loop n
        out .= SubStr(hex, Random(1, 16), 1)
    return out
}
