$CCMPath = 'C:\Windows\CCM'
$Paths = [System.Environment]::GetEnvironmentVariable('PATH') -split ';'
$NewPath = ($Paths + $CCMPath) -join ';'
[System.Environment]::SetEnvironmentVariable('PATH', $NewPath, [System.EnvironmentVariableTarget]::Machine)
