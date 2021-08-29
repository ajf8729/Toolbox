try {
    if ((((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2).State) -match 'Enabled') -or (((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).State) -match 'Enabled')) {
    return $true
    }
    else {
        return $false
    }
}

catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Warning -Message $LastError
    exit 1
}
