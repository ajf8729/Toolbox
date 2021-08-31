[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$ContentRootPath,
    [Parameter(Mandatory=$true)]
    [string]$InstallScriptFilename,
    [Parameter(Mandatory=$true)]
    [string]$UserCollectionTest,
    [Parameter(Mandatory=$true)]
    [string]$SiteCode,
    [Parameter(Mandatory=$true)]
    [string]$UserLimitingCollectionId,
    [Parameter(Mandatory=$true)]
    [string]$DeviceLimitingCollectionId,
    [Parameter(Mandatory=$true)]
    [ValidateSet(
        'EXE',
        'MSI'
    )]
    [string]$Type,
    [Parameter(Mandatory=$true)]
    [string]$Publisher,
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$true)]
    [ValidateSet(
        'x64',
        'x86'
    )]
    [string]$Architecture,
    [Parameter(Mandatory=$false)]
    [string]$RegKeyName,
    [Parameter(Mandatory=$false)]
    [boolean]$RegKeyContainsVersion,
    [Parameter(Mandatory=$false)]
    [boolean]$Is64bit,
    [Parameter(Mandatory=$true)]
    [int]$EstimatedRuntimeMins,
    [Parameter(Mandatory=$true)]
    [int]$MaximumRuntimeMins,
    [Parameter(Mandatory=$true)]
    [string]$DPGroupName,
    [Parameter(Mandatory=$true)]
    [boolean]$IsFreeApp
)

function New-DetectionScript {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$RegistryKey,
        [Parameter(Mandatory=$true)]
        [string]$Version,
        [Parameter(Mandatory=$true)]
        [boolean]$Is64bit
    )
    
$DetectionScriptText64BitString = @"
if (Test-Path -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$RegistryKey" -ErrorAction Ignore) {
`$AppVersion = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$RegistryKey' -Name DisplayVersion -ErrorAction Ignore | Select-Object -ExpandProperty DisplayVersion | Sort-Object -Property DisplayVersion | Select-Object -First 1
if (`$AppVersion -ge "$Version") {
Write-Host "Installed"
}
else {
}
}
else {
}
"@

$DetectionScriptText64BitVersion = @"
if (Test-Path -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$RegistryKey" -ErrorAction Ignore) {
`$AppVersion = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$RegistryKey' -Name DisplayVersion -ErrorAction Ignore | Select-Object -ExpandProperty DisplayVersion | Sort-Object -Property DisplayVersion | Select-Object -First 1
if ([System.Version]`$AppVersion -ge [System.Version]"$Version") {
Write-Host "Installed"
}
else {
}
}
else {
}
"@

$DetectionScriptText32BitString = @"
if (Test-Path -Path "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$RegistryKey" -ErrorAction Ignore) {
`$AppVersion = Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$RegistryKey' -Name DisplayVersion -ErrorAction Ignore | Select-Object -ExpandProperty DisplayVersion | Sort-Object -Property DisplayVersion | Select-Object -First 1
if (`$AppVersion -ge "$Version") {
Write-Host "Installed"
}
else {
}
}
else {
}
"@

$DetectionScriptText32BitVersion = @"
if (Test-Path -Path "HKLM:SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$RegistryKey" -ErrorAction Ignore) {
`$AppVersion = Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$RegistryKey' -Name DisplayVersion -ErrorAction Ignore | Select-Object -ExpandProperty DisplayVersion | Sort-Object -Property DisplayVersion | Select-Object -First 1
if ([System.Version]`$AppVersion -ge [System.Version]"$Version") {
Write-Host "Installed"
}
else {
}
}
else {
}
"@
    
    if ($Version -like "*_*" -or $Version -like "*-*") {
        if ($Is64Bit) {
            return $DetectionScriptText64BitString
        }
        else {
            return $DetectionScriptText32BitString
        }
    }
    else {
        if ($Is64Bit) {
            return $DetectionScriptText64BitVersion
        }
        else {
            return $DetectionScriptText32BitVersion
        }
    }
}

function Test-PSADT {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    if (Test-Path -Path "$Path\AppDeployToolkit") {
        return $true
    }
    else {
        return $false
    }
}

function New-AppCollections {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AppName,
        [Parameter(Mandatory=$false)]
        [switch]$IsFreeApp
    )
    
    $UserCollectionName   = "$($AppName) (Available)"
    $DeviceCollectionName = "$($AppName) (Required)"
    $RefreshSchedule = New-CMSchedule -RecurInterval Hours -RecurCount 1

    if (-not (Test-Path -Path ".\UserCollection\Application")) {
        New-Item -Path ".\UserCollection\" -Name "Application" -ItemType Folder
    }

    if (-not (Test-Path -Path ".\DeviceCollection\Application")) {
        New-Item -Path ".\DeviceCollection\" -Name "Application" -ItemType Folder
    }
    
    if (-not $IsFreeApp) {
        if (-not (Get-CMCollection -CollectionType User -Name $UserCollectionName)) {
            $UserCollection = New-CMCollection -CollectionType User -Name $UserCollectionName -LimitingCollectionId $UserLimitingCollectionId -RefreshSchedule $RefreshSchedule -RefreshType Periodic
            Move-CMObject -InputObject ($UserCollection) -FolderPath ".\UserCollection\Application"
        }
        else {
            Write-Error -Message "User collection ""$UserCollectionName"" already exists"
            break
        }
    }
    
    if (-not (Get-CMCollection -CollectionType Device -Name $DeviceCollectionName)) {
        $DeviceCollection = New-CMCollection -CollectionType Device -Name $DeviceCollectionName -LimitingCollectionId $DeviceLimitingCollectionId -RefreshSchedule $RefreshSchedule -RefreshType Periodic
        Move-CMObject -InputObject ($DeviceCollection) -FolderPath ".\DeviceCollection\Application"
    }
    else {
        Write-Error -Message "Device collection ""$DeviceCollectionName"" already exists"
        break
    }
}

