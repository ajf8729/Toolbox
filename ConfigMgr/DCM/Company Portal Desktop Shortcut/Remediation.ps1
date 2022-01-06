$SCShortcutPath = "$env:Public\Desktop\Software Center.lnk"

if (Test-Path -Path $SCShortcutPath) {
    Remove-Item -Path $SCShortcutPath -Force
}

$ShortcutPath = "$env:Public\Desktop\Company Portal.url"
$Shell = New-Object -COM WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = 'CompanyPortal:'
$Shortcut.Save()
