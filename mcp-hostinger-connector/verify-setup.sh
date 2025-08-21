#!/bin/bash

# Script de vérification de l'installation du connecteur MCP Hostinger
# Usage: ./verify-setup.sh

echo "🔍 Vérification de l'installation du connecteur MCP Hostinger..."

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [ "$status" = "WARNING" ]; then
        echo -e "${YELLOW}⚠️ $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

# Vérification des fichiers essentiels
echo -e "\n${BLUE}📁 Vérification des fichiers essentiels...${NC}"

# Fichiers de configuration
if [ -f "package.json" ]; then
    print_status "OK" "package.json trouvé"
else
    print_status "ERROR" "package.json manquant"
fi

if [ -f "tsconfig.json" ]; then
    print_status "OK" "tsconfig.json trouvé"
else
    print_status "ERROR" "tsconfig.json manquant"
fi

if [ -f ".env" ]; then
    print_status "OK" ".env trouvé"
else
    print_status "WARNING" ".env manquant (sera créé lors de la configuration)"
fi

# Scripts Windows
if [ -f "install-official.ps1" ]; then
    print_status "OK" "install-official.ps1 trouvé"
else
    print_status "ERROR" "install-official.ps1 manquant"
fi

if [ -f "test-official.ps1" ]; then
    print_status "OK" "test-official.ps1 trouvé"
else
    print_status "ERROR" "test-official.ps1 manquant"
fi

# Scripts Linux
if [ -f "install-official.sh" ]; then
    print_status "OK" "install-official.sh trouvé"
else
    print_status "ERROR" "install-official.sh manquant"
fi

if [ -f "test-official.sh" ]; then
    print_status "OK" "test-official.sh trouvé"
else
    print_status "ERROR" "test-official.sh manquant"
fi

if [ -f "install-nodejs.sh" ]; then
    print_status "OK" "install-nodejs.sh trouvé"
else
    print_status "ERROR" "install-nodejs.sh manquant"
fi

if [ -f "quick-start.sh" ]; then
    print_status "OK" "quick-start.sh trouvé"
else
    print_status "ERROR" "quick-start.sh manquant"
fi

# Workflows
if [ -f "workflows/migrate-hostinger-site.ps1" ]; then
    print_status "OK" "workflows/migrate-hostinger-site.ps1 trouvé"
else
    print_status "ERROR" "workflows/migrate-hostinger-site.ps1 manquant"
fi

if [ -f "workflows/migrate-hostinger-site.sh" ]; then
    print_status "OK" "workflows/migrate-hostinger-site.sh trouvé"
else
    print_status "ERROR" "workflows/migrate-hostinger-site.sh manquant"
fi

# Documentation
if [ -f "README.md" ]; then
    print_status "OK" "README.md trouvé"
else
    print_status "ERROR" "README.md manquant"
fi

if [ -f "LINUX_SETUP.md" ]; then
    print_status "OK" "LINUX_SETUP.md trouvé"
else
    print_status "ERROR" "LINUX_SETUP.md manquant"
fi

if [ -f "USAGE.md" ]; then
    print_status "OK" "USAGE.md trouvé"
else
    print_status "ERROR" "USAGE.md manquant"
fi

if [ -f "SUMMARY.md" ]; then
    print_status "OK" "SUMMARY.md trouvé"
else
    print_status "ERROR" "SUMMARY.md manquant"
fi

# Vérification des permissions Linux
echo -e "\n${BLUE}🔐 Vérification des permissions Linux...${NC}"

if [ -x "install-official.sh" ]; then
    print_status "OK" "install-official.sh exécutable"
else
    print_status "WARNING" "install-official.sh non exécutable (chmod +x install-official.sh)"
fi

if [ -x "test-official.sh" ]; then
    print_status "OK" "test-official.sh exécutable"
else
    print_status "WARNING" "test-official.sh non exécutable (chmod +x test-official.sh)"
fi

if [ -x "workflows/migrate-hostinger-site.sh" ]; then
    print_status "OK" "workflows/migrate-hostinger-site.sh exécutable"
else
    print_status "WARNING" "workflows/migrate-hostinger-site.sh non exécutable (chmod +x workflows/migrate-hostinger-site.sh)"
fi

# Vérification de la structure des dossiers
echo -e "\n${BLUE}📂 Vérification de la structure des dossiers...${NC}"

if [ -d "src" ]; then
    print_status "OK" "Dossier src trouvé"
    if [ -f "src/index.ts" ]; then
        print_status "OK" "src/index.ts trouvé"
    else
        print_status "ERROR" "src/index.ts manquant"
    fi
else
    print_status "ERROR" "Dossier src manquant"
fi

if [ -d "workflows" ]; then
    print_status "OK" "Dossier workflows trouvé"
else
    print_status "ERROR" "Dossier workflows manquant"
fi

# Vérification des dépendances (si node_modules existe)
echo -e "\n${BLUE}📦 Vérification des dépendances...${NC}"

if [ -d "node_modules" ]; then
    print_status "OK" "node_modules trouvé"
    
    # Vérifier quelques dépendances clés
    if [ -d "node_modules/@modelcontextprotocol" ]; then
        print_status "OK" "SDK MCP installé"
    else
        print_status "WARNING" "SDK MCP non installé (npm install)"
    fi
    
    if [ -d "node_modules/puppeteer" ]; then
        print_status "OK" "Puppeteer installé"
    else
        print_status "WARNING" "Puppeteer non installé (npm install)"
    fi
