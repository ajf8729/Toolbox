$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment

$AutologonUsername = $TSEnv.Value("AutologonUsername")
$AutologonDomain   = $TSEnv.Value("AutologonDomain")
$AutologonPassword = $TSEnv.Value("AutologonPassword")

$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

Start-Process -FilePath "$($ScriptDirectory)\Autologon64.exe" -ArgumentList "/AcceptEula $AutologonUsername $AutologonDomain $AutologonPassword"
