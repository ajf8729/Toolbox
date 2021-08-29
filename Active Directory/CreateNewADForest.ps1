[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$DomainName,
    [Parameter(Mandatory=$True)]
    [string]$DomainNetbiosName
)

$Features = (
    "AD-Domain-Services",
    "DNS"
)

Install-WindowsFeature -Name $Features

Import-Module -Name ADDSDeployment

$Parameters = @{
    DomainName           = $DomainName;
    DomainNetbiosName    = $DomainNetbiosName;
    ForestMode           = 'WinThreshold';
    DomainMode           = 'WinThreshold';
    DatabasePath         = 'C:\Windows\NTDS';
    LogPath              = 'C:\Windows\NTDS';
    SysvolPath           = 'C:\Windows\SYSVOL';
    InstallDns           = $true;
    CreateDnsDelegation  = $false;
    NoRebootOnCompletion = $false;
    Verbose              = $true
}

Install-ADDSForest @Parameters
