$ShortcutPath = "$env:Public\Desktop\Software Center.lnk"
$Shell = New-Object -COM WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "softwarecenter:"
$Shortcut.Description = "ConfigMgr Software Center"
$Shortcut.IconLocation = "$env:SystemRoot\CCM\scclient.exe,0"
$Shortcut.Save()
