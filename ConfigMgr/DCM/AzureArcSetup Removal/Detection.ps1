$AzureArcSetup = Get-WindowsFeature -Name AzureArcSetup
if ($AzureArcSetup.Installed -eq $false) {
    return $true
}
else {
    return $false
}
