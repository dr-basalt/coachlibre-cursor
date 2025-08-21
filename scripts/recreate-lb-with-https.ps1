# Script pour recréer le Load Balancer avec HTTP et HTTPS
Write-Host "Recreation du Load Balancer avec HTTP et HTTPS..." -ForegroundColor Green

# Configuration
$HETZNER_API_TOKEN = $env:HETZNER_API_TOKEN
$LB_NAME = "coachlibre-lb"
$LB_TYPE = "lb11"
$LOCATION = "fsn1"

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

# 1. Récupérer les serveurs K3s
Write-Host "Recuperation des serveurs K3s..." -ForegroundColor Yellow
$servers = Invoke-HetznerAPI -Endpoint "/servers"
$k3sServers = $servers.servers | Where-Object { $_.name -like "*k3s*" }
Write-Host "Serveurs K3s trouves: $($k3sServers.Count)" -ForegroundColor Green

# 2. Supprimer l'ancien load balancer
Write-Host "Suppression de l'ancien load balancer..." -ForegroundColor Yellow
$loadBalancers = Invoke-HetznerAPI -Endpoint "/load_balancers"
$existingLB = $loadBalancers.load_balancers | Where-Object { $_.name -eq $LB_NAME }

if ($existingLB) {
    $deleteResponse = Invoke-HetznerAPI -Method "DELETE" -Endpoint "/load_balancers/$($existingLB.id)"
    if ($deleteResponse) {
        Write-Host "Ancien load balancer supprime" -ForegroundColor Green
    }
    Start-Sleep -Seconds 10
}

# 3. Créer le nouveau load balancer avec HTTP et HTTPS
Write-Host "Creation du nouveau load balancer..." -ForegroundColor Yellow

# Préparer les targets
$targets = @()
foreach ($server in $k3sServers) {
    $targets += @{
        type = "server"
        server = @{ id = $server.id }
        use_private_ip = $false
    }
}

# Créer le load balancer avec les deux services
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
        },
        @{
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
    )
}

$newLB = Invoke-HetznerAPI -Method "POST" -Endpoint "/load_balancers" -Body $lbBody

if ($newLB -and $newLB.load_balancer) {
    Write-Host "Nouveau load balancer cree avec succes!" -ForegroundColor Green
    Write-Host "  ID: $($newLB.load_balancer.id)" -ForegroundColor Cyan
    Write-Host "  IP: $($newLB.load_balancer.public_net.ipv4.ip)" -ForegroundColor Cyan
    Write-Host "  Services:" -ForegroundColor Cyan
    foreach ($service in $newLB.load_balancer.services) {
        Write-Host "    - $($service.protocol) sur le port $($service.listen_port)" -ForegroundColor Yellow
    }
    
    # Sauvegarder la nouvelle IP
    $newLB.load_balancer.public_net.ipv4.ip | Out-File -FilePath "temp-lb-ip.txt" -Encoding UTF8
    Write-Host "Nouvelle IP sauvegardee: $($newLB.load_balancer.public_net.ipv4.ip)" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de la creation du load balancer" -ForegroundColor Red
    exit 1
}

Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host "Le load balancer supporte maintenant HTTP et HTTPS" -ForegroundColor Cyan
