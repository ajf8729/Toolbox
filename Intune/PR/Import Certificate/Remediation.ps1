# https://anthonyfontanez.com/index.php/2023/12/30/importing-certificates-with-remediations/

$Certificate = @'
-----BEGIN CERTIFICATE-----
MIIC7TCCAdWgAwIBAgIQbz8rVazRoKpPqOJB9x1uSTANBgkqhkiG9w0BAQsFADAm
MSQwIgYDVQQDExtXU1VTIFB1Ymxpc2hlcnMgU2VsZi1zaWduZWQwHhcNMjMwOTIx
MTk1NTMxWhcNMjgwOTE5MTk1NTMxWjAmMSQwIgYDVQQDExtXU1VTIFB1Ymxpc2hl
cnMgU2VsZi1zaWduZWQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDk
+9X8ZcheMK9dV2n0d9xdbaggGJOSaUEJtLHPZBvW4xaU4d1TuELHnMhxj+4JLpno
nimls14hXdJHYRK8BMoM4iKtNl4g0GlCAnv1hvpKBioP5qdXCo6lv+DneCjo2fWR
s7m5IRpXwfnD/P+3AbQP7/4yxcPIjqaKi00VRpRg1JqLkppDc9jLTP55arcyAVAq
meW5Oyanh9y5qZ6mgPK9NgygINUxqHI+9k6OogNZ1x1Jcajr5+T7K45mK7x22Hy6
eTE1YPWBtvlfGuFCP1RBTLxWvUJHxx8kVfPEoklfiy1dUZKBzRf/kmkEe+SnJ034
puk/Syf7VM0HOIexSMUNAgMBAAGjFzAVMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA0G
CSqGSIb3DQEBCwUAA4IBAQC3+7DXPf7taPZbarZig0IfH1zYeIbIr8ImsHU5E3QN
RZXxuFBuXQIUVLNsmigW2HntCDtwDKRi5lGEbvB5fe73gPLdyhEe6vgGmV3H2lYX
VxGr3ZAC9r/Fmk59RtB87iBwUlMxQuxb/mMQIMIAzEiNnuyORZ2Yfbd6ShNwyvUl
swcDodlB2iGCAZ6ktJBk9BiUevfO68LdeYzl4/OEulhzfD8hBzuT9rYF75yoFoNr
gIsli3kszJ62MnroDpkExx47igYIajoWb+/FI7VI242PErI0+3KbaICnd6U9BWA2
a8C5b8oE1zOEq14Y0oPaaiXkIQhAbqY2E+26o86rNi+w
-----END CERTIFICATE-----
'@
$Store = 'TrustedPublisher'
$Filename = (New-Guid).Guid
$Certificate | Out-File -FilePath "$env:TEMP\$Filename.cer"
Import-Certificate -FilePath "$env:TEMP\$Filename.cer" -CertStoreLocation "Cert:\LocalMachine\$Store" | Out-Null
Remove-Item -Path "$env:TEMP\$Filename.cer" -Force
