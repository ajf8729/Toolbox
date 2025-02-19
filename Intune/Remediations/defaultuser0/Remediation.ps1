if (Get-LocalUser -Name 'defaultuser0' -ErrorAction Ignore) {
    Remove-LocalUser -Name 'defaultuser0' -Confirm:$false
}

if (Get-CimInstance -ClassName Win32_UserProfile -Filter 'LocalPath = "C:\\Users\\defaultuser0"') {
    Get-CimInstance -ClassName Win32_UserProfile -Filter 'LocalPath = "C:\\Users\\defaultuser0"' | Remove-CimInstance -Confirm:$false
}
