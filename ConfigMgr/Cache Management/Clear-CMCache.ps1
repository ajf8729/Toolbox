$CMObject = New-Object -ComObject "UIResource.UIResourceMgr"
$CMCacheObjects = $CMObject.GetCacheInfo()
$CMCacheElements = $CMCacheObjects.GetCacheElements()

foreach ($CacheElement in $CMCacheElements)
{
    $CMCacheObjects.DeleteCacheElementEx($CacheElement.CacheElementID)
}