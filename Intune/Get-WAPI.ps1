Write-Host 'Setting execution policy to Unrestricted...' -ForegroundColor Green
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force | Out-Null

Write-Host 'Installing NuGet package provider...' -ForegroundColor Green
Install-PackageProvider -Name NuGet -Force | Out-Null

Write-Host 'Installing Get-WindowsAutoPilotInfo script...' -ForegroundColor Green
Install-Script -Name Get-WindowsAutoPilotInfo -Force | Out-Null

Write-Host 'Installing WindowsAutopilotIntune module...' -ForegroundColor Green
Install-Module -Name WindowsAutopilotIntune -Force | Out-Null

Write-Host 'Executing "Get-WindowsAutoPilotInfo -Online -Assign"...' -ForegroundColor Green
Get-WindowsAutoPilotInfo -Online -Assign
