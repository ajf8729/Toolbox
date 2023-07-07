$Compliant = $False
$Paths = [System.Environment]::GetEnvironmentVariable('PATH') -split ';'
foreach ($Path in $Paths) {
    if ($Path -eq 'C:\Windows\CCM') {
        $Compliant = $True
    }
}
return $Compliant
