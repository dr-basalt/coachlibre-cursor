# Guide d'installation Linux pour le connecteur MCP Hostinger

Ce guide détaille l'installation et l'utilisation du connecteur MCP Hostinger sur les systèmes Linux (Ubuntu 24.04+, CentOS, RHEL, etc.).

## 🐧 Prérequis système

### Distributions supportées
- **Ubuntu** 20.04+ / 22.04+ / 24.04+
- **Debian** 11+ / 12+
- **CentOS** 8+ / Stream
- **RHEL** 8+ / 9+
- **Rocky Linux** 8+ / 9+
- **AlmaLinux** 8+ / 9+
- **Fedora** 35+

### Prérequis logiciels
- **Node.js** 18+ (installé automatiquement)
- **npm** (installé avec Node.js)
- **curl** et **wget** (installés automatiquement)
- **sudo** (pour les installations globales)

## 🚀 Installation rapide

### Étape 1: Cloner le projet
```bash
git clone <repository-url>
cd mcp-hostinger-connector
```

### Étape 2: Rendre les scripts exécutables
```bash
chmod +x *.sh
chmod +x workflows/*.sh
```

### Étape 3: Installation automatique
```bash
# Installation complète avec Node.js
./install-official.sh "votre_token_hostinger" "ori3com.cloud"

# Ou démarrage rapide (si Node.js déjà installé)
./quick-start.sh "votre_token_hostinger" "ori3com.cloud"
```

## 📦 Installation manuelle

### Étape 1: Installation de Node.js
```bash
# Installation automatique de Node.js 20
./install-nodejs.sh 20

# Ou installation manuelle
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Étape 2: Installation du serveur MCP officiel
```bash
# Installation globale du serveur MCP officiel
sudo npm install -g hostinger-api-mcp

# Vérification
hostinger-api-mcp --version
```

### Étape 3: Installation des dépendances locales
```bash
# Installation des dépendances du projet
npm install

# Compilation du connecteur personnalisé
npm run build
```

### Étape 4: Configuration
```bash
# Copier le fichier d'exemple
cp .env.example .env

# Éditer la configuration
nano .env
```

## ⚙️ Configuration

### Variables d'environnement (.env)
```bash
# Configuration obligatoire
HOSTINGER_API_TOKEN=votre_token_hostinger
HOSTINGER_DOMAIN=ori3com.cloud

# Configuration pour le serveur MCP officiel
DEBUG=false
APITOKEN=votre_token_hostinger

# Configuration optionnelle WordPress
WORDPRESS_USERNAME=admin
WORDPRESS_PASSWORD=votre_mot_de_passe

# Configuration crawling
CRAWL_DELAY=1000
MAX_CONCURRENT_REQUESTS=5
```

### Configuration MCP (mcp-config.json)
```json
{
  "mcpServers": {
    "hostinger-official": {
      "command": "hostinger-api-mcp",
      "env": {
        "DEBUG": "false",
        "APITOKEN": "votre_token_hostinger"
      }
    },
    "hostinger-custom": {
      "command": "node",
      "args": ["/chemin/vers/mcp-hostinger-connector/dist/index.js"],
      "env": {
        "HOSTINGER_API_TOKEN": "votre_token_hostinger",
        "HOSTINGER_DOMAIN": "ori3com.cloud"
      }
    }
  }
}
```

## 🧪 Tests

### Test du serveur MCP officiel
```bash
# Test de base
./test-official.sh "https://ori3com.cloud" "list_domains"

# Test rapide
./test-official-quick.sh "https://ori3com.cloud" "get_domain_info"
```

### Test du connecteur personnalisé
```bash
# Test de détection CMS
./test-connector.sh "https://ori3com.cloud" "detect_cms"

# Test d'extraction de contenu
./test-connector.sh "https://ori3com.cloud" "extract_content"

# Test de crawling
./test-connector.sh "https://ori3com.cloud" "crawl_site"
```

## 🚀 Démarrage

### Serveur MCP officiel
```bash
# Démarrage direct
hostinger-api-mcp

# Ou via script
./start-official.sh
```

### Connecteur personnalisé
```bash
# Démarrage direct
node dist/index.js

