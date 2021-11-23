[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$SiteCode,
    [Parameter(Mandatory=$true)]
    [int]$ScriptExecutionTimeout
)

$CMAgent = Get-WmiObject -Namespace "root\sms\site_$SiteCode" -Class "SMS_SCI_ClientComp" | Where-Object -FilterScript {$_.ClientComponentName -eq 'Configuration Management Agent'}
$CMAgent.Get()
$Props = $CMAgent.Props

foreach ($Prop in $Props) {
    if ($Prop.PropertyName -eq "ScriptExecutionTimeout") {
        $Prop.Value = $ScriptExecutionTimeout
    }
}

$CMAgent.Props = $Props
$CMAgent.Put()
