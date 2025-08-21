#!/bin/bash

# Script d'installation automatique de Node.js (Linux/Ubuntu)
# Usage: ./install-nodejs.sh [VERSION]

NODE_VERSION=${1:-"20"}

echo "🚀 Installation automatique de Node.js (Linux/Ubuntu)..."

# Vérifier si Node.js est déjà installé
if command -v node &> /dev/null; then
    CURRENT_VERSION=$(node --version)
    echo "✅ Node.js déjà installé: $CURRENT_VERSION"
    
    # Vérifier si la version demandée est différente
    if [[ "$CURRENT_VERSION" == *"v$NODE_VERSION"* ]]; then
        echo "✅ Version $NODE_VERSION déjà installée"
        exit 0
    else
        echo "⚠️ Version différente détectée. Mise à jour vers v$NODE_VERSION..."
    fi
fi

# Détecter la distribution Linux
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "❌ Impossible de détecter la distribution Linux"
    exit 1
fi

echo "📋 Distribution détectée: $OS $VER"

# Installation selon la distribution
case $OS in
    "Ubuntu"|"Debian GNU/Linux")
        echo "📦 Installation pour Ubuntu/Debian..."
        
        # Mettre à jour les paquets
        sudo apt-get update
        
        # Installer les dépendances
        sudo apt-get install -y curl wget gnupg2
        
        # Ajouter le repository NodeSource
        echo "📥 Ajout du repository NodeSource..."
        curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
        
        # Installer Node.js
        echo "📦 Installation de Node.js v$NODE_VERSION..."
        sudo apt-get install -y nodejs
        
        # Vérifier l'installation
        if command -v node &> /dev/null; then
            NODE_VERSION_INSTALLED=$(node --version)
            NPM_VERSION_INSTALLED=$(npm --version)
            echo "✅ Node.js installé avec succès: $NODE_VERSION_INSTALLED"
            echo "✅ npm installé: $NPM_VERSION_INSTALLED"
        else
            echo "❌ Erreur lors de l'installation de Node.js"
            exit 1
        fi
        ;;
        
    "CentOS Linux"|"Red Hat Enterprise Linux"|"Rocky Linux"|"AlmaLinux")
        echo "📦 Installation pour CentOS/RHEL/Rocky/AlmaLinux..."
        
        # Installer les dépendances
        sudo yum install -y curl wget
        
        # Ajouter le repository NodeSource
        echo "📥 Ajout du repository NodeSource..."
        curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash -
        
        # Installer Node.js
        echo "📦 Installation de Node.js v$NODE_VERSION..."
        sudo yum install -y nodejs
        
        # Vérifier l'installation
        if command -v node &> /dev/null; then
            NODE_VERSION_INSTALLED=$(node --version)
            NPM_VERSION_INSTALLED=$(npm --version)
            echo "✅ Node.js installé avec succès: $NODE_VERSION_INSTALLED"
            echo "✅ npm installé: $NPM_VERSION_INSTALLED"
        else
            echo "❌ Erreur lors de l'installation de Node.js"
            exit 1
        fi
        ;;
        
    "Fedora")
        echo "📦 Installation pour Fedora..."
        
        # Installer les dépendances
        sudo dnf install -y curl wget
        
        # Ajouter le repository NodeSource
        echo "📥 Ajout du repository NodeSource..."
        curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash -
        
        # Installer Node.js
        echo "📦 Installation de Node.js v$NODE_VERSION..."
        sudo dnf install -y nodejs
        
        # Vérifier l'installation
        if command -v node &> /dev/null; then
            NODE_VERSION_INSTALLED=$(node --version)
            NPM_VERSION_INSTALLED=$(npm --version)
            echo "✅ Node.js installé avec succès: $NODE_VERSION_INSTALLED"
            echo "✅ npm installé: $NPM_VERSION_INSTALLED"
        else
            echo "❌ Erreur lors de l'installation de Node.js"
            exit 1
        fi
        ;;
        
    *)
        echo "❌ Distribution non supportée: $OS"
        echo "📋 Distributions supportées: Ubuntu, Debian, CentOS, RHEL, Rocky Linux, AlmaLinux, Fedora"
        echo "💡 Installation manuelle requise depuis: https://nodejs.org/"
        exit 1
        ;;
esac

# Configuration post-installation
echo "🔧 Configuration post-installation..."

# Créer un lien symbolique global pour npm si nécessaire
if [ ! -L /usr/local/bin/npm ]; then
    sudo ln -sf /usr/bin/npm /usr/local/bin/npm
fi

# Configurer npm pour les installations globales sans sudo
echo "📁 Configuration de npm pour les installations globales..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Ajouter au PATH si pas déjà présent
if ! grep -q "npm-global" ~/.bashrc; then
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
    echo "📝 PATH mis à jour dans ~/.bashrc"
fi

# Recharger le profil
source ~/.bashrc

# Vérification finale
echo "🔍 Vérification finale..."
NODE_FINAL_VERSION=$(node --version)
NPM_FINAL_VERSION=$(npm --version)
NODE_PATH=$(which node)
NPM_PATH=$(which npm)

echo "✅ Installation terminée avec succès!"
echo "📊 Informations finales:"
echo "   - Node.js: $NODE_FINAL_VERSION ($NODE_PATH)"
echo "   - npm: $NPM_FINAL_VERSION ($NPM_PATH)"
echo "   - Répertoire npm global: ~/.npm-global"

echo -e "\n💡 Pour installer des paquets globaux sans sudo:"
echo "   npm install -g <package-name>"

echo -e "\n🔄 Redémarrez votre terminal ou exécutez:"
echo "   source ~/.bashrc"





