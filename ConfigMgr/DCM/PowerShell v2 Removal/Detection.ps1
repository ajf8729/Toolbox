$Compliant = $true
$ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType

switch ($ProductType) {
    # Workstation
    1 {
        if (((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root).State -ne 'Disabled') -or ((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2).State -ne 'Disabled')) {
            $Compliant = $false
        }
    }
    # Domain Controller / Server
    {$_ -in 2, 3} {
        # Wildcard added to handle if value returned is 'DisabledWithPayloadRemoved'
        if ((Get-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2).State -notlike 'Disabled*') {
            $Compliant = $false
        }
    }
}

return $Compliant
