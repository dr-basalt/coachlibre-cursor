# Script pour désactiver la redirection HTTPS automatique
Write-Host "Desactivation de la redirection HTTPS automatique..." -ForegroundColor Green

# Token API Cloudflare
$CLOUDFLARE_API_TOKEN = "2RFHFkRSnlFgtohjnuMiNHqMQI8yobr1XCNL8qE-"
$CLOUDFLARE_ZONE_ID = "5a22c18b316e5695060d4b9aeacdae7e"
$DOMAIN = "ori3com.cloud"
$SUBDOMAIN = "coachlibre.infra"

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Domaine: $DOMAIN" -ForegroundColor Yellow
Write-Host "  Sous-domaine: $SUBDOMAIN" -ForegroundColor Yellow
Write-Host "  Zone ID: $CLOUDFLARE_ZONE_ID" -ForegroundColor Yellow

# Fonction pour appeler l'API Cloudflare
function Invoke-CloudflareAPI {
    param(
        [string]$Method = "GET",
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    $headers = @{
        "Authorization" = "Bearer $CLOUDFLARE_API_TOKEN"
        "Content-Type" = "application/json"
    }
    
    $uri = "https://api.cloudflare.com/client/v4$Endpoint"
    
    try {
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $jsonBody
        } else {
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
        }
        return $response
    } catch {
        Write-Host "Erreur API: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            Write-Host "Code d'erreur: $statusCode" -ForegroundColor Red
        }
        return $null
    }
}

# 1. Vérifier la zone
Write-Host "`n1. Verification de la zone..." -ForegroundColor Yellow
$zone = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID"
if ($zone -and $zone.success) {
    Write-Host "   Zone OK: $($zone.result.name)" -ForegroundColor Green
} else {
    Write-Host "   Erreur zone" -ForegroundColor Red
    exit 1
}

# 2. Désactiver Always Use HTTPS
Write-Host "`n2. Desactivation de Always Use HTTPS..." -ForegroundColor Yellow
$httpsBody = @{ value = "off" }
$httpsResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" -Body $httpsBody

if ($httpsResponse -and $httpsResponse.success) {
    Write-Host "   Always Use HTTPS desactive" -ForegroundColor Green
} else {
    Write-Host "   Erreur desactivation HTTPS" -ForegroundColor Red
}

# 3. Test de l'accès HTTP
Write-Host "`n3. Test de l'acces HTTP..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

try {
    $httpResponse = Invoke-WebRequest -Uri "http://$SUBDOMAIN.$DOMAIN" -TimeoutSec 10
    Write-Host "   HTTP OK: Status $($httpResponse.StatusCode)" -ForegroundColor Green
    if ($httpResponse.Content -like "*CoachLibre*") {
        Write-Host "   Contenu CoachLibre detecte!" -ForegroundColor Green
    }
} catch {
    Write-Host "   Erreur HTTP: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Test de l'accès HTTPS (optionnel)
Write-Host "`n4. Test de l'acces HTTPS (optionnel)..." -ForegroundColor Yellow
try {
    $httpsResponse = Invoke-WebRequest -Uri "https://$SUBDOMAIN.$DOMAIN" -TimeoutSec 10
    Write-Host "   HTTPS OK: Status $($httpsResponse.StatusCode)" -ForegroundColor Green
    if ($httpsResponse.Content -like "*CoachLibre*") {
        Write-Host "   Contenu CoachLibre detecte!" -ForegroundColor Green
    }
} catch {
    Write-Host "   Erreur HTTPS: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nConfiguration terminee!" -ForegroundColor Green
Write-Host "URL HTTP: http://$SUBDOMAIN.$DOMAIN" -ForegroundColor Cyan
Write-Host "URL HTTPS: https://$SUBDOMAIN.$DOMAIN" -ForegroundColor Cyan
Write-Host "Redirection HTTPS automatique: Desactivee" -ForegroundColor Cyan
