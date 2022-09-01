$OSDComputerName = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

if ($OSDComputerName.Contains('-')) {
    $OSDComputerName = $OSDComputerName.Replace('-', '')
}

$Length = $OSDComputerName.Length

if ($Length -gt 15) {
    $OSDComputerName = $OSDComputerName.Substring($Length - 15)
}

return $OSDComputerName
