# Downloads X-Plane Plugin SDK 4.3.0 into repo root ./SDK if missing.
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$dest = Join-Path $root "SDK"
$marker = Join-Path $dest "CHeaders\XPLM\XPLMPlugin.h"
if (Test-Path $marker) {
    Write-Host "SDK already present: $dest"
    exit 0
}
$zipUrl = "https://developer.x-plane.com/wp-content/plugins/code-sample-generation/sdk_zip_files/XPSDK430.zip"
$zipPath = Join-Path $env:TEMP "XPSDK430.zip"
Write-Host "Downloading SDK..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
Write-Host "Extracting to $root ..."
Expand-Archive -Path $zipPath -DestinationPath $root -Force
if (-not (Test-Path $marker)) { throw "SDK extract failed: missing $marker" }
Write-Host "OK: $dest"
