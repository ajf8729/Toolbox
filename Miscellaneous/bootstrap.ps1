# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Prep folders
Write-Host "Creating folders..."
if (-not (Test-Path -Path "$env:USERPROFILE\.ssh")) {
    New-Item -Path "$env:USERPROFILE\.ssh" -ItemType Directory | Out-Null
}
if (-not (Test-Path -Path "$env:SystemDrive\AJF8729\Git")) {
    New-Item -Path "$env:SystemDrive\AJF8729\Git" -ItemType Directory -Force | Out-Null
}

Set-Location -Path "$env:SystemDrive\AJF8729"

# Download latest release of DesktopAppInstaller
Write-Host "Downloading DesktopAppInstaller..."
$tag = (Invoke-WebRequest -UseBasicParsing "https://api.github.com/repos/microsoft/winget-cli/releases" | ConvertFrom-Json)[0].tag_name
$download = "https://github.com/microsoft/winget-cli/releases/download/$tag/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
Invoke-WebRequest -UseBasicParsing $download -OutFile "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

# Install DesktopAppInstaller
Write-Host "Installing DesktopAppInstaller..."
Add-AppxPackage -Path "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

# Install Git
Write-Host "Installing Git..."
winget install "Git" -h

# Install VS Code
Write-Host "Installing VS Code..."
winget install "Microsoft Visual Studio Code" -h

# Configure Git
git config --global user.email "ajf@anthonyfontanez.com"
git config --global user.name "Anthony J. Fontanez"

#Set GIT_SSH
Write-Host "Setting GIT_SSH..."
[System.Environment]::SetEnvironmentVariable('GIT_SSH', 'C:\Windows\System32\OpenSSH\ssh.exe', [System.EnvironmentVariableTarget]::Machine)

# Download PowerShell profile
Write-Host "Downloading PowerShell profile..."
New-Item -Path $PROFILE -Force | Out-Null
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/ajf8729/dotfiles/main/Microsoft.PowerShell_profile.ps1" | Out-File -FilePath $PROFILE -Force

# Download private key
Write-Host "Downloading SSH private key..."
scp ajf@anthonyfontanez.com:.ssh\id_rsa "$env:USERPROFILE\.ssh\id_rsa"

#Enable SSH agent
Write-Host "Enabling/starting SSH agent service..."
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent

Write-Host "All done!"
