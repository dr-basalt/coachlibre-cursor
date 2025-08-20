# Script PowerShell pour préparer le déploiement Vercel
# Ce script copie les packages workspace dans le frontend pour éviter les erreurs de workspace

Write-Host "Preparation du deploiement Vercel..." -ForegroundColor Green

# Créer un répertoire temporaire pour le déploiement
$deployDir = "apps/frontend/vercel-deploy"
if (Test-Path $deployDir) {
    Remove-Item -Recurse -Force $deployDir
}
New-Item -ItemType Directory -Path $deployDir -Force

# Copier le contenu du frontend
Copy-Item -Path "apps/frontend/*" -Destination $deployDir -Recurse -Force

# Créer les répertoires pour les packages
New-Item -ItemType Directory -Path "$deployDir/packages/ui" -Force
New-Item -ItemType Directory -Path "$deployDir/packages/shared" -Force

# Copier les packages workspace nécessaires
Copy-Item -Path "packages/ui/*" -Destination "$deployDir/packages/ui" -Recurse -Force
Copy-Item -Path "packages/shared/*" -Destination "$deployDir/packages/shared" -Recurse -Force

# Modifier le package.json pour utiliser des chemins relatifs
$packageJsonPath = "$deployDir/package.json"
$packageJson = Get-Content $packageJsonPath -Raw
$packageJson = $packageJson -replace '"@coachlibre/ui": "workspace:\*"', '"@coachlibre/ui": "file:./packages/ui"'
$packageJson = $packageJson -replace '"@coachlibre/shared": "workspace:\*"', '"@coachlibre/shared": "file:./packages/shared"'
Set-Content -Path $packageJsonPath -Value $packageJson

Write-Host "Deploiement Vercel prepare dans $deployDir" -ForegroundColor Green
Write-Host "Utilisez ce repertoire pour votre deploiement Vercel" -ForegroundColor Yellow
