# Build win.xpl with mingw (requires SDK; run fetch-sdk.ps1 first).
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$src = Join-Path $root "src"
$marker = Join-Path $root "SDK\CHeaders\XPLM\XPLMPlugin.h"
if (-not (Test-Path $marker)) {
    throw "Missing SDK. Run: powershell -File scripts/fetch-sdk.ps1"
}
$mingwBin = "C:\ProgramData\mingw64\mingw64\bin"
if (-not (Test-Path (Join-Path $mingwBin "mingw32-make.exe"))) {
    $mingwBin = $null
    foreach ($c in @("mingw32-make.exe", "x86_64-w64-mingw32-gcc.exe")) {
        $g = Get-Command $c -ErrorAction SilentlyContinue
        if ($g) { $mingwBin = Split-Path $g.Source -Parent; break }
    }
}
if (-not $mingwBin) { throw "mingw32-make / x86_64-w64-mingw32-gcc not found in PATH or C:\ProgramData\mingw64\mingw64\bin" }
$env:Path = "$mingwBin;$env:Path"
Push-Location $src
try {
    & mingw32-make.exe -f Makefile.mgw64 SDK=../SDK NO_OPENAL=1
    if ($LASTEXITCODE -ne 0) { throw "make failed with $LASTEXITCODE" }
    $out = Join-Path $src "win.xpl"
    if (-not (Test-Path $out)) { throw "Expected output missing: $out" }
    Write-Host "Built: $out"
} finally {
    Pop-Location
}
