$Compliant = $true

if (Test-Path -Path 'Registry::HKEY_CLASSES_ROOT\ms-msdt') {
    $Compliant = $false
}

return $Compliant
