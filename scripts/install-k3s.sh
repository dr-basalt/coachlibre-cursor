#!/bin/bash

# 🚀 Script d'Installation CoachLibre sur K3s
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

# Fonction pour vérifier les prérequis
check_prerequisites() {
    print_status "Vérification des prérequis..."
    
    # Vérifier kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    
    # Vérifier helm
    if ! command -v helm &> /dev/null; then
        print_error "helm n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    
    # Vérifier docker
    if ! command -v docker &> /dev/null; then
        print_error "docker n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    
    # Vérifier l'accès au cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Impossible d'accéder au cluster Kubernetes. Vérifiez votre configuration."
        exit 1
    fi
    
    print_success "Tous les prérequis sont satisfaits"
}

# Fonction pour installer cert-manager
install_cert_manager() {
    print_status "Installation de cert-manager..."
    
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
    
    print_status "Attente que cert-manager soit prêt..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s
    
    print_success "cert-manager installé avec succès"
}

# Fonction pour configurer Let's Encrypt
configure_letsencrypt() {
    print_status "Configuration de Let's Encrypt..."
    
    read -p "Email pour Let's Encrypt: " EMAIL
    
    cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: $EMAIL
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
EOF
    
    print_success "Let's Encrypt configuré"
}

# Fonction pour configurer les secrets
configure_secrets() {
    print_status "Configuration des secrets..."
    
    echo "Veuillez fournir vos clés API :"
    read -p "Clé API OpenAI: " OPENAI_KEY
    read -p "Clé API Mistral: " MISTRAL_KEY
    read -p "Clé secrète Stripe: " STRIPE_KEY
    
    # Générer des secrets aléatoires
    JWT_SECRET=$(openssl rand -base64 32)
    ENCRYPTION_KEY=$(openssl rand -base64 32)
    
    # Encoder en base64
    OPENAI_B64=$(echo -n "$OPENAI_KEY" | base64)
    MISTRAL_B64=$(echo -n "$MISTRAL_KEY" | base64)
    STRIPE_B64=$(echo -n "$STRIPE_KEY" | base64)
    JWT_B64=$(echo -n "$JWT_SECRET" | base64)
    ENCRYPTION_B64=$(echo -n "$ENCRYPTION_KEY" | base64)
    
    # Créer le fichier secret.yaml
    cat > infrastructure/k8s/secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: coachlibre-secrets
  namespace: coachlibre
type: Opaque
data:
  OPENAI_API_KEY: "$OPENAI_B64"
  MISTRAL_API_KEY: "$MISTRAL_B64"
  STRIPE_SECRET_KEY: "$STRIPE_B64"
  JWT_SECRET: "$JWT_B64"
  ENCRYPTION_KEY: "$ENCRYPTION_B64"
EOF
    
    print_success "Secrets configurés"
}

# Fonction pour configurer les domaines
configure_domains() {
    print_status "Configuration des domaines..."
    
    read -p "Domaine frontend (ex: app.mondomaine.com): " FRONTEND_DOMAIN
    read -p "Domaine API (ex: api.mondomaine.com): " API_DOMAIN
    
    # Mettre à jour configmap.yaml
    sed -i "s/app.coachlibre.com/$FRONTEND_DOMAIN/g" infrastructure/k8s/configmap.yaml
    sed -i "s/api.coachlibre.com/$API_DOMAIN/g" infrastructure/k8s/configmap.yaml
    
    # Mettre à jour ingress.yaml
    sed -i "s/app.coachlibre.com/$FRONTEND_DOMAIN/g" infrastructure/k8s/ingress.yaml
    sed -i "s/api.coachlibre.com/$API_DOMAIN/g" infrastructure/k8s/ingress.yaml
    
    print_success "Domaines configurés"
}

# Fonction pour build les images Docker
build_images() {
    print_status "Build des images Docker..."
    
    # Build API
    print_status "Build de l'image API..."
    docker build -t coachlibre/api:latest ./apps/api
    
    # Build Frontend
    print_status "Build de l'image Frontend..."
    docker build -t coachlibre/frontend:latest ./apps/frontend
    
    print_success "Images Docker buildées"
}

# Fonction pour déployer CoachLibre
deploy_coachlibre() {
    print_status "Déploiement de CoachLibre..."
    
    cd infrastructure/k8s
    
    # Appliquer tous les manifests
    kubectl apply -k .
    
    cd ../..
    
    print_success "CoachLibre déployé"
}

# Fonction pour vérifier le déploiement
verify_deployment() {
    print_status "Vérification du déploiement..."
    
    # Attendre que les pods soient prêts
    print_status "Attente que les pods soient prêts..."
    kubectl wait --for=condition=ready pod -l app=postgresql -n coachlibre --timeout=300s
    kubectl wait --for=condition=ready pod -l app=redis -n coachlibre --timeout=300s
    kubectl wait --for=condition=ready pod -l app=qdrant -n coachlibre --timeout=300s
    kubectl wait --for=condition=ready pod -l app=api -n coachlibre --timeout=300s
    kubectl wait --for=condition=ready pod -l app=frontend -n coachlibre --timeout=300s
    
    # Afficher le statut
    print_status "Statut des pods :"
    kubectl get pods -n coachlibre
    
    print_status "Statut des services :"
    kubectl get services -n coachlibre
    
    print_status "Statut de l'ingress :"
    kubectl get ingress -n coachlibre
    
    print_success "Déploiement vérifié"
}

# Fonction principale
main() {
    echo "🚀 Installation de CoachLibre sur K3s"
    echo "====================================="
    echo ""
    
    # Vérifier les prérequis
    check_prerequisites
    
    # Installer cert-manager
    install_cert_manager
    
    # Configurer Let's Encrypt
    configure_letsencrypt
    
    # Configurer les secrets
    configure_secrets
    
    # Configurer les domaines
    configure_domains
    
    # Build les images
    build_images
    
    # Déployer CoachLibre
    deploy_coachlibre
    
    # Vérifier le déploiement
    verify_deployment
    
    echo ""
    print_success "🎉 Installation terminée avec succès !"
    echo ""
    echo "Vos services sont maintenant accessibles :"
    echo "- Frontend : https://$FRONTEND_DOMAIN"
    echo "- API : https://$API_DOMAIN"
    echo ""
    echo "Commandes utiles :"
    echo "- Vérifier les pods : kubectl get pods -n coachlibre"
    echo "- Voir les logs : kubectl logs -f deployment/api -n coachlibre"
    echo "- Accéder à un pod : kubectl exec -it deployment/api -n coachlibre -- bash"
    echo ""
}

# Exécuter le script principal
main "$@" 