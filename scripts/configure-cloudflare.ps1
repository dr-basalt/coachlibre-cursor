# Script de configuration automatique Cloudflare
Write-Host "☁️ Configuration automatique Cloudflare..." -ForegroundColor Green

# Configuration
$CLOUDFLARE_API_TOKEN = $env:CLOUDFLARE_API_TOKEN
$CLOUDFLARE_ZONE_ID = $env:CLOUDFLARE_ZONE_ID
$DOMAIN = "ori3com.cloud"
$SUBDOMAIN = "coachlibre.infra"
$FULL_DOMAIN = "$SUBDOMAIN.$DOMAIN"

# Vérifier si les variables sont configurées
if (-not $CLOUDFLARE_API_TOKEN) {
    Write-Host "❌ Variable d'environnement CLOUDFLARE_API_TOKEN non configurée" -ForegroundColor Red
    Write-Host "📝 Veuillez configurer votre token API Cloudflare:" -ForegroundColor Yellow
    Write-Host "   \$env:CLOUDFLARE_API_TOKEN = 'votre_token_ici'" -ForegroundColor Yellow
    exit 1
}

if (-not $CLOUDFLARE_ZONE_ID) {
    Write-Host "❌ Variable d'environnement CLOUDFLARE_ZONE_ID non configurée" -ForegroundColor Red
    Write-Host "📝 Veuillez configurer votre Zone ID Cloudflare:" -ForegroundColor Yellow
    Write-Host "   \$env:CLOUDFLARE_ZONE_ID = 'votre_zone_id_ici'" -ForegroundColor Yellow
    exit 1
}

# Demander l'IP du load balancer
$lbIP = Read-Host "Entrez l'IP du Load Balancer Hetzner"

if (-not $lbIP) {
    Write-Host "❌ IP du Load Balancer requise" -ForegroundColor Red
    exit 1
}

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
Write-Host "📋 Vérification de la zone Cloudflare..." -ForegroundColor Yellow
try {
    $zone = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID"
    if ($zone.success) {
        Write-Host "✅ Zone trouvée: $($zone.result.name)" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur lors de la récupération de la zone" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification de la zone: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Vérifier si l'enregistrement existe déjà
Write-Host "🔍 Vérification de l'enregistrement DNS existant..." -ForegroundColor Yellow
try {
    $records = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/dns_records"
    $existingRecord = $records.result | Where-Object { $_.name -eq $FULL_DOMAIN }
    
    if ($existingRecord) {
        Write-Host "⚠️ Enregistrement DNS existant trouvé" -ForegroundColor Yellow
        
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
            Write-Host "✅ Enregistrement DNS mis à jour" -ForegroundColor Green
        } else {
            Write-Host "❌ Erreur lors de la mise à jour: $($updateResponse.errors)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "📝 Création de l'enregistrement DNS..." -ForegroundColor Yellow
        
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
            Write-Host "✅ Enregistrement DNS créé" -ForegroundColor Green
        } else {
            Write-Host "❌ Erreur lors de la création: $($createResponse.errors)" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "❌ Erreur lors de la gestion DNS: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Configurer SSL/TLS
Write-Host "🔒 Configuration SSL/TLS..." -ForegroundColor Yellow
try {
    $sslBody = @{
        value = "full"
    }
    
    $sslResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" -Body $sslBody
    
    if ($sslResponse.success) {
        Write-Host "✅ SSL/TLS configuré en mode Full" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Erreur lors de la configuration SSL: $($sslResponse.errors)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Erreur lors de la configuration SSL: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 4. Configurer les règles de sécurité
Write-Host "🛡️ Configuration des règles de sécurité..." -ForegroundColor Yellow
try {
    # Activer Always Use HTTPS
    $httpsBody = @{
        value = "on"
    }
    
    $httpsResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" -Body $httpsBody
    
    if ($httpsResponse.success) {
        Write-Host "✅ Always Use HTTPS activé" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Erreur lors de l'activation HTTPS: $($httpsResponse.errors)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Erreur lors de la configuration HTTPS: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "🎉 Configuration Cloudflare terminée!" -ForegroundColor Green
Write-Host "🌐 URL finale: https://$FULL_DOMAIN" -ForegroundColor Cyan
Write-Host "📝 Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Attendre la propagation DNS (5-10 minutes)" -ForegroundColor Yellow
Write-Host "2. Tester l'accès sur https://$FULL_DOMAIN" -ForegroundColor Yellow
Write-Host "3. Vérifier le certificat SSL" -ForegroundColor Yellow
