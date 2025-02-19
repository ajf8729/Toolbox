$SCShortcutPath = "$env:Public\Desktop\Software Center.lnk"
$CPShortcutPath = "$env:Public\Desktop\Company Portal.url"

if (Test-Path -Path $SCShortcutPath) {
	Write-Output 'Software Center desktop shortcut exists'
    exit 1
}

if ( -not (Test-Path -Path $CPShortcutPath) ) {
	Write-Output 'Company Portal desktop shortcut does not exist'
    exit 1
}
