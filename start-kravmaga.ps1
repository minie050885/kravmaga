# start-kravmaga.ps1
# Lance MySQL + phpMyAdmin + Laravel + Nuxt + VS Code + Chrome pour le projet Kravmaga

$projectPath = "C:\Users\Marie\Documents\nuxt\kravmaga"
$apiPath = Join-Path $projectPath "api"
$webPath = Join-Path $projectPath "web"
$dockerExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"

$laravelHost = "127.0.0.1"
$laravelPort = 9000

Write-Host ""
Write-Host "=== Kravmaga: start stack ===" -ForegroundColor Cyan
Write-Host ("Project: " + $projectPath)
Write-Host ""

# 1) Libérer les ports réservés (sans toucher à MySQL docker)
Write-Host "-> Freeing reserved ports..." -ForegroundColor Yellow

$portsToFree = @(3000, 9000, 9001)

$pidsToKill = @()
foreach ($port in $portsToFree) {
    $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    foreach ($conn in $connections) {
        if ($conn.OwningProcess -and ($pidsToKill -notcontains $conn.OwningProcess)) {
            $pidsToKill += $conn.OwningProcess
        }
    }
}

if ($pidsToKill.Count -eq 0) {
    Write-Host "   No process is listening on reserved ports." -ForegroundColor DarkGray
} else {
    foreach ($processId in $pidsToKill) {
        $proc = Get-Process -Id $processId -ErrorAction SilentlyContinue
        $procName = if ($proc) { $proc.ProcessName } else { "unknown" }
        Write-Host ("   Killing PID " + $processId + " (" + $procName + ")") -ForegroundColor Red
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 1
}

Write-Host ""

# 2) Docker Desktop
Write-Host "-> Checking Docker Desktop..." -ForegroundColor Yellow
if (-not (Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue)) {
    Write-Host "   Starting Docker Desktop..." -ForegroundColor Yellow
    Start-Process $dockerExe
}

# 3) Attendre que Docker soit prêt
Write-Host "-> Waiting for Docker daemon..." -ForegroundColor Yellow
$dockerReady = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        docker info > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            $dockerReady = $true
            break
        }
    } catch {}
    Start-Sleep -Seconds 1
}

if (-not $dockerReady) {
    Write-Host "Docker daemon not ready. Aborting." -ForegroundColor Red
    exit 1
}

# 4) Docker containers
Write-Host "-> Starting Docker containers..." -ForegroundColor Yellow
docker start kravmaga-mysql | Out-Null
docker start kravmaga-phpmyadmin | Out-Null

Write-Host "   MySQL:      127.0.0.1:3307"
Write-Host "   phpMyAdmin: http://localhost:9001/" -ForegroundColor Green
Write-Host ""

# 5) Ouvrir VS Code
Write-Host "-> Opening VS Code..." -ForegroundColor Yellow
Start-Process "code" -ArgumentList $projectPath

# Maximiser VS Code (le carré)
Start-Sleep -Seconds 2
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinApi {
  [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
}
"@

$codeProc = $null
for ($i = 0; $i -lt 20; $i++) {
    $codeProc = Get-Process -Name "Code" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($codeProc -and $codeProc.MainWindowHandle -ne 0) {
        break
    }
    Start-Sleep -Milliseconds 300
}

if ($codeProc -and $codeProc.MainWindowHandle -ne 0) {
    [WinApi]::ShowWindowAsync($codeProc.MainWindowHandle, 3) | Out-Null  # 3 = SW_MAXIMIZE
}

# 6) Laravel API (port 9000)
Write-Host "-> Starting Laravel API..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", ("cd " + $apiPath + "; php artisan serve --host=" + $laravelHost + " --port=" + $laravelPort)

# 7) Nuxt Web
Write-Host "-> Starting Nuxt web..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", ("cd " + $webPath + "; npm run dev")

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host ("Laravel: http://" + $laravelHost + ":" + $laravelPort) -ForegroundColor Green
Write-Host "Nuxt:    http://localhost:3000" -ForegroundColor Green
Write-Host "pMA:     http://localhost:9001" -ForegroundColor Green
Write-Host ""

# 8) Ouvre les onglets dans Chrome
Start-Sleep -Seconds 3
Start-Process "cmd.exe" -ArgumentList '/c start "" chrome http://localhost:3000/ http://127.0.0.1:9000/api/members http://localhost:9001/' -WindowStyle Hidden

