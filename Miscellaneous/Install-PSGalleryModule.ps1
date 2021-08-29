[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$ModuleName
)

$PSGalleryExists = Get-PSRepository -Name PSGallery

if ($null -eq $PSGalleryExists) {
    Register-PSRepository -Default
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

$ModuleExists = Get-Module -Name $ModuleName

if ($null -eq $ModuleExists) {
    Install-Module -Name $ModuleName -Repository PSGallery -Scope AllUsers -Verbose
}
