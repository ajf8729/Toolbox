[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$RootOUName,
    [Parameter(Mandatory=$True)]
    [string]$RootOUDescription
)

Import-Module -Name ActiveDirectory

$DomainDN = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName

New-ADOrganizationalUnit -Name $RootOUName -Path $DomainDN -Description $RootOUDescription

$RootOUDN = "OU=$RootOUName,$DomainDn"

$OUs = (
    "Administrators",
    "Autopilot",
    "Clients",
    "Groups",
    "Servers",
    "Staging",
    "Users"
)

foreach ($OU in $OUs) {
    New-ADOrganizationalUnit -Name $OU -Path $RootOUDN -Description "$RootOUDescription $OU"
}
