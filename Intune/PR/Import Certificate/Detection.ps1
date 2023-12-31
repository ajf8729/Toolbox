# https://anthonyfontanez.com/index.php/2023/12/30/importing-certificates-with-remediations/

$Thumbprint = 'A053DF291934DCB023A2C2C2A0C9C0B7FFFEC4D7'
$Store = 'TrustedPublisher'

if (Test-Path -Path "Cert:\LocalMachine\$Store\$Thumbprint") {
    Write-Output 'Certificate exists'
    exit 0
}
else {
    Write-Output 'Certificate does not exist'
    exit 1
}
