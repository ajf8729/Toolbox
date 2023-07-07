$Compliant = $False
$CCMPath = 'C:\Windows\CCM'
$Paths = [System.Environment]::GetEnvironmentVariable('PATH') -split ';'
foreach ($Path in $Paths) {
    if ($Path -eq $CCMPath) {
        $Compliant = $True
    }
}
return $Compliant
