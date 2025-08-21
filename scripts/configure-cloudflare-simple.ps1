# Script simplifié pour configurer Cloudflare
Write-Host "Configuration Cloudflare..." -ForegroundColor Green

# Configuration
$CLOUDFLARE_API_TOKEN = $env:CLOUDFLARE_API_TOKEN
$CLOUDFLARE_ZONE_ID = $env:CLOUDFLARE_ZONE_ID
$DOMAIN = "ori3com.cloud"
$SUBDOMAIN = "coachlibre.infra"
$FULL_DOMAIN = "$SUBDOMAIN.$DOMAIN"

# Vérifier si les variables sont configurées
if (-not $CLOUDFLARE_API_TOKEN) {
    Write-Host "Token API Cloudflare non configuré" -ForegroundColor Red
    exit 1
}

if (-not $CLOUDFLARE_ZONE_ID) {
    Write-Host "Zone ID Cloudflare non configuré" -ForegroundColor Red
    exit 1
}

# Lire l'IP du load balancer
$lbIP = Get-Content "temp-lb-ip.txt" -ErrorAction SilentlyContinue
if (-not $lbIP) {
    Write-Host "IP du Load Balancer non trouvée" -ForegroundColor Red
    exit 1
}

Write-Host "IP du Load Balancer: $lbIP" -ForegroundColor Cyan

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
    
    if ($Body) {
        $jsonBody = $Body | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $jsonBody
    } else {
        $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
    }
    
    return $response
}

# 1. Vérifier la zone
Write-Host "Verification de la zone Cloudflare..." -ForegroundColor Yellow
try {
    $zone = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID"
    if ($zone.success) {
        Write-Host "Zone trouvee: $($zone.result.name)" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de la recuperation de la zone" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Vérifier si l'enregistrement existe déjà
Write-Host "Verification de l'enregistrement DNS existant..." -ForegroundColor Yellow
try {
    $records = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/dns_records"
    $existingRecord = $records.result | Where-Object { $_.name -eq $FULL_DOMAIN }
    
    if ($existingRecord) {
        Write-Host "Enregistrement DNS existant trouve" -ForegroundColor Yellow
        
        # Mettre à jour l'enregistrement existant
        $updateBody = @{
            type = "A"
            name = $SUBDOMAIN
            content = $lbIP
            ttl = 1
            proxied = $true
        }
        
        $updateResponse = Invoke-CloudflareAPI -Method "PUT" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/dns_records/$($existingRecord.id)" -Body $updateBody
        
        if ($updateResponse.success) {
            Write-Host "Enregistrement DNS mis a jour" -ForegroundColor Green
        } else {
            Write-Host "Erreur lors de la mise a jour: $($updateResponse.errors)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Creation de l'enregistrement DNS..." -ForegroundColor Yellow
        
        # Créer un nouvel enregistrement
        $createBody = @{
            type = "A"
            name = $SUBDOMAIN
            content = $lbIP
            ttl = 1
            proxied = $true
        }
        
        $createResponse = Invoke-CloudflareAPI -Method "POST" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/dns_records" -Body $createBody
        
        if ($createResponse.success) {
            Write-Host "Enregistrement DNS cree" -ForegroundColor Green
        } else {
            Write-Host "Erreur lors de la creation: $($createResponse.errors)" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "Erreur lors de la gestion DNS: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Configurer SSL/TLS
Write-Host "Configuration SSL/TLS..." -ForegroundColor Yellow
try {
    $sslBody = @{
        value = "full"
    }
    
    $sslResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" -Body $sslBody
    
    if ($sslResponse.success) {
        Write-Host "SSL/TLS configure en mode Full" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de la configuration SSL: $($sslResponse.errors)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erreur lors de la configuration SSL: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 4. Activer Always Use HTTPS
Write-Host "Activation Always Use HTTPS..." -ForegroundColor Yellow
try {
    $httpsBody = @{
        value = "on"
    }
    
    $httpsResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" -Body $httpsBody
    
    if ($httpsResponse.success) {
        Write-Host "Always Use HTTPS active" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de l'activation HTTPS: $($httpsResponse.errors)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erreur lors de la configuration HTTPS: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "Configuration Cloudflare terminee!" -ForegroundColor Green
Write-Host "URL finale: https://$FULL_DOMAIN" -ForegroundColor Cyan
Write-Host "Prochaines etapes:" -ForegroundColor Yellow
Write-Host "1. Attendre la propagation DNS (5-10 minutes)" -ForegroundColor Yellow
Write-Host "2. Tester l'acces sur https://$FULL_DOMAIN" -ForegroundColor Yellow
