@echo off
setlocal EnableDelayedExpansion

:_start
set A11=1
set A12=2
set A13=3
set A21=4
set A22=
set A23=6
set A31=7
set A32=8
set A33=9
set blank=A22

set M11=A12 A21
set M12=A11 A13 A22
set M13=A12 A23
set M21=A11 A22 A31
set M22=A12 A21 A23 A32
set M23=A13 A22 A33
set M31=A21 A32
set M32=A22 A31 A33
set M33=A23 A32

set sysStackAij=
set usrStackAij=
set gAutoResolvedFlg=0
set trainingMode=0
set mvCnt=0

set initMoveCnt=0
set lastMoveCnt=0
set movingNum=0
set lastMoveNum=0
set autoMoveCnt=0

call :_getRndByRange 8 14 levelStep

choice /c enh /m "Select difficulty: Easy / Normal / Hard "
goto _level%errorlevel%
:_level3
set /a initMoveCnt+=%levelStep%
:_level2
set /a initMoveCnt+=%levelStep%
:_level1
set /a initMoveCnt+=%levelStep%
set autoMoveCnt=%initMoveCnt%

:_preparePuzzle
if %initMoveCnt% equ 0 goto _showPuzzle
	 call :_getAij %blank% i j
	 call :_getMovingList %i% %j% mlist
	 call :_getStrbyte %mlist% bytecnt
	 set /a rangeMax=%bytecnt%-1
:_preparePuzzleRnd
	call :_getRndByRange 0 %rangeMax% rndnum
	call :_pickOneNum %mlist% %rndnum% movingNum
	if %lastMoveNum% equ %movingNum% (
		goto _preparePuzzleRnd
	) else (
		set lastMoveNum=%movingNum%
	)
	call :_getMovingAij %i% %j% %rndnum% Aij
	
	if "%sysStackAij%"=="" (
		set sysStackAij=%blank%
	) else (
		set sysStackAij=%blank% %sysStackAij%
	)
	call :_gDoMove %Aij% %blank% 0
	set /a initMoveCnt-=1
goto _preparePuzzle

:_showPuzzle
cls
call :_showMatrix A 3 3
call :_getAij %blank% i j
call :_promptForMoving %i% %j% Aij
if %gAutoResolvedFlg% equ 1 goto _autoResolvedOK
if "%Aij%"=="" goto _showPuzzle

if "%usrStackAij%"=="" (
	set usrStackAij=%blank%
) else (
	set usrStackAij=%blank% %usrStackAij%
)
call :_gDoMove %Aij% %blank%

:_autoResolvedOK
call :_checkMatrix
if %errorlevel% equ 0 (
	cls
	call :_showMatrix A 3 3
	if %gAutoResolvedFlg% equ 1 (
		echo Resolved by auto-resolving %autoMoveCnt% steps and user moving %mvCnt% steps.
	) else (
		echo Resolved by moving %mvCnt% steps.
	)
) else (
	goto _showPuzzle
)
pause
goto _start
goto :eof

:_showMatrix
if %trainingMode% equ 1 (
	if defined sysStackAij echo SYS moved: [%sysStackAij%]
	if defined usrStackAij echo YOU moved: [%usrStackAij%]
	echo.
)
for /l %%i in (1,1,%2) do (
	set thisRow=
	for /l %%j in (1,1,%3) do (
		if %%j equ 1 (
			set thisRow=!%1%%i%%j!
		) else (
			set thisRow=!thisRow!	!%1%%i%%j!
		)
	)
	echo !thisRow! && echo.
)
exit /b

:_getAij
set ij=%1
set %2=%ij:~1,1%
set %3=%ij:~-1%
exit /b

