$TAK = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL2lkZW50aXR5L2NsYWltcy90ZW5hbnRpZCI6IjliMTlhNjY5LTQ3YWQtNDExYy04ZDllLTMzYWY1MWRhMGM4ZSIsImFwcGlkIjoiM2NmNmRmOTItMjc0NS00ZjZmLWJiY2YtMTliNTliY2RiNjJhIiwiaXNzIjoiSXNzdWVyIiwiYXVkIjoiQXVkaWVuY2UifQ._EmG_ns8KRWNef6EwRxTfZofndBq1UxmS7HKvaiKbtU'

try {
    $TenantAssociationKey = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Common\officesvcmanager' -Name TenantAssociationKey).TenantAssociationKey
    
    if ($TenantAssociationKey -eq $TAK) {
        Write-Output 'TenantAssociationKey is correct'
        exit 0
    }
    else {
        Write-Output 'TenantAssociationKey is NOT correct'
        exit 1
    }
}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Error -Message $LastError
    exit 1
}
