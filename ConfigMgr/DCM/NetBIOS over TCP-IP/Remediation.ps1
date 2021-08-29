Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration |
    Where-Object -FilterScript {$_.TcpipNetbiosOptions -ne $null} |
    Invoke-CimMethod -MethodName SetTcpipNetbios -Arguments @{TcpipNetbiosOptions = 2}
