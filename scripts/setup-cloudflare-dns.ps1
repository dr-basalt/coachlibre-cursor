# Script simple pour configurer l'entrée DNS Cloudflare
Write-Host "Configuration DNS Cloudflare..." -ForegroundColor Green

# Configuration
$CLOUDFLARE_API_TOKEN = $env:CLOUDFLARE_API_TOKEN
$CLOUDFLARE_ZONE_ID = $env:CLOUDFLARE_ZONE_ID
$LB_IP = "167.235.219.194"  # IP du load balancer créé
$SUBDOMAIN = "coachlibre.infra"
$DOMAIN = "ori3com.cloud"
$FULL_DOMAIN = "$SUBDOMAIN.$DOMAIN"

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Domaine: $FULL_DOMAIN" -ForegroundColor Yellow
Write-Host "  IP: $LB_IP" -ForegroundColor Yellow

# Vérifier les tokens
if (-not $CLOUDFLARE_API_TOKEN) {
    Write-Host "Token API Cloudflare manquant" -ForegroundColor Red
    exit 1
}

if (-not $CLOUDFLARE_ZONE_ID) {
    Write-Host "Zone ID Cloudflare manquant" -ForegroundColor Red
    exit 1
}

Write-Host "Tokens configures" -ForegroundColor Green

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

# 1. Vérifier la zone
Write-Host "Verification de la zone..." -ForegroundColor Yellow
$zone = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID"
if ($zone -and $zone.success) {
    Write-Host "Zone OK: $($zone.result.name)" -ForegroundColor Green
} else {
    Write-Host "Erreur zone" -ForegroundColor Red
    exit 1
}

# 2. Créer l'enregistrement DNS
Write-Host "Creation de l'enregistrement DNS..." -ForegroundColor Yellow
$dnsBody = @{
    type = "A"
    name = $SUBDOMAIN
    content = $LB_IP
    ttl = 1
    proxied = $true
}

$dnsResponse = Invoke-CloudflareAPI -Method "POST" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/dns_records" -Body $dnsBody

if ($dnsResponse -and $dnsResponse.success) {
    Write-Host "Enregistrement DNS cree avec succes!" -ForegroundColor Green
    Write-Host "  ID: $($dnsResponse.result.id)" -ForegroundColor Cyan
    Write-Host "  Nom: $($dnsResponse.result.name)" -ForegroundColor Cyan
    Write-Host "  IP: $($dnsResponse.result.content)" -ForegroundColor Cyan
} else {
    Write-Host "Erreur creation DNS" -ForegroundColor Red
    if ($dnsResponse) {
        Write-Host "  Erreurs: $($dnsResponse.errors)" -ForegroundColor Red
    }
    exit 1
}

# 3. Configurer SSL
Write-Host "Configuration SSL..." -ForegroundColor Yellow
$sslBody = @{ value = "full" }
$sslResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" -Body $sslBody

if ($sslResponse -and $sslResponse.success) {
    Write-Host "SSL configure en mode Full" -ForegroundColor Green
} else {
    Write-Host "Erreur configuration SSL" -ForegroundColor Yellow
}

# 4. Activer HTTPS
Write-Host "Activation HTTPS..." -ForegroundColor Yellow
$httpsBody = @{ value = "on" }
$httpsResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" -Body $httpsBody

if ($httpsResponse -and $httpsResponse.success) {
    Write-Host "HTTPS force active" -ForegroundColor Green
} else {
    Write-Host "Erreur activation HTTPS" -ForegroundColor Yellow
}

Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host "URL: https://$FULL_DOMAIN" -ForegroundColor Cyan
Write-Host "Attendre 5-10 minutes pour la propagation DNS" -ForegroundColor Yellow
