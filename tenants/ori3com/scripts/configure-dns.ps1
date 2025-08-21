# Script de configuration DNS et Cloudflare pour Ori3Com
param(
    [string]$CloudflareToken = "",
    [string]$ZoneId = "",
    [string]$Domain = "coachlibre.infra.ori3com.cloud"
)

Write-Host "🌐 Configuration DNS et Cloudflare pour Ori3Com..." -ForegroundColor Green

# Vérifier les paramètres
if ([string]::IsNullOrEmpty($CloudflareToken)) {
    Write-Host "❌ Token Cloudflare manquant. Utilisez -CloudflareToken 'votre_token'" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($ZoneId)) {
    Write-Host "❌ Zone ID Cloudflare manquant. Utilisez -ZoneId 'votre_zone_id'" -ForegroundColor Red
    exit 1
}

# Headers pour l'API Cloudflare
$headers = @{
    'Authorization' = "Bearer $CloudflareToken"
    'Content-Type' = 'application/json'
}

# Obtenir l'IP du load balancer Hetzner
Write-Host "🔍 Récupération de l'IP du load balancer..." -ForegroundColor Yellow
try {
    $lbResponse = Invoke-WebRequest -Uri "http://coachlibre.infra.ori3com.cloud" -UseBasicParsing -TimeoutSec 10
    $lbIP = $lbResponse.Headers['X-Forwarded-For'] -split ', ' | Select-Object -First 1
    
    if ([string]::IsNullOrEmpty($lbIP)) {
        # Fallback: utiliser l'IP du serveur
        $lbIP = "49.13.218.200"  # IP du serveur Hetzner
    }
    
    Write-Host "✅ IP du load balancer: $lbIP" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Impossible de récupérer l'IP automatiquement, utilisation de l'IP par défaut" -ForegroundColor Yellow
    $lbIP = "49.13.218.200"
}

# Créer l'enregistrement A dans Cloudflare
Write-Host "📝 Création de l'enregistrement A dans Cloudflare..." -ForegroundColor Yellow

$dnsRecord = @{
    type = "A"
    name = $Domain
    content = $lbIP
    ttl = 1  # Auto
    proxied = $true  # Activer le proxy Cloudflare
}

$dnsJson = $dnsRecord | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneId/dns_records" -Method POST -Headers $headers -Body $dnsJson
    
    if ($response.success) {
        Write-Host "✅ Enregistrement DNS créé avec succès!" -ForegroundColor Green
        Write-Host "📋 Détails: $($response.result.name) -> $($response.result.content)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Erreur lors de la création de l'enregistrement DNS" -ForegroundColor Red
        Write-Host "📋 Erreurs: $($response.errors | ConvertTo-Json)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la communication avec l'API Cloudflare" -ForegroundColor Red
    Write-Host "📋 Détails: $($_.Exception.Message)" -ForegroundColor Red
}

# Configuration SSL/TLS
Write-Host "🔒 Configuration SSL/TLS..." -ForegroundColor Yellow

$sslSettings = @{
    value = "full"  # Full SSL/TLS encryption
}

$sslJson = $sslSettings | ConvertTo-Json

try {
    $sslResponse = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneId/settings/ssl" -Method PATCH -Headers $headers -Body $sslJson
    
    if ($sslResponse.success) {
        Write-Host "✅ Configuration SSL/TLS mise à jour!" -ForegroundColor Green
        Write-Host "📋 Mode SSL: $($sslResponse.result.value)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ Erreur lors de la configuration SSL/TLS" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Erreur lors de la configuration SSL/TLS" -ForegroundColor Yellow
}

# Configuration des règles de sécurité
Write-Host "🛡️ Configuration des règles de sécurité..." -ForegroundColor Yellow

$securitySettings = @{
    value = "medium"  # Niveau de sécurité moyen
}

$securityJson = $securitySettings | ConvertTo-Json

try {
    $securityResponse = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneId/settings/security_level" -Method PATCH -Headers $headers -Body $securityJson
    
    if ($securityResponse.success) {
        Write-Host "✅ Règles de sécurité configurées!" -ForegroundColor Green
        Write-Host "📋 Niveau de sécurité: $($securityResponse.result.value)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ Erreur lors de la configuration des règles de sécurité" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Erreur lors de la configuration des règles de sécurité" -ForegroundColor Yellow
}

Write-Host "🎉 Configuration terminée !" -ForegroundColor Green
Write-Host "🌐 Site accessible sur: https://$Domain" -ForegroundColor Cyan
Write-Host "📋 Note: La propagation DNS peut prendre quelques minutes" -ForegroundColor Yellow




