$Compliant = $False
$CCMPath = 'C:\Windows\CCM'
$Paths = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').GetValue('PATH', $null, 'DoNotExpandEnvironmentNames') -split ';'
foreach ($Path in $Paths) {
    if ($Path -eq $CCMPath) {
        $Compliant = $True
    }
}
return $Compliant
