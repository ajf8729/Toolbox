# Import the ConfigurationManager module
Import-Module -Name ConfigurationManager

# Get the site code
$SiteCode = (Get-CimInstance -Namespace ROOT/SMS -ClassName SMS_ProviderLocation).SiteCode

# Change to the site psdrive
Set-Location -Path "$($SiteCode):"

# Find the latest update
$LatestSiteUpdate = (Get-CMSiteUpdate -Fast | Sort-Object -Descending -Property LastUpdateTime | Select-Object -First 1).Name

# Install the update
Install-CMSiteUpdate -Name $LatestSiteUpdate -Confirm:$false -Force
