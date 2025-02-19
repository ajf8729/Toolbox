try {
    $RestrictDriverInstallationToAdministrators = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint' -Name RestrictDriverInstallationToAdministrators).RestrictDriverInstallationToAdministrators
    
    if ($RestrictDriverInstallationToAdministrators -eq 0) {
        Write-Output 'RestrictDriverInstallationToAdministrators is equal to 0'
        exit 0
    }
    else {
        Write-Output 'RestrictDriverInstallationToAdministrators is NOT equal to 0'
        exit 1
    }
}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Error -Message $LastError
    exit 1
}
