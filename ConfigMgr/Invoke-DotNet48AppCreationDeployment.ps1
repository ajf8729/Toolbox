[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ContentPath
)

# script to package .NET 4.8 and deploy it to all CM servers
# -create query collection
# -download content
# -create app
# -deploy app

$Uri = 'https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe'
$QueryExpression = 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemRoles = "SMS Site System"'

if ( -not (Test-Path -Path "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1") ) {
    Write-Error -Message 'ConfigurationManager module does not exist.'
    exit
}

Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"

$SiteCode = (Get-CimInstance -Namespace ROOT/SMS -ClassName SMS_ProviderLocation).SiteCode
Set-Location -Path "$($SiteCode):"

Invoke-WebRequest -Uri $Uri -OutFile $ContentPath -UseBasicParsing

New-CMDeviceCollection -Name "ConfigMgr Site System Servers" -LimitingCollectionName "All Systems" -RefreshType Periodic -RefreshSchedule (New-CMSchedule -RecurCount 1 -RecurInterval Days)
Add-CMDeviceCollectionQueryMembershipRule -CollectionName "ConfigMgr Site System Servers" -QueryExpression $QueryExpression -RuleName "SMS Site System"

New-CMApplication -Name $AppName -LocalizedName $Name -SoftwareVersion $Version -IconLocationFile $IconPath -ReleaseDate (Get-Date -Format yyyy-MM-dd)
Add-CMScriptDeploymentType -ApplicationName $AppName -DeploymentTypeName $DeploymentTypeName -InstallCommand $InstallScriptFilename -ScriptLanguage PowerShell -ScriptText $DetectionScriptText -ContentLocation $ContentLocation -EstimatedRuntimeMins $EstimatedRuntimeMins -MaximumRuntimeMins $MaximumRuntimeMins -LogonRequirementType WhetherOrNotUserLoggedOn -UserInteractionMode Hidden -InstallationBehaviorType InstallForSystem -ContentFallback -SlowNetworkDeploymentMode Download
New-CMApplicationDeployment -Name $AppName -CollectionName $DeviceCollectionProd -DeployAction Install -DeployPurpose Required -OverrideServiceWindow $false -RebootOutsideServiceWindow $false -UserNotification DisplaySoftwareCenterOnly
