@echo off
sc config winmgmt start= disabled
net stop winmgmt /y
cd %WINDIR%\system32\wbem
for /f %%s in ('dir /b *.dll') do regsvr32 /s %%s
wmiprvse /regserver
winmgmt /regserver
net start winmgmt
for /f %%s in ('dir /b *.mof *.mfl') do mofcomp %%s