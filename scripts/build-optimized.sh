#!/bin/bash

# Script de build optimisé pour Docker
set -e

echo "🔧 Installation des dépendances..."
pnpm install --frozen-lockfile

echo "📦 Build des packages partagés..."
pnpm run build --filter=@coachlibre/shared

echo "🎨 Build du package UI..."
pnpm run build --filter=@coachlibre/ui

echo "🚀 Build de l'application frontend..."
pnpm run build --filter=@coachlibre/frontend

echo "✅ Build terminé avec succès!" 