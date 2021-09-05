[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$SiteCode,
    [Parameter(Mandatory=$true)]
    [System.IO.FileInfo]$LogPath
)

$Timestamp = Get-Date -Format "yyyy-MM-dd_hh-mm-ss-tt"
$Filename = "RemovedRetiredApplications-$TimeStamp-$env:USERNAME.csv"

try {
    New-PSDrive -PSProvider FileSystem -Name "LogPath" -Root $LogPath | Out-Null
    Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
    Set-Location -Path "$($SiteCode):"
    $RetiredApplications = Get-CMApplication -Fast | Where-Object -FilterScript {$_.IsExpired -eq $true}
    $RetiredApplications | Select-Object -Property LocalizedDisplayName,Manufacturer,SoftwareVersion | Export-Csv -Path "LogPath:\$Filename" -NoTypeInformation
    $RetiredApplications | Remove-CMApplication -Force
    Set-Location -Path $env:SystemDrive
}
catch {
    Write-Warning -Message $_.Exception.Message
    break
}
