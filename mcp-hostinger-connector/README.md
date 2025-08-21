# Connecteur MCP Hostinger

Un connecteur MCP (Model Context Protocol) pour interagir avec les sites CMS hébergés sur Hostinger, incluant la détection de CMS, l'extraction de contenu, et l'intégration avec les APIs WordPress et Hostinger.

## 🚀 Fonctionnalités

### Outils disponibles

1. **`detect_cms`** - Détecte le type de CMS utilisé sur un site
   - Analyse les patterns HTML, meta tags, et chemins caractéristiques
   - Supporte WordPress, Joomla, Drupal, Magento, Shopify
   - Fournit un score de confiance

2. **`extract_content`** - Extrait le contenu d'un site CMS
   - Utilise Puppeteer pour contourner les protections
   - Extrait pages, posts, images, et contenu textuel
   - Gestion des sites avec JavaScript dynamique

3. **`wordpress_api_connect`** - Se connecte à l'API WordPress REST
   - Accès aux posts, pages, utilisateurs, etc.
   - Support des endpoints personnalisés
   - Gestion des métadonnées et pagination

4. **`hostinger_api_connect`** - Interagit avec l'API Hostinger
   - Liste des domaines
   - Informations sur les domaines
   - Gestion des bases de données

5. **`crawl_site`** - Crawling complet avec gestion des protections
   - Crawling récursif configurable
   - Contournement des protections anti-bot
   - Extraction structurée des données

## 📋 Prérequis

- Node.js 18+ 
- npm ou yarn
- Clé API Hostinger (optionnelle pour certaines fonctionnalités)

## 🛠️ Installation

### Installation rapide (Windows)

```powershell
# Cloner le projet
git clone <repository-url>
cd mcp-hostinger-connector

# Installation automatique
.\install-official.ps1 -HostingerApiToken "votre_token" -Domain "ori3com.cloud"
```

### Installation rapide (Linux/Ubuntu)

```bash
# Cloner le projet
git clone <repository-url>
cd mcp-hostinger-connector

# Rendre les scripts exécutables
chmod +x *.sh
chmod +x workflows/*.sh

# Installation automatique
./install-official.sh "votre_token" "ori3com.cloud"

# Ou démarrage rapide
./quick-start.sh "votre_token" "ori3com.cloud"
```

### Installation manuelle

```bash
# Installer les dépendances
npm install

# Compiler le projet
npm run build

# Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos paramètres
```

## ⚙️ Configuration

### Variables d'environnement

Créez un fichier `.env` avec les paramètres suivants :

```env
# Configuration obligatoire
HOSTINGER_API_KEY=votre_clé_api_hostinger
HOSTINGER_DOMAIN=ori3com.cloud

# Configuration optionnelle WordPress
WORDPRESS_USERNAME=admin
WORDPRESS_PASSWORD=votre_mot_de_passe

# Configuration crawling
CRAWL_DELAY=1000
MAX_CONCURRENT_REQUESTS=5
```

### Configuration MCP

Ajoutez la configuration suivante à votre client MCP :

```json
{
  "mcpServers": {
    "hostinger": {
      "command": "node",
      "args": ["/chemin/vers/mcp-hostinger-connector/dist/index.js"],
      "env": {
        "HOSTINGER_API_KEY": "votre_clé_api",
        "HOSTINGER_DOMAIN": "ori3com.cloud"
      }
    }
  }
}
```

## 🧪 Tests

### Test rapide (Windows)

```powershell
# Test de détection CMS
.\test-official-quick.ps1 -Url "https://ori3com.cloud" -Action "detect_cms"

# Test d'extraction de contenu
.\test-connector.ps1 -Url "https://ori3com.cloud" -Action "extract_content"

# Test de crawling
.\test-connector.ps1 -Url "https://ori3com.cloud" -Action "crawl_site"
```

### Test rapide (Linux)

```bash
# Test du serveur officiel
./test-official-quick.sh "https://ori3com.cloud" "list_domains"

# Test du connecteur personnalisé
./test-connector.sh "https://ori3com.cloud" "detect_cms"

# Test d'extraction de contenu
./test-connector.sh "https://ori3com.cloud" "extract_content"
```

### Test manuel

```powershell
# Test complet (Windows)
.\test-connector.ps1 -Url "https://ori3com.cloud" -Action "detect_cms"
```

```bash
# Test complet (Linux)
./test-connector.sh "https://ori3com.cloud" "detect_cms"
```

## 📖 Utilisation

### Détection de CMS

```json
{
  "name": "detect_cms",
  "arguments": {
    "url": "https://ori3com.cloud"
  }
}
```

**Réponse attendue :**
```json
{
  "cms": "wordpress",
  "confidence": 8,
  "url": "https://ori3com.cloud",
  "analysis": {
    "has_wp_admin": true,
    "has_wp_json": true,
    "has_joomla_admin": false,
    "has_drupal_admin": false
  }
}
```

### Extraction de contenu

```json
{
  "name": "extract_content",
  "arguments": {
    "url": "https://ori3com.cloud",
    "content_type": "all"
  }
}
```

### Connexion API WordPress

```json
{
  "name": "wordpress_api_connect",
  "arguments": {
    "url": "https://ori3com.cloud",
    "endpoint": "posts"
  }
}
```

### Crawling de site

```json
{
  "name": "crawl_site",
  "arguments": {
    "url": "https://ori3com.cloud",
    "depth": 2,
    "bypass_protection": true
  }
}
```

## 🔧 Développement

### Structure du projet

```
mcp-hostinger-connector/
├── src/
│   └── index.ts              # Point d'entrée principal
├── dist/                     # Code compilé
├── scripts/
│   ├── setup.ps1            # Script d'installation
│   ├── test-connector.ps1   # Script de test
│   └── quick-test.ps1       # Test rapide
├── package.json
├── tsconfig.json
└── README.md
```

### Commandes de développement

```bash
# Développement
npm run dev

# Compilation
npm run build

# Tests
npm test

# Démarrage
npm start

# Installation du serveur MCP officiel
npm run install-hostinger-mcp
```

## 🛡️ Sécurité

### Gestion des clés API

- Les clés API sont stockées dans le fichier `.env` (non commité)
- Utilisation de variables d'environnement pour la configuration
- Validation des paramètres d'entrée

### Contournement des protections

- User-Agents réalistes
- Délais aléatoires entre les requêtes
- Headers HTTP complets
- Gestion des timeouts et retry

## 📊 Monitoring et Logs

Le connecteur génère des logs détaillés pour :
- Les requêtes effectuées
- Les erreurs rencontrées
- Les performances
- Les détections de CMS

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Pour toute question ou problème :

1. Consultez la documentation
2. Vérifiez les logs d'erreur
3. Testez avec les scripts fournis
4. Ouvrez une issue sur GitHub

## 🔄 Mises à jour

Pour mettre à jour le connecteur :

### Windows
```powershell
# Mise à jour des dépendances
npm update

# Recompilation
npm run build

# Test après mise à jour
.\test-official-quick.ps1
```

### Linux
```bash
# Mise à jour des dépendances
npm update

# Recompilation
npm run build

# Test après mise à jour
./test-official-quick.sh
```

---

**Développé avec ❤️ par l'équipe CoachLibre**
