# https://anthonyfontanez.com/index.php/2023/12/30/importing-certificates-with-remediations/

$Thumbprint = 'd5481e84552c7a55884de8af160d71a541dff87d'
$Store = 'TrustedPublisher'

if (Test-Path -Path "Cert:\LocalMachine\$Store\$Thumbprint") {
    Write-Output 'Certificate exists'
    exit 0
}
else {
    Write-Output 'Certificate does not exist'
    exit 1
}
