$Compliant = $true

$IPv6 = Get-NetAdapterBinding -ComponentID 'ms_tcpip6'

if ($IPv6.Enabled -contains $false) {
    $Compliant = $false
}

return $Compliant
