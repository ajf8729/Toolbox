Set ts = CreateObject("Microsoft.SMS.TSEnvironment")

Set objSysInfo = CreateObject("ADSystemInfo")
strComputerDN = objSysInfo.ComputerName

dim objGroup

Set objGroup = GetObject("LDAP://CN=OSD,OU=SCCM,OU=Groups,DC=ad,DC=domain,DC=tld")

if(objGroup.IsMember("LDAP://" & strComputerDN) = true) then
	objGroup.Remove("LDAP://" & strComputerDN)
end if
