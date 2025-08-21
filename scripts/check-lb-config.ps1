# Script pour vérifier la configuration du Load Balancer Hetzner
Write-Host "Verification de la configuration du Load Balancer..." -ForegroundColor Green

# Configuration
$HETZNER_API_TOKEN = $env:HETZNER_API_TOKEN
$LB_NAME = "coachlibre-lb"

# Vérifier si le token est configuré
if (-not $HETZNER_API_TOKEN) {
    Write-Host "Token API Hetzner manquant" -ForegroundColor Red
    exit 1
}

# Fonction pour appeler l'API Hetzner
function Invoke-HetznerAPI {
    param(
        [string]$Method = "GET",
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    $headers = @{
        "Authorization" = "Bearer $HETZNER_API_TOKEN"
        "Content-Type" = "application/json"
    }
    
    $uri = "https://api.hetzner.cloud/v1$Endpoint"
    
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

# Récupérer le load balancer
Write-Host "Recuperation du load balancer..." -ForegroundColor Yellow
$loadBalancers = Invoke-HetznerAPI -Endpoint "/load_balancers"
$existingLB = $loadBalancers.load_balancers | Where-Object { $_.name -eq $LB_NAME }

if (-not $existingLB) {
    Write-Host "Load balancer $LB_NAME non trouve" -ForegroundColor Red
    exit 1
}

Write-Host "Load balancer trouve: $($existingLB.name)" -ForegroundColor Green
Write-Host "  ID: $($existingLB.id)" -ForegroundColor Cyan
Write-Host "  IP: $($existingLB.public_net.ipv4.ip)" -ForegroundColor Cyan
Write-Host "  Location: $($existingLB.location.name)" -ForegroundColor Cyan

Write-Host "`nConfiguration des services:" -ForegroundColor Yellow
foreach ($service in $existingLB.services) {
    Write-Host "  - Protocol: $($service.protocol)" -ForegroundColor Cyan
    Write-Host "    Port d'ecoute: $($service.listen_port)" -ForegroundColor White
    Write-Host "    Port de destination: $($service.destination_port)" -ForegroundColor White
    Write-Host "    Health check: $($service.health_check.protocol) sur le port $($service.health_check.port)" -ForegroundColor White
    Write-Host ""
}

Write-Host "Targets (serveurs):" -ForegroundColor Yellow
foreach ($target in $existingLB.targets) {
    Write-Host "  - Type: $($target.type)" -ForegroundColor Cyan
    if ($target.type -eq "server") {
        Write-Host "    Server ID: $($target.server.id)" -ForegroundColor White
        Write-Host "    IP: $($target.ip.ip)" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "Configuration actuelle:" -ForegroundColor Green
if ($existingLB.services | Where-Object { $_.protocol -eq "https" }) {
    Write-Host "  ✅ HTTPS supporte" -ForegroundColor Green
} else {
    Write-Host "  ❌ HTTPS non supporte (HTTP seulement)" -ForegroundColor Red
}

