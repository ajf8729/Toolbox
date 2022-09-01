$ScriptBlock = {
    param([string]$RoleName)
    $PortNumber = 443
    #Determine Port Number to use
    Switch ($RoleName) {
        'SMS Software Update Point' {$PortNumber = 8531; $SiteName = 'WSUS Administration'}
        Default {$PortNumber = 443; $SiteName = 'Default Web Site'}
    }
    $ValueChanged = $false
    #Make sure this matches our desired certificate name
    $templatename = 'SCCM IIS Certificate'
    #Source: https://stackoverflow.com/questions/43327855/identifying-certificate-by-certificate-template-name-in-powershell
    $Certificate = Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object { $_.Extensions | Where-Object { ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $templateName) }}
    #Check for our https binding on our port # and Site name.
    $HttpsBinding = Get-WebBinding -Protocol https -Port $PortNumber -Name $SiteName
    #If No binding, create a new binding
    if (!$HttpsBinding) {
        New-WebBinding -Protocol https -Port $PortNumber -IPAddress * -Name $SiteName
        $HttpsBinding = Get-WebBinding -Protocol https -Port $PortNumber -Name $SiteName
    }
    #If our certificate hash does not match our thumbprint, rebind it. 
    if ($HttpsBinding.certificateHash -ne $Certificate.Thumbprint) {
        $ValueChanged = $true
        $HttpsBinding.AddSslCertificate($Certificate.Thumbprint, 'my')
    }
    #Build a return object with the information we care about
    $ReturnObj = [pscustomobject]@{HTTPSBinding = $HttpsBinding
        RoleName                                = $RoleName
        Certificate                             = $Certificate
        ValueChanged                            = $ValueChanged
    }
    Return $ReturnObj
}
#Get all site systems with the specified roles; this allows us to handle port changes in our script block for SMS Software Update Points
$Computers = Get-CMSiteRole -AllSite | Where-Object {$_.RoleName -in @('SMS Management Point', 'SMS Distribution Point', 'SMS Software Update Point') -and $_.NALType -ne 'Windows Azure'} | Select-Object NetworkOSPath, RoleName
$Computers | ForEach-Object {
    $Computer = $_.NetworkOSPath
    $RoleName = $_.RoleName
    $Computer = ($Computer).Substring(2, $Computer.Length - 2)
    $Return = Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock -ArgumentList $RoleName
    if ($Return.ValueChanged -eq $true) {
        Write-Output ('Certificate value changed to ' + $Return.Certificate.Thumbprint + ' for ' + $Return.RoleName + ' on ' + $Return.PSComputerName)
    }
    else {
        Write-Output ('Correct Binding in use for ' + $Return.RoleName + ' on ' + $Return.PSComputerName)
    }
}
