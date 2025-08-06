#!/bin/bash

# 🚀 Script de Déploiement Simplifié CoachLibre
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

# Vérification des prérequis
check_prerequisites() {
    print_status "Vérification des prérequis..."
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker n'est pas installé"
        exit 1
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    print_success "Prérequis vérifiés"
}

# Build des images Docker
build_images() {
    print_status "Build des images Docker..."
    
    # Build API
    print_status "Building image API..."
    docker build -t coachlibre/api:latest ./apps/api
    
    # Build Frontend
    print_status "Building image Frontend..."
    docker build -t coachlibre/frontend:latest ./apps/frontend
    
    print_success "Images Docker buildées"
}

# Déploiement avec Docker Compose
deploy_docker() {
    print_status "Déploiement avec Docker Compose..."
    
    # Arrêter les conteneurs existants
    docker-compose down 2>/dev/null || true
    
    # Démarrer les services
    docker-compose up -d
    
    print_success "Déploiement Docker terminé"
}

# Vérification du déploiement
verify_deployment() {
    print_status "Vérification du déploiement..."
    
    # Attendre que les services soient prêts
    sleep 10
    
    # Vérifier les conteneurs
    if docker-compose ps | grep -q "Up"; then
        print_success "✅ Conteneurs démarrés"
    else
        print_error "❌ Conteneurs non démarrés"
        return 1
    fi
    
    # Tester l'API
    if curl -f http://localhost:8000/health >/dev/null 2>&1; then
        print_success "✅ API accessible"
    else
        print_warning "⚠️ API non accessible (peut prendre du temps à démarrer)"
    fi
    
    # Tester le frontend
    if curl -f http://localhost:3000 >/dev/null 2>&1; then
        print_success "✅ Frontend accessible"
    else
        print_warning "⚠️ Frontend non accessible (peut prendre du temps à démarrer)"
    fi
    
    return 0
}

# Affichage des informations
show_info() {
    echo ""
    print_success "🎉 Déploiement terminé !"
    echo ""
    echo "📊 Services disponibles :"
    echo "- Frontend : http://$(hostname -I | awk '{print $1}'):3000"
    echo "- API : http://$(hostname -I | awk '{print $1}'):8000"
    echo "- PostgreSQL : localhost:5432"
    echo "- Redis : localhost:6379"
    echo "- Qdrant : http://$(hostname -I | awk '{print $1}'):6333"
    echo ""
    echo "🔧 Commandes utiles :"
    echo "- Voir les logs : docker-compose logs -f"
    echo "- Arrêter : docker-compose down"
    echo "- Redémarrer : docker-compose restart"
    echo "- Statut : docker-compose ps"
    echo ""
}

# Fonction principale
main() {
    echo "🚀 Déploiement Simplifié CoachLibre"
    echo "==================================="
    echo ""
    
    # Vérifier qu'on est dans le bon répertoire
    if [ ! -f "docker-compose.yml" ]; then
        print_error "Ce script doit être exécuté depuis la racine du projet CoachLibre"
        exit 1
    fi
    
    # Vérification des prérequis
    check_prerequisites
    
    # Build des images
    build_images
    
    # Déploiement
    deploy_docker
    
    # Vérification
    if verify_deployment; then
        show_info
    else
        print_warning "⚠️ Déploiement terminé avec des avertissements"
        show_info
    fi
}

# Exécuter le script principal
main "$@" 