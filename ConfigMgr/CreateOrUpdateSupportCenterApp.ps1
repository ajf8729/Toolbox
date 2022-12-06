[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [string]$SiteCode,
    [Parameter(Mandatory = $True)]
    [string]$DpGroupName,
    [Parameter(Mandatory = $True)]
    [string]$DeploymentCollectionName
)

#Requires -Modules ConfigurationManager

Import-Module -Name ConfigurationManager

# Store current path to return to at end of script
$ReturnPath = (Get-Location).Path
# Support Center application name
$AppName = 'Configuration Manager Support Center'

Set-Location -Path "$($SiteCode):"

# Build paths for app use
$SiteServerName = (Get-CMSite -SiteCode $SiteCode).ServerName
$SiteInstallDir = (Get-CMSite -SiteCode $SiteCode).InstallDir
$SupportCenterLocalPath = "$SiteInstallDir\tools\SupportCenter"
$SupportCenterUncPath = "\\$SiteServerName\SMS_$SiteCode\tools\SupportCenter"
$SupportCenterFilename = 'supportcenterinstaller.msi'

# Get Support Center version and product code
$Version = (((Get-AppLockerFileInformation -Path "$SupportCenterLocalPath\$SupportCenterFilename").Publisher).BinaryVersion).ToString()
$ProductCode = ((Get-AppLockerFileInformation -Path "$SupportCenterLocalPath\$SupportCenterFilename").Publisher).BinaryName

# Check if app already exists
$SupportCenterApp = Get-CMApplication -Name $AppName -Fast

# App does not exist; create it
if ($null -eq $SupportCenterApp) {
    Write-Host "$AppName does not exist, creating it..." -ForegroundColor Green
    Write-Host "Downloading icon..." -ForegroundColor Green
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ajf8729/Toolbox/main/ConfigMgr/SupportCenterIcon.png' -OutFile $env:TEMP\SupportCenterIcon.png
    Write-Host "Creating app..." -ForegroundColor Green
    New-CMApplication -Name $AppName -LocalizedName $AppName -Publisher 'Microsoft Corporation' -SoftwareVersion $Version -IconLocationFile "$env:TEMP\SupportCenterIcon.png" -ReleaseDate (Get-Date) | Out-Null
    Write-Host "Creating deployment type..." -ForegroundColor Green
    Add-CMMsiDeploymentType -ApplicationName $AppName -DeploymentTypeName $AppName -EstimatedRuntimeMins 5 -MaximumRuntimeMins 15 -InstallationBehaviorType InstallForSystem -InstallCommand "msiexec.exe /i $SupportCenterFilename /qn" -LogonRequirementType WhereOrNotUserLoggedOn -ContentLocation "$SupportCenterUncPath\$SupportCenterFilename" | Out-Null
    Write-Host "Creating required deployment to $DeploymentCollectionName collection..." -ForegroundColor Green
    New-CMApplicationDeployment -Name $AppName -CollectionName $DeploymentCollectionName -DeployAction Install -DeployPurpose Required -DistributeContent -DistributionPointGroupName $DpGroupName | Out-Null
}
# App exists, update it
else {
    Write-Host "$AppName already exists, updating it..." -ForegroundColor Green
    Write-Host "Updating release date..." -ForegroundColor Green
    $SupportCenterApp | Set-CMApplication -ReleaseDate (Get-Date) | Out-Null
    Write-Host "Updating product code..." -ForegroundColor Green
    $SupportCenterApp | Get-CMDeploymentType | Set-CMMsiDeploymentType -ProductCode $ProductCode | Out-Null
    Write-Host "Invoking content redistribution..." -ForegroundColor Green
    Invoke-CMContentRedistribution -InputObject $SupportCenterApp | Out-Null
}
Write-Host "All done!" -ForegroundColor Green

# Return to previously stored path
Set-Location -Path $ReturnPath
