$Path = "$env:Public\Desktop"
$Filename = "Software Center.lnk"

$Shell = New-Object -COM WScript.Shell
$Shortcut = $Shell.CreateShortcut("$Path\$Filename")
$Shortcut.TargetPath = "softwarecenter:"
$Shortcut.Description = "ConfigMgr Software Center"
$Shortcut.IconLocation = "$env:SystemRoot\CCM\scclient.exe,0"
$Shortcut.Save()
