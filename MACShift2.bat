@echo off
if defined MACShift2Ready if /i "%1"=="-chktransport" goto _chktransport
if defined MACShift2Ready if /i "%1"=="-calcsubkey" goto _calcsubkey
setlocal enabledelayedexpansion

set Me=%~dpfs0
set Me.Tempfile=%TEMP%\%~ns0.tmp
set Me.Date=%~t0
echo MACshift2 - MAC modifier for Windows Vista
echo 	-by Roger/TSRh %Me.Date%
set MACShift2Ready=1
echo %0 | find ":" >nul && (set ShellType=GUI) || (set ShellType=CONSOLE)

echo Searching...
set lastcmd="getmac /nh /fo csv | find /i "tcp">%Me.Tempfile%"
getmac /nh /fo csv | find /i "tcp">%Me.Tempfile%
if exist %Me.Tempfile% call %Me% -chktransport %Me.Tempfile% else goto _accessdenied
if %errorlevel% equ 1 goto _mediadisconnect
echo Active MAC address: %activemac%

set basekey=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\
set chkkey=NetCfgInstanceId
set mackey=NetworkAddress
set lastcmd="reg query %basekey% /v %chkkey% /s /t REG_SZ>%Me.Tempfile%"
reg query %basekey% /v %chkkey% /s /t REG_SZ>%Me.Tempfile%
if exist %Me.Tempfile% call %Me% -calcsubkey %Me.Tempfile% else goto _accessdenied
set lastcmd="call %Me% -calcsubkey %Me.Tempfile%"
if not defined subkey goto _nosubkey
echo.
echo MAC address is a 12-digit-string with each can only be 0~9 and a~f.
goto _prompt4mac
:_reentermac
echo.
echo [%newmac%] is NOT a valid MAC address.
echo Correct format is: [%activemac%].
:_prompt4mac
rem echo.
rem echo MAC address is a 12-digit-string with each can only be 0~9 or a~f!!!
set newmac=
set /p newmac=Enter new MAC address according to the above format:
if not defined newmac (
	echo Nothing entered. Quit.
	goto _end
)

if "%newmac%"=="0" goto _set_mac
set dummymac=%newmac%
set maclen=0
:_next_char
set dummymac=%dummymac:~1%
set /a maclen=%maclen%+1
if defined dummymac goto _next_char

set invalidmac=false
if %maclen% neq 12 set invalidmac=true
if %invalidmac%==true goto _reentermac 
echo %newmac%|findstr /i "^[0-9a-f]*$">nul || set invalidmac=true
if %invalidmac%==true goto _reentermac 

:_set_mac
set needchange=1
if /i "%activemac%"=="%newmac%" set needchange=
if not defined needchange goto _samemac
set regopdenied=1
set lastcmd="reg add %basekey%%subkey% /v %mackey% /t REG_SZ /d %newmac% /f>nul"
reg add %basekey%%subkey% /v %mackey% /t REG_SZ /d %newmac% /f>nul
if %errorlevel%==1 goto _accessdenied
set destmac=DEFAULT
if %newmac% neq 0 set destmac=%newmac%
echo MAC Address changed to [%destmac%].
echo You MUST restart Windows to take effect!
goto _cleanup

rem ------------------------------------------------------------
:_chktransport
if %~z2 equ 0 exit /b 1
for /f "delims=_ tokens=2" %%a in (%2) do set transportname=%%a
if defined transportname set transportname=%transportname:"=%
rem DUMMY LINE for holding UE highlighting"
for /f "delims=-, tokens=1-6" %%a in (%2) do set activemac=%%a%%b%%c%%d%%e%%f
if defined activemac set activemac=%activemac:"=%
rem DUMMY LINE for holding UE highlighting"
exit /b 0

:_calcsubkey
if %~z2 equ 0 exit /b 1
find /n "%transportname%" %2 | find "%transportname%">%22
for /f "delims=[] tokens=1" %%v in (%22) do set subkey=%%v
if defined subkey set /a subkey=%subkey%/3-1
if defined subkey (if %subkey% lss 10 (set subkey=000%subkey%) else set subkey=00%subkey%)
exit /b 0
rem ------------------------------------------------------------
:_samemac
echo.
echo INFORMATION:
echo The new MAC address that you specified is same with the current active one.
echo Command exit without modification.
goto _cleanup

:_invalidparam
echo ERROR! Invalid parameter.
goto _dump

:_accessdenied
set target=%Me.Tempfile%
if defined regopdenied set target=Registry
echo ERROR! Access denied while writing to [%target%].
goto _dump

:_mediadisconnect
echo ERROR! Media Disconnected!
goto _dump

:_nosubkey
echo ERROR! No subkey retrieved!
goto _dump

rem ------------------------------------------------------------
:_dump
if defined lastcmd echo Last command=[%lastcmd%]
goto _cleanup

:_cleanup
if exist %Me.Tempfile% del /f %Me.Tempfile%>nul
if exist %Me.Tempfile%2 del /f %Me.Tempfile%2>nul
goto _end
:_end
if %ShellType%==GUI pause
endlocal 
