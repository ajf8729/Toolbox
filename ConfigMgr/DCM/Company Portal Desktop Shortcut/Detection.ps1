$SCShortcutPath = "$env:Public\Desktop\Software Center.lnk"
$CPShortcutPath = "$env:Public\Desktop\Company Portal.url"

if ( -not (Test-Path -Path $SCShortcutPath) -and (Test-Path -Path $CPShortcutPath) ) {
	return $true
}
else {
	return $false
}
