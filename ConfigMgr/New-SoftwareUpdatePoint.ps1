[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$SiteCode,
    [Parameter(Mandatory=$True)]
    [string]$SiteSystemServerName
)

Import-Module -FullyQualifiedName "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"

Set-Location -Path "$($SiteCode):"

New-CMSiteSystemServer -SiteCode $SiteCode -SiteSystemServerName $SiteSystemServerName -Verbose

$Parameters = @{
    WsusIisPort          = '8530';
    WsusIisSslPort       = '8531';
    SiteSystemServerName = $SiteSystemServerName;
    SiteCode             = $SiteCode;
    ClientConnectionType = 'Intranet';
    WsusSsl              = $true;
    Verbose              = $true
}

Add-CMSoftwareUpdatePoint @Parameters

Set-Location -Path "$env:SYSTEMDRIVE"
