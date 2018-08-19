;================================================================================;
;	Blockland Launcher - A nice launcher for Blockland and its servers           ;
;	Copyright (C) 2018  Brian Baker https://github.com/Fooly-Cooly               ;
;	Licensed with GPL v3 https://www.gnu.org/licenses/gpl-3.0.txt                ;
;	Works with AHK ANSI, Unicode & 64-bit                                        ;
;================================================================================;

FileInstall, bg.png, -
FileInstall, start.png, -
FileInstall, lan.png, -
FileInstall, dedicated.png, -
FileInstall, quit.png, -

#Include ..\AHK_Libraries\ILButton.ahk
#Include ..\AHK_Libraries\ConsoleSend.ahk

Gui +LastFound
Gui, Color, FFFFFA
WinSet, TransColor, FFFFFA
Gui, +Border -Caption -MaximizeBox -MinimizeBox -SysMenu ;+ToolWindow
Gui_Add_Picture("bg.png",		 "x0   y0   BackgroundTrans")
Gui_Add_Picture("start.png",	 "x147 y30  BackgroundTrans AltSubmit gStart ", "hPic")
Gui_Add_Picture("dedicated.png", "x57  y118 BackgroundTrans AltSubmit gDedicated")
Gui_Add_Picture("lan.png",		 "x154 y206 BackgroundTrans AltSubmit gLan")
Gui_Add_Picture("quit.png",		 "x246 y292 BackgroundTrans AltSubmit gGuiClose")
Gui, Show, w608 h372 Center ;AutoSize
FileDelete, -
return

Start:
	Run, Blockland.exe ptlaaxobimwroe `
	ExitApp
Return

Lan:
	Run, Blockland.exe ptlaaxobimwroe -dedicatedLAN `
	Goto, launch
Return

Dedicated:
	Run, Blockland.exe ptlaaxobimwroe -dedicated `
	Goto, launch
Return

launch:
	; System Tray Settings:
	;#NoTrayIcon
	Menu, Tray, Icon, Blockland.exe, 1
	Menu, Tray, NoStandard
	Menu, Tray, Add, Restore, TrayRestore
	Menu, Tray, Add
	Menu, Tray, Add, Exit, GuiClose
	Menu, Tray, Default, Restore
	Menu, Tray, Click, 1

	; Console/Gui Styles:
	WS_POPUP		:= 0x80000000	; -Console
	WS_CAPTION		:= 0xC00000		; -Console
	WS_THICKFRAME	:= 0x40000		; -Console
	WS_EX_CLIENTEDGE:= 0x200		; -Console
	WS_CHILD		:= 0x40000000	; +Console
	WS_CLIPCHILDREN	:= 0x2000000	; +Gui

	; SetWindowPos Flags:
	SWP_NOACTIVATE 		:= 0x10
	SWP_SHOWWINDOW		:= 0x40
	SWP_NOSENDCHANGING	:= 0x400 ;Incorrectly adjusts the size of the client area, If Omitted.

	;Close old Gui, Create New Gui, get window ID and set minimize hook:
	Gui, Destroy
	Gui, +LastFound +%WS_CLIPCHILDREN%
	GuiWindow := WinExist()
	DllCall( "RegisterShellHookWindow", UInt, GuiWindow)
	MsgNum := DllCall("RegisterWindowMessage", Str, "SHELLHOOK")
	TrayMinimize(Event)
	{
		If (Event = 5)
		{
			Global GuiWindow
			WinGet, mState, MinMax, ahk_id %GuiWindow%
			If (mState = -1)
			{
				Critical
				Gui, Hide
				Menu, Tray, Icon
				Return
			}
		}
	}
	OnMessage( MsgNum, "TrayMinimize")

	WinWaitActive, ahk_exe Blockland.exe
	ConsoleWindow := WinExist()

	; Get console client area:
	VarSetCapacity(ConsoleRect, 16)
	DllCall("GetClientRect", "uint", ConsoleWindow, "uint", &ConsoleRect)
	ConsoleWidth := NumGet(ConsoleRect, 8,	"Int")
	ConsoleHeight:= NumGet(ConsoleRect, 12, "Int")

	; Apply necessary style changes:
	WinSet, Style,	% -(WS_POPUP|WS_CAPTION|WS_THICKFRAME)
	WinSet, Style,	% +WS_CHILD
	WinSet, ExStyle,% -WS_EX_CLIENTEDGE

	; Combine Gui and Console then move and resize Console:
	DllCall("SetParent", "uint", ConsoleWindow, "uint", GuiWindow)
	DllCall("SetWindowPos", "uint", ConsoleWindow, "uint", 0
		, "int", 10, "int", 10, "int", ConsoleWidth, "int", ConsoleHeight
		, "uint", SWP_NOACTIVATE|SWP_SHOWWINDOW|SWP_NOSENDCHANGING)

	; Adjust size variables for gui:
	EditWidth	 := % ConsoleWidth	- 85
	ConsoleWidth := % ConsoleWidth	+ 20
	ConsoleHeight:= % ConsoleHeight	+ 20

	; Add input below the console:
	WinSet, Disable,, ahk_id %ConsoleWindow%
	Gui, Add, DropDownList, w45 h20 x10 y%ConsoleHeight% vCmdMode, Say||Cmd
	Gui, Add, Edit, w%EditWidth% h20 x60 y%ConsoleHeight% vCmd
	Gui, Add, Button, y%ConsoleHeight% Default, OK
	Gui, Show, w%ConsoleWidth%, Blockland Server	; Show Gui with specific width since auto-sizing won't account for the console.

	; Close console host on script exit:
	OnExit, GuiClose
Return

TrayRestore:
	Critical
	Menu, Tray, NoIcon
	Gui, Show
Return

ButtonOK:
	GuiControlGet, Cmd
	GuiControlGet, CmdMode
	if(CmdMode == "Say")
		Cmd = messageAll("","%Cmd%");
	ConsoleSend(Cmd, "ahk_id " ConsoleWindow)
	ControlSend, , {Enter}, ahk_id %ConsoleWindow%
	GuiControl, , Cmd
Return

GuiClose:
	WinClose, ahk_id %ConsoleWindow%
ExitApp
