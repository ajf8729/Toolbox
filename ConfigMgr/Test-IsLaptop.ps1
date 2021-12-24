$TSEnv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$TSEnv.Value('IsLaptop') = $false

$ChassisTypes = (Get-CimInstance -ClassName Win32_SystemEnclosure -Property ChassisTypes).ChassisTypes

if ($ChassisTypes -in 8, 9, 10, 11, 14, 30, 31, 32) {
    $TSEnv.Value('IsLaptop') = $true
}
