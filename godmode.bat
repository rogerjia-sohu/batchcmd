@echo off
setlocal
set gmid={ED7BA470-8E54-465E-825C-99712043E01C}
echo %0 | find ":" >nul && (set ShellType=GUI) || (set ShellType=CONSOLE)

if "%1"=="" goto _end
md "%~1.%gmid%"

:_end
if "%ShellType%"=="GUI" pause