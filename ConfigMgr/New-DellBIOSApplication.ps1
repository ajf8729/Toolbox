[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$ContentRootPath, #\\ad.ajf8729.com\Shares\SOURCE\DELL\BIOS
    [Parameter(Mandatory=$true)]
    [string]$SiteCode,
    [Parameter(Mandatory=$True)]
    [string]$Publisher,
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
$AppName = "Dell $Model BIOS $Version"
$LocaliziedAppName = "$Model BIOS"
$FileName = Get-ChildItem -Path "$FullPath\*.exe" | Select-Object -ExpandProperty Name
$BareFileName = $FileName.TrimEnd(".exe")
$InstallScriptFileName = "Install.ps1"
$InstallScript = "$FullPath\$InstallScriptFileName"

$InstallScriptContents = @"
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
"@

$InstallScriptContents | Out-File -FIlePath $InstallScript -Force

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

Write-Host ""

Write-Host "Creating BIOS application '$AppName'"
New-CMApplication -Name $AppName -LocalizedName $LocaliziedAppName -SoftwareVersion $Version -Publisher $Publisher -AddOwner $env:USERNAME -IconLocationFile $Icon

Write-Host "Adding application deployment type '$AppName' to application '$AppName'"
Add-CMScriptDeploymentType -ApplicationName $AppName -DeploymentTypeName $AppName -InstallCommand $InstallScriptFileName -ScriptLanguage PowerShell -ScriptText $DetectScript -ContentLocation $FullPath -EstimatedRuntimeMins 5 -MaximumRuntimeMins 15 -LogonRequirementType WhetherOrNotUserLoggedOn -UserInteractionMode Hidden -InstallationBehaviorType InstallForSystem

Write-Host "Moving BIOS application '$AppName' to BIOS folder"
Get-CMApplication -Name $AppName | Move-CMObject -FolderPath "$($SiteCode):\Application\BIOS"

Write-Host "Distributing application '$AppName' content to DP group '$DPGroupName'"
Start-CMContentDistribution -ApplicationName $AppName -DistributionPointGroupName $DPGroupName

Write-Host "Deploying application '$AppName' to device collection '$Collection' as '$DeployPurpose'"
New-CMApplicationDeployment -Name $AppName -CollectionName $Collection -DeployAction Install -DeployPurpose $DeployPurpose

Write-Host ""

Set-Location -Path $env:SystemDrive
