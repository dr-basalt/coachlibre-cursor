# Script d'installation automatique de Node.js
param(
    [string]$Version = "18.19.0"
)

Write-Host "Installation automatique de Node.js..." -ForegroundColor Green

# Vérifier si Node.js est déjà installé
try {
    $nodeVersion = node --version
    Write-Host "Node.js deja installe: $nodeVersion" -ForegroundColor Green
    return
} catch {
    Write-Host "Node.js non installe, installation en cours..." -ForegroundColor Yellow
}

# URL de téléchargement de Node.js
$nodeUrl = "https://nodejs.org/dist/v$Version/node-v$Version-x64.msi"
$installerPath = "$env:TEMP\node-v$Version-x64.msi"

Write-Host "Telechargement de Node.js v$Version..." -ForegroundColor Yellow

try {
    # Télécharger l'installateur
    Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath
    
    Write-Host "Installation de Node.js..." -ForegroundColor Yellow
    
    # Installer Node.js silencieusement
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait
    
    # Nettoyer le fichier temporaire
    if (Test-Path $installerPath) {
        Remove-Item $installerPath
    }
    
    # Rafraîchir les variables d'environnement
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host "Node.js installe avec succes!" -ForegroundColor Green
    
    # Vérifier l'installation
    try {
        $nodeVersion = node --version
        $npmVersion = npm --version
        Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
        Write-Host "npm: $npmVersion" -ForegroundColor Green
    } catch {
        Write-Host "Redemarrez votre terminal pour que les changements prennent effet" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Erreur lors de l'installation: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Installation manuelle requise depuis: https://nodejs.org/" -ForegroundColor Yellow
}




