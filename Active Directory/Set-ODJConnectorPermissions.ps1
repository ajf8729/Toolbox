[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$ServiceAccount
)

$FileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule($ServiceAccount, 'Read', 'Allow')

$Certificate = Get-ChildItem 'Cert:\LocalMachine\My\' | Where-Object {$_.Issuer -eq 'CN=Microsoft Intune ODJ Connector CA'}
$PrivateKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Certificate)
$PrivateKeyFilename = $PrivateKey.key.UniqueName
$PrivateKeyPath = "$env:ProgramData\Microsoft\Crypto\RSA\MachineKeys\$PrivateKeyFilename"
$PrivateKeyPermissions = Get-Acl -Path $PrivateKeyPath
$PrivateKeyPermissions.AddAccessRule($FileSystemAccessRule)
Set-Acl -Path $PrivateKeyPath -AclObject $PrivateKeyPermissions

Stop-Service -Name ODJConnectorSvc
Start-Process -FilePath 'sc.exe' -ArgumentList 'config', 'ODJConnectorSvc', 'obj=', $ServiceAccount -NoNewWindow
Start-Service -Name ODJConnectorSvc
