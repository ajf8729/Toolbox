<#
    .Synopsis
        This script will retrive autologon credentials from ConfigMgr Task Sequence variables and set them using Sysinternals Autologon.exe.
    .Example
        ./Enable-Autologon.ps1
    .Description
        This script will retrive autologon credentials from ConfigMgr Task Sequence variables and set them using Sysinternals Autologon.exe.
        It requires Autologon.exe within the same content location as this script.
    .Notes
        NAME: Enable-Autologon.ps1
        AUTHOR: Anthony Fontanez (ajf@anthonyfontanez.com)
        VERSION: 1.1
        LASTEDIT: 2021-01-27
        CHANGELOG:
            1.0 (2018-01-07) Initial script creation
            1.1 (2021-01-27) Update email address
#>

$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$AutologonUsername = $TSEnv.Value("AutologonUsername")
$AutologonPassword = $TSEnv.Value("AutologonPassword")
$AutologonDomain  = $TSEnv.Value("AutologonDomain")
$RegistryPath = "HKCU:\Software\Sysinternals\Autologon"
$Name = "EulaAccepted"
$Value = "1"
$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

New-Item -Path $RegistryPath -Force
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force
Start-Process -FilePath "$($ScriptDirectory)\Autologon.exe" -ArgumentList "$AutologonUsername $AutologonDomain $AutologonPassword"
