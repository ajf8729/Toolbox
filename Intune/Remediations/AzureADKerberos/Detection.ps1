try {
    $CloudKerberosTicketRetrievalEnabled = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -Name CloudKerberosTicketRetrievalEnabled).CloudKerberosTicketRetrievalEnabled
    
    if ($CloudKerberosTicketRetrievalEnabled -eq 1) {
        Write-Output 'CloudKerberosTicketRetrievalEnabled is equal to 1'
        exit 0
    }
    else {
        Write-Output 'CloudKerberosTicketRetrievalEnabled is NOT equal to 1'
        exit 1
    }
}
catch {
    $LastError = $Error | Select-Object -First 1 -ExpandProperty Exception | Select-Object -ExpandProperty Message
    Write-Error -Message $LastError
    exit 1
}
