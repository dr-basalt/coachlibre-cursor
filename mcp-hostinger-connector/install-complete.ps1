# Script d'installation complet du connecteur MCP Hostinger
param(
    [string]$HostingerApiKey = "",
    [string]$Domain = "ori3com.cloud",
    [switch]$SkipNodeInstall
)

Write-Host "Installation complete du connecteur MCP Hostinger..." -ForegroundColor Green

# Étape 1: Installation de Node.js
if (!$SkipNodeInstall) {
    Write-Host "`nEtape 1: Installation de Node.js..." -ForegroundColor Cyan
    . .\install-nodejs.ps1
}

# Étape 2: Vérification des prérequis
Write-Host "`nEtape 2: Verification des prerequis..." -ForegroundColor Cyan

# Vérifier Node.js
try {
    $nodeVersion = node --version
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "Node.js non installe. Executez: .\install-nodejs.ps1" -ForegroundColor Red
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

# Étape 3: Installation des dépendances
Write-Host "`nEtape 3: Installation des dependances..." -ForegroundColor Cyan
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de l'installation des dependances" -ForegroundColor Red
    exit 1
}
Write-Host "Dependances installees" -ForegroundColor Green

# Étape 4: Compilation
Write-Host "`nEtape 4: Compilation du projet..." -ForegroundColor Cyan
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de la compilation" -ForegroundColor Red
    exit 1
}
Write-Host "Projet compile" -ForegroundColor Green

# Étape 5: Configuration
Write-Host "`nEtape 5: Configuration..." -ForegroundColor Cyan

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

# Étape 6: Création des scripts utilitaires
Write-Host "`nEtape 6: Creation des scripts utilitaires..." -ForegroundColor Cyan

# Script de démarrage
$startScript = @"
# Script de demarrage du connecteur MCP Hostinger
Write-Host "Demarrage du connecteur MCP Hostinger..." -ForegroundColor Green

# Verifier que le fichier .env existe
if (!(Test-Path ".env")) {
    Write-Host "Fichier .env manquant. Executez install-complete.ps1 d'abord." -ForegroundColor Red
    exit 1
}

# Demarrer le connecteur
Write-Host "Connexion au serveur MCP..." -ForegroundColor Yellow
node dist/index.js

Write-Host "Connecteur arrete" -ForegroundColor Green
"@

$startScript | Out-File -FilePath "start-connector.ps1" -Encoding UTF8
Write-Host "Script de demarrage cree: start-connector.ps1" -ForegroundColor Green

# Script de test rapide
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

# Étape 7: Test initial
Write-Host "`nEtape 7: Test initial..." -ForegroundColor Cyan
Write-Host "Test de compilation reussi!" -ForegroundColor Green

# Instructions finales
Write-Host "`nInstallation terminee avec succes!" -ForegroundColor Green
Write-Host "`nInstructions d'utilisation:" -ForegroundColor Cyan
Write-Host "1. Configurez votre cle API Hostinger dans le fichier .env" -ForegroundColor White
Write-Host "2. Testez le connecteur: .\quick-test.ps1" -ForegroundColor White
Write-Host "3. Demarrez le connecteur: .\start-connector.ps1" -ForegroundColor White
Write-Host "4. Integrez la configuration MCP dans votre client MCP" -ForegroundColor White

Write-Host "`nDocumentation: README.md" -ForegroundColor Yellow
Write-Host "Support: Ouvrez une issue sur GitHub en cas de probleme" -ForegroundColor Yellow


