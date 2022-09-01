# Find undeployed required updates
Get-CMSoftwareUpdate -Fast | Where-Object {$_.NumMissing -ge 1 -and $_.IsDeployed -eq $false -and $_.IsSuperseded -eq $false} | Select-Object LocalizedDisplayName, LocalizedInformativeURL | Sort-Object LocalizedDisplayName | Format-Table -AutoSize
