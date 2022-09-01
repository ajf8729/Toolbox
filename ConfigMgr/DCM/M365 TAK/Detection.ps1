$Compliant = $true

$TAK = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL2lkZW50aXR5L2NsYWltcy90ZW5hbnRpZCI6ImY5NGVjODRmLWJkOTUtNDg1Zi04ZTc1LWRmNjA2YmVjMmUzYyIsImFwcGlkIjoiM2NmNmRmOTItMjc0NS00ZjZmLWJiY2YtMTliNTliY2RiNjJhIiwiaXNzIjoiSXNzdWVyIiwiYXVkIjoiQXVkaWVuY2UifQ.kmE4iOZd6qQujZe-hNzuIV5oaEfO-Q5E5CL7dseCiL4'

$TenantAssociationKey = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officesvcmanager' -Name TenantAssociationKey).TenantAssociationKey
    
if ($TenantAssociationKey -ne $TAK) {
    $Compliant = $false
}

return $Compliant
