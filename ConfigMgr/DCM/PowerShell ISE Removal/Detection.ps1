if ((Get-WindowsCapability -Online -Name 'Microsoft.Windows.PowerShell.ISE').State -eq 'Installed') {
    return $false
}
else {
    return $true
}
