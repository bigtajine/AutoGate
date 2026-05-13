# Build src/lin.xpl using Linux in Docker (Docker Desktop on Windows).
# Requires: Docker Engine running (Docker Desktop fully started).
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Get-DockerExe {
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if ($docker) { return $docker.Path }
    $alt = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"
    if (Test-Path $alt) { return $alt }
    return $null
}

function Start-DockerDesktopIfNeeded {
    $dd = @(
        "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $dd) { return }
    $running = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if (-not $running) {
        Write-Host "Starting Docker Desktop..."
        Start-Process $dd
    }
}

function Wait-DockerReady {
    param([string]$Exe, [int]$TimeoutSec = 180)
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        $p = Start-Process -FilePath $Exe -ArgumentList "info" -NoNewWindow -Wait -PassThru `
            -RedirectStandardOutput "$env:TEMP\docker-info-out.txt" `
            -RedirectStandardError "$env:TEMP\docker-info-err.txt"
        if ($p.ExitCode -eq 0) { return $true }
        Start-Sleep -Seconds 5
    }
    return $false
}

$exe = Get-DockerExe
if (-not $exe) {
    Write-Error "Docker not found. Install Docker Desktop, then re-run this script."
}

Start-DockerDesktopIfNeeded
Write-Host "Waiting for Docker engine (up to 3 min)..."
if (-not (Wait-DockerReady -Exe $exe -TimeoutSec 180)) {
    Write-Error @"
Docker engine is not responding. Fix Docker Desktop first, then re-run:

  1) Open Docker Desktop and wait until it says 'Engine running'.
  2) If it says 'Unable to start': enable virtualization in BIOS, install WSL 2
     (`wsl --install` in an admin prompt), reboot, then open Docker Desktop again.
  3) When `docker info` works in a terminal, run:

     powershell -File scripts\build-lin-xpl-docker.ps1
"@
}

Push-Location $root
try {
    $env:DOCKER_BUILDKIT = "1"
    $out = Join-Path $root "dist-lin"
    if (Test-Path $out) { Remove-Item -Recurse -Force $out }
    Write-Host "Building lin.xpl in container..."
    $p = Start-Process -FilePath $exe -ArgumentList @(
        "build", "-f", "Dockerfile.lin", "--target", "artifact",
        "--output", "type=local,dest=$out", "."
    ) -NoNewWindow -Wait -PassThru -WorkingDirectory $root `
        -RedirectStandardOutput "$env:TEMP\docker-build-out.txt" `
        -RedirectStandardError "$env:TEMP\docker-build-err.txt"
    if ($p.ExitCode -ne 0) {
        Get-Content "$env:TEMP\docker-build-err.txt" -ErrorAction SilentlyContinue | Write-Host
        throw "docker build failed ($($p.ExitCode))"
    }
    $built = Join-Path $out "lin.xpl"
    if (-not (Test-Path $built)) { throw "Missing $built" }
    Copy-Item -Force $built (Join-Path $root "src\lin.xpl")
    Write-Host "OK: $(Join-Path $root 'src\lin.xpl')"
} finally {
    Remove-Item Env:DOCKER_BUILDKIT -ErrorAction SilentlyContinue
    Pop-Location
}
