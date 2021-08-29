@echo off
REM https://docs.microsoft.com/windows/security/identity-protection/credential-guard/credential-guard-manage#disable-windows-defender-credential-guard

REM Delete registry keys
reg delete HKLM\System\CurrentControlSet\Control\LSA /v LsaCfgFlags /f
reg delete HKLM\Software\Policies\Microsoft\Windows\DeviceGuard /v EnableVirtualizationBasedSecurity /f
reg delete HKLM\Software\Policies\Microsoft\Windows\DeviceGuard /v RequirePlatformSecurityFeatures /f

REM Delete EFI variables
mountvol X: /s
copy %WINDIR%\System32\SecConfig.efi X:\EFI\Microsoft\Boot\SecConfig.efi /Y
bcdedit /create {0cb3b571-2f2e-4343-a879-d86a476d7215} /d "DebugTool" /application osloader
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} path "\EFI\Microsoft\Boot\SecConfig.efi"
bcdedit /set {bootmgr} bootsequence {0cb3b571-2f2e-4343-a879-d86a476d7215}
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} loadoptions DISABLE-LSA-ISO,DISABLE-VBS
bcdedit /set {0cb3b571-2f2e-4343-a879-d86a476d7215} device partition=X:
mountvol X: /d

REM Restart computer
shutdown -t 60 -r
