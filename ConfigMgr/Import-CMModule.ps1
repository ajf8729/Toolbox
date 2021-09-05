if (Test-Path -Path "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1") {
    Import-Module -FullyQualifiedName "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManagers.psd1"
}
else {
    Write-Warning -Message $_.Exception.Message
}
