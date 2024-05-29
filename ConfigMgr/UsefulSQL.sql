--DRS health checks
select * from Sites
select * from ServerData
select * from RCM_DrsInitializationTracking where InitializationStatus not in (6,7)
select * from RCM_DrsInitializationTracking where SiteRequesting = 'PSA' order by InitializationPercent
select * from RCM_ReplicationLinkStatus where SnapshotApplied<>1
select * from DrsSendHistory where ProcessedTime IS NULL
select * from sys.transmission_queue
select * from sys.transmission_queue order by enqueue_time asc

--Repl groups and tables included
select * from v_ReplicationData
select * from ArticleData where ReplicationID = X
select id from v_ReplicationData where ReplicationGroup = 'Event Results'
select * from ArticleData where ReplicationID = (select id from v_ReplicationData where ReplicationGroup = 'Event Results')

--Reset DRS ProcessedTime to EndTime
select * from DrsSendHistory where ProcessedTime IS NULL
update DrsSendHistory set ProcessedTime = EndTime, SyncCompleteTime = EndTime where ProcessedTime is NULL and TargetSite = 'PS1'

--Broker endpoint perms
GRANT CONNECT ON ENDPOINT::ConfigMgrEndpoint TO public;

--SPs
exec spdiagmessagesinqueue;
exec spdiagdrs;
exec spdiaggetspaceused;

--Indexing
select distinct sch.name + '.'+ OBJECT_NAME(stat.object_id), ind.name, convert(int,stat.avg_fragmentation_in_percent) as Fragmentation_percent
from sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'LIMITED') stat
join sys.indexes ind on
stat.object_id=ind.object_id and stat.index_id=ind.index_id
join sys.objects obj on obj.object_id=stat.object_id
join sys.schemas sch on obj.schema_id=sch.schema_id
where ind.name is not null and stat.avg_fragmentation_in_percent > 10.0 and ind.type > 0
order By convert(int,stat.avg_fragmentation_in_percent) desc

exec sp_MSForEachtable 'DBCC DBREINDEX ("?")'
Go

exec sp_MSForEachTable 'UPDATE STATISTICS ? WITH FULLSCAN'
go

--Finding old inventoried software
select * from v_LifecycleDetectedGroups

select GroupName,MainstreamSupportEndDateAsDate,ExtendedSupportEndDateAsDate,InstallCount from v_LifecycleDetectedGroups

select * from vSMS_CombinedDeviceResources AS cdr INNER JOIN v_LifecycleDetectedResourceIdsByGroupName AS life ON cdr.MachineID = life.ResourceID

select Name,SiteCode,Domain,IsClient,IsObsolete,IsActive,LastClientCheckTime,LastStatusMessage,LastActiveTime,GroupName
from vSMS_CombinedDeviceResources AS cdr INNER JOIN v_LifecycleDetectedResourceIdsByGroupName AS life ON cdr.MachineID = life.ResourceID
where GroupName = 'Windows Server 2012 R2'

--Content source locations
select * from v_ContentInfo where ContentSource is not null

--Clean up old stale client operations
select * from vSMS_ClientOperation order by requestedtime desc
--get top value for the next id, stop the obj repl mgr component, delete opa files in objmgr inbox, then run the sp, then start the component
EXEC spAoSetComponentRuntimeValue @component=N'SMS_OBJECT_REPLICATION_MANAGER', @scenarioId=1, @scenarioKey=N'Client Operation', @strvalue=N'0x0000000000843E10'

--fix stuck init after site db move
SELECT * FROM Rcm_recoverytracking where RecoveryStatus <> 9 
UPDATE RCM_Drsinitializationtracking set initializationstatus=4  where InitializationStatus not in (6,7)

--get SQL version, MAXDOP, and memory config
SELECT @@version
SELECT name,value,value_in_use FROM sys.configurations WHERE name in ('max degree of parallelism','min server memory (MB)','max server memory (MB)')

--end conversation
end conversation '<Conversation_Handle>' with cleanup

--site updates
select * from CM_UpdatePackages order by DateReleased desc

--MWs
select c.collectionid,c.name,s.name,s.servicewindowtype from v_collection c join v_servicewindow s on c.collectionid = s.collectionid

