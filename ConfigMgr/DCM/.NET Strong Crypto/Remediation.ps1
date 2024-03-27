New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727\' -Name 'SchUseStrongCrypto' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727\' -Name 'SystemDefaultTlsVersions' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\' -Name 'SchUseStrongCrypto' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727\' -Name 'SchUseStrongCrypto' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727\' -Name 'SystemDefaultTlsVersions' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SchUseStrongCrypto' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions' -PropertyType DWord -Value 1 -Force | Out-Null
