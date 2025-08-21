#!/bin/bash

# Script de démarrage rapide du connecteur MCP Hostinger (Linux)
# Usage: ./quick-start.sh [HOSTINGER_API_TOKEN] [DOMAIN]

HOSTINGER_API_TOKEN=${1:-""}
DOMAIN=${2:-"ori3com.cloud"}

echo "🚀 Démarrage rapide du connecteur MCP Hostinger (Linux)..."

# Vérifier les prérequis
echo "🔍 Vérification des prérequis..."

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js non installé. Installation automatique..."
    chmod +x install-nodejs.sh
    ./install-nodejs.sh
fi

# Vérifier npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm non installé"
    exit 1
fi

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo "✅ Node.js: $NODE_VERSION"
echo "✅ npm: $NPM_VERSION"

# Installation rapide si pas déjà fait
if [ ! -f "package.json" ]; then
    echo "❌ Projet non initialisé. Installation complète requise."
    echo "💡 Exécutez: ./install-official.sh [TOKEN] [DOMAIN]"
    exit 1
fi

# Vérifier si les dépendances sont installées
if [ ! -d "node_modules" ]; then
    echo "📦 Installation des dépendances..."
    npm install
fi

# Vérifier si le projet est compilé
if [ ! -f "dist/index.js" ]; then
    echo "🔨 Compilation du projet..."
    npm run build
fi

# Configuration rapide
if [ ! -f ".env" ]; then
    echo "⚙️ Configuration rapide..."
    
    if [ -z "$HOSTINGER_API_TOKEN" ]; then
        echo "❌ Token API Hostinger manquant"
        echo "💡 Usage: ./quick-start.sh [TOKEN] [DOMAIN]"
        exit 1
    fi
    
    # Créer le fichier .env
    cat > .env << EOF
# Configuration du connecteur MCP Hostinger
HOSTINGER_API_TOKEN=$HOSTINGER_API_TOKEN
HOSTINGER_DOMAIN=$DOMAIN

# Configuration pour le serveur MCP officiel
DEBUG=false
APITOKEN=$HOSTINGER_API_TOKEN

# Configuration optionnelle pour WordPress
WORDPRESS_USERNAME=admin
WORDPRESS_PASSWORD=your_password_here

# Configuration pour le crawling
CRAWL_DELAY=1000
MAX_CONCURRENT_REQUESTS=5
EOF
    
    echo "✅ Fichier .env créé"
fi

# Menu de sélection
echo -e "\n🎯 Sélectionnez une option:"
echo "1. Démarrer le serveur MCP officiel"
echo "2. Démarrer le connecteur personnalisé"
echo "3. Tester le serveur officiel"
echo "4. Tester le connecteur personnalisé"
echo "5. Migration d'un site depuis Hostinger"
echo "6. Quitter"

read -p "Votre choix (1-6): " choice

case $choice in
    1)
        echo "🚀 Démarrage du serveur MCP officiel..."
        if command -v hostinger-api-mcp &> /dev/null; then
            hostinger-api-mcp
        else
            echo "❌ Serveur MCP officiel non installé"
            echo "💡 Exécutez: sudo npm install -g hostinger-api-mcp"
        fi
        ;;
    2)
        echo "🚀 Démarrage du connecteur personnalisé..."
        node dist/index.js
        ;;
    3)
        echo "🧪 Test du serveur officiel..."
        if [ -f "test-official.sh" ]; then
            chmod +x test-official.sh
            ./test-official.sh
        else
            echo "❌ Script de test officiel non trouvé"
        fi
        ;;
    4)
        echo "🧪 Test du connecteur personnalisé..."
        if [ -f "test-connector.sh" ]; then
            chmod +x test-connector.sh
            ./test-connector.sh
        else
            echo "❌ Script de test connecteur non trouvé"
        fi
        ;;
    5)
        echo "🔄 Migration d'un site depuis Hostinger..."
        if [ -f "workflows/migrate-hostinger-site.sh" ]; then
            chmod +x workflows/migrate-hostinger-site.sh
            read -p "Domaine source: " source_domain
            read -p "Tenant cible: " target_tenant
            ./workflows/migrate-hostinger-site.sh "$source_domain" "$target_tenant" "$HOSTINGER_API_TOKEN"
        else
            echo "❌ Script de migration non trouvé"
        fi
        ;;
    6)
        echo "👋 Au revoir!"
        exit 0
        ;;
    *)
        echo "❌ Choix invalide"
        exit 1
        ;;
esac





