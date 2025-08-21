# Script d'extraction du contenu du site Ori3Com
param(
    [string]$SourceUrl = "https://www.ori3com.cloud",
    [string]$OutputDir = "tenants/ori3com/content"
)

Write-Host "Extraction du contenu du site Ori3Com..." -ForegroundColor Green
Write-Host "URL Source: $SourceUrl" -ForegroundColor Cyan
Write-Host "Dossier de sortie: $OutputDir" -ForegroundColor Cyan

# Créer les dossiers nécessaires
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
        Write-Host "Créé: $dir" -ForegroundColor Yellow
    }
}

# Fonction pour télécharger une URL avec gestion d'erreurs
function Download-Url {
    param([string]$Url, [string]$OutputPath)
    
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 30 -UseBasicParsing
        $response.Content | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "Téléchargé: $Url -> $OutputPath" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "Erreur lors du téléchargement de $Url : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Fonction pour extraire les URLs des ressources
function Extract-ResourceUrls {
    param([string]$HtmlContent, [string]$BaseUrl)
    
    $urls = @()
    
    # Extraire les liens CSS
    $cssPattern = 'href="([^"]*\.css[^"]*)"'
    $cssMatches = [regex]::Matches($HtmlContent, $cssPattern)
    foreach ($match in $cssMatches) {
        $url = $match.Groups[1].Value
        if ($url.StartsWith("http")) {
            $urls += $url
        } elseif ($url.StartsWith("/")) {
            $urls += "$BaseUrl$url"
        } else {
            $urls += "$BaseUrl/$url"
        }
    }
    
    # Extraire les liens JavaScript
    $jsPattern = 'src="([^"]*\.js[^"]*)"'
    $jsMatches = [regex]::Matches($HtmlContent, $jsPattern)
    foreach ($match in $jsMatches) {
        $url = $match.Groups[1].Value
        if ($url.StartsWith("http")) {
            $urls += $url
        } elseif ($url.StartsWith("/")) {
            $urls += "$BaseUrl$url"
        } else {
            $urls += "$BaseUrl/$url"
        }
    }
    
    # Extraire les images
    $imgPattern = 'src="([^"]*\.(jpg|jpeg|png|gif|svg|webp)[^"]*)"'
    $imgMatches = [regex]::Matches($HtmlContent, $imgPattern)
    foreach ($match in $imgMatches) {
        $url = $match.Groups[1].Value
        if ($url.StartsWith("http")) {
            $urls += $url
        } elseif ($url.StartsWith("/")) {
            $urls += "$BaseUrl$url"
        } else {
            $urls += "$BaseUrl/$url"
        }
    }
    
    return $urls | Sort-Object -Unique
}

# Télécharger la page principale
Write-Host "Téléchargement de la page principale..." -ForegroundColor Yellow
$mainResponse = Download-Url -Url $SourceUrl -OutputPath "$OutputDir/index.html"

if ($mainResponse) {
    $htmlContent = $mainResponse.Content
    
    # Extraire les URLs des ressources
    Write-Host "Extraction des URLs des ressources..." -ForegroundColor Yellow
    $resourceUrls = Extract-ResourceUrls -HtmlContent $htmlContent -BaseUrl $SourceUrl
    
    Write-Host "Ressources trouvées: $($resourceUrls.Count)" -ForegroundColor Cyan
    
    # Télécharger les ressources
    foreach ($url in $resourceUrls) {
        $fileName = [System.IO.Path]::GetFileName($url)
        $extension = [System.IO.Path]::GetExtension($url)
        
        switch ($extension) {
            ".css" { 
                $outputPath = "$OutputDir/assets/css/$fileName"
                Download-Url -Url $url -OutputPath $outputPath
            }
            ".js" { 
                $outputPath = "$OutputDir/assets/js/$fileName"
                Download-Url -Url $url -OutputPath $outputPath
            }
            { $_ -match "\.(jpg|jpeg|png|gif|svg|webp)$" } { 
                $outputPath = "$OutputDir/assets/images/$fileName"
                Download-Url -Url $url -OutputPath $outputPath
            }
        }
    }
    
    # Créer un fichier de rapport
    $report = @"
# Rapport d'extraction - Ori3Com
Date: $(Get-Date)
URL Source: $SourceUrl
Dossier de sortie: $OutputDir

## Statistiques
- Ressources trouvées: $($resourceUrls.Count)
- CSS: $((Get-ChildItem "$OutputDir/assets/css" -ErrorAction SilentlyContinue).Count)
- JavaScript: $((Get-ChildItem "$OutputDir/assets/js" -ErrorAction SilentlyContinue).Count)
- Images: $((Get-ChildItem "$OutputDir/assets/images" -ErrorAction SilentlyContinue).Count)

## Ressources extraites
$($resourceUrls -join "`n")

## Prochaines étapes
1. Vérifier le contenu extrait
2. Adapter les chemins dans le HTML
3. Optimiser les ressources
4. Déployer sur Kubernetes
"@
    
    $report | Out-File -FilePath "$OutputDir/extraction-report.md" -Encoding UTF8
    Write-Host "Rapport créé: $OutputDir/extraction-report.md" -ForegroundColor Green
}

Write-Host "Extraction terminée !" -ForegroundColor Green
Write-Host "Vérifiez le contenu dans: $OutputDir" -ForegroundColor Yellow
