[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$Model,
    [Parameter(Mandatory=$True)]
    [string]$Version
)

$LogFileLocation = "\\ad.domain.tld\Shares\Logs\BIOS"
$Username = $env:USERNAME
$Timestamp = Get-Date -Format "yyyy-MM-dd_hh-mm-ss-tt"

Start-Transcript -Path "$LogFileLocation\$Make-$Model-$Version-$UserName-$timeStamp.log" | Out-Null

$BasePath = "\\ad.domain.tld\Shares\Apps\Dell\BIOS"
$FullPath = "$BasePath\$Model\$Version"
$IconPath = "$BasePath\icon.png"
$SiteCode = "SMS"
$AppName = "Dell $Model BIOS $Version"
$LocaliziedAppName = "$Model BIOS"
$FileName = Get-ChildItem -Path "$FullPath\*.exe" | Select-Object -ExpandProperty Name
$BareFileName = $FileName.TrimEnd(".exe")
$InstallScriptFileName = "SCCM_Install.ps1"
$InstallScript = "$FullPath\$InstallScriptFileName"

$InstallScriptContents = @"
`$BatteryStatus = Get-WmiObject Win32_Battery -Property BatteryStatus | Select-Object -ExpandProperty BatteryStatus
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

$InstallScriptContents | Out-File $InstallScript -Force

$Collection = "BIOS Update - $Model"
$DPGroup = "All DPs"
$DeployPurpose = "Available"

if ($BareFileName.Contains(".")) {
$DetectScript = @"
[System.Version]`$CurrentBIOSVersion = Get-WmiObject -Class Win32_BIOS | Select-Object -ExpandProperty SMBIOSBIOSVersion
[System.Version]`$NewBIOSVersion = "$Version"
if (`$CurrentBIOSVersion -ge `$NewBIOSVersion) {Write-Host "Installed"}
else {}
"@
}
else {
$BareVersion = $Version.TrimStart("A")
$DetectScript = @"
`$CurrentBIOSVersion =  (Get-WmiObject -Class Win32_BIOS | Select-Object -ExpandProperty SMBIOSBIOSVersion).TrimStart("A")
`$NewBIOSVersion = "$BareVersion"
if (`$CurrentBIOSVersion -ge `$NewBIOSVersion) {Write-Host "Installed"}
else {}
"@
}

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"

Set-Location "$($SiteCode):"

Write-Host ""
Write-Host "Creating BIOS application '$AppName'"
New-CMApplication -Name $AppName -LocalizedName $LocaliziedAppName -SoftwareVersion $Version -Publisher $Make -Owner $env:USERNAME -IconLocationFile $IconPath | Out-Null
Write-Host "Adding application deployment type '$AppName' to application '$AppName'"
Add-CMScriptDeploymentType -ApplicationName $AppName -DeploymentTypeName $AppName -InstallCommand $InstallScriptFileName -ScriptLanguage PowerShell -ScriptText $DetectScript -ContentLocation $FullPath -EstimatedRuntimeMins 5 -MaximumRuntimeMins 15 -LogonRequirementType WhetherOrNotUserLoggedOn -UserInteractionMode Hidden -InstallationBehaviorType InstallForSystem | Out-Null
Write-Host "Moving BIOS application '$AppName' to BIOS folder"
Get-CMApplication -Name $AppName | Move-CMObject -FolderPath "$($SiteCode):\Application\BIOS" | Out-Null
Write-Host "Distributing application '$AppName' content to DP group '$DPGroup'"
Start-CMContentDistribution -ApplicationName $AppName -DistributionPointGroupName $DPGroup | Out-Null
Write-Host "Deploying application '$AppName' to device collection '$Collection' as '$DeployPurpose'"
New-CMApplicationDeployment -Name $AppName -CollectionName $Collection -DeployAction Install -DeployPurpose $DeployPurpose | Out-Null
Write-Host "Setting application version and publisher"
Set-CMApplication -Name $AppName -SoftwareVersion $Version -Publisher $Make
Write-Host ""

Set-Location $env:SystemDrive

Stop-Transcript | Out-Null