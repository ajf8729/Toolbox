$ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType

switch ($ProductType) {
    # Workstation
    1 {
        Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
    }
    # Domain Controller / Server
    {$_ -in 2, 3} {
        Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2
    }
}
