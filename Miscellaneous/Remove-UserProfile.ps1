[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$Username
)

$ProfilesDirectory = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -Name ProfilesDirectory).ProfilesDirectory

Get-CimInstance -ClassName Win32_UserProfile |
    Where-Object -FilterScript { ($_.LocalPath -eq "$ProfilesDirectory\$Username") -and ($_.Special -eq $false) } |
    Remove-CimInstance
