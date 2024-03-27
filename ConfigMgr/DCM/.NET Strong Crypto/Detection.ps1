$Compliant = $true

if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727\' -Name 'SchUseStrongCrypto') -ne 1) {$Compliant = $false}
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727\' -Name 'SystemDefaultTlsVersions') -ne 1) {$Compliant = $false}
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\' -Name 'SchUseStrongCrypto') -ne 1) {$Compliant = $false}
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions') -ne 1) {$Compliant = $false}
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727\' -Name 'SchUseStrongCrypto') -ne 1) {$Compliant = $false}
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727\' -Name 'SystemDefaultTlsVersions') -ne 1) {$Compliant = $false}
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SchUseStrongCrypto') -ne 1) {$Compliant = $false}
if ((Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions') -ne 1) {$Compliant = $false}

return $Compliant
