# Script pour ajouter le service HTTPS au Load Balancer
Write-Host "Ajout du service HTTPS au Load Balancer..." -ForegroundColor Green

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

# 1. Récupérer le load balancer existant
Write-Host "Recuperation du load balancer..." -ForegroundColor Yellow
$loadBalancers = Invoke-HetznerAPI -Endpoint "/load_balancers"
$existingLB = $loadBalancers.load_balancers | Where-Object { $_.name -eq $LB_NAME }

if (-not $existingLB) {
    Write-Host "Load balancer $LB_NAME non trouve" -ForegroundColor Red
    exit 1
}

Write-Host "Load balancer trouve: $($existingLB.id)" -ForegroundColor Green

# 2. Ajouter le service HTTPS
Write-Host "Ajout du service HTTPS..." -ForegroundColor Yellow
$addServiceBody = @{
    protocol = "https"
    listen_port = 443
    destination_port = 80
    health_check = @{
        protocol = "http"
        port = 80
        interval = 15
        timeout = 10
        retries = 3
    }
}

$addResponse = Invoke-HetznerAPI -Method "POST" -Endpoint "/load_balancers/$($existingLB.id)/services" -Body $addServiceBody

if ($addResponse -and $addResponse.service) {
    Write-Host "Service HTTPS ajoute avec succes!" -ForegroundColor Green
    Write-Host "  ID: $($addResponse.service.id)" -ForegroundColor Cyan
    Write-Host "  Protocol: $($addResponse.service.protocol)" -ForegroundColor Cyan
    Write-Host "  Port: $($addResponse.service.listen_port)" -ForegroundColor Cyan
} else {
    Write-Host "Erreur lors de l'ajout du service HTTPS" -ForegroundColor Red
    exit 1
}

# 3. Vérifier la configuration finale
Write-Host "Verification de la configuration finale..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

$finalLB = Invoke-HetznerAPI -Endpoint "/load_balancers/$($existingLB.id)"
if ($finalLB -and $finalLB.load_balancer) {
    Write-Host "Services configures:" -ForegroundColor Green
    foreach ($service in $finalLB.load_balancer.services) {
        Write-Host "  - $($service.protocol) sur le port $($service.listen_port)" -ForegroundColor Cyan
    }
}

Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host "Le load balancer supporte maintenant HTTP et HTTPS" -ForegroundColor Cyan
