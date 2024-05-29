# Find undeployed required updates
Get-CMSoftwareUpdate -Fast | Where-Object {$_.NumMissing -ge 1 -and $_.IsDeployed -eq $false -and $_.IsSuperseded -eq $false} | Select-Object LocalizedDisplayName, LocalizedInformativeURL | Sort-Object LocalizedDisplayName | Format-Table -AutoSize
Get-CMSoftwareUpdate -IsDeployed $false -Fast | Where-Object {$_.NumMissing -gt 0} | Select-Object LocalizedDisplayName, ArticleID, NumMissing

#Find which SMSProv being used
Resolve-DnsName -Name (Get-NetTCPConnection -OwningProcess ((Get-Process -ProcessName Microsoft.ConfigurationManagement).Id) | Where-Object -FilterScript {$_.RemotePort -eq 443} | Select-Object -Unique RemoteAddress | Select-Object -ExpandProperty RemoteAddress) | Select-Object NameHost

#Get site update history
Get-CMSiteUpdateHistory | Select-Object Name, FullVersion, State, LastUpdateTime | Sort-Object FullVersion | Format-Table -AutoSize

#Get all WSUS clients across multiple SUPs
'cmpsa01.corp.ajf.one', 'cmpsb01.corp.ajf.one' | ForEach-Object {Get-WsusComputer -UpdateServer (Get-WsusServer -Name $_ -PortNumber 8531 -UseSsl)} | Select-Object @{ Name = 'UpdateServer'; Expression = { $_.UpdateServer.Name }}, FullDomainName, LastSyncTime | Sort-Object LastSyncTime -Descending
Get-CMSiteRole -RoleName 'SMS Software Update Point' -AllSite | ForEach-Object {Get-WsusComputer -UpdateServer (Get-WsusServer -Name ($_.NetworkOSPath).TrimStart('\\') -PortNumber 8531 -UseSsl)} | Where-Object {$_.LastSyncTime -gt (Get-Date).AddDays(-7)} | Select-Object @{ Name = 'UpdateServer'; Expression = { $_.UpdateServer.Name }} | Group-Object UpdateServer | Select-Object Name, Count | Sort-Object Name

#Reset policy
Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -Name ResetPolicy -ArgumentList '1'
Invoke-CimMethod -Namespace root/ccm -ClassName SMS_Client -Name ResetPolicy -Arguments @{uFlags = [UInt32]1}

#Inbox/Outbox stats
Get-ChildItem 'E:\SCCM2012\inboxes' -Recurse | Where-Object {!$_.PSIsContainer} | Group-Object Directory | Format-Table Name, Count -AutoSize
Get-ChildItem 'F:\SMS\MP' -Recurse | Where-Object {!$_.PSIsContainer} | Group-Object Directory | Format-Table Name, Count -AutoSize

#Get client MPs in use
#Assigned MP
Get-CimInstance -Namespace root/ccm -ClassName SMS_LookupMP
#Resident MP
Get-CimInstance -Namespace root/ccm -ClassName SMS_LocalMP

#Convert ESD to WIM
Get-WindowsImage -ImagePath .\install.esd | Select-Object ImageIndex, ImageName | Format-Table -AutoSize
Export-WindowsImage -SourceImagePath .\install.esd -SourceIndex 6 -DestinationImagePath .\install.wim -CompressionType Maximum -CheckIntegrity

#Create port listener
$Listener = [System.Net.Sockets.TcpListener]3343;
$Listener.Start();

$endpoint = New-Object System.Net.IPEndpoint([ipaddress]'172.20.0.55', 1433)
$listener = New-Object System.Net.Sockets.TcpListener $endpoint
$listener.start()

#Update boot WIM
Mount-WindowsImage -Path 'B:\Boot Mount Temp\' -ImagePath 'F:\ADK\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\en-us\winpe.wim' -Index 1
Add-WindowsPackage -PackagePath 'B:\Boot Image Patches\windows11.0-kb5034123-x64_d82c9af459245e90b5bf897f15a72cf810819f31.msu' -Path 'B:\Boot Mount Temp\' -Verbose
Save-WindowsImage -Path 'B:\Boot Mount Temp\' -CheckIntegrity -Verbose
Dismount-WindowsImage -Path 'B:\Boot Mount Temp\' -Save -CheckIntegrity -Verbose

#Offline servicing OS IM
Mount-WindowsImage -Path B:\ImageMountTemp\ -ImagePath G:\Shares\Content\WIM\W11_22H2\install-6-Windows-11-Pro.wim -Index 1 -Verbose
Add-WindowsPackage -Path B:\ImageMountTemp\ -PackagePath B:\ImagePatches\windows11.0-kb5034123-x64_d82c9af459245e90b5bf897f15a72cf810819f31.msu -Verbose
Add-WindowsPackage -Path B:\ImageMountTemp\ -PackagePath B:\ImagePatches\windows11.0-kb5033920-x64-ndp481_b171658bdaca6fe0af3550a48f691d4ceb4ee0d3.msu -Verbose
Dismount-WindowsImage -Path B:\ImageMountTemp\ -Save -CheckIntegrity -Verbose
Export-WindowsImage -SourceImagePath .\install-6-Windows-11-Pro.wim -SourceIndex 1 -DestinationImagePath new.wim -CompressionType Maximum -Verbose

#Check volume block size
Get-CimInstance -ClassName Win32_Volume | Select-Object Label, BlockSize | Format-Table -AutoSize

#Remotely check IIS cert bindings
'MP1', 'MP2', 'MPetc...' | ForEach-Object {
    Invoke-Command -ScriptBlock {
        Get-Item Cert:\LocalMachine\My\$(
            Get-ChildItem IIS:\SslBindings\0.0.0.0!443 | Select-Object -ExpandProperty Thumbprint
        ) | Select-Object Subject, Issuer
    }
}

#Test WSUS via URL
Invoke-WebRequest -Uri http://cmcasaux01.corp.ad.ajf8729.net:8530/ClientWebService/client.asmx

#ACP info
Get-CimInstance -Namespace root/ccm/Policy/Machine/ActualConfig -ClassName CCM_DownloadProvider

#Get Folder Size
(Get-ChildItem -Path G:\SCCMContentLib\ -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB

#Get collections for a device
(Get-CimInstance -Namespace root/SMS/site_PS1 -Query "SELECT SMS_Collection.* FROM SMS_FullCollectionMembership, SMS_Collection where name = 'CM01' and SMS_FullCollectionMembership.CollectionID = SMS_Collection.CollectionID").Name

#Get MWs locally
Get-CimInstance -Namespace root/ccm/ClientSDK -ClassName CCM_ServiceWindow | Where-Object -FilterScript {$_.Type -ne 6}
