#!/bin/bash

echo "🔍 Diagnostic du workspace pnpm"
echo "================================"

echo ""
echo "1. Vérification de la structure des packages:"
echo "----------------------------------------------"
ls -la packages/
echo ""

echo "2. Contenu du pnpm-workspace.yaml:"
echo "----------------------------------"
cat pnpm-workspace.yaml
echo ""

echo "3. Packages trouvés par pnpm:"
echo "-----------------------------"
pnpm list --depth=0
echo ""

echo "4. Vérification des package.json:"
echo "---------------------------------"
echo "Package shared:"
cat packages/shared/package.json | grep -E '"name"|"version"'
echo ""

echo "Package UI:"
cat packages/ui/package.json | grep -E '"name"|"version"'
echo ""

echo "5. Tentative d'installation avec debug:"
echo "----------------------------------------"
pnpm install --loglevel=debug 2>&1 | head -20
echo ""

echo "6. Vérification des liens workspace:"
echo "------------------------------------"
pnpm list --depth=0 --json | jq '.[] | select(.name | startswith("@coachlibre"))' 2>/dev/null || echo "jq non disponible, affichage brut:"
pnpm list --depth=0 | grep "@coachlibre" || echo "Aucun package @coachlibre trouvé"
