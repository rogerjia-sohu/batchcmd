@echo off
reg add "hklm\software\microsoft\windows nt\currentversion\winlogon" /v AutoAdminLogon /t reg_dword /d 0 /f
reg add "hklm\software\microsoft\windows nt\currentversion\winlogon" /v DefaultUserName /t reg_sz /d "" /f
reg add "hklm\software\microsoft\windows nt\currentversion\winlogon" /v DefaultPassword /t reg_sz /d "" /f