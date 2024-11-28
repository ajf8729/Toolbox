$AzureArcSetup = Get-WindowsFeature -Name AzureArcSetup
if (!($AzureArcSetup.Installed -eq $true)) {
    return $true
}
else {
    return $false
}
