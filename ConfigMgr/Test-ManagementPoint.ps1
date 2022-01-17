[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$ManagementPointFqdn,
    [Parameter(Mandatory = $true)]
    [ValidateSet(
        'HTTP',
        'HTTPS'
    )]
    [string]$Protocol,
    [Parameter(Mandatory = $true)]
    [ValidateSet(
        'mpcert',
        'mplist'
    )]
    [string]$Test
)

$Certificate = Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object -FilterScript {$_.EnhancedKeyUsageList -like "Client Authentication (1.3.6.1.5.5.7.3.2)"}

Invoke-WebRequest -Uri "$($Protocol)://$ManagementPointFqdn/sms_mp/.sms_aut?$Test" -Certificate $Certificate -UseBasicParsing | Select-Object -ExpandProperty Content
