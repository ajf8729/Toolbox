#######################################################################################################################
# SCCM2012SP1-RemoveDuplicateSSRSReports.ps1
# This script will connect to SSRS on a specified server and delete all reports that begin with a double underscore
# Used for SSRS cleanup after SCCM 2012 SP1 installation
# Script must be run from an account that has access to modify the SSRS instance
# 2/15/2013 - Mike Laughlin
#
# Resources used in writing this script:
# Starting point: http://stackoverflow.com/questions/9178685/change-datasource-of-ssrs-report-with-powershell
# API Documentation: http://msdn.microsoft.com/en-us/library/ms165967%28v=sql.90%29.aspx
#######################################################################################################################

# Define variables

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SiteCode,
    [Parameter(Mandatory = $true)]
    [string]$serverName
)

# Set the value of $noConfirm to $True only if you don't want to manually confirm report deletion. Use with caution.
$noConfirm = $False

# Safeguard	
If ( $SiteCode -eq '' -or $serverName -eq '' ) { Write-Host 'Enter the required information for the SiteCode and serverName variables before running this script.' -ForegroundColor Red -BackgroundColor Black ; Exit }

# Connect to SSRS
$ssrs = New-WebServiceProxy -Uri http://$serverName/ReportServer/ReportService2005.asmx?WSDL -UseDefaultCredential

# Get a listing of all reports in SSRS
$reportFolder = '/ConfigMgr_' + $SiteCode
$reports = $ssrs.ListChildren($reportFolder, $True)

# Find all reports starting with double underscores
$reportsToDelete = $reports | Where-Object { $_.Name.Substring(0, 2) -eq '__' }

# Quit if no reports are found
If ( $reportsToDelete.Count -eq 0 ) { Write-Host 'No reports found. Quitting.' ; Exit }

# Show a listing of the reports that will be deleted
Write-Host 'The following reports will be deleted from SSRS on' $serverName":`n"
$reportsToDelete.Name
Write-Host "`nTotal number of reports to delete:" $reportsToDelete.Count "`n"

# Get confirmation before deleting if $noConfirm has not been changed
If ( $noConfirm -eq $False ) { 
    $userConfirmation = Read-Host 'Delete these reports from' $serverName"? Enter Y or N"
    If ( $userConfirmation.ToUpper() -ne 'Y' ) { Write-Host 'Quitting, reports have not been deleted.' ; Exit }
}

# Delete the reports
$deletedReportCount = 0

Write-Host 'Beginning to delete reports now. Please wait.'
ForEach ( $report in $reportsToDelete ) { $ssrs.DeleteItem($report.Path) ; $deletedReportCount++ } 
Write-Host 'Reports have been deleted. Total number of deleted reports:' $deletedReportCount
