# Script pour démarrer l'application Astro avec TinaCMS en mode développement
Write-Host "Démarrage de l'application Astro avec TinaCMS..." -ForegroundColor Green

# Vérifier si Node.js est installé
try {
    $nodeVersion = node --version
    Write-Host "Node.js détecté: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "Node.js n'est pas installé. Veuillez l'installer depuis https://nodejs.org/" -ForegroundColor Red
    Write-Host "Ou utilisez un gestionnaire de paquets comme Chocolatey: choco install nodejs" -ForegroundColor Yellow
    exit 1
}

# Vérifier si pnpm est installé
try {
    $pnpmVersion = pnpm --version
    Write-Host "pnpm détecté: $pnpmVersion" -ForegroundColor Green
} catch {
    Write-Host "pnpm n'est pas installé. Installation en cours..." -ForegroundColor Yellow
    npm install -g pnpm
}

# Aller dans le répertoire frontend
Set-Location "apps/frontend"

Write-Host "Installation des dépendances..." -ForegroundColor Cyan
pnpm install

Write-Host "Démarrage de l'application Astro avec TinaCMS..." -ForegroundColor Cyan
Write-Host "L'interface sera disponible sur:" -ForegroundColor Yellow
Write-Host "  - Site: http://localhost:4321" -ForegroundColor White
Write-Host "  - CMS: http://localhost:4321/admin" -ForegroundColor White
Write-Host ""
Write-Host "Appuyez sur Ctrl+C pour arrêter" -ForegroundColor Gray

# Démarrer TinaCMS en mode développement
pnpm run tina:dev
