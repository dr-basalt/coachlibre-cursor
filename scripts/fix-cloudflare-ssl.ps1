# Script pour corriger la configuration SSL Cloudflare
Write-Host "Correction de la configuration SSL Cloudflare..." -ForegroundColor Green

# Configuration
$CLOUDFLARE_API_TOKEN = $env:CLOUDFLARE_API_TOKEN
$CLOUDFLARE_ZONE_ID = $env:CLOUDFLARE_ZONE_ID

# Vérifier les tokens
if (-not $CLOUDFLARE_API_TOKEN) {
    Write-Host "Token API Cloudflare manquant" -ForegroundColor Red
    exit 1
}

if (-not $CLOUDFLARE_ZONE_ID) {
    Write-Host "Zone ID Cloudflare manquant" -ForegroundColor Red
    exit 1
}

# Fonction API Cloudflare
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
        return $null
    }
}

# 1. Configurer SSL en mode Flexible (au lieu de Full)
Write-Host "Configuration SSL en mode Flexible..." -ForegroundColor Yellow
$sslBody = @{ value = "flexible" }
$sslResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" -Body $sslBody

if ($sslResponse -and $sslResponse.success) {
    Write-Host "SSL configure en mode Flexible" -ForegroundColor Green
} else {
    Write-Host "Erreur configuration SSL" -ForegroundColor Yellow
}

# 2. Désactiver Always Use HTTPS temporairement
Write-Host "Desactivation temporaire de Always Use HTTPS..." -ForegroundColor Yellow
$httpsBody = @{ value = "off" }
$httpsResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" -Body $httpsBody

if ($httpsResponse -and $httpsResponse.success) {
    Write-Host "Always Use HTTPS desactive" -ForegroundColor Green
} else {
    Write-Host "Erreur desactivation HTTPS" -ForegroundColor Yellow
}

# 3. Configurer TLS 1.3
Write-Host "Configuration TLS 1.3..." -ForegroundColor Yellow
$tlsBody = @{ value = "1.3" }
$tlsResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/min_tls_version" -Body $tlsBody

if ($tlsResponse -and $tlsResponse.success) {
    Write-Host "TLS 1.3 configure" -ForegroundColor Green
} else {
    Write-Host "Erreur configuration TLS" -ForegroundColor Yellow
}

Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host "Testez maintenant: https://coachlibre.infra.ori3com.cloud" -ForegroundColor Cyan
Write-Host "Si cela fonctionne, nous pourrons reactiver HTTPS plus tard" -ForegroundColor Yellow
