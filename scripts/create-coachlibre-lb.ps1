# Script de création du Load Balancer CoachLibre
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

# 1. Récupérer la liste des serveurs existants
Write-Host "Recuperation des serveurs existants..." -ForegroundColor Yellow
try {
    $servers = Invoke-HetznerAPI -Endpoint "/servers"
    Write-Host "Serveurs trouves: $($servers.servers.Count)" -ForegroundColor Green
} catch {
    Write-Host "Erreur lors de la recuperation des serveurs: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Identifier les nœuds K3s
$k3sNodes = @()
foreach ($server in $servers.servers) {
    if ($server.name -like "*k3s*") {
        $k3sNodes += @{
            id = $server.id
            name = $server.name
            ip = $server.public_net.ipv4.ip
        }
        Write-Host "Nœud K3s trouve: $($server.name) - $($server.public_net.ipv4.ip)" -ForegroundColor Cyan
    }
}

if ($k3sNodes.Count -eq 0) {
    Write-Host "Aucun nœud K3s trouve" -ForegroundColor Red
    exit 1
}

# 3. Vérifier si le load balancer existe déjà
Write-Host "Verification du load balancer existant..." -ForegroundColor Yellow
try {
    $loadBalancers = Invoke-HetznerAPI -Endpoint "/load_balancers"
    $existingLB = $loadBalancers.load_balancers | Where-Object { $_.name -eq $LB_NAME }
    
    if ($existingLB) {
        Write-Host "Load balancer '$LB_NAME' existe deja" -ForegroundColor Yellow
        $lbId = $existingLB.id
    } else {
        Write-Host "Creation du load balancer..." -ForegroundColor Yellow
        
        # Créer le load balancer
        $lbBody = @{
            name = $LB_NAME
            load_balancer_type = $LB_TYPE
            location = $LOCATION
            targets = @()
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
                    destination_port = 443
                    health_check = @{
                        protocol = "https"
                        port = 443
                        interval = 15
                        timeout = 10
                        retries = 3
                    }
                }
            )
        }
        
        # Ajouter les nœuds K3s comme targets
        foreach ($node in $k3sNodes) {
            $lbBody.targets += @{
                type = "server"
                server = @{
                    id = $node.id
                }
                use_private_ip = $false
            }
        }
        
        $newLB = Invoke-HetznerAPI -Method "POST" -Endpoint "/load_balancers" -Body $lbBody
        $lbId = $newLB.load_balancer.id
        Write-Host "Load balancer cree avec l'ID: $lbId" -ForegroundColor Green
    }
} catch {
    Write-Host "Erreur lors de la gestion du load balancer: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 4. Récupérer l'IP du load balancer
Write-Host "Recuperation de l'IP du load balancer..." -ForegroundColor Yellow
try {
    $lbDetails = Invoke-HetznerAPI -Endpoint "/load_balancers/$lbId"
    $lbIP = $lbDetails.load_balancer.public_net.ipv4.ip
    Write-Host "IP du load balancer: $lbIP" -ForegroundColor Green
} catch {
    Write-Host "Erreur lors de la recuperation des details du LB: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Configuration Hetzner terminee!" -ForegroundColor Green
Write-Host "IP du Load Balancer: $lbIP" -ForegroundColor Cyan
Write-Host "URL finale: https://coachlibre.infra.ori3com.cloud" -ForegroundColor Cyan

# Sauvegarder l'IP dans un fichier temporaire
$lbIP | Out-File -FilePath "temp-lb-ip.txt" -Encoding UTF8
Write-Host "IP sauvegardee dans temp-lb-ip.txt" -ForegroundColor Yellow
