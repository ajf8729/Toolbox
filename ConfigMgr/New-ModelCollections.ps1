#Original credit to /u/houstonau on Reddit
#https://www.reddit.com/r/SCCM/comments/5jhcpk/create_sccm_device_collections_based_on_model/
#Modified to update collections daily instead of incrementally

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$cmSiteID
)

Import-Module ${env:ProgramFiles(x86)}\ConfigMgrConsole\bin\ConfigurationManager.psd1

$rootCMDrive = "$($cmSiteID):"
$curModels = @()
$Schedule = New-CMSchedule –RecurInterval Days –RecurCount 1

If (!(Get-Item $rootCMDrive\DeviceCollection\Models))
{
    New-item $rootCMDrive\DeviceCollection\Models
}

function newModelCollection ([string]$modelName)
{
    Set-Location $rootCMDrive
    if (!(Get-CMDeviceCollection -Name $modelName))
    {
        New-CMDeviceCollection -Name $modelName -LimitingCollectionName 'All Systems' -RefreshSchedule $Schedule -RefreshType 2
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName $modelName -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = `"$($modelName)`"" -RuleName "Model is $($modelName)"
        Move-CMObject -InputObject (Get-CMDeviceCollection -Name $modelName) -FolderPath "$($rootCMDrive)\DeviceCollection\Models"
    }
}

Set-Location $rootCMDrive
$curModels = Invoke-CMWmiQuery -query "select distinct SMS_G_System_COMPUTER_SYSTEM.Manufacturer, SMS_G_System_COMPUTER_SYSTEM.Model from  SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId" | Select Manufacturer, Model

foreach ($model in $curModels)
{
	newModelCollection($model.model)
}
