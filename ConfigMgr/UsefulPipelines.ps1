# Find undeployed required updates
Get-CMSoftwareUpdate -Fast | Where-Object {$_.NumMissing -ge 1 -and $_.IsDeployed -eq $false -and $_.IsSuperseded -eq $false} | Select-Object LocalizedDisplayName, LocalizedInformativeURL | Sort-Object LocalizedDisplayName | Format-Table -AutoSize
Get-CMSoftwareUpdate -IsDeployed $false -Fast | ?{$_.NumMissing -gt 0} | select LocalizedDisplayName,ArticleID,NumMissing

#Find which SMSProv being used
Get-NetTCPConnection -OwningProcess ((Get-Process -ProcessName Microsoft.ConfigurationManagement).Id)

#Get site update history
Get-CMSiteUpdateHistory | select Name,FullVersion,State,LastUpdateTime | sort FullVersion | ft -AutoSize

#Get all WSUS clients across multiple SUPs
'cmpsa01.corp.ajf.one','cmpsb01.corp.ajf.one' | %{Get-WsusComputer -UpdateServer (Get-WsusServer -Name $_ -PortNumber 8531 -UseSsl)} | select @{ Name = 'UpdateServer'; Expression = { $_.UpdateServer.Name }},FullDomainName, LastSyncTime | sort LastSyncTime -Descending
Get-CMSiteRole -RoleName "SMS Software Update Point" -AllSite | %{Get-WsusComputer -UpdateServer (Get-WsusServer -Name ($_.NetworkOSPath).TrimStart("\\") -PortNumber 8531 -UseSsl)} | ?{$_.LastSyncTime -gt (Get-Date).AddDays(-7)} | select @{ Name = 'UpdateServer'; Expression = { $_.UpdateServer.Name }} | Group-Object UpdateServer | select Name,Count | sort Name
