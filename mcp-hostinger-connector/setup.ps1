# Script d'installation et de configuration du connecteur MCP Hostinger
param(
    [string]$HostingerApiKey = "",
    [string]$Domain = "ori3com.cloud",
    [switch]$SkipInstall
)

Write-Host "Installation du connecteur MCP Hostinger..." -ForegroundColor Green

# Vérifier les prérequis
Write-Host "Verification des prerequis..." -ForegroundColor Yellow

# Vérifier Node.js
try {
    $nodeVersion = node --version
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "Node.js non installe" -ForegroundColor Red
    Write-Host "Telechargez Node.js depuis: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Vérifier npm
try {
    $npmVersion = npm --version
    Write-Host "npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "npm non installe" -ForegroundColor Red
    exit 1
}

# Installation des dépendances
if (!$SkipInstall) {
    Write-Host "Installation des dependances..." -ForegroundColor Yellow
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erreur lors de l'installation des dependances" -ForegroundColor Red
        exit 1
    }
    Write-Host "Dependances installees" -ForegroundColor Green
}

# Compilation
Write-Host "Compilation du projet..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de la compilation" -ForegroundColor Red
    exit 1
}
Write-Host "Projet compile" -ForegroundColor Green

# Configuration
Write-Host "Configuration..." -ForegroundColor Yellow

# Créer le fichier .env
$envContent = @"
# Configuration du connecteur MCP Hostinger
HOSTINGER_API_KEY=$HostingerApiKey
HOSTINGER_DOMAIN=$Domain

# Configuration optionnelle pour WordPress
WORDPRESS_USERNAME=admin
WORDPRESS_PASSWORD=your_password_here

# Configuration pour le crawling
CRAWL_DELAY=1000
MAX_CONCURRENT_REQUESTS=5
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "Fichier .env cree" -ForegroundColor Green

# Créer la configuration MCP
$mcpConfig = @"
{
  "mcpServers": {
    "hostinger": {
      "command": "node",
      "args": ["$PWD\dist\index.js"],
      "env": {
        "HOSTINGER_API_KEY": "$HostingerApiKey",
        "HOSTINGER_DOMAIN": "$Domain"
      }
    }
  }
}
"@

$mcpConfig | Out-File -FilePath "mcp-config.json" -Encoding UTF8
Write-Host "Configuration MCP creee: mcp-config.json" -ForegroundColor Green

# Créer un script de démarrage
$startScript = @"
# Script de demarrage du connecteur MCP Hostinger
Write-Host "Demarrage du connecteur MCP Hostinger..." -ForegroundColor Green

# Verifier que le fichier .env existe
if (!(Test-Path ".env")) {
    Write-Host "Fichier .env manquant. Executez setup.ps1 d'abord." -ForegroundColor Red
    exit 1
}

# Demarrer le connecteur
Write-Host "Connexion au serveur MCP..." -ForegroundColor Yellow
node dist/index.js

Write-Host "Connecteur arrete" -ForegroundColor Green
"@

$startScript | Out-File -FilePath "start-connector.ps1" -Encoding UTF8
Write-Host "Script de demarrage cree: start-connector.ps1" -ForegroundColor Green

# Créer un script de test
$testScript = @"
# Script de test du connecteur
param(
    [string]`$Url = "https://$Domain",
    [string]`$Action = "detect_cms"
)

Write-Host "Test du connecteur..." -ForegroundColor Green
Write-Host "URL: `$Url" -ForegroundColor Cyan
Write-Host "Action: `$Action" -ForegroundColor Cyan

# Executer le test
. .\test-connector.ps1 -Url `$Url -Action `$Action
"@

$testScript | Out-File -FilePath "quick-test.ps1" -Encoding UTF8
Write-Host "Script de test cree: quick-test.ps1" -ForegroundColor Green

# Instructions d'utilisation
Write-Host "`nInstructions d'utilisation:" -ForegroundColor Cyan
Write-Host "1. Configurez votre cle API Hostinger dans le fichier .env" -ForegroundColor White
Write-Host "2. Testez le connecteur: .\quick-test.ps1" -ForegroundColor White
Write-Host "3. Demarrez le connecteur: .\start-connector.ps1" -ForegroundColor White
Write-Host "4. Integrez la configuration MCP dans votre client MCP" -ForegroundColor White

Write-Host "`nDocumentation: README.md" -ForegroundColor Yellow
Write-Host "Installation terminee !" -ForegroundColor Green
