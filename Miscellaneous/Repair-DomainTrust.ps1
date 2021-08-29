if (-Not (Test-ComputerSecureChannel)) {
	Test-ComputerSecureChannel -Repair -Verbose -Credential (Get-Credential)
}