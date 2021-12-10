try {
    $Compliant = $true

    if ((((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2).State) -match 'Enabled') -or (((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).State) -match 'Enabled')) {
        $Compliant = $false
    }

    if ($Compliant -eq $true) {
        Write-Output 'PowerShell v2 is disabled'
        exit 0
    }
    else {
        Write-Output 'PowerShell v2 is enabled'
        exit 1
    }
}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Error -Message $LastError
    exit 1
}
