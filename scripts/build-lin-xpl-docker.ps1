# Build src/lin.xpl using Linux in Docker (Docker Desktop on Windows).
# Requires: Docker with BuildKit (Docker Desktop enables this by default).
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    $alt = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"
    if (Test-Path $alt) { $docker = @{ Source = $alt } }
}
if (-not $docker) {
    Write-Error "Docker not found. Install Docker Desktop, then re-run this script."
}
$exe = if ($docker.Source) { $docker.Source } else { $docker.Path }
Push-Location $root
try {
    $env:DOCKER_BUILDKIT = "1"
    $out = Join-Path $root "dist-lin"
    if (Test-Path $out) { Remove-Item -Recurse -Force $out }
    & $exe build -f Dockerfile.lin --target artifact --output "type=local,dest=$out" .
    if ($LASTEXITCODE -ne 0) { throw "docker build failed ($LASTEXITCODE)" }
    $built = Join-Path $out "lin.xpl"
    if (-not (Test-Path $built)) { throw "Missing $built" }
    Copy-Item -Force $built (Join-Path $root "src\lin.xpl")
    Write-Host "Wrote: $(Join-Path $root 'src\lin.xpl')"
} finally {
    Remove-Item Env:DOCKER_BUILDKIT -ErrorAction SilentlyContinue
    Pop-Location
}
