if (((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).State -ne 'Disabled') -or ((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2).State -ne 'Disabled')) {
    return $false
}
else {
    return $true
}
