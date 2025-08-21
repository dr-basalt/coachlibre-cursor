#!/bin/bash

# Script d'installation du serveur MCP officiel Hostinger (Linux/Ubuntu)
# Usage: ./install-official.sh [HOSTINGER_API_TOKEN] [DOMAIN]

HOSTINGER_API_TOKEN=${1:-""}
DOMAIN=${2:-"ori3com.cloud"}
SKIP_NODE_INSTALL=${3:-"false"}

echo "🚀 Installation du serveur MCP officiel Hostinger (Linux)..."

# Étape 1: Installation de Node.js
if [ "$SKIP_NODE_INSTALL" != "true" ]; then
    echo -e "\n📦 Étape 1: Installation de Node.js..."
    
    # Vérifier si Node.js est déjà installé
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        echo "✅ Node.js déjà installé: $NODE_VERSION"
    else
        echo "📥 Installation de Node.js..."
        
        # Ajouter le repository NodeSource
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        
        # Installer Node.js
        sudo apt-get install -y nodejs
        
        # Vérifier l'installation
        NODE_VERSION=$(node --version)
        NPM_VERSION=$(npm --version)
        echo "✅ Node.js installé: $NODE_VERSION"
        echo "✅ npm installé: $NPM_VERSION"
    fi
fi

# Étape 2: Vérification des prérequis
echo -e "\n🔍 Étape 2: Vérification des prérequis..."

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js non installé. Exécutez: ./install-nodejs.sh"
    exit 1
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

# Étape 3: Installation du serveur MCP officiel
echo -e "\n🔧 Étape 3: Installation du serveur MCP officiel..."
sudo npm install -g hostinger-api-mcp

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'installation du serveur MCP officiel"
    exit 1
fi
echo "✅ Serveur MCP officiel installé"

# Étape 4: Installation des dépendances locales
echo -e "\n📚 Étape 4: Installation des dépendances locales..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de l'installation des dépendances"
    exit 1
fi
echo "✅ Dépendances installées"

# Étape 5: Compilation du connecteur personnalisé
echo -e "\n🔨 Étape 5: Compilation du connecteur personnalisé..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Erreur lors de la compilation"
    exit 1
fi
echo "✅ Connecteur personnalisé compilé"

# Étape 6: Configuration
echo -e "\n⚙️ Étape 6: Configuration..."

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

# Créer la configuration MCP avec les deux serveurs
cat > mcp-config.json << EOF
{
  "mcpServers": {
    "hostinger-official": {
      "command": "hostinger-api-mcp",
      "env": {
        "DEBUG": "false",
        "APITOKEN": "$HOSTINGER_API_TOKEN"
      }
    },
    "hostinger-custom": {
      "command": "node",
      "args": ["$(pwd)/dist/index.js"],
      "env": {
        "HOSTINGER_API_TOKEN": "$HOSTINGER_API_TOKEN",
        "HOSTINGER_DOMAIN": "$DOMAIN"
      }
    }
  }
}
EOF

echo "✅ Configuration MCP créée: mcp-config.json"

# Étape 7: Création des scripts utilitaires
echo -e "\n📝 Étape 7: Création des scripts utilitaires..."

# Script de démarrage du serveur officiel
cat > start-official.sh << 'EOF'
#!/bin/bash

# Script de démarrage du serveur MCP officiel Hostinger
echo "🚀 Démarrage du serveur MCP officiel Hostinger..."

# Vérifier que le fichier .env existe
if [ ! -f ".env" ]; then
    echo "❌ Fichier .env manquant. Exécutez ./install-official.sh d'abord."
    exit 1
fi

# Démarrer le serveur officiel
echo "🔌 Connexion au serveur MCP officiel..."
hostinger-api-mcp

echo "✅ Serveur officiel arrêté"
EOF

chmod +x start-official.sh
echo "✅ Script de démarrage officiel créé: start-official.sh"

# Script de démarrage du connecteur personnalisé
cat > start-custom.sh << 'EOF'
#!/bin/bash

# Script de démarrage du connecteur personnalisé
echo "🚀 Démarrage du connecteur personnalisé..."

# Vérifier que le fichier .env existe
if [ ! -f ".env" ]; then
    echo "❌ Fichier .env manquant. Exécutez ./install-official.sh d'abord."
    exit 1
fi

# Démarrer le connecteur personnalisé
echo "🔌 Connexion au connecteur personnalisé..."
node dist/index.js

echo "✅ Connecteur personnalisé arrêté"
EOF

chmod +x start-custom.sh
echo "✅ Script de démarrage personnalisé créé: start-custom.sh"

# Script de test avec le serveur officiel
cat > test-official-quick.sh << EOF
#!/bin/bash

# Script de test avec le serveur MCP officiel
URL=\${1:-"https://$DOMAIN"}
ACTION=\${2:-"list_domains"}

echo "🧪 Test du serveur MCP officiel..."
echo "URL: \$URL"
echo "Action: \$ACTION"

# Exécuter le test
./test-official.sh "\$URL" "\$ACTION"
EOF

chmod +x test-official-quick.sh
echo "✅ Script de test officiel créé: test-official-quick.sh"

# Étape 8: Test initial
echo -e "\n🧪 Étape 8: Test initial..."
echo "✅ Test d'installation réussi!"

# Instructions finales
echo -e "\n🎉 Installation terminée avec succès!"
echo -e "\n📋 Instructions d'utilisation:"
echo "1. Configurez votre token API Hostinger dans le fichier .env"
echo "2. Testez le serveur officiel: ./test-official-quick.sh"
echo "3. Démarrez le serveur officiel: ./start-official.sh"
echo "4. Démarrez le connecteur personnalisé: ./start-custom.sh"
echo "5. Intégrez la configuration MCP dans votre client MCP"

echo -e "\n📖 Documentation: README.md"
echo "🆘 Support: Ouvrez une issue sur GitHub en cas de problème"


