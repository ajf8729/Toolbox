@echo off
RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 8
reg delete "HKCU\Software\Microsoft\Internet Explorer\Main\EnterpriseMode" /v CurrentVersion /f
gpupdate /force