# Script pour créer un Load Balancer sans health check complexe
Write-Host "Creation du Load Balancer sans health check complexe..." -ForegroundColor Green

# Configuration
$HETZNER_API_TOKEN = $env:HETZNER_API_TOKEN
$LB_NAME = "coachlibre-lb"
$LB_TYPE = "lb11"
$LOCATION = "fsn1"
$INGRESS_PORT = 30337

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

# 1. Supprimer l'ancien load balancer
Write-Host "Suppression de l'ancien load balancer..." -ForegroundColor Yellow
$loadBalancers = Invoke-HetznerAPI -Endpoint "/load_balancers"
$existingLB = $loadBalancers.load_balancers | Where-Object { $_.name -eq $LB_NAME }

if ($existingLB) {
    $deleteResponse = Invoke-HetznerAPI -Method "DELETE" -Endpoint "/load_balancers/$($existingLB.id)"
    Write-Host "Ancien load balancer supprime" -ForegroundColor Green
    Start-Sleep -Seconds 10
}

# 2. Récupérer les serveurs K3s
Write-Host "Recuperation des serveurs K3s..." -ForegroundColor Yellow
$servers = Invoke-HetznerAPI -Endpoint "/servers"
$k3sServers = $servers.servers | Where-Object { $_.name -like "*k3s*" }

# Préparer les targets
$targets = @()
foreach ($server in $k3sServers) {
    $targets += @{
        type = "server"
        server = @{ id = $server.id }
        use_private_ip = $false
    }
}

# 3. Créer le nouveau load balancer sans health check HTTP
Write-Host "Creation du nouveau load balancer..." -ForegroundColor Yellow
$lbBody = @{
    name = $LB_NAME
    load_balancer_type = $LB_TYPE
    location = $LOCATION
    targets = $targets
    services = @(
        @{
            protocol = "http"
            listen_port = 80
            destination_port = $INGRESS_PORT
            health_check = @{
                protocol = "tcp"
                port = $INGRESS_PORT
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
    Write-Host "  IP: $($newLB.load_balancer.public_net.ipv4.ip)" -ForegroundColor Cyan
    Write-Host "  Port: 80 -> $INGRESS_PORT" -ForegroundColor Cyan
    Write-Host "  Health check: TCP sur $INGRESS_PORT" -ForegroundColor Cyan
    
    # Sauvegarder la nouvelle IP
    $newLB.load_balancer.public_net.ipv4.ip | Out-File -FilePath "temp-lb-ip.txt" -Encoding UTF8
} else {
    Write-Host "Erreur lors de la creation" -ForegroundColor Red
    exit 1
}

Write-Host "Configuration terminee!" -ForegroundColor Green
