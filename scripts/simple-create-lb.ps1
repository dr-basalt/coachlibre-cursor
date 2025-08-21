# Script simplifié pour créer le Load Balancer CoachLibre
Write-Host "Creation du Load Balancer CoachLibre..." -ForegroundColor Green

# Configuration
$HETZNER_API_TOKEN = $env:HETZNER_API_TOKEN
$LB_NAME = "coachlibre-lb"
$LB_TYPE = "lb11"
$LOCATION = "fsn1"

# Vérifier si le token est configuré
if (-not $HETZNER_API_TOKEN) {
    Write-Host "Token API Hetzner non configuré" -ForegroundColor Red
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
    
    if ($Body) {
        $jsonBody = $Body | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $jsonBody
    } else {
        $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
    }
    
    return $response
}

# 1. Récupérer les serveurs K3s
Write-Host "Recuperation des serveurs K3s..." -ForegroundColor Yellow
try {
    $servers = Invoke-HetznerAPI -Endpoint "/servers"
    $k3sServers = $servers.servers | Where-Object { $_.name -like "*k3s*" }
    Write-Host "Serveurs K3s trouves: $($k3sServers.Count)" -ForegroundColor Green
    
    foreach ($server in $k3sServers) {
        Write-Host "  - $($server.name): $($server.public_net.ipv4.ip)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Vérifier si le load balancer existe
Write-Host "Verification du load balancer existant..." -ForegroundColor Yellow
try {
    $loadBalancers = Invoke-HetznerAPI -Endpoint "/load_balancers"
    $existingLB = $loadBalancers.load_balancers | Where-Object { $_.name -eq $LB_NAME }
    
    if ($existingLB) {
        Write-Host "Load balancer existe deja: $($existingLB.public_net.ipv4.ip)" -ForegroundColor Yellow
        $lbIP = $existingLB.public_net.ipv4.ip
    } else {
        Write-Host "Creation du load balancer..." -ForegroundColor Yellow
        
        # Préparer les targets
        $targets = @()
        foreach ($server in $k3sServers) {
            $targets += @{
                type = "server"
                server = @{ id = $server.id }
                use_private_ip = $false
            }
        }
        
        # Créer le load balancer
        $lbBody = @{
            name = $LB_NAME
            load_balancer_type = $LB_TYPE
            location = $LOCATION
            targets = $targets
            services = @(
                @{
                    protocol = "http"
                    listen_port = 80
                    destination_port = 80
                    health_check = @{
                        protocol = "http"
                        port = 80
                        interval = 15
                        timeout = 10
                        retries = 3
                    }
                }
            )
        }
        
        $newLB = Invoke-HetznerAPI -Method "POST" -Endpoint "/load_balancers" -Body $lbBody
        $lbIP = $newLB.load_balancer.public_net.ipv4.ip
        Write-Host "Load balancer cree: $lbIP" -ForegroundColor Green
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host "IP du Load Balancer: $lbIP" -ForegroundColor Cyan
Write-Host "URL finale: https://coachlibre.infra.ori3com.cloud" -ForegroundColor Cyan

# Sauvegarder l'IP
$lbIP | Out-File -FilePath "temp-lb-ip.txt" -Encoding UTF8
Write-Host "IP sauvegardee dans temp-lb-ip.txt" -ForegroundColor Yellow
