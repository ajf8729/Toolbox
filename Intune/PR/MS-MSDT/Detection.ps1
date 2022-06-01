try {
    $msdt = Test-Path -Path 'Registry::HKEY_CLASSES_ROOT\ms-msdt'
    
    if (-not $msdt) {
        Write-Output 'HKEY_CLASSES_ROOT\ms-msdt does not exist'
        exit 0
    }
    else {
        Write-Output 'HKEY_CLASSES_ROOT\ms-msdt exists'
        exit 1
    }
}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Error -Message $LastError
    exit 1
}
