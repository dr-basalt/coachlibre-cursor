# Script complet pour corriger Cloudflare
Write-Host "Correction complete de la configuration Cloudflare..." -ForegroundColor Green

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

Write-Host "Instructions manuelles pour corriger Cloudflare:" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

Write-Host "`n1. Aller sur https://dash.cloudflare.com" -ForegroundColor Yellow
Write-Host "2. Selectionner le domaine: ori3com.cloud" -ForegroundColor Yellow
Write-Host "3. Aller dans SSL/TLS > Overview" -ForegroundColor Yellow
Write-Host "4. Changer Encryption mode: 'Off' (au lieu de Flexible)" -ForegroundColor Yellow
Write-Host "5. Cliquer Save" -ForegroundColor Yellow
Write-Host "6. Aller dans SSL/TLS > Edge Certificates" -ForegroundColor Yellow
Write-Host "7. Desactiver 'Always Use HTTPS'" -ForegroundColor Yellow
Write-Host "8. Cliquer Save" -ForegroundColor Yellow
Write-Host "9. Aller dans Rules > Page Rules" -ForegroundColor Yellow
Write-Host "10. Creer une nouvelle regle:" -ForegroundColor Yellow
Write-Host "    - URL: coachlibre.infra.ori3com.cloud/*" -ForegroundColor Yellow
Write-Host "    - Setting: SSL = Off" -ForegroundColor Yellow
Write-Host "    - Cliquer Save" -ForegroundColor Yellow

Write-Host "`nApres ces changements:" -ForegroundColor Green
Write-Host "- HTTP fonctionnera directement" -ForegroundColor Cyan
Write-Host "- HTTPS sera desactive temporairement" -ForegroundColor Cyan
Write-Host "- L'application sera accessible" -ForegroundColor Cyan

Write-Host "`nTest apres configuration:" -ForegroundColor Yellow
Write-Host "http://coachlibre.infra.ori3com.cloud" -ForegroundColor Cyan
