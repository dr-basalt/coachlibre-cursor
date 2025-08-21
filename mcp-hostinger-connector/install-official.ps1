# Script d'installation du serveur MCP officiel Hostinger
param(
    [string]$HostingerApiToken = "",
    [string]$Domain = "ori3com.cloud",
    [switch]$SkipNodeInstall
)

Write-Host "Installation du serveur MCP officiel Hostinger..." -ForegroundColor Green

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

# Étape 3: Installation du serveur MCP officiel
Write-Host "`nEtape 3: Installation du serveur MCP officiel..." -ForegroundColor Cyan
npm install -g hostinger-api-mcp

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de l'installation du serveur MCP officiel" -ForegroundColor Red
    exit 1
}
Write-Host "Serveur MCP officiel installe" -ForegroundColor Green

# Étape 4: Installation des dépendances locales
Write-Host "`nEtape 4: Installation des dependances locales..." -ForegroundColor Cyan
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de l'installation des dependances" -ForegroundColor Red
    exit 1
}
Write-Host "Dependances installees" -ForegroundColor Green

# Étape 5: Compilation du connecteur personnalisé
Write-Host "`nEtape 5: Compilation du connecteur personnalise..." -ForegroundColor Cyan
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors de la compilation" -ForegroundColor Red
    exit 1
}
Write-Host "Connecteur personnalise compile" -ForegroundColor Green

# Étape 6: Configuration
Write-Host "`nEtape 6: Configuration..." -ForegroundColor Cyan

# Créer le fichier .env
$envContent = @"
# Configuration du connecteur MCP Hostinger
HOSTINGER_API_TOKEN=$HostingerApiToken
HOSTINGER_DOMAIN=$Domain

# Configuration pour le serveur MCP officiel
DEBUG=false
APITOKEN=$HostingerApiToken

# Configuration optionnelle pour WordPress
WORDPRESS_USERNAME=admin
WORDPRESS_PASSWORD=your_password_here

# Configuration pour le crawling
CRAWL_DELAY=1000
MAX_CONCURRENT_REQUESTS=5
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "Fichier .env cree" -ForegroundColor Green

# Créer la configuration MCP avec les deux serveurs
$mcpConfig = @"
{
  "mcpServers": {
    "hostinger-official": {
      "command": "hostinger-api-mcp",
      "env": {
        "DEBUG": "false",
        "APITOKEN": "$HostingerApiToken"
      }
    },
    "hostinger-custom": {
      "command": "node",
      "args": ["$PWD\dist\index.js"],
      "env": {
        "HOSTINGER_API_TOKEN": "$HostingerApiToken",
        "HOSTINGER_DOMAIN": "$Domain"
      }
    }
  }
}
"@

$mcpConfig | Out-File -FilePath "mcp-config.json" -Encoding UTF8
Write-Host "Configuration MCP creee: mcp-config.json" -ForegroundColor Green

# Étape 7: Création des scripts utilitaires
Write-Host "`nEtape 7: Creation des scripts utilitaires..." -ForegroundColor Cyan

# Script de démarrage du serveur officiel
$startOfficialScript = @"
# Script de demarrage du serveur MCP officiel Hostinger
Write-Host "Demarrage du serveur MCP officiel Hostinger..." -ForegroundColor Green

# Verifier que le fichier .env existe
if (!(Test-Path ".env")) {
    Write-Host "Fichier .env manquant. Executez install-official.ps1 d'abord." -ForegroundColor Red
    exit 1
}

# Demarrer le serveur officiel
Write-Host "Connexion au serveur MCP officiel..." -ForegroundColor Yellow
hostinger-api-mcp

Write-Host "Serveur officiel arrete" -ForegroundColor Green
"@

$startOfficialScript | Out-File -FilePath "start-official.ps1" -Encoding UTF8
Write-Host "Script de demarrage officiel cree: start-official.ps1" -ForegroundColor Green

# Script de démarrage du connecteur personnalisé
$startCustomScript = @"
# Script de demarrage du connecteur personnalise
Write-Host "Demarrage du connecteur personnalise..." -ForegroundColor Green

# Verifier que le fichier .env existe
if (!(Test-Path ".env")) {
    Write-Host "Fichier .env manquant. Executez install-official.ps1 d'abord." -ForegroundColor Red
    exit 1
}

# Demarrer le connecteur personnalise
Write-Host "Connexion au connecteur personnalise..." -ForegroundColor Yellow
node dist/index.js

Write-Host "Connecteur personnalise arrete" -ForegroundColor Green
"@

$startCustomScript | Out-File -FilePath "start-custom.ps1" -Encoding UTF8
Write-Host "Script de demarrage personnalise cree: start-custom.ps1" -ForegroundColor Green

# Script de test avec le serveur officiel
$testOfficialScript = @"
# Script de test avec le serveur MCP officiel
param(
    [string]`$Url = "https://$Domain",
    [string]`$Action = "list_domains"
)

Write-Host "Test du serveur MCP officiel..." -ForegroundColor Green
Write-Host "URL: `$Url" -ForegroundColor Cyan
Write-Host "Action: `$Action" -ForegroundColor Cyan

# Executer le test
. .\test-official.ps1 -Url `$Url -Action `$Action
"@

$testOfficialScript | Out-File -FilePath "test-official-quick.ps1" -Encoding UTF8
Write-Host "Script de test officiel cree: test-official-quick.ps1" -ForegroundColor Green

# Étape 8: Test initial
Write-Host "`nEtape 8: Test initial..." -ForegroundColor Cyan
Write-Host "Test d'installation reussi!" -ForegroundColor Green

# Instructions finales
Write-Host "`nInstallation terminee avec succes!" -ForegroundColor Green
Write-Host "`nInstructions d'utilisation:" -ForegroundColor Cyan
Write-Host "1. Configurez votre token API Hostinger dans le fichier .env" -ForegroundColor White
Write-Host "2. Testez le serveur officiel: .\test-official-quick.ps1" -ForegroundColor White
Write-Host "3. Demarrez le serveur officiel: .\start-official.ps1" -ForegroundColor White
Write-Host "4. Demarrez le connecteur personnalise: .\start-custom.ps1" -ForegroundColor White
Write-Host "5. Integrez la configuration MCP dans votre client MCP" -ForegroundColor White

Write-Host "`nDocumentation: README.md" -ForegroundColor Yellow
Write-Host "Support: Ouvrez une issue sur GitHub en cas de probleme" -ForegroundColor Yellow




