# Sourced from https://msendpointmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.IO.FileInfo]$Path,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('ProductCode', 'ProductVersion', 'ProductName', 'Manufacturer', 'ProductLanguage', 'FullVersion')]
    [string]$Property
)

process {
    try {
        # Read property from MSI database
        $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
        $MSIDatabase = $WindowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $WindowsInstaller, @($Path.FullName, 0))
        $Query = "SELECT Value FROM Property WHERE Property = '$($Property)'"
        $View = $MSIDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $MSIDatabase, ($Query))
        $View.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $View, $null)
        $Record = $View.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $View, $null)
        $Value = $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 1)

        # Commit database and close view
        $MSIDatabase.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $MSIDatabase, $null)
        $View.GetType().InvokeMember('Close', 'InvokeMethod', $null, $View, $null)
        $MSIDatabase = $null
        $View = $null

        # Return the value
        return $Value
    }
    catch {
        Write-Warning -Message $_.Exception.Message
        break
    }
}
end {
    # Release ComObject and run garbage collection
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstaller) | Out-Null
    [System.GC]::Collect()
}
