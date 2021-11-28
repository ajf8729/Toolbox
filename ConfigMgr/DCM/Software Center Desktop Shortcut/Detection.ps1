$ShortcutPath = "$env:Public\Desktop\Software Center.lnk"

if (Test-Path -Path $ShortcutPath) {
	return $true
}
else {
	return $false
}