:_promptForMoving
call :_getMovingList %1 %2 mlist
call :_getStrbyte %mlist% mlistLen
echo Press a number to move, or T for training, A for auto-resolving
choice /c !mlist!ta
set n=!errorlevel!
if %n% leq %mlistLen% (
	for /f %%x in ("%n%") do (
		set %3=!m%%x!
	)
) else (
	set /a n-=%mlistLen%
	if !n! equ 1 (
		set /a trainingMode=1-!trainingMode!
	) else if !n! equ 2 (
		call :_autoResolve
		set gAutoResolvedFlg=1
	)
	set %3=
)
exit /b

:_getMovingList
for /f "tokens=1-4 delims= " %%a in ("!M%1%2!") do (
	set m1=%%a
	set m2=%%b
	set m3=%%c
	set m4=%%d
	set mlist=!%%a!!%%b!
	if not "%%c"=="" set mlist=!mlist!!%%c!
	if not "%%d"=="" set mlist=!mlist!!%%d!
	set %3=!mlist!
)
exit /b

:_gDoMove
set %2=!%1!
set %1=
set blank=%1
if "%3"=="" (
	set /a mvCnt+=1
)
exit /b

:_checkMatrix
if "%A11%"=="1" if "%A12%"=="2" if "%A13%"=="3" (
	if "%A21%"=="4" if "%A22%"=="" if "%A23%"=="6" (
		if "%A31%"=="7" if "%A32%"=="8" if "%A33%"=="9" (
			exit /b 0
		)
	)
)
exit /b 1

:_getRndByRange
set _min=%1
set _max=%2
set /a diff=%_max% - %_min%
set /a div=%diff% + 1
set /a n=%_min%+%random%%%div%
set %3=%n%
exit /b

:_pickOneNum
set numlist=%1
set offset=%2
goto _pickOneNum%offset%
:_pickOneNum0
set %3=%numlist:~0,1%
goto _end_pickOneNum
:_pickOneNum1
set %3=%numlist:~1,1%
goto _end_pickOneNum
:_pickOneNum2
set %3=%numlist:~2,1%
goto _end_pickOneNum
:_pickOneNum3
set %3=%numlist:~3,1%
goto _end_pickOneNum
:_end_pickOneNum
exit /b

:_getMovingAij
set coordList=!M%1%2!
set /a index=%3+1
for /f "tokens=%index%" %%a in ("%coordList%") do (
	set %4=%%a
)
exit /b

:_getStrbyte
set _tmpFile=%temp%\~t%random%.tmp
echo "%~1">%_tmpFile%
for %%f in (%_tmpFile%) do set /a %2=%%~zf-4
del /f /q %_tmpFile% >nul 2>&1
exit /b

:_autoResolve
call :_resolveOne Aij
if not "%Aij%"=="" goto _autoResolve
exit /b

:_resolveOne
set _curAij=
if defined usrStackAij (
	for /f "tokens=1" %%a in ("!usrStackAij!") do (
		set %1=%%a
		call :_getStrbyte "!usrStackAij!" usrStackByteLen
		if !usrStackByteLen! geq 4 (
			set /a newByteLen=!usrStackByteLen!-4
			for %%X in ("!newByteLen!") do (
				set usrStackAij=!usrStackAij:~-%%~X!
			)
		) else (
			set usrStackAij=!usrStackAij:%%a=!
		)
		call :_gDoMove %%a %blank% 0
		cls
		call :_showMatrix A 3 3
		timeout /t 2 >nul
		exit /b
	)
	set %1=
	exit /b
)
for /f "tokens=1" %%a in ("!sysStackAij!") do (
	set %1=%%a
	call :_getStrbyte "!sysStackAij!" sysStackByteLen
	if !sysStackByteLen! geq 4 (
		set /a newByteLen=!sysStackByteLen!-4
		for %%X in ("!newByteLen!") do (
			set sysStackAij=!sysStackAij:~-%%~X!
		)
	) else (
		set sysStackAij=!sysStackAij:%%a=!
	)
	call :_gDoMove %%a %blank% 0
	cls
	call :_showMatrix A 3 3
	timeout /t 2 >nul
	exit /b
)
set %1=
exit /b