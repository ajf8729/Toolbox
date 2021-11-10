[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$ContentRootPath,
    [Parameter(Mandatory=$true)]
    [string]$SiteCode,
    [Parameter(Mandatory=$True)]
    [string]$Model,
    [Parameter(Mandatory=$True)]
    [string]$Version,
    [Parameter(Mandatory=$true)]
    [string]$DPGroupName
)

if ( -not (Test-Path -Path "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1") ) {
    Write-Error -Message "ConfigurationManager module does not exist."
    exit
}

Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"

$FullPath = "$ContentRootPath\$Model\$Version"
$Icon = "$ContentRootPath\icon.png"
$ApplicationName = "Dell $Model BIOS $Version"
$LocaliziedApplicationName = "$Model BIOS"
$FileName = (Get-ChildItem -Path "$FullPath\*.exe").Name
$BareFileName = $FileName.TrimEnd(".exe")
$InstallScriptFileName = "Install.ps1"
$InstallScript = "$FullPath\$InstallScriptFileName"

@"
`$BatteryStatus = (Get-CimInstance -ClassName Win32_Battery).BatteryStatus
if (`$BatteryStatus -eq 2 -or `$BatteryStatus -eq `$null) {
`$FilePath = "`$PSScriptRoot\$Filename"
`$Arg1 = "/s"
`$Arg2 = "/l=`$env:SystemDrive\Logs\BIOS_$BareFileName.log"
Start-Process -FilePath `$FilePath -ArgumentList "`$Arg1 `$Arg2" -Wait
[System.Environment]::Exit(3010)
}
else {
[System.Environment]::Exit(1618)
}
"@ | Out-File -FilePath $InstallScript -Force

$Collection = "BIOS Update - $Model"
$DeployPurpose = "Available"

if ($BareFileName.Contains(".")) {
$DetectScript = @"
[System.Version]`$CurrentBIOSVersion = (Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion
[System.Version]`$NewBIOSVersion = "$Version"
if (`$CurrentBIOSVersion -ge `$NewBIOSVersion) {Write-Host "Installed"}
else {}
"@
}
else {
$BareVersion = $Version.TrimStart("A")
$DetectScript = @"
`$CurrentBIOSVersion =  ((Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion).TrimStart("A")
`$NewBIOSVersion = "$BareVersion"
if (`$CurrentBIOSVersion -ge `$NewBIOSVersion) {Write-Host "Installed"}
else {}
"@
}

Set-Location -Path "$($SiteCode):"

if (-not (Test-Path -Path ".\Application\BIOS")) {
    New-Item -Path "$($SiteCode):\Application\" -Name "BIOS" -ItemType Folder
}

New-CMApplication -Name $ApplicationName -LocalizedName $LocaliziedApplicationName -SoftwareVersion $Version -Publisher "Dell" -AddOwner $env:USERNAME -IconLocationFile $Icon
Add-CMScriptDeploymentType -ApplicationName $ApplicationName -DeploymentTypeName $ApplicationName -InstallCommand $InstallScriptFileName -ScriptLanguage PowerShell -ScriptText $DetectScript -ContentLocation $FullPath -EstimatedRuntimeMins 5 -MaximumRuntimeMins 15 -LogonRequirementType WhetherOrNotUserLoggedOn -UserInteractionMode Hidden -InstallationBehaviorType InstallForSystem
Get-CMApplication -Name $ApplicationName | Move-CMObject -FolderPath "$($SiteCode):\Application\BIOS"
Start-CMContentDistribution -ApplicationName $ApplicationName -DistributionPointGroupName $DPGroupName
New-CMApplicationDeployment -Name $ApplicationName -CollectionName $Collection -DeployAction Install -DeployPurpose $DeployPurpose

Set-Location -Path $env:SystemDrive
