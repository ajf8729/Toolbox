$UIResourceMgr = New-Object -ComObject 'UIResource.UIResourceMgr'
$Cache = $UIResourceMgr.GetCacheInfo()
$CacheElements = $Cache.GetCacheElements()

foreach ($CacheElement in $CacheElements) {
    $Cache.DeleteCacheElement($CacheElement.CacheElementID)
}
