[CmdletBinding()]
Param(
	[Parameter(Mandatory = $True)]
	[string]$SiteCode,
	[Parameter(Mandatory = $True)]
	[string]$Path
)

$Query = 'SELECT SourceClientResourceID,SourceName,RestoreClientResourceID,RestoreName,StorePath FROM SMS_StateMigration'
$Result = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Query $Query

$Export = @()

foreach ($Row in $Result) {
	$Query = 'SELECT * FROM SMS_StateMigration WHERE SourceClientResourceID=' + $Row.SourceClientResourceID + ' and RestoreClientResourceID=' + $Row.RestoreClientResourceID
	$StateMigration = Get-WmiObject -Namespace "Root\SMS\Site_$SiteCode" -Query $Query
	$Key = $StateMigration.GetEncryptDecryptKey()
	$Line = New-Object System.Object
	$Line | Add-Member -MemberType NoteProperty -Name 'SourceClientResourceID' -Value $Row.SourceClientResourceID
	$Line | Add-Member -MemberType NoteProperty -Name 'SourceName' -Value $Row.SourceName
	$Line | Add-Member -MemberType NoteProperty -Name 'RestoreClientResourceID' -Value $Row.RestoreclientResourceID
	$Line | Add-Member -MemberType NoteProperty -Name 'RestoreName' -Value $Row.RestoreName
	$Line | Add-Member -MemberType NoteProperty -Name 'StorePath' -Value $Row.StorePath
	$Line | Add-Member -MemberType NoteProperty -Name 'Key' -Value $Key.Key
	$Export += $Line
}

$DateTime = Get-Date -Format 'yyyy-MM-dd-HH-mm-ss'
$FileName = "$Path\USMT_Keys_$($DateTime).csv"

$Export | Export-Csv -NoTypeInformation -Path $FileName -Delimiter ';'
