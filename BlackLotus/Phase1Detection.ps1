# Check if running as CcmExec to adjust script output for CI use
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
else {
    if ($RunningAsCcmExec) {
        return $false
    }
    else {
        Write-Output 'Remediation required'
        exit 1
    }
}
