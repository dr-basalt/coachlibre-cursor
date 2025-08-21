# Script de crawling simplifié pour Ori3Com
param(
    [string]$SourceUrl = "https://www.ori3com.cloud",
    [string]$OutputDir = "tenants/ori3com/content"
)

Write-Host "🚀 Crawling simplifié du site Ori3Com..." -ForegroundColor Green
Write-Host "URL Source: $SourceUrl" -ForegroundColor Cyan
Write-Host "Dossier de sortie: $OutputDir" -ForegroundColor Cyan

# User-Agent Firefox réaliste
$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0"

# Headers pour contourner les protections
$headers = @{
    'User-Agent' = $userAgent
    'Accept' = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
    'Accept-Language' = 'fr-FR,fr;q=0.8,en-US;q=0.5,en;q=0.3'
    'Accept-Encoding' = 'gzip, deflate, br'
    'DNT' = '1'
    'Connection' = 'keep-alive'
    'Upgrade-Insecure-Requests' = '1'
}

# Fonction pour télécharger avec retry
function Download-UrlWithRetry {
    param([string]$Url, [string]$OutputPath, [int]$MaxRetries = 3)
    
    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            Write-Host "📥 Tentative $attempt/$MaxRetries - $Url" -ForegroundColor Cyan
            
            $response = Invoke-WebRequest -Uri $Url -Headers $headers -UseBasicParsing -TimeoutSec 30
            
            $response.Content | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "✅ Téléchargé: $Url -> $OutputPath" -ForegroundColor Green
            return $response
            
        } catch {
            Write-Host "❌ Erreur tentative $attempt : $($_.Exception.Message)" -ForegroundColor Red
            if ($attempt -lt $MaxRetries) {
                $delay = $attempt * 2
                Write-Host "🔄 Nouvelle tentative dans $delay secondes..." -ForegroundColor Yellow
                Start-Sleep -Seconds $delay
            }
        }
    }
    
    Write-Host "💥 Échec après $MaxRetries tentatives pour: $Url" -ForegroundColor Red
    return $null
}

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

# Télécharger la page principale
Write-Host "🌐 Téléchargement de la page principale..." -ForegroundColor Yellow
$mainResponse = Download-UrlWithRetry -Url $SourceUrl -OutputPath "$OutputDir/index.html"

if ($mainResponse) {
    $htmlContent = $mainResponse.Content
    
    # Extraire les URLs des ressources avec des patterns simples
    Write-Host "🔍 Extraction des URLs des ressources..." -ForegroundColor Yellow
    
    # CSS
    $cssMatches = [regex]::Matches($htmlContent, 'href="([^"]*\.css[^"]*)"')
    foreach ($match in $cssMatches) {
        $url = $match.Groups[1].Value
        if ($url.StartsWith("http")) {
            $fileName = [System.IO.Path]::GetFileName($url)
            $outputPath = "$OutputDir/assets/css/$fileName"
            Download-UrlWithRetry -Url $url -OutputPath $outputPath
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 3)
        }
    }
    
    # JavaScript
    $jsMatches = [regex]::Matches($htmlContent, 'src="([^"]*\.js[^"]*)"')
    foreach ($match in $jsMatches) {
        $url = $match.Groups[1].Value
        if ($url.StartsWith("http")) {
            $fileName = [System.IO.Path]::GetFileName($url)
            $outputPath = "$OutputDir/assets/js/$fileName"
            Download-UrlWithRetry -Url $url -OutputPath $outputPath
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 3)
        }
    }
    
    # Images
    $imgMatches = [regex]::Matches($htmlContent, 'src="([^"]*\.jpg[^"]*)"')
    foreach ($match in $imgMatches) {
        $url = $match.Groups[1].Value
        if ($url.StartsWith("http")) {
            $fileName = [System.IO.Path]::GetFileName($url)
            $outputPath = "$OutputDir/assets/images/$fileName"
            Download-UrlWithRetry -Url $url -OutputPath $outputPath
            Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 3)
        }
    }
    
    Write-Host "📋 Rapport de crawling créé" -ForegroundColor Green
}

Write-Host "🎉 Crawling terminé !" -ForegroundColor Green
Write-Host "📁 Vérifiez le contenu dans: $OutputDir" -ForegroundColor Yellow
