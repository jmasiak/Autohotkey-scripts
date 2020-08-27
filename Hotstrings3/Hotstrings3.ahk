﻿/*
Author:      Jakub Masiak, Maciej Słojewski, mslonik, http://mslonik.pl
Purpose:     Facilitate normal operation for company desktop.
Description: Hotkeys and hotstrings for my everyday professional activities and office cockpit.
License:     GNU GPL v.3
*/

#SingleInstance force 			; only one instance of this script may run at a time!
#NoEnv  						; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  							; Enable warnings to assist with detecting common errors.
#Persistent
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.
; ---------------------- HOTSTRINGS -----------------------------------
;~ The general hotstring rules:
;~ 1. Automatic changing small letters to capital letters: just press ending character (e.g. <Enter> or <Space> or <(>).
;~ 2. Automatic expansion of abbreviation: after small letters just press a </>.
;~ 2.1. If expansion contain double letters, use that letter and <2>. E.g. <c2ms> expands to <CCMS> and <c2ms/> expands to <Component Content Management System>.
;~ 3. Each hotstrings can be undone upon pressing of usual shotcuts: <Ctrl + z> or <Ctrl + BackSpace>.

IfNotExist, Categories2\PersonalHotstrings.csv
	FileAppend,, Categories2\PersonalHotstrings.csv, UTF-8
IfNotExist, Categories2\New.csv
	FileAppend,, Categories2\New.csv, UTF-8

Menu, Tray, Add, Edit Hotstring, GUIInit
; Menu, Tray, Add, About, About
Menu, Tray, Default, Edit Hotstring
Menu, Tray, Add
Menu, Tray, NoStandard
Menu, Tray, Standard

; ---------------------- SECTION OF GLOBAL VARIABLES ----------------------

CapCheck := ""
HotString := ""
PrevSec := A_Args[2]
PrevW := A_Args[3], PrevH := A_Args[4], PrevX := A_Args[5], PrevY := A_Args[6]
prevMon := A_Args[8]
init := 0
WindowTransparency	:= 0
MyHotstring 		:= ""
if !(A_Args[7])
	SelectedRow := 0
else
	SelectedRow := A_Args[7]
delay := 200
if !(prevMon)
	chMon := 0
else
	chMon := prevMon
delay := 200
flagMon := 0
if !(PrevSec)
	showGui := 1
else
	showGui := 2

; ---------------------------- INITIALIZATION -----------------------------

LoadFiles("voestalpineHotstrings.csv")
LoadFiles("PhysicsHotstrings.csv")
LoadFiles("Abbreviations.csv")
LoadFiles("PolishHotstrings.csv")
LoadFiles("GermanHotstrings.csv")
LoadFiles("TimeHotstrings.csv")
LoadFiles("FirstAndSecondNames.csv")
LoadFiles("EmojiHotstrings.csv")
LoadFiles("TechnicalHotstrings.csv")
LoadFiles("AutocorrectionHotstrings.csv")
LoadFiles("CapitalLetters.csv")
LoadFiles("PersonalHotstrings.csv")
LoadFiles("New.csv")
if(PrevSec)
	gosub GUIInit

; -------------------------- SECTION OF HOTKEYS ---------------------------

#if WinActive(, "Microsoft Word") or WinActive(, "Microsoft Outlook") or WinActive(, "Microsoft Excel") or WinActive("ahk_exe SciTe.exe") or WinActive("ahk_exe notepad.exe")
^z::			;~ Ctrl + z as in MS Word: Undo
$!BackSpace:: 	;~ Alt + Backspace as in MS Word: rolls back last Autocorrect action
	if (MyHotstring && (A_ThisHotkey != A_PriorHotkey))
		{
			
		;~ MsgBox, % "MyHotstring: " . MyHotstring . " A_ThisHotkey: " . A_ThisHotkey . " A_PriorHotkey: " . A_PriorHotkey
		ToolTip, Undo the last hotstring., % A_CaretX, % A_CaretY - 20
		Send, % "{BackSpace " . StrLen(MyHotstring) . "}" . SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", CaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
		SetTimer, TurnOffTooltip, -5000
		MyHotstring := ""
		}
	else
		{
		ToolTip,
		Send, !{BackSpace}
		}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

^c::
	Send, ^c
	IfWinExist, HS3
	{
		Sleep, %delay%
		ControlSetText, Edit2, %Clipboard%
	}
return
#if
; ------------------------- SECTION OF FUNCTIONS --------------------------

LoadFiles(nameoffile)
{
	Loop
	{
		FileReadLine, line, Categories\%nameoffile%, %A_Index%
		if ErrorLevel
			break
		line := StrReplace(line, "``n", "`n")
		line := StrReplace(line, "``r", "`r")
		StartHotstring(line)
	}
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

StartHotstring(txt)
{
	static Options, NewString, OnOff, SendFun, TextInsert
	txtsp := StrSplit(txt, "‖")
	Options := txtsp[1]
	NewString := txtsp[2]
	if (txtsp[3] == "A")
		SendFun := "NormalWay"
	else if (txtsp[3] == "C") 
		SendFun := "ViaClipboard"
	else if (txtsp[3] == "MC") 
		SendFun := "MenuText"
	else if (txtsp[3] == "MA") 
		SendFun := "MenuTextAHK"
	else if (txtsp[3] == "T")
		SendFun := "TimeAndDate"
	OnOff := txtsp[4]
	TextInsert := % txtsp[5]
	Hotstring(":" . Options . ":" . NewString, func(SendFun).bind(TextInsert), OnOff)
	return
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

NormalWay(ReplacementString)
{
	global MyHotstring
	Send, %ReplacementString%
	
	SetFormat, Integer, H
	InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt")
	Polish := Format("{:#x}", 0x415)
	InputLocaleID := InputLocaleID / 0xFFFF
	InputLocaleID := Format("{:#04x}", InputLocaleID)
	if(InputLocaleID = Polish)
	{
		Send, {LCtrl up}
	}
	
	MyHotstring := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", false, 1, 2) + 1)
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ViaClipboard(ReplacementString)
{
	global MyHotstring, oWord, delay
	ClipboardBackup := ClipboardAll
	Clipboard := ReplacementString
	ClipWait
	ifWinActive,, "Microsoft Word"
	{
		oWord := ComObjActive("Word.Application")
		oWord.Selection.Paste
		oWord := ""
	}
	else
	{
		Send, ^v
	}
	Sleep, %delay% ; this sleep is required surprisingly
	Clipboard := ClipboardBackup
	ClipboardBackup := ""
	MyHotstring := ReplacementString
	Hotstring("Reset")
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

MenuText(TextOptions)
{
	global MyHotstring, MenuListbox
	MyHotstring := ""
	Gui, Menu:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui, Menu:Margin, 0, 0
	Gui, Menu:Add, Listbox, x0 y0 h100 w250 vMenuListbox,
	for k, MenuItems in StrSplit(TextOptions,"¦") ;parse the data on the weird pipe character
	{
		GuiControl,, MenuListbox, % MenuItems
	}
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX, MouseY 
	Gui, Menu:Show, x%MouseX% y%MouseY%, Hotstring listbox
	if (MyHotstring == "")
	{
		HK := StrSplit(A_ThisHotkey, ":")
		ThisHotkey := SubStr(A_ThisHotkey, StrLen(HK[2])+3, StrLen(A_ThisHotkey)-StrLen(HK[2])-2)
		Send, % ThisHotkey
	}
	GuiControl, Choose, MenuListbox, 1
return
}
#IfWinActive Hotstring listbox
Enter::
Gui, Menu:Submit, Hide
ClipboardBack:=ClipboardAll ;backup clipboard
Clipboard:=MenuListbox ;Shove what was selected into the clipboard
Send, ^v ;paste the text
sleep, %delay% ;Remember to sleep before restoring clipboard or it will fail
MyHotstring := MenuListbox
Clipboard:=ClipboardBack
Gui, Menu:Destroy
Return
#If
#IfWinExist Hotstring listbox
	Esc::
	Gui, Menu:Destroy
	Send, % SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", CaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
	return
#If

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

MenuTextAHK(TextOptions){
	global MyHotstring, MenuListbox
	MyHotstring := ""
	Gui, MenuAHK:New, +LastFound +AlwaysOnTop -Caption +ToolWindow
	Gui, MenuAHK:Margin, 0, 0
	Gui, MenuAHK:Add, Listbox, x0 y0 h100 w250 vMenuListbox2,
	for k, MenuItems in StrSplit(TextOptions,"¦") ;parse the data on the weird pipe character
	{
		GuiControl,, MenuListbox2, % MenuItems
	}
	CoordMode, Mouse, Screen
	MouseGetPos, MouseX, MouseY 
	Gui, MenuAHK:Show, x%MouseX% y%MouseY%, HotstringAHK listbox
if (MyHotstring == "")
{
	HK := StrSplit(A_ThisHotkey, ":")
	ThisHotkey := SubStr(A_ThisHotkey, StrLen(HK[2])+3, StrLen(A_ThisHotkey)-StrLen(HK[2])-2)
	Send, % ThisHotkey
}
	GuiControl, Choose, MenuListbox2, 1
return
}
#IfWinActive HotstringAHK listbox
Enter::
Gui, MenuAHK:Submit, Hide
Send, % MenuListbox2
SetFormat, Integer, H
InputLocaleIDv:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt")
Polishv := Format("{:#x}", 0x415)
InputLocaleIDv := InputLocaleIDv / 0xFFFF
InputLocaleIDv := Format("{:#04x}", InputLocaleIDv)
;MsgBox, % InputLocaleID . " `" . Polish
	if(InputLocaleIDv = Polishv)
	{
		Send, {LCtrl up}
	}
	
	MyHotstring := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", false, 1, 2) + 1)
Gui, MenuAHK:Destroy
Return
#If
#IfWinExist HotstringAHK listbox
	Esc::
	Gui, MenuAHK:Destroy
	Send, % SubStr(A_PriorHotkey, InStr(A_PriorHotkey, ":", CaseSensitive := false, StartingPos := 1, Occurrence := 2) + 1)
	return
#If

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

TimeAndDate(ReplacementString)
{
    global MyHotstring
	ReplacementString := StrReplace(ReplacementString, "A_YYYY", A_YYYY)
	ReplacementString := StrReplace(ReplacementString, "A_MM", A_MM)
	ReplacementString := StrReplace(ReplacementString, "A_DD", A_DD)
	ReplacementString := StrReplace(ReplacementString, "A_Hour", A_Hour)
	ReplacementString := StrReplace(ReplacementString, "A_Min", A_Min)
    Send, %ReplacementString%
    SetFormat, Integer, H
	InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", 0, "UInt")
	Polish := Format("{:#x}", 0x415)
	InputLocaleID := InputLocaleID / 0xFFFF
	InputLocaleID := Format("{:#04x}", InputLocaleID)
	if(InputLocaleID = Polish)
	{
		Send, {LCtrl up}
	}
	
	MyHotstring := SubStr(A_ThisHotkey, InStr(A_ThisHotkey, ":", false, 1, 2) + 1)
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CheckOption(State,Button)
{
	If (State = "Yes")
	{
		State := 1
		GuiControl, , Button%Button%, 1
	}
	Else 
	{
		State := 0
		GuiControl, , Button%Button%, 0
	}
	Button := "Button" . Button

	CheckBoxColor(State,Button)  
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CheckBoxColor(State,Button)
{
	global chMon
	If (State = 1)
		Gui, HS3:Font,% "s" . 12*DPI%chMon% . " cRed Norm", Calibri
	Else 
		Gui, HS3:Font,% "s" . 12*DPI%chMon% . " cBlack Norm", Calibri
	GuiControl, HS3:Font, %Button%
}

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

F_ShowMonitorNumbers()
{
    global
    
    Loop, %N%
    {
        SysGet, MonitorBoundingCoordinates_, Monitor, %A_Index%
        Gui, %A_Index%:-SysMenu -Caption +Border +AlwaysOnTop
        Gui, %A_Index%:Color, Black ; WindowColor, ControlColor
        Gui, %A_Index%:Font, cWhite s26 bold, Calibri
        Gui, %A_Index%:Add, Text, x150 y150 w150 h150, % A_Index
        Gui, % A_Index . ":Show", % "x" .  MonitorBoundingCoordinates_Left + (Abs(MonitorBoundingCoordinates_Left - MonitorBoundingCoordinates_Right) / 2) - (300 / 2) . "y"
        . MonitorBoundingCoordinates_Top + (Abs(MonitorBoundingCoordinates_Top - MonitorBoundingCoordinates_Bottom) / 2) - (300 / 2) . "w300" . "h300"
    }
return
}

; --------------------------- SECTION OF LABELS ---------------------------

TurnOffTooltip:
	ToolTip ,
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

^#h::
GUIInit:
    SysGet, N, MonitorCount
    Loop, % N
    {
        SysGet, Mon%A_Index%, Monitor, %A_Index%
        W%A_Index% := Mon%A_Index%Right - Mon%A_Index%Left
        H%A_Index% := Mon%A_Index%Bottom - Mon%A_Index%Top
        DPI%A_Index% := round(W%A_Index%/1920*(96/A_ScreenDPI),2)
    }
    SysGet, PrimMon, MonitorPrimary
    if (chMon == 0)
        chMon := PrimMon
    Gui, HS3:New, % "+Resize MinSize"  . 860*DPI%chMon% . "x" . 490*DPI%chMon%+20
    Gui, HS3:Margin, 12.5*DPI%chMon%, 7.5*DPI%chMon%
    Gui, HS3:Font, % "s" . 12*DPI%chMon% . " bold cBlue", Calibri
    Gui, HS3:Add, Text, % "xm+" . 12*DPI%chMon%,Enter Hotstring:
    Gui, HS3:Font, % "s" . 12*DPI%chMon% . " norm cBlack"
    Gui, HS3:Add, Edit, % "w" . 199*DPI%chMon% . " h" . 25*DPI%chMon% . " xp+" . 212*DPI%chMon% . " yp vNewString",
    Gui, HS3:Font, % "s" . 12*DPI%chMon% . " bold cBlue"
    Gui, HS3:Add, GroupBox, % "section xm w" . 425*DPI%chMon% . " h" . 106*DPI%chMon%, Hotstring Options
    Gui, HS3:Font, % "s" . 12*DPI%chMon% . " norm cBlack"
    Gui, HS3:Add, CheckBox, % "gCapsCheck vImmediate xs+" . 12*DPI%chMon% . " ys+" . 25*DPI%chMon%, Immediate Execute (*)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vCaseSensitive xp+" . 225*DPI%chMon% . " yp+" . 0*DPI%chMon%, Case Sensitive (C)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vNoBackspace xp-" . 225*DPI%chMon% . " yp+" . 25*DPI%chMon%, No Backspace (B0)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vInsideWord xp+" . 225*DPI%chMon% . " yp+" . 0*DPI%chMon%, Inside Word (?)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vNoEndChar xp-" . 225*DPI%chMon% . " yp+" . 25*DPI%chMon%, No End Char (O)
    Gui, HS3:Add, CheckBox, % "gCapsCheck vDisHS xp+" . 225*DPI%chMon% . " yp+" . 0*DPI%chMon%, Disable
    Gui, HS3:Add, DropDownList, % "xm yp+" . 35*DPI%chMon% . " w" . 424*DPI%chMon% . " vByClip gByClip hwndddl", Send by Autohotkey|Send by Clipboard|Send by Menu (Clipboard)|Send by Menu (Autohotkey)|Send Time or Date
    PostMessage, 0x153, -1, 22*DPI%chMon%,, ahk_id %ddl%
    Gui, HS3:Add, Edit, % "yp+" . 37*DPI%chMon% . " w" . 424*DPI%chMon% . " h" . 25*DPI%chMon% . " vTextInsert xm"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%chMon% . " w" . 424*DPI%chMon% . " h" . 25*DPI%chMon% . " vTextInsert1 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%chMon% . " w" . 424*DPI%chMon% . " h" . 25*DPI%chMon% . " vTextInsert2 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%chMon% . " w" . 424*DPI%chMon% . " h" . 25*DPI%chMon% . " vTextInsert3 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%chMon% . " w" . 424*DPI%chMon% . " h" . 25*DPI%chMon% . " vTextInsert4 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%chMon% . " w" . 424*DPI%chMon% . " h" . 25*DPI%chMon% . " vTextInsert5 xm Disabled"
    Gui, HS3:Add, Edit, % "yp+" . 31*DPI%chMon% . " w" . 424*DPI%chMon% . " h" . 25*DPI%chMon% . " vTextInsert6 xm Disabled"
    Gui, HS3:Add, DropDownList, % "yp+" . 31*DPI%chMon% . " w" . 424*DPI%chMon% . " vSectionCombo gSectionChoose xm hwndddl" ,
    Loop,%A_ScriptDir%\Categories\*.csv
        GuiControl, , SectionCombo, %A_LoopFileName%
    PostMessage, 0x153, -1, 22*DPI%chMon%,, ahk_id %ddl%
    Gui, HS3:Font, bold

    Gui, HS3:Add, Button, % "xm yp+" . 37*DPI%chMon% . " w" . 135*DPI%chMon% . " gAddHotstring", Set Hotstring
	Gui, HS3:Add, Button, % "x+" . 10*DPI%chMon% . " yp w" . 135*DPI%chMon% . " gSaveHotstrings Disabled", Save Hotstring
    Gui, HS3:Add, Button, % "x+" . 10*DPI%chMon% . " yp w" . 135*DPI%chMon% . " vEdit gEdit Disabled", Edit Hotstring
    Gui, HS3:Font, % "s" . 12*DPI%chMon% . " cBlue Bold"
    Gui, HS3:Add, Text, ym, Hotstrings in section
    Gui, HS3:Font, % "s" . 12*DPI%chMon% . " cBlack Norm"
    Gui, HS3:Add, ListView, % "LV0x1 0x4 yp+" . 25*DPI%chMon% . " xp h" . 440*DPI%chMon% . " w" . 400*DPI%chMon% . " vHSList", Options|Hotstring|Fun|On/Off|Text
	Gui, HS3:Add, Edit, vStringCombo xs gViewString ReadOnly Hide,
    Menu, HSMenu, Add, &Monitor, CheckMon
    Menu, HSMenu, Add, &Delay, HSdelay
	Menu, HSMenu, Add, &Help, Help
	Menu, HSMenu, Add, &About, About
    Gui, HS3:Menu, HSMenu
	StartX := Mon%chMon%Left + (Abs(Mon%chMon%Right - Mon%chMon%Left)/2) - 430*DPI%chMon%
	StartY := Mon%chMon%Top + (Abs(Mon%chMon%Bottom - Mon%chMon%Top)/2) - (250*DPI%chMon%+31)
	StartW := 860*DPI%chMon%
	StartH := 490*DPI%chMon%+20
	if (showGui == 1)
	{
		Gui, HS3:Show, x%StartX% y%StartY% w%StartW% h%StartH%, HS3
	}
	else if (showGui == 2)
	{
		Gui, HS3:Show, W%PrevW% H%PrevH% X%PrevX% Y%PrevY%, HS3
	}
	else if (showGui == 3)
	{
		Gui, HS3:Show, x%StartX% y%StartY% w%StartW% h%StartH%, HS3
	}
	if (PrevSec != "")
	{
		GuiControl, Choose, SectionCombo, %PrevSec%
		gosub SectionChoose
		if(A_Args[7] > 0)
		{
			LV_Modify(A_Args[7], "Vis")
			LV_Modify(A_Args[7], "Select")
		}
	}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ViewString:
	GuiControlGet, StringCombo
	Select := StringCombo
	HotString := StrSplit(Select, """")
	HotString2 := StrSplit(HotString[2],":")
	NewStringvar := SubStr(HotString[2], StrLen( ":" . HotString2[2] . ":" ) + 1, StrLen(HotString[2])-StrLen(  ":" . HotString2[2] . ":" ))
	RText := StrSplit(Select, "bind(""")
	if InStr(RText[2], """On""")
	{
		OText := SubStr(RText[2], 1, StrLen(RText[2])-9)
	}
	else
	{    
		OText := SubStr(RText[2], 1, StrLen(RText[2])-10)
	}
	GuiControl, , NewString, % NewStringvar
	if (InStr(Select, """MenuText""") or InStr(Select, """MenuTextAHK"""))
	{
		TextInsert := OText
		OTextMenu := StrSplit(OText, "¦")
		GuiControl, , TextInsert, % OTextMenu[1]
		GuiControl, , TextInsert1, % OTextMenu[2]
		GuiControl, , TextInsert2, % OTextMenu[3]
		GuiControl, , TextInsert3, % OTextMenu[4]
		GuiControl, , TextInsert4, % OTextMenu[5]
		GuiControl, , TextInsert5, % OTextMenu[6]
		GuiControl, , TextInsert6, % OTextMenu[7]

	}
	else
	{
		GuiControl, , TextInsert, % OText
	}
	GoSub SetOptions 
	gosub byclip
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

AddHotstring:
	Gui, HS3:+OwnDialogs
	Gui, Submit, NoHide
	GuiControlGet, ByClip

	If (Trim(NewString) ="")
	{
		MsgBox Enter a Hotstring!
		return
	}
	if InStr(ByClip,"Send by Menu")
	{
		If ((Trim(TextInsert) ="") and (Trim(TextInsert1) ="") and (Trim(TextInsert2) ="") and (Trim(TextInsert3) ="") and (Trim(TextInsert4) ="") and (Trim(TextInsert5) ="") and (Trim(TextInsert6) =""))
		{
			MsgBox, 4,, Replacement text is blank. Do you want to proceed?
			IfMsgBox, No
			return
		}
		TextVar := ""
		If (Trim(TextInsert) !="")
			TextVar := % TextVar . "¦" . TextInsert
		If (Trim(TextInsert1) !="")
			TextVar := % TextVar . "¦" . TextInsert1
		If (Trim(TextInsert2) !="")
			TextVar := % TextVar . "¦" . TextInsert2
		If (Trim(TextInsert3) !="")
			TextVar := % TextVar . "¦" . TextInsert3
		If (Trim(TextInsert4) !="")
			TextVar := % TextVar . "¦" . TextInsert4
		If (Trim(TextInsert5) !="")
			TextVar := % TextVar . "¦" . TextInsert5
		If (Trim(TextInsert6) !="")
			TextVar := % TextVar . "¦" . TextInsert6
		TextInsert := SubStr(TextVar, 2, StrLen(TextVar)-1)
	}
	else{
		If (Trim(TextInsert) ="")
		{
			MsgBox, 4,, Replacement text is blank. Do you want to proceed?
			IfMsgBox, No
			Return
		}
	}
	if SectionCombo >= 1
		GuiControl, Enable, Save Hotstring

	OldOptions := ""

	GuiControlGet, StringCombo
	Select := StringCombo
	ControlGet, Items, Line,1, StringCombo

	Loop, Parse, Items, `n
	{  
		if InStr(A_LoopField, ":" . NewString . """", CaseSensitive)
		{
			HotString := StrSplit(A_LoopField, ":",,3)
			OldOptions := HotString[2]
			GuiControl,, StringCombo, ""
			break
		}
	}

; Added this conditional to prevent Hotstrings from a file losing the C1 option caused by
; cascading ternary operators when creating the options string. CapCheck set to 1 when 
; a Hotstring from a file contains the C1 option.

	If (CapCheck = 1) and ((OldOptions = "") or (InStr(OldOptions,"C1"))) and (Instr(Hotstring[2],"C1"))
		OldOptions := StrReplace(OldOptions,"C1") . "C"
	CapCheck := 0

	GoSub OptionString   ; Writes the Hotstring options string

; Add new/changed target item in DropDownList
	if (ByClip == "Send by Clipboard")
		SendFun := "ViaClipboard"
	else if (ByClip == "Send by Autohotkey")
		SendFun := "NormalWay"
	else if (ByClip == "Send by Menu (Clipboard)")
		SendFun := "MenuText"
	else if (ByClip == "Send by Menu (Autohotkey)")
		SendFun := "MenuTextAHK"
	else if (ByClip == "Send Time or Date")
		SendFun := "TimeAndDate"
	else 
	{
		MsgBox, Choose the method of sending the hotstring!
		return
	}

	if (DisHS == 1)
		OnOff := "Off"
	else
		OnOff := "On"
		GuiControl,, StringCombo , % "Hotstring("":" . Options . ":" . NewString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"

; Select target item in list
	gosub, ViewString

; If case sensitive (C) or inside a word (?) first deactivate Hotstring
	If (CaseSensitive or InsideWord or InStr(OldOptions,"C") 
		or InStr(OldOptions,"?")) 
		Hotstring(":" . OldOptions . ":" . NewString , func(SendFun).bind(TextInsert), "Off")

; Create Hotstring and activate
	Hotstring(":" . Options . ":" . NewString, func(SendFun).bind(TextInsert), OnOff)

	MsgBox, Hotstring has been set.
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Edit:
	Gui, HS3:+OwnDialogs
	If !(SelectedRow := LV_GetNext()) {
		MsgBox, 0, %A_ThisLabel%, Select a row in the list-view, please!
		Return
	}
	LV_GetText(Options, SelectedRow, 1)
	LV_GetText(NewString, SelectedRow, 2)
	LV_GetText(Fun, SelectedRow, 3)
	if (Fun = "A")
	{
		SendFun := "NormalWay"
	}
	else if(Fun = "C")
	{
		SendFun := "ViaClipboard"
	}
	else if (Fun = "MC")
	{
		SendFun := "MenuText"
	}
	else if (Fun = "MA")
	{
		SendFun := "MenuTextAHK"
	}
	else if (Fun := "T")
		SendFun := "TimeAndDate"
	LV_GetText(TextInsert, SelectedRow, 5)
	LV_GetText(OnOff, SelectedRow, 4)
	Hotstring(":"Options ":" NewString,func(SendFun).bind(TextInsert),OnOff)
	HotString := % "Hotstring("":" . Options . ":" . NewString . """, func(""" . SendFun . """).bind(""" . TextInsert . """), """ . OnOff . """)"
	GuiControl,, StringCombo ,  %HotString%
	gosub, ViewString
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SectionChoose:
	Gui, HS3:Submit, NoHide
	Gui, HS3:+OwnDialogs

	GuiControl, Enable, Edit
	
	if InStr(StringCombo, "Hotstring")
		GuiControl, Enable, Save Hotstring

	LV_Delete()
	FileRead, Text, Categories\%SectionCombo%

	SectionList := StrSplit(Text, "`r`n")
 
	Loop, % SectionList.MaxIndex()
		{
			str1 := StrSplit(SectionList[A_Index], "‖")
			LV_Add("", str1[1], str1[2], str1[3], str1[4], str1[5])
			LV_ModifyCol(2, "Sort")
		}
		LV_ModifyCol(5, "Auto")
	SendMessage, 4125, 4, 0, SysListView321
	wid := ErrorLevel
	if (wid < ColWid)
	{
		LV_ModifyCol(5, ColWid)
	}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

ByClip:
Gui, HS3:+OwnDialogs
GuiControlGet, ByClip
if InStr(ByClip, "Send by Menu")
{
	GuiControl, Enable, TextInsert1
	GuiControl, Enable, TextInsert2
	GuiControl, Enable, TextInsert3
	GuiControl, Enable, TextInsert4
	GuiControl, Enable, TextInsert5
	GuiControl, Enable, TextInsert6
}
else
{
	GuiControl, , TextInsert1,
	GuiControl, , TextInsert2,
	GuiControl, , TextInsert3,
	GuiControl, , TextInsert4,
	GuiControl, , TextInsert5,
	GuiControl, , TextInsert6,
	GuiControl, Disable, TextInsert1
	GuiControl, Disable, TextInsert2
	GuiControl, Disable, TextInsert3
	GuiControl, Disable, TextInsert4
	GuiControl, Disable, TextInsert5
	GuiControl, Disable, TextInsert6
}
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CapsCheck:
	If (Instr(HotString[2], "C1"))
		CapCheck := 1
	GuiControlGet, OutputVar1, Focus
	GuiControlGet, OutputVar2, , %OutputVar1%
	CheckBoxColor(OutputVar2,OutputVar1)
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SetOptions:
	OptionSet := Instr(Hotstring2[2],"*0") or InStr(Hotstring2[2],"*") = 0 ? CheckOption("No",2) :  CheckOption("Yes",2)
	OptionSet := ((Instr(Hotstring2[2],"C0")) or (Instr(Hotstring2[2],"C1")) or (Instr(Hotstring2[2],"C") = 0)) ? CheckOption("No",3) : CheckOption("Yes",3)
	OptionSet := Instr(Hotstring2[2],"B0") ? CheckOption("Yes",4) : CheckOption("No",4)
	OptionSet := Instr(Hotstring2[2],"?") ? CheckOption("Yes",5) : CheckOption("No",5)
	OptionSet := (Instr(Hotstring2[2],"O0") or (InStr(Hotstring2[2],"O") = 0)) ? CheckOption("No",6) : CheckOption("Yes",6)
	GuiControlGet, StringCombo
	Select := StringCombo
	if Select = 
		return
	OptionSet := (InStr(Select,"""On""")) ? CheckOption("No", 7) : CheckOption("Yes",7)
	if(InStr(Select,"NormalWay"))
		GuiControl, Choose, ByClip, Send by Autohotkey
	else if(InStr(Select, "ViaClipboard"))
		GuiControl, Choose, ByClip, Send by Clipboard
	else if(InStr(Select, """MenuText"""))
		GuiControl, Choose, ByClip, Send by Menu (Clipboard)
	else if(InStr(Select, """MenuTextAHK"""))
		GuiControl, Choose, ByClip, Send by Menu (Autohotkey)
	else if(InStr(Select, """TimeAndDate"""))
		GuiControl, Choose, ByCli, Send Time or Date
	CapCheck := 0
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

OptionString:
	Options := ""

	Options := CaseSensitive = 1 ? Options . "C"
		: (Instr(OldOptions,"C1")) ?  Options . "C0"
		: (Instr(OldOptions,"C0")) ?  Options
		: (Instr(OldOptions,"C")) ? Options . "C1" : Options

	Options := NoBackspace = 1 ?  Options . "B0" 
		: (NoBackspace = 0) and (Instr(OldOptions,"B0"))
		? Options . "B" : Options

	Options := (Immediate = 1) ?  Options . "*" 
		: (Instr(OldOptions,"*0")) ?  Options
		: (Instr(OldOptions,"*")) ? Options . "*0" : Options

	Options := InsideWord = 1 ?  Options . "?" : Options

	Options := (NoEndChar = 1) ?  Options . "O"
		: (Instr(OldOptions,"O0")) ?  Options
		: (Instr(OldOptions,"O")) ? Options . "O0" : Options

	Hotstring[2] := Options
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SaveHotstrings:
	Gui, HS3:+OwnDialogs
	SaveFile := SectionCombo
	if SectionCombo == ""
	{
		MsgBox, Choose section before saving!
		return
	}
	SaveFile := StrReplace(SaveFile, ".csv", "")
	GuiControlGet, Items,, StringCombo
	OnOff := ""
	SendFun := ""
	if InStr(Items, """On""")
		OnOff := "On"
	else if InStr(Items, """Off""")
		OnOff := "Off"
	if InStr(Items, "ViaClipboard")
		SendFun := "C"
	else if InStr(Items, "NormalWay")
		SendFun := "A"
	else if InStr(Items, """MenuText""")
		SendFun := "MC"
	else if InStr(Items, """MenuTextAHK""")
		SendFun := "MA"
	else if InStr(Items, """TimeAndDate""")
		SendFun := "T"
	HSSplit := StrSplit(Items, ":")
	Options := HSSplit[2]
	StrSp2 := StrSplit(HSSplit[3], """,")
	NewString := StrSp2[1]
	StrSp := StrSplit(Items, "bind(""")
	StrSp1 := StrSplit(StrSp[2], """),")
	TextInsert := StrSp1[1]
	OutputFile =% A_ScriptDir . "\Categories\temp.csv"
	InputFile = % A_ScriptDir . "\Categories\" . SaveFile . ".csv"
	LString := % "‖" . NewString . "‖"
	SaveFlag := 0

	Loop, Read, %InputFile%, %OutputFile%
	{
		if InStr(A_LoopReadLine, LString)
		{
			if !(SelectedRow)
			{
				MsgBox, 4,, The hostring "%NewString%" exists in a file %SaveFile%.csv. Do you want to proceed?
				IfMsgBox, No
					return
			}
			LV_Modify(A_Index, "", Options, NewString, SendFun, OnOff, TextInsert)
			SaveFlag := 1
		}
	}
	addvar := 0 ; potrzebne, bo źle pokazuje max index listy
	if (SaveFlag == 0)
	{
		LV_Add("", Options, NewString, SendFun, OnOff, TextInsert)
		addvar := 1
	}
	LV_ModifyCol(2, "Sort")
	name := SubStr(SectionCombo, 1, StrLen(SectionCombo)-4)
	name := % name . ".csv"
	FileDelete, Categories\%name%
	Loop, % SectionList.MaxIndex()-1 + addvar
	{
		LV_GetText(txt1, A_Index, 1)
		LV_GetText(txt2, A_Index, 2)
		LV_GetText(txt3, A_Index, 3)
		LV_GetText(txt4, A_Index, 4)
		LV_GetText(txt5, A_Index, 5)
		txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5 . "`r`n"
		FileAppend, %txt%, Categories\%name%, UTF-8
	}
	LV_GetText(txt1, SectionList.MaxIndex()+addvar, 1)
	LV_GetText(txt2, SectionList.MaxIndex()+addvar, 2)
	LV_GetText(txt3, SectionList.MaxIndex()+addvar, 3)
	LV_GetText(txt4, SectionList.MaxIndex()+addvar, 4)
	LV_GetText(txt5, SectionList.MaxIndex()+addvar, 5)
	txt := % txt1 . "‖" . txt2 . "‖" . txt3 . "‖" . txt4 . "‖" . txt5
	FileAppend, %txt%, Categories\%name%, UTF-8
	MsgBox Hotstring added to the %SaveFile%.csv file!
	WinGetPos, PrevX, PrevY , , ,HS3
	Run, AutoHotkey.exe Hotstrings3.ahk GUIInit %SectionCombo% %PrevW% %PrevH% %PrevX% %PrevY% %SelectedRow% %chMon%
Return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

SaveMon:
	flagMon := 0
	if (prevMon != chMon)
		showGui := 3
	gosub, GUIInit
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CheckMon:
    Gui, Mon:Submit, NoHide
    Gui, Mon:Destroy
    Gui, Mon:New, +AlwaysOnTop
	if (flagMon != 1)
	{
		prevMon := chMon
		flagMon := 1
	}
    SysGet, N, MonitorCount
    SysGet, PrimMon, MonitorPrimary
    if (chMon == 0)
        chMon := PrimMon
    MFS := 10*DPI%chMon%
    Gui, Mon:Margin, 12.5*DPI%chMon%, 7.5*DPI%chMon%
    Gui, Mon:Font, s%MFS%
    Gui, Mon:Add, Text, % " w" . 500*DPI%chMon%, Choose a monitor where GUI will be located:
    Loop, % N
    {
        if (A_Index == chMon)
        {
            Gui, Mon:Add, Radio,%  "xm+" . 50*DPI%chMon% . " h" . 25*DPI%chMon% . " gCheckMon AltSubmit vchMon Checked", % "Monitor #" . A_Index . (A_Index = PrimMon ? " (primary)" : "")
        }
        else
        {
            Gui, Mon:Add, Radio, % "xm+" . 50*DPI%chMon% . " h" . 25*DPI%chMon% . " gCheckMon AltSubmit", % "Monitor #" . A_Index . (A_Index = PrimMon ? " (primary)" : "")
        }
    }
    Gui, Mon:Add, Button, % "Default xm+" . 30*DPI%chMon% . " y+" . 15*DPI%chMon% . " h" . 30*DPI%chMon% . " gCheckMonitorNumbering", &Check Monitor Numbering
    Gui, Mon:Add, Button, % "x+" . 30*DPI%chMon% . " h" . 30*DPI%chMon% . " yp gSaveMon", &Save
    SysGet, MonitorBoundingCoordinates_, Monitor, % chMon
    Gui, Mon: Show
        , % "x" . MonitorBoundingCoordinates_Left + (Abs(MonitorBoundingCoordinates_Left - MonitorBoundingCoordinates_Right) / 2) - 200*DPI%chMon%
        . "y" . MonitorBoundingCoordinates_Top + (Abs(MonitorBoundingCoordinates_Top - MonitorBoundingCoordinates_Bottom) / 2) - 80*DPI%chMon%
        . "w" . 400*DPI%chMon% . "h" . 150*DPI%chMon%, Configure Monitor
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CheckMonitorNumbering:
    F_ShowMonitorNumbers()
    SetTimer, DestroyGuis, -3000
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DestroyGuis:
    Loop, %N%
    {
        Gui, %A_Index%:Destroy
    }
    Gui, Font ; restore the font to the system's default GUI typeface, size and colour.
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HSdelay:
    Gui, HSDel:New, -MinimizeBox -MaximizeBox
    Gui, HSDel:Margin, 12.5*DPI%chMon%, 7.5*DPI%chMon%
    Gui, HSDel:Font, % "s" . 12*DPI%chMon% . " norm cBlack"
    Gui, HSDel:Add, Slider,  vMySlider gmySlider Range100-1000 ToolTipBottom Buddy1999, %delay%
    Gui, HSDel:Add, Text,% "yp+" . 62.5*DPI%chMon% . " xm+" . 10*DPI%chMon% . " vDelayText" , Hotstring delay %delay% ms
    Gui, HSDel:Show, % "w" . 212.5*DPI%chMon% . " h" . 112.5*DPI%chMon% . " y" . Mon%chMon%Top + (Abs(Mon%chMon%Bottom - Mon%chMon%Top)/2) - 106.25*DPI%chMon%  
        . " x" . Mon%chMon%Left + (Abs(Mon%chMon%Right - Mon%chMon%Left)/2) - 56.25*DPI%chMon%, Set Delay
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

MySlider:
    delay := MySlider
    if (delay = 1000)
        GuiControl,,DelayText, Hotstring delay 1 s
    else
        GuiControl,,DelayText, Hotstring delay %delay% ms
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Help:
	Gui, MyHelp:Destroy
	Gui, MyHelp:Margin, 12.5*DPI%chMon%, 7.5*DPI%chMon%
	Gui, MyHelp:Font, % "Bold cBlue s" . 14*DPI%chMon%, Calibri
	Gui, MyHelp:Add, Text,xm, Hotstrings 3.0 - Help
	Gui, MyHelp:Font, % "cBlack s" . 12*DPI%chMon%
	Gui, MyHelp:Add, Text, xm, Hotstrings 3.0
	Gui, MyHelp:Font, Norm
	Gui, MyHelp:Add, Text, x+1 , % " is a tool that allows you to use and define new hotstrings (more information: " 
	Gui, MyHelp:Font, Underline cBlue
	Gui, MyHelp:Add, Text, x+1 gLink vTxtLink, https://www.autohotkey.com/docs/Hotstrings.htm
	Gui, MyHelp:Font, Norm cBlack
	Gui, MyHelp:Add, Text, x+1, ).
	SysGet, MonitorBoundingCoordinates_, Monitor, % chMon
    Gui, MyHelp: Show
        , % "x" . MonitorBoundingCoordinates_Left + (Abs(MonitorBoundingCoordinates_Left - MonitorBoundingCoordinates_Right) / 2) - 500*DPI%chMon%
        . "y" . MonitorBoundingCoordinates_Top + (Abs(MonitorBoundingCoordinates_Top - MonitorBoundingCoordinates_Bottom) / 2) - 250*DPI%chMon%
        . "w" . 1000*DPI%chMon% . "h" . 500*DPI%chMon%, Hotstrings.ahk Help
return


Link:
	Run, https://www.autohotkey.com/docs/Hotstrings.htm
return
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

About:
	Gui, MyAbout: Destroy
	Gui, MyAbout: Font, % "Bold s" . 10*DPI%chMon%
    Gui, MyAbout: Add, Text, , Hotstrings.ahk
    Gui, MyAbout: Font, % "Norm s" . 10*DPI%chMon%
    Gui, MyAbout: Add, Text, xm, Authors: Jakub Masiak, Maciej Słojewski
	Gui, MyAbout: Add, Text, xm, The Hotstrings.ahk script allows the use of hotstrings (
	Gui, MyAbout: Font, % "CBlue Underline s" . 10*DPI%chMon%
    Gui, MyAbout: Add, Text, x+1, https://www.autohotkey.com/docs/Hotstrings.htm
	Gui, MyAbout: Font, % "Norm cBlack s" . 10*DPI%chMon%
	Gui, MyAbout: Add, Text, x+1, ).
	Gui, MyAbout: Add, Text, xm, The "Edit Hostrings" option allows you to add new hostings and edit existing ones using a dedicated interface.
    Gui, MyAbout: Add, Button, % "Default Hidden w" . 100*DPI%chMon% . " gMyOK Center vOkButtonVariabl hwndOkButtonHandle", &OK
    GuiControlGet, MyGuiControlGetVariable, MyAbout: Pos, %OkButtonHandle%
	SysGet, MonitorBoundingCoordinates_, Monitor, % chMon
    Gui, MyAbout: Show
        , % "x" . MonitorBoundingCoordinates_Left + (Abs(MonitorBoundingCoordinates_Left - MonitorBoundingCoordinates_Right) / 2) - 335*DPI%chMon%
        . "y" . MonitorBoundingCoordinates_Top + (Abs(MonitorBoundingCoordinates_Top - MonitorBoundingCoordinates_Bottom) / 2) - 70*DPI%chMon%
        . "w" . 670*DPI%chMon% . "h" . 140*DPI%chMon%, Hotstrings.ahk About
    WinGetPos, , , MyAboutWindowWidth, , Hotstrings.ahk About
    NewButtonXPosition := ( MyAboutWindowWidth - 100*DPI%chMon%)/2
    GuiControl, Move, %OkButtonHandle%, % "x" NewButtonXPosition
    GuiControl, Show, %OkButtonHandle%
return  

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

MyOK:
MyAboutGuiClose: ; Launched when the window is closed by pressing its X button in the title bar
    Gui, MyAbout: Destroy
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HS3GuiSize:
	if (ErrorLevel == 1)
		return
	if (ErrorLevel == 0)
		showGui := 2
	IniW := StartW
	IniH := StartH
	LV_Width := 400*DPI%chMon%
	LV_Height := 440*DPI%chMon%
	LV_ModifyCol(1,70*DPI%chMon%)
	LV_ModifyCol(2,100*DPI%chMon%)
	LV_ModifyCol(3,40*DPI%chMon%)	
	LV_ModifyCol(4,60*DPI%chMon%)
	LV_ModifyCol(1,"Center")
	LV_ModifyCol(2,"Center")
	LV_ModifyCol(3,"Center")
	LV_ModifyCol(4,"Center")

	WinGetPos, PrevX, PrevY , , ,HS3
	PrevW := A_GuiWidth
	PrevH := A_GuiHeight

	NewHeight := LV_Height+(A_GuiHeight-IniH)
	NewWidth := LV_Width+(A_GuiWidth-IniW)
	ColWid := (NewWidth-270)
	LV_ModifyCol(5, "Auto")
	SendMessage, 4125, 4, 0, SysListView321
	wid := ErrorLevel
	if (wid < ColWid)
	{
		LV_ModifyCol(5, ColWid)
	}
	GuiControl, Move, HSList, W%NewWidth% H%NewHeight%
return

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

HS3GuiEscape:
HS3GuiClose:
	WinGetPos, PrevX, PrevY , , ,HS3
	Gui, HS3:Destroy
return