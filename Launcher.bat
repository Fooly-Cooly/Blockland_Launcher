@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:menuLOOP
echo.
echo.= Menu =================================================
echo.
for /f "tokens=1,2,* delims=_ " %%A in ('"findstr /b /c:":menu_" "%~f0""') do echo.  %%B  %%C
set choice=
echo.&set /p choice=Make a choice or hit ENTER to quit: ||GOTO:EOF
echo.&call:menu_%choice%
GOTO:menuLOOP

::-----------------------------------------------------------
:: menu functions follow below here
::-----------------------------------------------------------

:menu_1   Dedicated
blockland.exe ptlaaxobimwroe -dedicated
GOTO:menu_Q

:menu_2   Dedicated Lan
blockland.exe ptlaaxobimwroe -dedicatedLAN
GOTO:menu_Q

:menu_3   Start Game
blockland.exe ptlaaxobimwroe -mod editor
GOTO:menu_Q

:menu_

:menu_Q   Quit
::CLS
exit