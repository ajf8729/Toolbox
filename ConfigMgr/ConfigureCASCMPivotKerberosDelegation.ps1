[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$CasSqlServiceAccount,
    [Parameter(Mandatory = $True)]
    [string[]]$PriSqlServiceAccounts,
    [Parameter(Mandatory = $True)]
    [string[]]$CasSmsProviders
)

Write-Host 'CAS SQL Service Account Configuration:' -ForegroundColor Green
$CasSqlServiceAccount |
    ForEach-Object {
        Get-ADServiceAccount -Identity $_ -Properties msDS-AllowedToDelegateTo
    } |
    Select-Object Name, msDS-AllowedToDelegateTo |
    Sort-Object Name |
    Format-Table -AutoSize

Write-Host 'PRI SQL Service Account Configuration:' -ForegroundColor Green
$PriSqlServiceAccounts |
    ForEach-Object {
        Get-ADServiceAccount -Identity $_ -Properties msDS-AllowedToDelegateTo
    } |
    Select-Object Name, msDS-AllowedToDelegateTo |
    Sort-Object Name |
    Format-Table -AutoSize

Write-Host 'CAS SMS Provider Computer Account Configuration:' -ForegroundColor Green
$CasSmsProviders |
    ForEach-Object {
        Get-ADComputer -Identity $_ -Properties msDS-AllowedToDelegateTo
    } |
    Select-Object Name, msDS-AllowedToDelegateTo |
    Sort-Object Name |
    Format-Table -AutoSize
