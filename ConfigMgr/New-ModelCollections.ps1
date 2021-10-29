Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1"

$SiteCode = (Get-CimInstance -Namespace ROOT/SMS -ClassName SMS_ProviderLocation).SiteCode

Set-Location -Path "$($SiteCode):"

$Schedule = New-CMSchedule -RecurInterval Days -RecurCount 1

if (-not (Test-Path -Path "$($SiteCode):\DeviceCollection\Models")) {
    New-Item -Path "$($SiteCode):\DeviceCollection\" -Name "Models"
}

$Models = Invoke-CMWmiQuery -Query "select distinct SMS_G_System_COMPUTER_SYSTEM.Manufacturer, SMS_G_System_COMPUTER_SYSTEM.Model from  SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId" | Select-Object -ExpandProperty Model

foreach ($Model in $Models) {
    if (-not (Get-CMDeviceCollection -Name $Model)) {
        $Collection = New-CMDeviceCollection -Name $Model -LimitingCollectionName 'All Systems' -RefreshSchedule $Schedule -RefreshType 2
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName $Model -QueryExpression "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = `"$($Model)`"" -RuleName $Model
        Move-CMObject -InputObject $Collection -FolderPath "$($SiteCode):\DeviceCollection\Models"
    }
}
