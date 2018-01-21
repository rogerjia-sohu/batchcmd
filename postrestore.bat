@echo off
setlocal
set L_DEBUG=0
set Me=%~nxs0
set Me.StdOut=NUL
if "%L_DEBUG%"=="1" set Me.StdOut=CON
set Me.Path=%~dps0
set Me.Tempfile=%Temp%\~LR%random%.tmp
echo %0 | find ":" >nul && (set ShellType=GUI) || (set ShellType=CONSOLE)
chcp | find "936" >%Me.StdOut% && set langid=936 || set langid=437

:_set_stage1_msg
goto _set_stage1_msg_%langid%
:_set_stage1_msg_936
set msg1=计算机还原已经完成，正在进行最后配置，请稍候……
goto _show_set_stage1_msg
:_set_stage1_msg_437
set msg1=Windows Complete PC Restore is about to finish, please wait a while for the final operation...
goto _show_set_stage1_msg
:_show_set_stage1_msg
shutdown /r /t 600 /c "%msg1%"

echo 禁用自动登录……
call %Me.Path%disautologon.bat
echo 删除装载点……
call %Me.Path%umountrec.bat
fsutil dirty set %systemdrive%
shutdown /a

:_set_stage2_msg
goto _set_stage2_msg_%langid%
:_set_stage2_msg_936
set msg1=计算机配置完成，系统将在10秒后重新启动。
goto _show_set_stage2_msg
:_set_stage2_msg_437
set msg1=Finalization is over, system will restart after 10 seconds.
goto _show_set_stage2_msg
:_show_set_stage2_msg
shutdown /r /t 10 /c "%msg1%"

goto _end

:_end
rem if "%ShellType%"=="GUI" pause
if exist %Me.Tempfile% del /f /q %Me.Tempfile%
endlocal