if ($IsFreeApp) {
    $UserCollectionProd = "All Users"
}
else {
    $UserCollectionProd = "$($Name) (Available)"
}
$DeviceCollectionProd = "$($Name) (Required)"

$AppPath = "$ContentRootPath\$Name"

if (Test-Path -Path "$AppPath\icon.png") {
    $IconPath = "$AppPath\icon.png"
}
else {
    Write-Error -Message "Icon path not found"
    break
}

$Version = (Get-ChildItem -Path "$AppPath" -Directory | Sort-Object -Descending Name | Select-Object -First 1 | Select-Object -ExpandProperty Name)
$AppName = "$Name $Version"
$ContentLocation = "$AppPath\$Version\$Architecture"
$DeploymentTypeName = "$Name $Version $Architecture"

switch ($Type) {
    "EXE" {
        if ($RegItemContainsVersion) {
            $DetectionScriptText = New-DetectionScript -RegistryKey "$RegKeyName $Version" -Version $Version -Is64bit $Is64bit
        }
        else {
            $DetectionScriptText = New-DetectionScript -RegistryKey $RegKeyName -Version $Version -Is64bit $Is64bit
        }
    }
    "MSI" {    
        $MsiPath = "$AppPath\$Version\$Architecture"
    
        if (Test-PSADT -Path $MsiPath) {
            $MsiFilename = (Get-ChildItem -Path "$MsiPath\Files\*.msi" | Sort-Object -Descending Name | Select-Object -First 1 | Select-Object -ExpandProperty Name)
        }
        else {
            $MsiFilename = (Get-ChildItem -Path "$MsiPath\*.msi" | Sort-Object -Descending Name | Select-Object -First 1 | Select-Object -ExpandProperty Name)
        }

        if (Test-PSADT -Path $ContentLocation) {
            [string]$MsiProductCode = Get-CMAPMsiProductCode -Path "$ContentLocation\Files\$MsiFilename"
        }
        else {
            [string]$MsiProductCode = Get-CMAPMsiProductCode -Path "$ContentLocation\$MsiFilename"
        }
    }
}

Set-Location -Path "$($SiteCode):"

if (Get-CMApplication -Name $AppName) {
    Write-Error -Message "Application '$AppName' already exists"
    Set-Location -Path $env:SystemDrive
    break
}

$UserCollection = Get-CMCollection -CollectionType User -Name $UserCollectionProd
$DeviceCollection = Get-CMCollection -CollectionType Device -Name $DeviceCollectionProd

if ( ($null -eq $UserCollection) -or ($null -eq $DeviceCollection) ) {
    if ($IsFreeApp) {
        New-AppCollections -AppName $Name -IsFreeApp
    }
    else {
        New-AppCollections -AppName $Name
    }
}

New-CMApplication -Name $AppName -LocalizedName $Name -SoftwareVersion $Version -IconLocationFile $IconPath -ReleaseDate (Get-Date -Format yyyy-MM-dd) | Out-Null
Set-CMApplication -Name $AppName -SoftwareVersion $Version -Publisher $Publisher | Out-Null

switch ($Type) {
    "EXE" {
        Add-CMScriptDeploymentType -ApplicationName $AppName -DeploymentTypeName $DeploymentTypeName -InstallCommand $InstallScriptFilename -ScriptLanguage PowerShell -ScriptText $DetectionScriptText -ContentLocation $ContentLocation -EstimatedRuntimeMins $EstimatedRuntimeMins -MaximumRuntimeMins $MaximumRuntimeMins -LogonRequirementType WhetherOrNotUserLoggedOn -UserInteractionMode Hidden -InstallationBehaviorType InstallForSystem -ContentFallback -SlowNetworkDeploymentMode Download | Out-Null
        New-CMApplicationDeployment -Name $AppName -CollectionName $UserCollectionProd -DeployAction Install -DeployPurpose Available -DistributeContent -DistributionPointGroupName $DPGroup | Out-Null
        New-CMApplicationDeployment -Name $AppName -CollectionName $DeviceCollectionProd -DeployAction Install -DeployPurpose Required -OverrideServiceWindow $false -RebootOutsideServiceWindow $false -UserNotification DisplaySoftwareCenterOnly | Out-Null
    }
    "MSI" {
        Add-CMScriptDeploymentType -ApplicationName $AppName -DeploymentTypeName $DeploymentTypeName -InstallCommand $InstallScriptFilename -ProductCode $MsiProductCode.Trim() -ContentLocation $ContentLocation -EstimatedRuntimeMins $EstimatedRuntimeMins -MaximumRuntimeMins $MaximumRuntimeMins -LogonRequirementType WhetherOrNotUserLoggedOn -UserInteractionMode Hidden -InstallationBehaviorType InstallForSystem -ContentFallback -SlowNetworkDeploymentMode Download | Out-Null
        New-CMApplicationDeployment -Name $AppName -CollectionName $UserCollectionProd -DeployAction Install -DeployPurpose Available -DistributeContent -DistributionPointGroupName $DPGroup | Out-Null
        New-CMApplicationDeployment -Name $AppName -CollectionName $DeviceCollectionProd -DeployAction Install -DeployPurpose Required -OverrideServiceWindow $false -RebootOutsideServiceWindow $false -UserNotification DisplaySoftwareCenterOnly | Out-Null
    }
}

Set-Location -Path $env:SystemDrive
