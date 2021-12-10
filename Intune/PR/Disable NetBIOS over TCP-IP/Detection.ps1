try {
    $Compliant = $true

    $Options = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Property TcpipNetbiosOptions |
        Where-Object -FilterScript {$_.TcpipNetbiosOptions -ne $null} |
        Select-Object -ExpandProperty TcpipNetbiosOptions

    foreach ($Option in $Options) {
        if ($Option -ne 2) {
            $Compliant = $false
        }
    }

    if ($Compliant -eq $true) {
        Write-Output 'NetBIOS over TCP/IP is disabled'
        exit 0
    }
    else {
        Write-Output 'NetBIOS over TCP/IP is enabled'
        exit 1
    }
}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Error -Message $LastError
    exit 1
}
