# Script de test de l'API Cloudflare
Write-Host "Test de l'API Cloudflare..." -ForegroundColor Green

# Configuration
$CLOUDFLARE_API_TOKEN = $env:CLOUDFLARE_API_TOKEN
$CLOUDFLARE_ZONE_ID = $env:CLOUDFLARE_ZONE_ID

Write-Host "Token API: $($CLOUDFLARE_API_TOKEN.Substring(0,10))..." -ForegroundColor Cyan
Write-Host "Zone ID: $CLOUDFLARE_ZONE_ID" -ForegroundColor Cyan

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

# 1. Test de l'utilisateur
Write-Host "Test de l'utilisateur..." -ForegroundColor Yellow
$user = Invoke-CloudflareAPI -Endpoint "/user"
if ($user -and $user.success) {
    Write-Host "Utilisateur OK: $($user.result.email)" -ForegroundColor Green
} else {
    Write-Host "Erreur utilisateur" -ForegroundColor Red
}

# 2. Test de la zone
Write-Host "Test de la zone..." -ForegroundColor Yellow
$zone = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID"
if ($zone -and $zone.success) {
    Write-Host "Zone OK: $($zone.result.name)" -ForegroundColor Green
} else {
    Write-Host "Erreur zone" -ForegroundColor Red
}

# 3. Test des permissions SSL
Write-Host "Test des permissions SSL..." -ForegroundColor Yellow
$sslSettings = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/settings/ssl"
if ($sslSettings -and $sslSettings.success) {
    Write-Host "SSL actuel: $($sslSettings.result.value)" -ForegroundColor Green
} else {
    Write-Host "Erreur permissions SSL" -ForegroundColor Red
}

# 4. Test des enregistrements DNS
Write-Host "Test des enregistrements DNS..." -ForegroundColor Yellow
$dnsRecords = Invoke-CloudflareAPI -Endpoint "/zones/$CLOUDFLARE_ZONE_ID/dns_records"
if ($dnsRecords -and $dnsRecords.success) {
    Write-Host "Enregistrements DNS trouves: $($dnsRecords.result.Count)" -ForegroundColor Green
    foreach ($record in $dnsRecords.result) {
        Write-Host "  - $($record.name): $($record.type) -> $($record.content)" -ForegroundColor Cyan
    }
} else {
    Write-Host "Erreur enregistrements DNS" -ForegroundColor Red
}

Write-Host "Test termine!" -ForegroundColor Green