else
    print_status "WARNING" "node_modules manquant (npm install)"
fi

# Vérification de la compilation (si dist existe)
echo -e "\n${BLUE}🔨 Vérification de la compilation...${NC}"

if [ -d "dist" ]; then
    print_status "OK" "Dossier dist trouvé"
    if [ -f "dist/index.js" ]; then
        print_status "OK" "dist/index.js trouvé"
    else
        print_status "ERROR" "dist/index.js manquant (npm run build)"
    fi
else
    print_status "WARNING" "Dossier dist manquant (npm run build)"
fi

# Vérification de Node.js (si disponible)
echo -e "\n${BLUE}🟢 Vérification de Node.js...${NC}"

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_status "OK" "Node.js installé: $NODE_VERSION"
    
    # Vérifier la version
    if [[ "$NODE_VERSION" == *"v18"* ]] || [[ "$NODE_VERSION" == *"v20"* ]] || [[ "$NODE_VERSION" == *"v21"* ]]; then
        print_status "OK" "Version Node.js compatible"
    else
        print_status "WARNING" "Version Node.js ancienne (recommandé: 18+)"
    fi
else
    print_status "WARNING" "Node.js non installé (./install-nodejs.sh)"
fi

if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_status "OK" "npm installé: $NPM_VERSION"
else
    print_status "WARNING" "npm non installé"
fi

# Vérification du serveur MCP officiel (si disponible)
echo -e "\n${BLUE}🔌 Vérification du serveur MCP officiel...${NC}"

if command -v hostinger-api-mcp &> /dev/null; then
    MCP_VERSION=$(hostinger-api-mcp --version 2>&1)
    print_status "OK" "Serveur MCP officiel installé: $MCP_VERSION"
else
    print_status "WARNING" "Serveur MCP officiel non installé (sudo npm install -g hostinger-api-mcp)"
fi

# Résumé final
echo -e "\n${BLUE}📊 Résumé de la vérification...${NC}"

TOTAL_FILES=0
MISSING_FILES=0
WARNINGS=0

# Compter les fichiers manquants et warnings
for file in package.json tsconfig.json install-official.ps1 test-official.ps1 install-official.sh test-official.sh install-nodejs.sh quick-start.sh workflows/migrate-hostinger-site.ps1 workflows/migrate-hostinger-site.sh README.md LINUX_SETUP.md USAGE.md SUMMARY.md src/index.ts; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    if [ ! -f "$file" ]; then
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

# Vérifier les warnings
if [ ! -f ".env" ]; then WARNINGS=$((WARNINGS + 1)); fi
if [ ! -d "node_modules" ]; then WARNINGS=$((WARNINGS + 1)); fi
if [ ! -d "dist" ]; then WARNINGS=$((WARNINGS + 1)); fi
if ! command -v node &> /dev/null; then WARNINGS=$((WARNINGS + 1)); fi
if ! command -v hostinger-api-mcp &> /dev/null; then WARNINGS=$((WARNINGS + 1)); fi

echo "📈 Statistiques:"
echo "   - Fichiers essentiels: $((TOTAL_FILES - MISSING_FILES))/$TOTAL_FILES"
echo "   - Fichiers manquants: $MISSING_FILES"
echo "   - Warnings: $WARNINGS"

if [ $MISSING_FILES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Installation complète et prête à l'emploi !${NC}"
    echo -e "\n${BLUE}📋 Prochaines étapes:${NC}"
    echo "1. Configurer votre token API Hostinger dans .env"
    echo "2. Tester l'installation: ./test-official.sh"
    echo "3. Démarrer le connecteur: ./quick-start.sh"
elif [ $MISSING_FILES -eq 0 ]; then
    echo -e "\n${YELLOW}⚠️ Installation partielle - quelques warnings à résoudre${NC}"
    echo -e "\n${BLUE}📋 Actions recommandées:${NC}"
    if [ ! -f ".env" ]; then echo "- Créer le fichier .env avec votre configuration"; fi
    if [ ! -d "node_modules" ]; then echo "- Exécuter: npm install"; fi
    if [ ! -d "dist" ]; then echo "- Exécuter: npm run build"; fi
    if ! command -v node &> /dev/null; then echo "- Installer Node.js: ./install-nodejs.sh"; fi
    if ! command -v hostinger-api-mcp &> /dev/null; then echo "- Installer le serveur MCP: sudo npm install -g hostinger-api-mcp"; fi
else
    echo -e "\n${RED}❌ Installation incomplète - fichiers essentiels manquants${NC}"
    echo -e "\n${BLUE}📋 Actions requises:${NC}"
    echo "- Vérifier que tous les fichiers du projet sont présents"
    echo "- Recloner le repository si nécessaire"
fi

echo -e "\n${BLUE}📖 Documentation:${NC}"
echo "- README.md - Guide principal"
echo "- LINUX_SETUP.md - Guide Linux spécifique"
echo "- USAGE.md - Guide d'utilisation détaillé"
echo "- SUMMARY.md - Résumé du projet"


