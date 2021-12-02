[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$CAName,
    [Parameter(Mandatory = $true)]
    [string]$TemplateName
)

# Import CM module and change to SMS drive path
Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"
$SiteCode = (Get-CimInstance -Namespace ROOT/SMS -ClassName SMS_ProviderLocation).SiteCode
Set-Location -Path "$($SiteCode):"

# Request and export cert
$Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$SubjectName = "CN=ConfigMgr Client $Timestamp"
$Certificate = Get-Certificate -Url "LDAP:////$($CAName)" -Template $TemplateName -SubjectName $SubjectName -CertStoreLocation 'Cert:\LocalMachine\My\'
$Thumbprint = $Certificate.Certificate.Thumbprint
$Password = (New-Guid).Guid | ConvertTo-SecureString -AsPlainText -Force
Export-PfxCertificate -Cert "Cert:\LocalMachine\My\$Thumbprint" -FilePath "C:\$Thumbprint.pfx" -Password $Password | Out-Null

# Loop through DPs and update cert
$DPs = ((Get-CMDistributionPoint -SiteCode $SiteCode).NetworkOSPath).trim('\\')
foreach ($DP in $DPs) {
    Set-CMDistributionPoint -SiteSystemServerName $DP -CertificatePath "C:\$Thumbprint.pfx" -CertificatePassword $Password -Confirm:$false -Force
}

# Remove local copies of cert
Remove-Item -Path "Cert:\LocalMachine\My\$Thumbprint" -Force
Remove-Item -Path "C:\$Thumbprint.pfx" -Force
