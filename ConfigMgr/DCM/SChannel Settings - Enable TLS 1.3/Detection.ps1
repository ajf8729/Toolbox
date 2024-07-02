try {
    # Check Keys
    if (-not (Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3')) {
        return $false
    }
    if (-not (Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client')) {
        return $false
    }
    if (-not (Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server')) {
        return $false
    }
    # Check Values
    if ((Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client' -Name 'Enabled' -ErrorAction SilentlyContinue) -ne 1) {
        return $false
    }
    if ((Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -Name 'Enabled' -ErrorAction SilentlyContinue) -ne 1) {
        return $false
    }
}
catch {
    return $false
}
return $true
