#!/bin/bash

# 🚀 Script de Build Optimisé CoachLibre
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

# Configuration de la mémoire
setup_memory() {
    print_status "Configuration de la mémoire pour le build..."
    
    # Augmenter la mémoire Node.js
    export NODE_OPTIONS="--max-old-space-size=4096"
    
    # Vérifier la mémoire disponible
    MEMORY_AVAILABLE=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    print_status "Mémoire disponible: ${MEMORY_AVAILABLE}MB"
    
    if [ "$MEMORY_AVAILABLE" -lt 2048 ]; then
        print_warning "Mémoire faible détectée, augmentation de la swap..."
        # Créer un fichier swap temporaire si nécessaire
        sudo fallocate -l 2G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
    fi
}

# Build séquentiel pour éviter les problèmes de mémoire
build_sequential() {
    print_status "Build séquentiel des packages..."
    
    # 1. Build shared (le plus simple)
    print_status "Building @coachlibre/shared..."
    cd packages/shared
    pnpm run build
    cd ../..
    
    # 2. Build agents
    print_status "Building @coachlibre/agents..."
    cd packages/agents
    pnpm run build
    cd ../..
    
    # 3. Build UI (avec plus de mémoire)
    print_status "Building @coachlibre/ui..."
    cd packages/ui
    NODE_OPTIONS="--max-old-space-size=4096" pnpm run build
    cd ../..
    
    # 4. Build setup-wizard
    print_status "Building @coachlibre/setup-wizard..."
    cd tools/setup-wizard
    pnpm run build
    cd ../..
    
    # 5. Build frontend
    print_status "Building @coachlibre/frontend..."
    cd apps/frontend
    NODE_OPTIONS="--max-old-space-size=4096" pnpm run build
    cd ../..
    
    # 6. Build API (pas de build nécessaire)
    print_status "API - pas de build nécessaire (Python)"
}

# Vérification du build
verify_build() {
    print_status "Vérification du build..."
    
    # Vérifier que les dossiers dist existent
    for package in packages/shared packages/agents packages/ui tools/setup-wizard; do
        if [ -d "$package/dist" ]; then
            print_success "✅ $package buildé avec succès"
        else
            print_error "❌ $package n'a pas de dossier dist"
            return 1
        fi
    done
    
    # Vérifier le frontend
    if [ -d "apps/frontend/dist" ]; then
        print_success "✅ Frontend buildé avec succès"
    else
        print_error "❌ Frontend n'a pas de dossier dist"
        return 1
    fi
    
    return 0
}

# Nettoyage
cleanup() {
    print_status "Nettoyage..."
    
    # Supprimer le swap temporaire si créé
    if [ -f "/swapfile" ]; then
        sudo swapoff /swapfile
        sudo rm /swapfile
    fi
}

# Fonction principale
main() {
    echo "🚀 Build Optimisé CoachLibre"
    echo "============================"
    echo ""
    
    # Vérifier qu'on est dans le bon répertoire
    if [ ! -f "pnpm-workspace.yaml" ]; then
        print_error "Ce script doit être exécuté depuis la racine du projet CoachLibre"
        exit 1
    fi
    
    # Configuration de la mémoire
    setup_memory
    
    # Build séquentiel
    if build_sequential; then
        print_success "Build séquentiel terminé"
    else
        print_error "Erreur lors du build séquentiel"
        cleanup
        exit 1
    fi
    
    # Vérification
    if verify_build; then
        print_success "🎉 Build réussi !"
    else
        print_error "❌ Vérification du build échouée"
        cleanup
        exit 1
    fi
    
    # Nettoyage
    cleanup
    
    echo ""
    print_success "✅ Build optimisé terminé avec succès !"
    echo ""
    echo "Vous pouvez maintenant :"
    echo "- Déployer avec Docker : docker-compose up -d"
    echo "- Déployer sur K3s : ./scripts/install-k3s.sh"
    echo "- Lancer le développement : pnpm dev"
    echo ""
}

# Gestion des erreurs
trap cleanup EXIT

# Exécuter le script principal
main "$@" 