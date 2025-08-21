# Script de diagnostic complet de la chaîne de production
Write-Host "Diagnostic complet de la chaine de production..." -ForegroundColor Green
Write-Host "Cloudflare -> Hetzner LB -> K3s Nodes -> Pods -> CoachLibre" -ForegroundColor Cyan

# Configuration
$DOMAIN = "coachlibre.infra.ori3com.cloud"
$LB_IP = "167.235.219.194"
$K3S_NODES = @("49.13.218.200", "91.99.152.96", "159.69.244.226")

Write-Host "`n=== 1. DIAGNOSTIC DNS ET CLOUDFLARE ===" -ForegroundColor Yellow

# Test DNS
Write-Host "`n1.1 Test de resolution DNS..." -ForegroundColor Cyan
try {
    $dnsResult = Resolve-DnsName -Name $DOMAIN -Type A -ErrorAction Stop
    Write-Host "   DNS resolu vers: $($dnsResult.IPAddress)" -ForegroundColor Green
    
    # Vérifier si c'est une IP Cloudflare
    if ($dnsResult.IPAddress -like "188.114.*" -or $dnsResult.IPAddress -like "172.64.*" -or $dnsResult.IPAddress -like "108.162.*") {
        Write-Host "   ⚠️ IP Cloudflare detectee - Proxy actif" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ IP directe - Pas de proxy Cloudflare" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Erreur DNS: $($_.Exception.Message)" -ForegroundColor Red
}

# Test HTTP direct
Write-Host "`n1.2 Test HTTP direct..." -ForegroundColor Cyan
try {
    $httpResponse = Invoke-WebRequest -Uri "http://$DOMAIN" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   HTTP OK: Status $($httpResponse.StatusCode)" -ForegroundColor Green
    if ($httpResponse.Content -like "*CoachLibre*") {
        Write-Host "   ✅ Contenu CoachLibre detecte" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ Contenu inattendu" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Erreur HTTP: $($_.Exception.Message)" -ForegroundColor Red
}

# Test HTTPS
Write-Host "`n1.3 Test HTTPS..." -ForegroundColor Cyan
try {
    $httpsResponse = Invoke-WebRequest -Uri "https://$DOMAIN" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   HTTPS OK: Status $($httpsResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erreur HTTPS: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== 2. DIAGNOSTIC LOAD BALANCER HETZNER ===" -ForegroundColor Yellow

# Test direct du load balancer
Write-Host "`n2.1 Test direct du Load Balancer..." -ForegroundColor Cyan
try {
    $lbResponse = Invoke-WebRequest -Uri "http://$LB_IP" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   LB direct OK: Status $($lbResponse.StatusCode)" -ForegroundColor Green
    if ($lbResponse.Content -like "*CoachLibre*") {
        Write-Host "   ✅ Contenu CoachLibre sur LB" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Erreur LB direct: $($_.Exception.Message)" -ForegroundColor Red
}

# Test des nœuds K3s
Write-Host "`n2.2 Test des noeuds K3s..." -ForegroundColor Cyan
foreach ($node in $K3S_NODES) {
    try {
        $nodeResponse = Invoke-WebRequest -Uri "http://$node" -TimeoutSec 5 -ErrorAction Stop
        Write-Host "   Noeud ${node}: Status $($nodeResponse.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "   Noeud ${node}: Erreur - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== 3. DIAGNOSTIC CLUSTER K3S ===" -ForegroundColor Yellow

# Vérifier la connexion K3s
Write-Host "`n3.1 Connexion au cluster K3s..." -ForegroundColor Cyan
try {
    $context = kubectl config current-context
    Write-Host "   Contexte actuel: $context" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erreur contexte K3s" -ForegroundColor Red
}

# Vérifier les nœuds
Write-Host "`n3.2 Noeuds du cluster..." -ForegroundColor Cyan
try {
    $nodes = kubectl get nodes --no-headers 2>$null
    if ($nodes) {
        Write-Host "   Noeuds trouves:" -ForegroundColor Green
        $nodes | ForEach-Object { Write-Host "     $_" -ForegroundColor Cyan }
    } else {
        Write-Host "   ❌ Aucun noeud trouve" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur acces noeuds: $($_.Exception.Message)" -ForegroundColor Red
}

# Vérifier le namespace
Write-Host "`n3.3 Namespace coachlibre..." -ForegroundColor Cyan
try {
    $namespace = kubectl get namespace coachlibre 2>$null
    if ($namespace) {
        Write-Host "   ✅ Namespace coachlibre existe" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Namespace coachlibre non trouve" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur namespace: $($_.Exception.Message)" -ForegroundColor Red
}

# Vérifier les pods
Write-Host "`n3.4 Pods CoachLibre..." -ForegroundColor Cyan
try {
    $pods = kubectl get pods -n coachlibre --no-headers 2>$null
    if ($pods) {
        Write-Host "   Pods trouves:" -ForegroundColor Green
        $pods | ForEach-Object { Write-Host "     $_" -ForegroundColor Cyan }
    } else {
        Write-Host "   ❌ Aucun pod trouve" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur pods: $($_.Exception.Message)" -ForegroundColor Red
}

# Vérifier les services
Write-Host "`n3.5 Services..." -ForegroundColor Cyan
try {
    $services = kubectl get services -n coachlibre --no-headers 2>$null
    if ($services) {
        Write-Host "   Services trouves:" -ForegroundColor Green
        $services | ForEach-Object { Write-Host "     $_" -ForegroundColor Cyan }
    } else {
        Write-Host "   ❌ Aucun service trouve" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur services: $($_.Exception.Message)" -ForegroundColor Red
}

# Vérifier les ingress
Write-Host "`n3.6 Ingress..." -ForegroundColor Cyan
try {
    $ingresses = kubectl get ingress -n coachlibre --no-headers 2>$null
    if ($ingresses) {
        Write-Host "   Ingress trouves:" -ForegroundColor Green
        $ingresses | ForEach-Object { Write-Host "     $_" -ForegroundColor Cyan }
    } else {
        Write-Host "   ❌ Aucun ingress trouve" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur ingress: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== 4. TEST PORT-FORWARD LOCAL ===" -ForegroundColor Yellow

# Test port-forward
Write-Host "`n4.1 Test port-forward local..." -ForegroundColor Cyan
try {
    # Démarrer port-forward en arrière-plan
    $portForwardJob = Start-Job -ScriptBlock {
        kubectl port-forward service/coachlibre-frontend-service 8080:80 -n coachlibre
    }
    
    Start-Sleep -Seconds 3
    
    $localResponse = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "   Port-forward OK: Status $($localResponse.StatusCode)" -ForegroundColor Green
    if ($localResponse.Content -like "*CoachLibre*") {
        Write-Host "   ✅ Contenu CoachLibre via port-forward" -ForegroundColor Green
    }
    
    # Arrêter le job
    Stop-Job $portForwardJob
    Remove-Job $portForwardJob
} catch {
    Write-Host "   ❌ Erreur port-forward: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== 5. RESUME DIAGNOSTIC ===" -ForegroundColor Yellow
Write-Host "URL de test: http://$DOMAIN" -ForegroundColor Cyan
Write-Host "IP Load Balancer: $LB_IP" -ForegroundColor Cyan
Write-Host "Noeuds K3s: $($K3S_NODES -join ', ')" -ForegroundColor Cyan
