#!/bin/bash

# Script pour préparer le déploiement Vercel
# Ce script copie les packages workspace dans le frontend pour éviter les erreurs de workspace

echo "🚀 Préparation du déploiement Vercel..."

# Créer un répertoire temporaire pour le déploiement
mkdir -p apps/frontend/vercel-deploy

# Copier le contenu du frontend
cp -r apps/frontend/* apps/frontend/vercel-deploy/

# Copier les packages workspace nécessaires
mkdir -p apps/frontend/vercel-deploy/packages/ui
mkdir -p apps/frontend/vercel-deploy/packages/shared

cp -r packages/ui/* apps/frontend/vercel-deploy/packages/ui/
cp -r packages/shared/* apps/frontend/vercel-deploy/packages/shared/

# Modifier le package.json pour utiliser des chemins relatifs
cd apps/frontend/vercel-deploy

# Remplacer les workspace:* par des chemins relatifs
sed -i 's/"@coachlibre\/ui": "workspace:\*"/"@coachlibre\/ui": "file:.\/packages\/ui"/g' package.json
sed -i 's/"@coachlibre\/shared": "workspace:\*"/"@coachlibre\/shared": "file:.\/packages\/shared"/g' package.json

echo "✅ Déploiement Vercel préparé dans apps/frontend/vercel-deploy/"
echo "📁 Utilisez ce répertoire pour votre déploiement Vercel"
