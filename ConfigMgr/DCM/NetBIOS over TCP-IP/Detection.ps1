$Compliant = $true
$Options = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Property TcpipNetbiosOptions |
    Where-Object -FilterScript {$_.TcpipNetbiosOptions -ne $null} |
    Select-Object -ExpandProperty TcpipNetbiosOptions

foreach ($Option in $Options) {
    if ($Option -ne 2) {
        $Compliant = $false
    }
}

return $Compliant
