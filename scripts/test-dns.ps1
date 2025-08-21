# Script de test DNS
Write-Host "Test de resolution DNS..." -ForegroundColor Green

$domain = "coachlibre.infra.ori3com.cloud"

try {
    $result = Resolve-DnsName -Name $domain -Type A -ErrorAction Stop
    Write-Host "DNS resolu: $($result.IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "Erreur DNS: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Test termine" -ForegroundColor Green
