# Script pour configurer Cloudflare en mode SSL Flexible
Write-Host "Configuration Cloudflare SSL Flexible..." -ForegroundColor Green

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

# 2. Configurer SSL en mode Flexible
Write-Host "`n2. Configuration SSL en mode Flexible..." -ForegroundColor Yellow
$sslBody = @{ value = "flexible" }
$sslResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" -Body $sslBody

if ($sslResponse -and $sslResponse.success) {
    Write-Host "   SSL configure en mode Flexible" -ForegroundColor Green
} else {
    Write-Host "   Erreur configuration SSL" -ForegroundColor Red
    if ($sslResponse) {
        Write-Host "   Details: $($sslResponse.errors)" -ForegroundColor Red
    }
}

# 3. Activer Always Use HTTPS
Write-Host "`n3. Activation de Always Use HTTPS..." -ForegroundColor Yellow
$httpsBody = @{ value = "on" }
$httpsResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" -Body $httpsBody

if ($httpsResponse -and $httpsResponse.success) {
    Write-Host "   Always Use HTTPS active" -ForegroundColor Green
} else {
    Write-Host "   Erreur activation HTTPS" -ForegroundColor Red
}

# 4. Test de l'accès HTTPS
Write-Host "`n4. Test de l'acces HTTPS..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

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
Write-Host "URL HTTPS: https://$SUBDOMAIN.$DOMAIN" -ForegroundColor Cyan
Write-Host "Mode SSL: Flexible (SSL termine chez Cloudflare, HTTP vers origine)" -ForegroundColor Cyan
