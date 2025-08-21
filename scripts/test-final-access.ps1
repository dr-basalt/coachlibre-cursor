# Script de test final de l'accès CoachLibre
Write-Host "Test final de l'acces CoachLibre..." -ForegroundColor Green

# Configuration
$DOMAIN = "coachlibre.infra.ori3com.cloud"

Write-Host "Test du domaine: $DOMAIN" -ForegroundColor Cyan

# 1. Test de résolution DNS
Write-Host "`n1. Test de resolution DNS..." -ForegroundColor Yellow
try {
    $dnsResult = Resolve-DnsName -Name $DOMAIN -Type A -ErrorAction Stop
    Write-Host "   DNS resolu: $($dnsResult.IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "   Erreur DNS: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Test HTTP
Write-Host "`n2. Test HTTP..." -ForegroundColor Yellow
try {
    $httpResponse = Invoke-WebRequest -Uri "http://$DOMAIN" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   HTTP OK: Status $($httpResponse.StatusCode)" -ForegroundColor Green
    if ($httpResponse.Content -like "*CoachLibre*") {
        Write-Host "   Contenu correct detecte" -ForegroundColor Green
    }
} catch {
    Write-Host "   Erreur HTTP: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Test HTTPS
Write-Host "`n3. Test HTTPS..." -ForegroundColor Yellow
try {
    $httpsResponse = Invoke-WebRequest -Uri "https://$DOMAIN" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   HTTPS OK: Status $($httpsResponse.StatusCode)" -ForegroundColor Green
    if ($httpsResponse.Content -like "*CoachLibre*") {
        Write-Host "   Contenu correct detecte" -ForegroundColor Green
    }
} catch {
    Write-Host "   Erreur HTTPS: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Test de performance
Write-Host "`n4. Test de performance..." -ForegroundColor Yellow
try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-WebRequest -Uri "https://$DOMAIN" -TimeoutSec 30
    $stopwatch.Stop()
    $responseTime = $stopwatch.ElapsedMilliseconds
    Write-Host "   Temps de reponse: ${responseTime}ms" -ForegroundColor Green
} catch {
    Write-Host "   Erreur performance: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Vérification du cluster K3s
Write-Host "`n5. Verification du cluster K3s..." -ForegroundColor Yellow
try {
    $pods = kubectl get pods -n coachlibre --no-headers 2>$null
    if ($pods) {
        Write-Host "   Pods actifs dans le namespace coachlibre" -ForegroundColor Green
        $pods | ForEach-Object { Write-Host "     $_" -ForegroundColor Cyan }
    } else {
        Write-Host "   Aucun pod trouve" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Erreur cluster: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest termine!" -ForegroundColor Green
Write-Host "URL finale: https://$DOMAIN" -ForegroundColor Cyan
