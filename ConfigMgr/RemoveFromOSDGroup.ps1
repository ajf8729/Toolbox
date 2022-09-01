$ADGroup = 'OSD_Required'
$ADGroupObj = (([ADSISearcher]"(&(objectCategory=computer)(objectClass=computer)(cn=$env:ComputerName))").FindOne().Properties.memberof -match "CN=$ADGroup,")

if ($ADGroupObj -and $ADGroupObj.count -gt 0) {
    [ADSI]$Group = 'LDAP://CN=OSD_Required,OU=CM,OU=Groups,OU=ORG,DC=ad,DC=domain,DC=com'
    $Group.Remove(([ADSISearcher]"(&(objectCategory=computer)(objectClass=computer)(cn=$env:ComputerName))").FindOne().Path)
}
