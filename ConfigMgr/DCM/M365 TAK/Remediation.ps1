$TAK = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL2lkZW50aXR5L2NsYWltcy90ZW5hbnRpZCI6ImY5NGVjODRmLWJkOTUtNDg1Zi04ZTc1LWRmNjA2YmVjMmUzYyIsImFwcGlkIjoiM2NmNmRmOTItMjc0NS00ZjZmLWJiY2YtMTliNTliY2RiNjJhIiwiaXNzIjoiSXNzdWVyIiwiYXVkIjoiQXVkaWVuY2UifQ.kmE4iOZd6qQujZe-hNzuIV5oaEfO-Q5E5CL7dseCiL4'

if ( -not ( Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officesvcmanager' ) ) {
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officesvcmanager' -Force
}

New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officesvcmanager' -Name 'TenantAssociationKey' -PropertyType String -Value $TAK -Force

Start-Process -FilePath "$env:CommonProgramFiles\microsoft shared\ClickToRun\officesvcmgr.exe" -ArgumentList '/checkin' -NoNewWindow
