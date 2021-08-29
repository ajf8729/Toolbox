[CmdletBinding()]
Param(
	[Parameter(Mandatory=$true)]
	[string]$SiteCode,
	[Parameter(Mandatory=$true)]
	[string]$Folder,
	[Parameter(Mandatory=$true)]
	[string]$DomainName,
	[Parameter(Mandatory=$true)]
	[string]$RootOUName
)

Import-Module -Name ActiveDirectory
Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\..\bin\ConfigurationManager.psd1"

$FolderPath = "${SiteCode}:\DeviceCollection\$($Folder)"
$DomainDN   = Get-ADDomain -Identity $DomainName | Select-Object -ExpandProperty DistinguishedName
$OUs        = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=$($RootOUName),$($DomainDN)" -Properties CanonicalName,DistinguishedName,Name,Description | Select-Object -Property CanonicalName,DistinguishedName,Name,Description | Sort-Object -Property CanonicalName

Set-Location -Path "$($SiteCode):"

$RefreshInterval = New-CMSchedule -RecurCount 1 -RecurInterval Days

foreach ($OU in $OUs) {
	$Name        = $OU.Name
	$Description = $OU.Description
	$DN          = $OU.DistinguishedName
	$CN          = $OU.CanonicalName
	$Comment     = "$Name | $Description | ""$DN"""
	
	New-CMDeviceCollection -LimitingCollectionName "All Systems" -Name $CN -RefreshSchedule $RefreshInterval -Comment $Comment | Out-Null
	Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CN -QueryExpression "select * from SMS_R_System where SMS_R_System.SystemOUName = '$CN'" -RuleName $CN
	Move-CMObject -FolderPath $FolderPath -ObjectId (Get-CMDeviceCollection -Name $CN).CollectionID
	
	Write-Host -Object "Device Collection ""$CN"" created"
}

Set-Location -Path $env:SystemDrive
