# Script de test de l'accès externe CoachLibre
Write-Host "🧪 Test de l'accès externe CoachLibre..." -ForegroundColor Green

# Configuration
$DOMAIN = "coachlibre.infra.ori3com.cloud"
$NAMESPACE = "coachlibre"

# 1. Vérification de l'état du cluster
Write-Host "📋 Vérification de l'état du cluster..." -ForegroundColor Yellow
kubectl get pods -n $NAMESPACE
kubectl get ingress -n $NAMESPACE
kubectl get services -n $NAMESPACE

# 2. Test de résolution DNS
Write-Host "🌐 Test de résolution DNS..." -ForegroundColor Yellow
try {
    $dnsResult = Resolve-DnsName -Name $DOMAIN -Type A -ErrorAction Stop
    Write-Host "✅ DNS résolu: $($dnsResult.IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur de résolution DNS: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "⚠️ Vérifiez la configuration Cloudflare" -ForegroundColor Yellow
}

# 3. Test de connectivité HTTP
Write-Host "🔗 Test de connectivité HTTP..." -ForegroundColor Yellow
try {
    $httpResponse = Invoke-WebRequest -Uri "http://$DOMAIN" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✅ HTTP accessible (Status: $($httpResponse.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur HTTP: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Test de connectivité HTTPS
Write-Host "🔒 Test de connectivité HTTPS..." -ForegroundColor Yellow
try {
    $httpsResponse = Invoke-WebRequest -Uri "https://$DOMAIN" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✅ HTTPS accessible (Status: $($httpsResponse.StatusCode))" -ForegroundColor Green
    
    # Vérifier le certificat
    $cert = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
    Write-Host "✅ Certificat SSL valide" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur HTTPS: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Test du contenu de la page
Write-Host "📄 Test du contenu de la page..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://$DOMAIN" -TimeoutSec 10
    if ($response.Content -like "*CoachLibre*") {
        Write-Host "✅ Contenu de la page correct" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Contenu de la page inattendu" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors du test du contenu: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Test des logs
Write-Host "📊 Vérification des logs..." -ForegroundColor Yellow
try {
    $logs = kubectl logs -n $NAMESPACE -l app=coachlibre-frontend --tail=10
    Write-Host "✅ Logs récupérés" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Erreur lors de la récupération des logs: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 7. Test de performance
Write-Host "⚡ Test de performance..." -ForegroundColor Yellow
try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-WebRequest -Uri "https://$DOMAIN" -TimeoutSec 30
    $stopwatch.Stop()
    $responseTime = $stopwatch.ElapsedMilliseconds
    Write-Host "✅ Temps de réponse: ${responseTime}ms" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors du test de performance: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "🎉 Tests terminés!" -ForegroundColor Green
Write-Host "🌐 URL de test: https://$DOMAIN" -ForegroundColor Cyan
Write-Host "📝 Pour surveiller les logs: kubectl logs -f -n $NAMESPACE -l app=coachlibre-frontend" -ForegroundColor Yellow
