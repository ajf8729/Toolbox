$Path = "$env:Public\Desktop"
$Filename = "Software Center.lnk"

if (Test-Path -Path "$Path\$Filename") {
	return $true
}
else {
	return $false
}
