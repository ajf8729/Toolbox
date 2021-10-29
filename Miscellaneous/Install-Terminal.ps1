$releases = Invoke-WebRequest -Uri "https://api.github.com/repos/microsoft/terminal/releases" -UseBasicParsing
$latest = ((($releases | ConvertFrom-Json) | Where-Object -FilterScript {$_.name -notlike "*Preview*"})[0]).assets[0]
$browser_download_url = $latest.browser_download_url
$name = $latest.name

Invoke-WebRequest -Uri $browser_download_url -OutFile $env:TEMP\$name -UseBasicParsing

Add-AppxPackage -Path $env:TEMP\$name