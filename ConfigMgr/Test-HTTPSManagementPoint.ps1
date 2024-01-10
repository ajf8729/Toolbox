[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ManagementPointFqdn,
    [Parameter(Mandatory = $true)]
    [string]$CAName
)

$Certificate = Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object -FilterScript {$_.EnhancedKeyUsageList -like '*(1.3.6.1.5.5.7.3.2)' -and $_.Issuer -like "*$CAName*"} | Select-Object -First 1

Write-Host "MPCert Results:"
Invoke-WebRequest -Uri "https://$ManagementPointFqdn/sms_mp/.sms_aut?mpcert" -Certificate $Certificate -UseBasicParsing | Select-Object -ExpandProperty Content

Write-Host "MPList Results:"
Invoke-WebRequest -Uri "https://$ManagementPointFqdn/sms_mp/.sms_aut?mplist" -Certificate $Certificate -UseBasicParsing | Select-Object -ExpandProperty Content
