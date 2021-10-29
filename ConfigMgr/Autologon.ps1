$TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment

$Username = $TSEnv.Value("Username")
$Domain   = $TSEnv.Value("Domain")
$Password = $TSEnv.Value("Password")

$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

Start-Process -FilePath "$($ScriptDirectory)\Autologon64.exe" -ArgumentList "/AcceptEula $Username $Domain $Password"
