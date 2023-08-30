try {
    Start-Process -FilePath 'dism.exe' -ArgumentList '/Online', '/Disable-Feature', '/FeatureName:MicrosoftWindowsPowerShellV2'
    exit 0
}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Warning -Message $LastError
    exit 1
}