# Ou via script
./start-custom.sh
```

## 🔄 Migration de sites

### Workflow de migration automatique
```bash
# Migration d'un site depuis Hostinger
./workflows/migrate-hostinger-site.sh "ori3com.cloud" "ori3com" "votre_token"

# Paramètres:
# 1. Domaine source (ex: ori3com.cloud)
# 2. Nom du tenant (ex: ori3com)
# 3. Token API Hostinger
```

### Étapes de migration
1. **Création de la structure** : Dossiers et fichiers de base
2. **Récupération des informations** : Via API Hostinger
3. **Détection du CMS** : WordPress, Joomla, etc.
4. **Extraction du contenu** : HTML, CSS, JS, images
5. **Création des fichiers de déploiement** : Kubernetes, DNS
6. **Documentation** : README et scripts de maintenance

## 🐳 Intégration avec Docker

### Dockerfile
```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copier les fichiers de configuration
COPY package*.json ./
COPY tsconfig.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code source
COPY src/ ./src/

# Compiler le projet
RUN npm run build

# Exposer le port
EXPOSE 3000

# Commande de démarrage
CMD ["node", "dist/index.js"]
```

### Docker Compose
```yaml
version: '3.8'

services:
  mcp-hostinger:
    build: .
    environment:
      - HOSTINGER_API_TOKEN=${HOSTINGER_API_TOKEN}
      - HOSTINGER_DOMAIN=${HOSTINGER_DOMAIN}
    ports:
      - "3000:3000"
    volumes:
      - ./logs:/app/logs
```

## 🔧 Dépannage

### Problèmes courants

#### Node.js non trouvé
```bash
# Vérifier l'installation
which node
node --version

# Réinstaller si nécessaire
./install-nodejs.sh
```

#### Permissions npm
```bash
# Configurer npm pour les installations globales sans sudo
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

#### Serveur MCP officiel non trouvé
```bash
# Réinstaller le serveur MCP officiel
sudo npm uninstall -g hostinger-api-mcp
sudo npm install -g hostinger-api-mcp

# Vérifier l'installation
which hostinger-api-mcp
hostinger-api-mcp --version
```

#### Erreurs de compilation
```bash
# Nettoyer et réinstaller
rm -rf node_modules dist
npm install
npm run build
```

### Logs et debugging
```bash
# Activer le mode debug
export DEBUG=true

# Vérifier les logs
tail -f logs/mcp-hostinger.log

# Test avec verbose
./test-connector.sh "https://ori3com.cloud" "detect_cms" 2>&1 | tee debug.log
```

## 🔒 Sécurité

### Bonnes pratiques
- **Ne jamais commiter** le fichier `.env` dans Git
- **Utiliser des tokens temporaires** avec expiration
- **Restreindre les permissions** des scripts
- **Auditer régulièrement** les dépendances

### Permissions des fichiers
```bash
# Permissions sécurisées
chmod 600 .env
chmod 644 *.json
chmod 755 *.sh
chmod 755 workflows/*.sh
```

## 📊 Monitoring

### Scripts de monitoring
```bash
# Vérifier l'état des services
./scripts/health-check.sh

# Surveiller les performances
./scripts/monitor.sh

# Nettoyer les logs
./scripts/cleanup.sh
```

### Intégration avec systemd
```ini
# /etc/systemd/system/mcp-hostinger.service
[Unit]
Description=MCP Hostinger Connector
After=network.target

[Service]
Type=simple
User=mcp
WorkingDirectory=/opt/mcp-hostinger-connector
ExecStart=/usr/bin/node dist/index.js
Restart=always
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
```

## 🤝 Support

### Ressources utiles
- **Documentation officielle** : [Hostinger MCP Tutorial](https://www.hostinger.com/tutorials/how-to-run-hostinger-api-mcp-server)
- **Issues GitHub** : [Rapporter un problème](https://github.com/coachlibre/mcp-hostinger-connector/issues)
- **Discussions** : [Forum communautaire](https://github.com/coachlibre/mcp-hostinger-connector/discussions)

### Commandes de diagnostic
```bash
# Informations système
./scripts/diagnostic.sh

# Test de connectivité
./scripts/connectivity-test.sh

# Rapport de santé
./scripts/health-report.sh
```

---

**Note** : Ce guide est optimisé pour Ubuntu 24.04+ mais fonctionne sur toutes les distributions Linux supportées.





