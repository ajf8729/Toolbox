try {
    Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManagers.psd1"
}
catch {
    Write-Warning -Message $_.Exception.Message
}
