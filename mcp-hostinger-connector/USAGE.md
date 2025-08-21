# Guide d'utilisation du connecteur MCP Hostinger

## 🚀 Installation rapide

### Option 1: Installation automatique complète

```powershell
# Installation complète avec Node.js
.\install-complete.ps1 -HostingerApiKey "votre_cle_api" -Domain "ori3com.cloud"
```

### Option 2: Installation manuelle

```powershell
# 1. Installer Node.js
.\install-nodejs.ps1

# 2. Installer les dépendances
npm install

# 3. Compiler le projet
npm run build

# 4. Configurer l'environnement
.\setup.ps1 -HostingerApiKey "votre_cle_api" -Domain "ori3com.cloud"
```

## 🔧 Configuration

### Variables d'environnement

Créez un fichier `.env` avec les paramètres suivants :

```env
# Configuration obligatoire
HOSTINGER_API_KEY=votre_cle_api_hostinger
HOSTINGER_DOMAIN=ori3com.cloud

# Configuration optionnelle WordPress
WORDPRESS_USERNAME=admin
WORDPRESS_PASSWORD=votre_mot_de_passe

# Configuration crawling
CRAWL_DELAY=1000
MAX_CONCURRENT_REQUESTS=5
```

### Obtenir une clé API Hostinger

1. Connectez-vous à votre compte Hostinger
2. Allez dans "API" dans le panneau de contrôle
3. Générez une nouvelle clé API
4. Copiez la clé dans votre fichier `.env`

## 🧪 Tests

### Test rapide

```powershell
# Test de détection CMS
.\quick-test.ps1 -Url "https://ori3com.cloud" -Action "detect_cms"

# Test d'extraction de contenu
.\quick-test.ps1 -Url "https://ori3com.cloud" -Action "extract_content"

# Test de crawling
.\quick-test.ps1 -Url "https://ori3com.cloud" -Action "crawl_site"
```

### Test manuel

```powershell
# Test complet avec options personnalisées
.\test-connector.ps1 -Url "https://ori3com.cloud" -Action "detect_cms"
```

## 🔌 Utilisation avec un client MCP

### Configuration du client

Ajoutez la configuration suivante à votre client MCP :

```json
{
  "mcpServers": {
    "hostinger": {
      "command": "node",
      "args": ["/chemin/vers/mcp-hostinger-connector/dist/index.js"],
      "env": {
        "HOSTINGER_API_KEY": "votre_cle_api",
        "HOSTINGER_DOMAIN": "ori3com.cloud"
      }
    }
  }
}
```

### Exemples d'utilisation

#### 1. Détection de CMS

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

#### 2. Extraction de contenu

```json
{
  "name": "extract_content",
  "arguments": {
    "url": "https://ori3com.cloud",
    "content_type": "all"
  }
}
```

#### 3. Connexion API WordPress

```json
{
  "name": "wordpress_api_connect",
  "arguments": {
    "url": "https://ori3com.cloud",
    "endpoint": "posts"
  }
}
```

#### 4. Crawling de site

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

## 🛠️ Développement

### Structure du projet

```
mcp-hostinger-connector/
├── src/
│   └── index.ts              # Point d'entrée principal
├── dist/                     # Code compilé
├── scripts/
│   ├── install-nodejs.ps1   # Installation Node.js
│   ├── install-complete.ps1 # Installation complète
│   ├── setup.ps1            # Configuration
│   ├── test-connector.ps1   # Tests
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
```

### Ajouter un nouveau CMS

1. Ajouter les patterns dans `detectCMS()`
2. Implémenter la méthode d'extraction
3. Ajouter les tests unitaires
4. Mettre à jour la documentation

## 🔒 Sécurité

### Gestion des protections

Le connecteur inclut plusieurs mécanismes pour contourner les protections :

- **User-Agent réaliste** : Simulation d'un navigateur Chrome
- **Headers complets** : Accept-Language, Accept-Encoding, etc.
- **Délais aléatoires** : Évite la détection de bot
- **Puppeteer** : Rendu JavaScript complet

### Authentification

Pour les sites WordPress protégés :

```json
{
  "name": "wordpress_api_connect",
  "arguments": {
    "url": "https://ori3com.cloud",
    "endpoint": "posts",
    "username": "admin",
    "password": "password"
  }
}
```

## 📊 CMS Supportés

### WordPress
- ✅ Détection automatique
- ✅ API REST v2
- ✅ Extraction de contenu
- ✅ Authentification

### Joomla
- ✅ Détection automatique
- 🔄 API (en développement)
- ✅ Extraction de contenu

### Drupal
- ✅ Détection automatique
- 🔄 API (en développement)
- ✅ Extraction de contenu

### Magento
- ✅ Détection automatique
- 🔄 API (en développement)
- ✅ Extraction de contenu

### Shopify
- ✅ Détection automatique
- 🔄 API (en développement)
- ✅ Extraction de contenu

## 🚨 Limitations

1. **Rate Limiting** : Respectez les limites de l'hébergeur
2. **Protections** : Certaines protections avancées peuvent bloquer l'accès
3. **Authentification** : Nécessite des credentials valides pour l'API Hostinger
4. **JavaScript** : Certains sites nécessitent l'exécution de JavaScript

## 📝 Logs

Le connecteur génère des logs détaillés :

```bash
# Niveau DEBUG
DEBUG=mcp:* npm start

# Logs personnalisés
npm start 2>&1 | tee connector.log
```

## 🆘 Dépannage

### Problèmes courants

1. **Node.js non installé**
   ```powershell
   .\install-nodejs.ps1
   ```

2. **Dépendances manquantes**
   ```bash
   npm install
   ```

3. **Erreur de compilation**
   ```bash
   npm run build
   ```

4. **Clé API invalide**
   - Vérifiez votre clé API Hostinger
   - Assurez-vous qu'elle est correctement configurée dans `.env`

5. **Site inaccessible**
   - Vérifiez l'URL
   - Assurez-vous que le site n'est pas protégé par Cloudflare
   - Essayez avec `bypass_protection: true`

### Support

Pour toute question ou problème :

1. Consultez la documentation
2. Vérifiez les logs d'erreur
3. Testez avec les scripts fournis
4. Ouvrez une issue sur GitHub

---

**Version** : 1.0.0  
**Dernière mise à jour** : $(Get-Date)  
**Auteur** : CoachLibre Team





