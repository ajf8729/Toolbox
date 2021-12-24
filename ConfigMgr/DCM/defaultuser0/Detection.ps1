$Compliant = $true

if ((Get-LocalUser -Name 'defaultuser0' -ErrorAction Ignore) -or (Get-CimInstance -ClassName Win32_UserProfile -Filter 'LocalPath = "C:\\Users\\defaultuser0"')) {
    $Compliant = $false
}

return $Compliant
