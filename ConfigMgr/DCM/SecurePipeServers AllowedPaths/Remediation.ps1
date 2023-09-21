$SMSPath = 'SOFTWARE\Microsoft\SMS'
$MachineAllowedPaths = Get-ItemPropertyValue -Path HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths\ -Name Machine
$NewMachineAllowedPaths = $MachineAllowedPaths + $SMSPath
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths\ -Name Machine -Value $NewMachineAllowedPaths
