# Script de crawling avancé pour Ori3Com avec contournement Cloudflare
param(
    [string]$SourceUrl = "https://www.ori3com.cloud",
    [string]$OutputDir = "tenants/ori3com/content"
)

Write-Host "🚀 Crawling avancé du site Ori3Com..." -ForegroundColor Green
Write-Host "URL Source: $SourceUrl" -ForegroundColor Cyan
Write-Host "Dossier de sortie: $OutputDir" -ForegroundColor Cyan

# Configuration des User-Agents réalistes
$userAgents = @(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:119.0) Gecko/20100101 Firefox/119.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:120.0) Gecko/20100101 Firefox/120.0",
    "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0"
)

# Headers réalistes pour contourner Cloudflare
$headers = @{
    'Accept' = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
    'Accept-Language' = 'fr-FR,fr;q=0.8,en-US;q=0.5,en;q=0.3'
    'Accept-Encoding' = 'gzip, deflate, br'
    'DNT' = '1'
    'Connection' = 'keep-alive'
    'Upgrade-Insecure-Requests' = '1'
    'Sec-Fetch-Dest' = 'document'
    'Sec-Fetch-Mode' = 'navigate'
    'Sec-Fetch-Site' = 'none'
    'Sec-Fetch-User' = '?1'
    'Cache-Control' = 'max-age=0'
}

# Fonction pour générer un délai aléatoire
function Get-RandomDelay {
    param([int]$MinSeconds = 1, [int]$MaxSeconds = 3)
    $delay = Get-Random -Minimum $MinSeconds -Maximum $MaxSeconds
    Write-Host "⏳ Attente de $delay secondes..." -ForegroundColor Yellow
    Start-Sleep -Seconds $delay
}

# Fonction pour télécharger avec gestion d'erreurs et retry
function Download-UrlWithRetry {
    param(
        [string]$Url, 
        [string]$OutputPath,
        [int]$MaxRetries = 3
    )
    
    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            # Sélectionner un User-Agent aléatoire
            $randomUserAgent = $userAgents | Get-Random
            $headers['User-Agent'] = $randomUserAgent
            
            Write-Host "📥 Tentative $attempt/$MaxRetries - $Url" -ForegroundColor Cyan
            
            $response = Invoke-WebRequest -Uri $Url -Headers $headers -UseBasicParsing -TimeoutSec 30
            
            # Vérifier si c'est une page Cloudflare
            if ($response.Content -match "cloudflare" -or $response.Content -match "checking your browser") {
                Write-Host "⚠️  Détection Cloudflare, attente plus longue..." -ForegroundColor Yellow
                Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 10)
                continue
            }
            
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

# Créer les dossiers nécessaires
$directories = @(
    "$OutputDir",
    "$OutputDir/assets",
    "$OutputDir/assets/css",
    "$OutputDir/assets/js",
    "$OutputDir/assets/images",
    "$OutputDir/assets/fonts",
    "$OutputDir/pages"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "📁 Créé: $dir" -ForegroundColor Yellow
    }
}

