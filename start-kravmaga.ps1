# start-kravmaga.ps1
# Lance MySQL + phpMyAdmin + Laravel + Nuxt pour le projet Kravmaga

$projectPath = "C:\Users\Marie\Documents\nuxt\kravmaga"
$apiPath = Join-Path $projectPath "api"
$webPath = Join-Path $projectPath "web"

Write-Host ""
Write-Host "=== Kravmaga: start stack ===" -ForegroundColor Cyan
Write-Host "Project: $projectPath"
Write-Host ""

# 1) Docker containers
Write-Host "-> Starting Docker containers..." -ForegroundColor Yellow
docker start kravmaga-mysql | Out-Null
docker start kravmaga-phpmyadmin | Out-Null

Write-Host "   MySQL:      http://127.0.0.1:3307 (port expose) / container: kravmaga-mysql"
Write-Host "   phpMyAdmin: http://localhost:8081/" -ForegroundColor Green
Write-Host ""

# 2) Laravel API
Write-Host "-> Starting Laravel API..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", ("cd " + $apiPath + "; php artisan serve")

# 3) Nuxt Web
Write-Host "-> Starting Nuxt web..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", ("cd " + $webPath + "; npm run dev")

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Laravel: http://127.0.0.1:8000" -ForegroundColor Green
Write-Host "Nuxt:    http://localhost:3000" -ForegroundColor Green
Write-Host ""
