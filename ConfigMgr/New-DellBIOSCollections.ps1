[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$SiteCode,
    [Parameter(Mandatory=$True)]
    [string]$IncludeCollection
)

# Note: This script assumes that New-ModelCollections.ps1 has been previously run to create the model-based collections used as limiting collections here.

if ( -not (Test-Path -Path "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1") ) {
    Write-Error -Message "ConfigurationManager module does not exist."
    exit
}

Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
Set-Location -Path "$($SiteCode):"

if (-not (Test-Path -Path ".\DeviceCollection\BIOS")) {
    New-Item -Path "$($SiteCode):\DeviceCollection\" -Name "BIOS" -ItemType Folder
}

$Models = @(
	"Latitude E5470"
)

foreach ($Model in $Models) {
    New-CMDeviceCollection -Name "BIOS Update - $Model" -LimitingCollectionName $Model -RefreshType None
    Get-CMDeviceCollection -Name "BIOS Update - $Model" | Move-CMObject -FolderPath "$($SiteCode):\DeviceCollection\BIOS"
    Add-CMDeviceCollectionIncludeMembershipRule -CollectionName "BIOS Update - $Model" -IncludeCollectionName $IncludeCollection
}

Set-Location -Path $env:SystemDrive
