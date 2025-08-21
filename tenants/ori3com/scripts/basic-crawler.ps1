# Script de crawling basique pour Ori3Com
param(
    [string]$SourceUrl = "https://www.ori3com.cloud",
    [string]$OutputDir = "tenants/ori3com/content"
)

Write-Host "🚀 Crawling basique du site Ori3Com..." -ForegroundColor Green

# Créer les dossiers
$directories = @(
    "$OutputDir",
    "$OutputDir/assets",
    "$OutputDir/assets/css",
    "$OutputDir/assets/js",
    "$OutputDir/assets/images",
    "$OutputDir/pages"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "📁 Créé: $dir" -ForegroundColor Yellow
    }
}

# Headers pour contourner les protections
$headers = @{
    'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0'
    'Accept' = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    'Accept-Language' = 'fr-FR,fr;q=0.8,en-US;q=0.5,en;q=0.3'
}

# Télécharger la page principale
Write-Host "🌐 Téléchargement de la page principale..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $SourceUrl -Headers $headers -UseBasicParsing -TimeoutSec 30
    $response.Content | Out-File -FilePath "$OutputDir/index.html" -Encoding UTF8
    Write-Host "✅ Page principale téléchargée" -ForegroundColor Green
    
    # Analyser le contenu
    $htmlContent = $response.Content
    Write-Host "📊 Taille du contenu: $($htmlContent.Length) caractères" -ForegroundColor Cyan
    
    # Créer un rapport
    $report = @"
# Rapport de Crawling Basique - Ori3Com
Date: $(Get-Date)
URL Source: $SourceUrl
Dossier de sortie: $OutputDir

## Statistiques
- Taille du contenu: $($htmlContent.Length) caractères
- Contenu extrait avec succès

## Prochaines étapes
1. Analyser le contenu extrait
2. Adapter les chemins dans le HTML
3. Créer la version dynamique
4. Déployer sur Kubernetes
"@
    
    $report | Out-File -FilePath "$OutputDir/crawling-report.md" -Encoding UTF8
    Write-Host "📋 Rapport créé" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erreur lors du téléchargement: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "🎉 Crawling terminé !" -ForegroundColor Green
Write-Host "📁 Vérifiez le contenu dans: $OutputDir" -ForegroundColor Yellow

