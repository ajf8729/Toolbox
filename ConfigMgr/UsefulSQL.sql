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
