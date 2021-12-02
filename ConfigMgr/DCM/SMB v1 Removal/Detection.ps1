$Compliant = $true

try {
    [string]$OperatingSystemVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version

    switch -Regex ($OperatingSystemVersion) {
        '(^10\.0.*|^6\.3.*)' {
            # Windows 8.1 / Server 2012 R2 / Windows 10 / Server 2016
            if (((Get-SmbServerConfiguration).EnableSMB1Protocol) -or (((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State) -match 'Enable(d|Pending)')) {
                $Compliant = $false
            }
        }
        '^6\.2.*' {
            # Windows 8 / Server 2012
            if (((Get-SmbServerConfiguration).EnableSMB1Protocol) -or ((sc.exe qc lanmanworkstation) -match 'MRxSmb10')) {
                $Compliant = $false
            }
        }
        '^6\.(0|1).*' {
            # Windows Vista / Server 2008 / Windows 7 / Server 2008R2
            if ((((Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name SMB1 -ErrorAction SilentlyContinue).SMB1) -ne '0') -or ((sc.exe qc lanmanworkstation) -match 'MRxSMb10')) {
                $Compliant = $false
            }
        }
        default {
            throw 'Unsupported Operating System'
        }
    }
}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Warning -Message $LastError
    exit 1
}

return $Compliant
