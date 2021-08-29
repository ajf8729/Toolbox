try {
[string]$OperatingSystemVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version

switch -Regex ($OperatingSystemVersion) {
    '(^10\.0.*|^6\.3.*)' {
        # Windows 8.1 / Server 2012 R2 / Windows 10 / Server 2016

        # SMB v1 Server Settings
        if ((Get-SmbServerConfiguration).EnableSMB1Protocol) {
            Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
        }

        # SMB v1 Client Settings
        if (((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State) -match 'Enable(d|Pending)') {
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
        }
    }
    '^6\.2.*' {
        # Windows 8 / Server 2012

        # SMB v1 Server Settings
        if ((Get-SmbServerConfiguration).EnableSMB1Protocol) {
            Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
        }

        # SMB v1 Client Settings
        if ((sc.exe qc lanmanworkstation) -match 'MRxSmb10') {
            Start-Process -FilePath "$env:windir\System32\sc.exe" -ArgumentList 'config lanmanworkstation depend= bowser/mrxsmb20/nsi' -WindowStyle Hidden
            Start-Process -FilePath "$env:windir\System32\sc.exe" -ArgumentList 'config mrxsmb10 start= disabled' -WindowStyle Hidden
        }
    }
    '^6\.(0|1).*' {
        # Windows Vista / Server 2008 / Windows 7 / Server 2008R2

        # SMB v1 Server Settings
        if (((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name SMB1 -ErrorAction SilentlyContinue).SMB1) -ne '0') {
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name SMB1 -Type DWORD -Value 0 -Force -ErrorAction SilentlyContinue
        }

        # SMB v1 Client Settings
        if ((sc.exe qc lanmanworkstation) -match 'MRxSmb10') {
            Start-Process -FilePath "$env:windir\System32\sc.exe" -ArgumentList 'config lanmanworkstation depend= bowser/mrxsmb20/nsi' -WindowStyle Hidden
            Start-Process -FilePath "$env:windir\System32\sc.exe" -ArgumentList 'config mrxsmb10 start= disabled' -WindowStyle Hidden
        }
    }
    default {
        throw "Unsupported Operating System"
    }
}

exit 0

}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Warning -Message $LastError
    exit 1
}
