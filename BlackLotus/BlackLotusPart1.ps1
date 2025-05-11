$ParentProcessName = (Get-Process -Id ((Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID").ParentProcessId)).ProcessName
if ($ParentProcessName -eq 'CcmExec') {
    $RunningAsCcmExec = $true
}

$WindowsUEFICA2023Capable = Get-ItemPropertyValue -Path HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing -Name WindowsUEFICA2023Capable -ErrorAction Ignore

# Check if we are already in expected state, and exit if so
if ($WindowsUEFICA2023Capable -eq 2) {
    if ($RunningAsCcmExec) {
        return $true
    }
    else {
        Write-Output '"Windows UEFI CA 2023" certificate is in the DB and the system is starting from the 2023 signed boot manager'
        exit 0
    }
}
# Continue with remediation if WindowsUEFICA2023Capable ne 2

$SecureBootDB = [System.Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI db).bytes)

# Step 1: Install the updated certificate definitions to the DB
if ($SecureBootDB -notmatch 'Windows UEFI CA 2023') {
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Secureboot -Name AvailableUpdates -Value 0x40 -Force
    Start-ScheduledTask -TaskName '\Microsoft\Windows\PI\Secure-Boot-Update'
    # TODO - watch for TPM event and loop for a bit until it occurs
}

# Step 2: Update the Boot Manager on your device
if ($SecureBootDB -match 'Windows UEFI CA 2023') {
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Secureboot -Name AvailableUpdates -Value 0x100 -Force
    Start-ScheduledTask -TaskName '\Microsoft\Windows\PI\Secure-Boot-Update'
    for ($i = 0; $i -lt $12; $i++) {
        $event1799 = Get-WinEvent -LogName System -MaxEvents 100 | Where-Object {$_.Id -eq 1799}
        if (-not $event1799) {
            $i++
            Start-Sleep -Seconds 10
        }
    }
    if ($event1799) {
        # Verify Step 2 is complete
        mountvol s: /s
        # Get-AuthenticodeSignature will not work for our purposes, see the following links:
        # https://github.com/PowerShell/PowerShell/issues/8401#issuecomment-783993634
        # https://github.com/PowerShell/PowerShell/issues/23820
        # Good: "CN=Windows UEFI CA 2023, O=Microsoft Corporation, C=US"
        # Bad: "CN=Microsoft Windows Production PCA 2011, O=Microsoft Corporation, L=Redmond, S=Washington, C=US"
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate]::CreateFromSignedFile('S:\EFI\Microsoft\Boot\bootmgfw.efi')
        mountvol s: /d
        if ($cert.Issuer -ne 'CN=Windows UEFI CA 2023, O=Microsoft Corporation, C=US') {
            if ($RunningAsCcmExec) {
                return $false
            }
            else {
                Write-Output 'bootmgr.efi is not signed with 2023 CA'
                exit 1
            }
        }
        else {
            if ($RunningAsCcmExec) {
                return $true
            }
            else {
                Write-Output 'bootmgr.efi is signed with 2023 CA'
                exit 0
            }
        }
    }
    else {
        if ($RunningAsCcmExec) {
            return $false
        }
        else {
            Write-Output 'New signed boot manager installation not detected'
            exit 1
        }
    }
}
