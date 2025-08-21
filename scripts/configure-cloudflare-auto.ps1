# Script de configuration automatique Cloudflare
Write-Host "Configuration automatique Cloudflare..." -ForegroundColor Green

# Demander le token API
$CLOUDFLARE_API_TOKEN = Read-Host "Entrez votre token API Cloudflare" -AsSecureString
$CLOUDFLARE_API_TOKEN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($CLOUDFLARE_API_TOKEN))

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

# 2. Configurer SSL en mode Off
Write-Host "`n2. Configuration SSL en mode Off..." -ForegroundColor Yellow
$sslBody = @{ value = "off" }
$sslResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" -Body $sslBody

if ($sslResponse -and $sslResponse.success) {
    Write-Host "   SSL configure en mode Off" -ForegroundColor Green
} else {
    Write-Host "   Erreur configuration SSL" -ForegroundColor Red
    if ($sslResponse) {
        Write-Host "   Details: $($sslResponse.errors)" -ForegroundColor Red
    }
}

# 3. Désactiver Always Use HTTPS
Write-Host "`n3. Desactivation de Always Use HTTPS..." -ForegroundColor Yellow
$httpsBody = @{ value = "off" }
$httpsResponse = Invoke-CloudflareAPI -Method "PATCH" -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/always_use_https" -Body $httpsBody

if ($httpsResponse -and $httpsResponse.success) {
    Write-Host "   Always Use HTTPS desactive" -ForegroundColor Green
} else {
    Write-Host "   Erreur desactivation HTTPS" -ForegroundColor Red
}

# 4. Vérifier l'enregistrement DNS
Write-Host "`n4. Verification de l'enregistrement DNS..." -ForegroundColor Yellow
$dnsRecords = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/dns_records"
$coachlibreRecord = $dnsRecords.result | Where-Object { $_.name -eq "$SUBDOMAIN.$DOMAIN" }

if ($coachlibreRecord) {
    Write-Host "   Enregistrement DNS trouve: $($coachlibreRecord.content)" -ForegroundColor Green
    Write-Host "   Proxy: $($coachlibreRecord.proxied)" -ForegroundColor Green
} else {
    Write-Host "   Enregistrement DNS non trouve" -ForegroundColor Red
}

# 5. Test de l'accès
Write-Host "`n5. Test de l'acces..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

try {
    $httpResponse = Invoke-WebRequest -Uri "http://$SUBDOMAIN.$DOMAIN" -TimeoutSec 10
    Write-Host "   HTTP OK: Status $($httpResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   Erreur HTTP: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $httpsResponse = Invoke-WebRequest -Uri "https://$SUBDOMAIN.$DOMAIN" -TimeoutSec 10
    Write-Host "   HTTPS OK: Status $($httpsResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   Erreur HTTPS: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nConfiguration terminee!" -ForegroundColor Green
Write-Host "URL de test: http://$SUBDOMAIN.$DOMAIN" -ForegroundColor Cyan
