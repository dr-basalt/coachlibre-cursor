#!/bin/bash

# 🔧 Script de correction TypeScript CoachLibre
# Auteur: CoachLibre Team
# Version: 1.0.0

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour créer le tsconfig.json racine
create_root_tsconfig() {
    print_status "Création du tsconfig.json racine..."
    
    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "allowJs": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./",
    "baseUrl": ".",
    "paths": {
      "@coachlibre/shared": ["packages/shared/src"],
      "@coachlibre/ui": ["packages/ui/src"],
      "@coachlibre/agents": ["packages/agents"],
      "@coachlibre/api": ["apps/api"],
      "@coachlibre/frontend": ["apps/frontend"],
      "@coachlibre/backoffice": ["apps/backoffice"],
      "@coachlibre/frontoffice": ["apps/frontoffice"]
    }
  },
  "include": [
    "packages/**/*",
    "apps/**/*",
    "tools/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "build",
    "*.d.ts"
  ],
  "references": [
    { "path": "./packages/shared" },
    { "path": "./packages/ui" },
    { "path": "./packages/agents" },
    { "path": "./apps/api" },
    { "path": "./apps/frontend" },
    { "path": "./apps/backoffice" },
    { "path": "./apps/frontoffice" },
    { "path": "./tools/setup-wizard" }
  ]
}
EOF
    
    print_success "tsconfig.json racine créé"
}

# Fonction pour corriger les tsconfig.json des packages
fix_package_tsconfigs() {
    print_status "Correction des tsconfig.json des packages..."
    
    # Package agents
    cat > packages/agents/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./",
    "declaration": true,
    "declarationMap": true,
    "noEmit": false
  },
  "include": [
    "**/*.ts"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ]
}
EOF
    
    # Package shared
    cat > packages/shared/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "noEmit": false,
    "lib": ["ES2020", "DOM"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF
    
    # Package ui
    cat > packages/ui/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "noEmit": false,
    "lib": ["ES2020", "DOM"],
    "jsx": "react-jsx"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts", "**/*.stories.tsx"]
}
EOF
    
    print_success "tsconfig.json des packages corrigés"
}

# Fonction pour tester le build
test_build() {
    print_status "Test du build..."
    
    if pnpm run build; then
        print_success "Build réussi !"
        return 0
    else
        print_error "Build échoué"
        return 1
    fi
}

# Fonction principale
main() {
    echo "🔧 Correction TypeScript CoachLibre"
    echo "==================================="
    echo ""
    
    # Vérifier qu'on est dans le bon répertoire
    if [ ! -f "pnpm-workspace.yaml" ]; then
        print_error "Ce script doit être exécuté depuis la racine du projet CoachLibre"
        exit 1
    fi
    
    # Créer le tsconfig.json racine
    create_root_tsconfig
    
    # Corriger les tsconfig.json des packages
    fix_package_tsconfigs
    
    # Tester le build
    if test_build; then
        echo ""
        print_success "🎉 Configuration TypeScript corrigée avec succès !"
        echo ""
        echo "Vous pouvez maintenant :"
        echo "- Build le projet : pnpm run build"
        echo "- Lancer le développement : pnpm dev"
        echo "- Déployer sur K3s : ./scripts/install-k3s.sh"
        echo ""
    else
        print_error "❌ Il y a encore des problèmes avec la configuration TypeScript"
        exit 1
    fi
}

# Exécuter le script principal
main "$@" 