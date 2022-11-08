Get-ADObject -Filter "objectClass -eq 'user'" -Properties msDS-SupportedEncryptionTypes |
    Where-Object -FilterScript {
        (($_."msDS-SupportedEncryptionTypes" -band 0x3f) -ne 0) -and
        (($_."msDS-SupportedEncryptionTypes" -band 0x38) -eq 0)
    }
