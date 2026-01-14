# stop-kravmaga.ps1
Write-Host "Stopping Docker containers..." -ForegroundColor Yellow
docker stop kravmaga-phpmyadmin | Out-Null
docker stop kravmaga-mysql | Out-Null
Write-Host "Done." -ForegroundColor Green
