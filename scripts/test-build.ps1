# Script de test du build frontend
Write-Host "🧪 Test du build frontend..." -ForegroundColor Green

# Aller dans le répertoire frontend
Set-Location apps/frontend

# Vérifier si pnpm est installé
try {
    pnpm --version
} catch {
    Write-Host "❌ pnpm n'est pas installé. Installation..." -ForegroundColor Red
    npm install -g pnpm
}

# Installer les dépendances
Write-Host "📦 Installation des dépendances..." -ForegroundColor Yellow
pnpm install

# Tester le build
Write-Host "🔨 Test du build..." -ForegroundColor Yellow
pnpm run build

# Vérifier si le répertoire dist existe
if (Test-Path "dist") {
    Write-Host "✅ Build réussi! Répertoire dist créé." -ForegroundColor Green
    Get-ChildItem dist -Recurse | Select-Object Name, Length
} else {
    Write-Host "❌ Build échoué! Répertoire dist non trouvé." -ForegroundColor Red
    Write-Host "📁 Contenu du répertoire:" -ForegroundColor Yellow
    Get-ChildItem
}

# Retourner au répertoire racine
Set-Location ../..
