# Script pour désactiver le proxy Cloudflare
Write-Host "Desactivation du proxy Cloudflare..." -ForegroundColor Green

# Token API Cloudflare
$CLOUDFLARE_API_TOKEN = "2RFHFkRSnlFgtohjnuMiNHqMQI8yobr1XCNL8qE-"
$CLOUDFLARE_ZONE_ID = "5a22c18b316e5695060d4b9aeacdae7e"
$DOMAIN = "ori3com.cloud"
$SUBDOMAIN = "coachlibre.infra"

Write-Host "Instructions manuelles pour desactiver le proxy:" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "`n1. Aller sur https://dash.cloudflare.com" -ForegroundColor Yellow
Write-Host "2. Selectionner le domaine: ori3com.cloud" -ForegroundColor Yellow
Write-Host "3. Aller dans DNS > Records" -ForegroundColor Yellow
Write-Host "4. Trouver l'enregistrement: coachlibre.infra.ori3com.cloud" -ForegroundColor Yellow
Write-Host "5. Cliquer sur l'enregistrement pour l'editer" -ForegroundColor Yellow
Write-Host "6. Desactiver le proxy (nuage gris au lieu d'orange)" -ForegroundColor Yellow
Write-Host "7. Cliquer Save" -ForegroundColor Yellow

Write-Host "`nOu creer un nouvel enregistrement sans proxy:" -ForegroundColor Cyan
Write-Host "1. Cliquer 'Add record'" -ForegroundColor Yellow
Write-Host "2. Type: A" -ForegroundColor Yellow
Write-Host "3. Name: coachlibre.infra" -ForegroundColor Yellow
Write-Host "4. IPv4 address: 167.235.219.194" -ForegroundColor Yellow
Write-Host "5. Proxy status: DNS only (nuage gris)" -ForegroundColor Yellow
Write-Host "6. Cliquer Save" -ForegroundColor Yellow

Write-Host "`nApres ces changements:" -ForegroundColor Green
Write-Host "- L'acces sera direct sans passer par Cloudflare" -ForegroundColor Cyan
Write-Host "- HTTP fonctionnera immediatement" -ForegroundColor Cyan
Write-Host "- Pas de probleme SSL" -ForegroundColor Cyan

Write-Host "`nTest apres configuration:" -ForegroundColor Yellow
Write-Host "http://coachlibre.infra.ori3com.cloud" -ForegroundColor Cyan
