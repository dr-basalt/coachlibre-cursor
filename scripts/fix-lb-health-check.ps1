# Script pour corriger le health check du Load Balancer
Write-Host "Correction du health check du Load Balancer..." -ForegroundColor Green

# Configuration
$HETZNER_API_TOKEN = $env:HETZNER_API_TOKEN
$LB_NAME = "coachlibre-lb"
$INGRESS_PORT = 30337

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

# 1. Récupérer le load balancer existant
Write-Host "Recuperation du load balancer..." -ForegroundColor Yellow
$loadBalancers = Invoke-HetznerAPI -Endpoint "/load_balancers"
$existingLB = $loadBalancers.load_balancers | Where-Object { $_.name -eq $LB_NAME }

if (-not $existingLB) {
    Write-Host "Load balancer $LB_NAME non trouve" -ForegroundColor Red
    exit 1
}

Write-Host "Load balancer trouve: $($existingLB.id)" -ForegroundColor Green

# 2. Mettre à jour le health check pour qu'il fonctionne avec l'Ingress
Write-Host "Mise a jour du health check..." -ForegroundColor Yellow
$updateBody = @{
    services = @(
        @{
            protocol = "http"
            listen_port = 80
            destination_port = $INGRESS_PORT
            health_check = @{
                protocol = "http"
                port = $INGRESS_PORT
                interval = 15
                timeout = 10
                retries = 3
                http = @{
                    domain = "coachlibre.infra.ori3com.cloud"
                    path = "/"
                    response = "200"
                    status_codes = @("200", "404")
                    tls = $false
                }
            }
        }
    )
}

$updateResponse = Invoke-HetznerAPI -Method "PUT" -Endpoint "/load_balancers/$($existingLB.id)" -Body $updateBody

if ($updateResponse -and $updateResponse.load_balancer) {
    Write-Host "Health check mis a jour avec succes!" -ForegroundColor Green
    Write-Host "Configuration:" -ForegroundColor Cyan
    foreach ($service in $updateResponse.load_balancer.services) {
        Write-Host "  - Port: $($service.listen_port) -> $($service.destination_port)" -ForegroundColor Yellow
        Write-Host "  - Health check: $($service.health_check.protocol) sur $($service.health_check.port)" -ForegroundColor Yellow
        Write-Host "  - Domain: $($service.health_check.http.domain)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Erreur lors de la mise a jour" -ForegroundColor Red
    exit 1
}

Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host "Le health check utilise maintenant le domaine: coachlibre.infra.ori3com.cloud" -ForegroundColor Cyan
