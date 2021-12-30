# Originally sourced from https://www.reddit.com/r/Intune/comments/grptqy/domain_join_hanging_in_autopilot/fs7cnsy/ (https://www.reddit.com/user/touchytypist)

#Monitor Autopilot OU for New Computer Accounts and Trigger Azure AD Connect Sync

$AutopilotOU = 'OU=Autopilot,OU=CORP,DC=corp,DC=ajf8729,DC=com'
$ScriptIntervalInMinutes = 5
$ScriptName = $MyInvocation.MyCommand.Name
$LogFilePath = "C:\CORP\Logs\$ScriptName.log"

#Start Logging
Start-Transcript -Path $LogFilePath -Append

#Get Autopilot Computer Objects
$AutopilotComputers = Get-ADComputer -SearchBase $AutopilotOU -Filter * -Properties WhenCreated

#If new Autopilot computer object is found in Autopilot OU trigger Azure AD Connect sync
if ($AutopilotComputers.WhenCreated -gt (Get-Date).AddMinutes(-$ScriptIntervalInMinutes)) {
    Write-Host "New Computer Objects Detected in Autopilot OU ($AutopilotOU). Starting Azure AD Connect Sync."
    #Get Azure AD Connector's current sync state. If Azure AD Connector is already syncing then monitor syncing.
    $ADSyncScheduler = Get-ADSyncScheduler
    if ($ADSyncScheduler.SyncCycleInProgress -eq $True) {
        Write-Host 'Azure AD Connect sync already in progress, ignoring manual sync request.' -ForegroundColor Yellow
        Exit
    }

    #If Azure AD Connector is not already syncing, start sync.
    else {
        Start-ADSyncSyncCycle -PolicyType Delta
        Write-Host 'Syncing on-premises Active Directory changes to Azure Active Directory.' -ForegroundColor Green
        Start-Sleep 3

        #Wait for syncing to start
        Get-ADSyncScheduler
        while ($ADSyncScheduler.SyncCycleInProgress -ne $True) {
            Write-Host 'Starting Sync...'
            Start-Sleep 3
            Get-ADSyncScheduler
        }
    }

    #Monitor syncing status
    Get-ADSyncScheduler
    while ($ADSyncScheduler.SyncCycleInProgress -eq $True) {
        Write-Host 'Syncing...'
        Start-Sleep 3
        Get-ADSyncScheduler
    }
}
else {
    Write-Host "No New Computer Objects in Autopilot OU ($AutopilotOU). No Azure AD Connect Sync Required."
}

#Stop Logging
Stop-Transcript
