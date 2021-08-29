$PSGalleryExists = Get-PSRepository -Name PSGallery

if ($null -eq $PSGalleryExists) {
    Register-PSRepository -Default
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

Update-Module -Verbose
