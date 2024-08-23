$CCMPath = 'C:\Windows\CCM'
$Paths = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').GetValue('PATH', $null, 'DoNotExpandEnvironmentNames') -split ';'
$NewPath = ($Paths + $CCMPath) -join ';'
[System.Environment]::SetEnvironmentVariable('PATH', $NewPath, [System.EnvironmentVariableTarget]::Machine)
