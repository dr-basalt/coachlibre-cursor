# Script de test de l'API Hetzner
Write-Host "Test de l'API Hetzner..." -ForegroundColor Green

# Configuration
$HETZNER_API_TOKEN = $env:HETZNER_API_TOKEN

# Vérifier si le token est configuré
if (-not $HETZNER_API_TOKEN) {
    Write-Host "Token API Hetzner non configuré" -ForegroundColor Red
    exit 1
}

Write-Host "Token API configuré" -ForegroundColor Green

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
    
    if ($Body) {
        $jsonBody = $Body | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $jsonBody
    } else {
        $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
    }
    
    return $response
}

# Test de récupération des serveurs
Write-Host "Récupération des serveurs..." -ForegroundColor Yellow
try {
    $servers = Invoke-HetznerAPI -Endpoint "/servers"
    Write-Host "Serveurs trouvés: $($servers.servers.Count)" -ForegroundColor Green
    
    foreach ($server in $servers.servers) {
        Write-Host "  - $($server.name): $($server.public_net.ipv4.ip)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test de récupération des load balancers
Write-Host "Récupération des load balancers..." -ForegroundColor Yellow
try {
    $loadBalancers = Invoke-HetznerAPI -Endpoint "/load_balancers"
    Write-Host "Load balancers trouvés: $($loadBalancers.load_balancers.Count)" -ForegroundColor Green
    
    foreach ($lb in $loadBalancers.load_balancers) {
        Write-Host "  - $($lb.name): $($lb.public_net.ipv4.ip)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Test terminé avec succès!" -ForegroundColor Green