--clean up builtin objects from uninstalled sites
SELECT * FROM UnknownSystem_DISC WHERE SiteCode0 = 'PSB'
SELECT * FROM ProvisioningSystem_DISC WHERE SiteCode0 = 'PSB'
DELETE FROM UnknownSystem_DISC WHERE SiteCode0 = 'PSB'
DELETE FROM ProvisioningSystem_DISC WHERE SiteCode0 = 'PSB'

--test Kerberos
SELECT auth_scheme FROM sys.dm_exec_connections WHERE session_id = @@SPID

--find blocking sessions
exec sp_whoisactive @find_block_leaders = 1, @sort_order = '[blocked_session_count] DESC'

--find device by ip address
select distinct
A.Name0,c.IPAddress0,
D.IP_Subnets0
from v_R_System A
inner join v_FullCollectionMembership B on A.ResourceID=B.ResourceID
Inner join v_GS_NETWORK_ADAPTER_CONFIGUR C ON A.ResourceID=C.ResourceID
Inner Join v_RA_System_IPSubnets D ON A.ResourceID=D.ResourceID
where c.IPAddress0 like '%172.20.0.51%'

--Cloud Collection Sync device status
select distinct CK.ApprovalStatus, CK.AADDeviceID, CG.AADGroupID, CG.CloudServiceID, * 
FROM CollectionAADGroupMapping AS CG
join CollectionMembers c on CG.CollectionSiteID=c.SiteID
join System_DISC SD on SD.ItemKey = c.MachineID  
join ClientKeyData CK on CK.SMSID = SD.SMS_Unique_Identifier0

--Devices not in a BG
SELECT 
    CD.[MachineID],
    CD.[BoundaryGroups],
    Subquery.Name0,
    LEFT(Subquery.IpAddress0, CHARINDEX(',', Subquery.IpAddress0 + ',') - 1) AS IpAddress
FROM v_CombinedDeviceResources CD
JOIN (
    SELECT DISTINCT
        SD.ResourceId,
        SD.Name0,
        IP.IpAddress0
    FROM v_Gs_System SD
    JOIN v_Gs_Network_Adapter_Configur IP ON SD.ResourceId = IP.ResourceId
    WHERE IP.DefaultIPGateway0 IS NOT NULL
        AND IP.IPAddress0 IS NOT NULL
        AND IP.IPAddress0 <> '0.0.0.0'
        AND IP.IpAddress0 LIKE '[0-9]%.[0-9]%.[0-9]%.[0-9]%'
) AS Subquery ON CD.MachineID = Subquery.ResourceId
WHERE CD.BoundaryGroups IS NULL AND CD.CNIsOnInternet <> 1
ORDER BY Subquery.IpAddress0

--cloud collection sync troubleshooting
select ResourceID,Name0,AADDeviceID,AADTenantID from v_R_System
where Client0 = 1
and AADDeviceID is null
and ResourceID in (select ResourceID from v_FullCollectionMembership where CollectionID = N'SMS000KM')

--Autopilot hashes
select S.Name0, B.SerialNumber0, M.DeviceHardwareData0
from v_R_System S join v_GS_PC_BIOS B on S.ResourceID = B.ResourceID
join v_GS_MDM_DEVDETAIL_EXT01 M on B.ResourceID = M.ResourceID

--find device based on IP
SELECT IP.ResourceID, S.Name0 As 'Name', IP.IP_Addresses0 As 'IP Addresses'
FROM v_RA_System_IPAddresses IP INNER JOIN v_R_System S ON IP.ResourceID = S.ResourceID
WHERE IP.IP_Addresses0 like '%172.20.0.21%'

--find collection variables
select C.CollectionID as 'Collection ID',
	C.Name as 'Collection Name',
	V.Name as 'Variable Name',
	V.IsMasked as 'Masked',
	V.Value as 'Variable Value'
from v_Collection C
	join v_CollectionVariable V
		on C.CollectionID = V.CollectionID

--get resource id ranges
select dbo.fnGetSiteRangeStart()
select dbo.fnGetSiteRangeEnd()