# Fonction pour extraire les URLs des ressources avec regex avancées
function Extract-ResourceUrls {
    param([string]$HtmlContent, [string]$BaseUrl)
    
    $urls = @()
    
    # Patterns pour différents types de ressources
    $patterns = @{
        'css' = @(
            'href="([^"]*\.css[^"]*)"',
            'url\(["\']?([^"\']*\.css[^"\']*)["\']?\)'
        )
        'js' = @(
            'src="([^"]*\.js[^"]*)"',
            'script.*?src="([^"]*\.js[^"]*)"'
        )
        'images' = @(
            'src="([^"]*\.(jpg|jpeg|png|gif|svg|webp|ico)[^"]*)"',
            'background.*?url\(["\']?([^"\']*\.(jpg|jpeg|png|gif|svg|webp)[^"\']*)["\']?\)',
            'data-src="([^"]*\.(jpg|jpeg|png|gif|svg|webp)[^"]*)"'
        )
        'fonts' = @(
            'src:.*?url\(["\']?([^"\']*\.(woff|woff2|ttf|eot)[^"\']*)["\']?\)',
            'href="([^"]*\.(woff|woff2|ttf|eot)[^"]*)"'
        )
    }
    
    foreach ($type in $patterns.Keys) {
        foreach ($pattern in $patterns[$type]) {
            $matches = [regex]::Matches($HtmlContent, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            foreach ($match in $matches) {
                $url = $match.Groups[1].Value
                if ($url.StartsWith("http")) {
                    $urls += @{Url = $url; Type = $type}
                } elseif ($url.StartsWith("/")) {
                    $urls += @{Url = "$BaseUrl$url"; Type = $type}
                } elseif ($url.StartsWith("./") -or $url.StartsWith("../")) {
                    $urls += @{Url = "$BaseUrl/$url"; Type = $type}
                } else {
                    $urls += @{Url = "$BaseUrl/$url"; Type = $type}
                }
            }
        }
    }
    
    return $urls | Sort-Object -Property Url -Unique
}

# Fonction pour normaliser les URLs
function Normalize-Url {
    param([string]$Url, [string]$BaseUrl)
    
    if ($Url.StartsWith("//")) {
        return "https:$Url"
    } elseif ($Url.StartsWith("/")) {
        return "$BaseUrl$Url"
    } elseif ($Url.StartsWith("http")) {
        return $Url
    } else {
        return "$BaseUrl/$Url"
    }
}

# Télécharger la page principale
Write-Host "🌐 Téléchargement de la page principale..." -ForegroundColor Yellow
$mainResponse = Download-UrlWithRetry -Url $SourceUrl -OutputPath "$OutputDir/index.html"

if ($mainResponse) {
    $htmlContent = $mainResponse.Content
    
    # Extraire les URLs des ressources
    Write-Host "🔍 Extraction des URLs des ressources..." -ForegroundColor Yellow
    $resourceUrls = Extract-ResourceUrls -HtmlContent $htmlContent -BaseUrl $SourceUrl
    
    Write-Host "📊 Ressources trouvées: $($resourceUrls.Count)" -ForegroundColor Cyan
    
    # Télécharger les ressources avec délais aléatoires
    foreach ($resource in $resourceUrls) {
        $url = $resource.Url
        $type = $resource.Type
        $fileName = [System.IO.Path]::GetFileName($url)
        
        # Éviter les URLs vides ou invalides
        if ([string]::IsNullOrEmpty($fileName) -or $fileName -eq "." -or $fileName -eq "..") {
            continue
        }
        
        switch ($type) {
            "css" { 
                $outputPath = "$OutputDir/assets/css/$fileName"
                Download-UrlWithRetry -Url $url -OutputPath $outputPath
            }
            "js" { 
                $outputPath = "$OutputDir/assets/js/$fileName"
                Download-UrlWithRetry -Url $url -OutputPath $outputPath
            }
            "images" { 
                $outputPath = "$OutputDir/assets/images/$fileName"
                Download-UrlWithRetry -Url $url -OutputPath $outputPath
            }
            "fonts" { 
                $outputPath = "$OutputDir/assets/fonts/$fileName"
                Download-UrlWithRetry -Url $url -OutputPath $outputPath
            }
        }
        
        # Délai aléatoire entre chaque téléchargement
        Get-RandomDelay -MinSeconds 1 -MaxSeconds 3
    }
    
    # Créer un fichier de rapport détaillé
    $report = @"
# Rapport de Crawling Avancé - Ori3Com
Date: $(Get-Date)
URL Source: $SourceUrl
Dossier de sortie: $OutputDir

## Statistiques
- Ressources trouvées: $($resourceUrls.Count)
- CSS: $($resourceUrls | Where-Object {$_.Type -eq 'css'} | Measure-Object | Select-Object -ExpandProperty Count)
- JavaScript: $($resourceUrls | Where-Object {$_.Type -eq 'js'} | Measure-Object | Select-Object -ExpandProperty Count)
- Images: $($resourceUrls | Where-Object {$_.Type -eq 'images'} | Measure-Object | Select-Object -ExpandProperty Count)
- Fonts: $($resourceUrls | Where-Object {$_.Type -eq 'fonts'} | Measure-Object | Select-Object -ExpandProperty Count)

## Ressources extraites par type
### CSS
$($resourceUrls | Where-Object {$_.Type -eq 'css'} | ForEach-Object {$_.Url} | Out-String)

### JavaScript
$($resourceUrls | Where-Object {$_.Type -eq 'js'} | ForEach-Object {$_.Url} | Out-String)

### Images
$($resourceUrls | Where-Object {$_.Type -eq 'images'} | ForEach-Object {$_.Url} | Out-String)

### Fonts
$($resourceUrls | Where-Object {$_.Type -eq 'fonts'} | ForEach-Object {$_.Url} | Out-String)

## Prochaines étapes
1. Analyser le contenu extrait
2. Adapter les chemins dans le HTML
3. Créer la version dynamique
4. Déployer sur Kubernetes
"@
    
    $report | Out-File -FilePath "$OutputDir/crawling-report.md" -Encoding UTF8
    Write-Host "📋 Rapport créé: $OutputDir/crawling-report.md" -ForegroundColor Green
}

Write-Host "🎉 Crawling terminé !" -ForegroundColor Green
Write-Host "📁 Vérifiez le contenu dans: $OutputDir" -ForegroundColor Yellow
