$Compliant = $False
$SMSPath = 'SOFTWARE\Microsoft\SMS'
$MachineAllowedPaths = Get-ItemPropertyValue -Path HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths\ -Name Machine
foreach ($MachineAllowedPath in $MachineAllowedPaths) {
    if ($MachineAllowedPath -eq $SMSPath) {
        $Compliant = $True
    }
}
return $Compliant
