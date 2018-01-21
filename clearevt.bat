;@echo off
;goto _main
Application
DFS Replication
HardwareEvents
Internet Explorer
Key Management Service
Media Center
Security
System
;:_main
;for /f "tokens=* eol=;" %%a in (%~fs0) do wmic nteventlog where logfilename="%%a" call cleareventlog /nointeractive > nul 2>&1