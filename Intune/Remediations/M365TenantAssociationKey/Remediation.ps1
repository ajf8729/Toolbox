$TAK = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL2lkZW50aXR5L2NsYWltcy90ZW5hbnRpZCI6IjliMTlhNjY5LTQ3YWQtNDExYy04ZDllLTMzYWY1MWRhMGM4ZSIsImFwcGlkIjoiM2NmNmRmOTItMjc0NS00ZjZmLWJiY2YtMTliNTliY2RiNjJhIiwiaXNzIjoiSXNzdWVyIiwiYXVkIjoiQXVkaWVuY2UifQ._EmG_ns8KRWNef6EwRxTfZofndBq1UxmS7HKvaiKbtU'
if (-not (Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officesvcmanager')) {
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officesvcmanager' -Force
}
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officesvcmanager' -Name 'TenantAssociationKey' -PropertyType String -Value $TAK -Force
Start-Process -FilePath "$env:CommonProgramFiles\microsoft shared\ClickToRun\officesvcmgr.exe" -ArgumentList '/checkin' -NoNewWindow
