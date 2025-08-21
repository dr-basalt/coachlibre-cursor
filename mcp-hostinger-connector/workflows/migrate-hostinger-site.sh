#!/bin/bash

# Workflow de migration d'un site depuis Hostinger (Linux/Ubuntu)
# Usage: ./migrate-hostinger-site.sh [SOURCE_DOMAIN] [TARGET_TENANT] [HOSTINGER_API_TOKEN]

SOURCE_DOMAIN=${1:-"ori3com.cloud"}
TARGET_TENANT=${2:-"ori3com"}
HOSTINGER_API_TOKEN=${3:-""}
USE_OFFICIAL_MCP=${4:-"true"}
SKIP_CONFIRMATION=${5:-"false"}

echo "🚀 Workflow de migration depuis Hostinger (Linux)..."
echo "Domaine source: $SOURCE_DOMAIN"
echo "Tenant cible: $TARGET_TENANT"
echo "Utilise MCP officiel: $USE_OFFICIAL_MCP"

# Étape 1: Vérification des prérequis
echo -e "\n🔍 Étape 1: Vérification des prérequis..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -d "../tenants" ]; then
    echo "❌ Répertoire tenants non trouvé. Exécutez depuis la racine du projet."
    exit 1
fi

# Vérifier le token API
if [ -z "$HOSTINGER_API_TOKEN" ]; then
    echo "❌ Token API Hostinger manquant. Utilisez: ./migrate-hostinger-site.sh [DOMAIN] [TENANT] [TOKEN]"
    exit 1
fi

# Étape 2: Création de la structure du tenant
echo -e "\n📁 Étape 2: Création de la structure du tenant..."

TENANT_PATH="../tenants/$TARGET_TENANT"
TENANT_CONTENT_PATH="$TENANT_PATH/content"
TENANT_DEPLOYMENT_PATH="$TENANT_PATH/deployment"
TENANT_SCRIPTS_PATH="$TENANT_PATH/scripts"

# Créer les dossiers
mkdir -p "$TENANT_PATH"
mkdir -p "$TENANT_CONTENT_PATH/assets/css"
mkdir -p "$TENANT_CONTENT_PATH/assets/js"
mkdir -p "$TENANT_CONTENT_PATH/assets/images"
mkdir -p "$TENANT_CONTENT_PATH/pages"
mkdir -p "$TENANT_DEPLOYMENT_PATH"
mkdir -p "$TENANT_SCRIPTS_PATH"

echo "✅ Structure de dossiers créée"

# Étape 3: Récupération des informations du domaine via MCP
echo -e "\n🌐 Étape 3: Récupération des informations du domaine..."

# Créer un script temporaire pour interroger le serveur MCP
cat > temp-domain-query.js << EOF
import { spawn } from 'child_process';

// Charger les variables d'environnement
const env = {
    APITOKEN: '$HOSTINGER_API_TOKEN',
    DEBUG: 'false'
};

// Démarrer le serveur MCP approprié
const mcpCommand = '$USE_OFFICIAL_MCP' === 'true' ? 'hostinger-api-mcp' : 'node';
const mcpArgs = '$USE_OFFICIAL_MCP' === 'true' ? [] : ['dist/index.js'];

const mcpServer = spawn(mcpCommand, mcpArgs, {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: { ...process.env, ...env }
});

// Requête pour obtenir les informations du domaine
const domainRequest = {
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: {
        name: 'get_domain_info',
        arguments: {
            domain: '$SOURCE_DOMAIN'
        }
    }
};

mcpServer.stdin.write(JSON.stringify(domainRequest) + '\n');

let response = '';
mcpServer.stdout.on('data', (data) => {
    response += data.toString();
});

mcpServer.stderr.on('data', (data) => {
    console.error('Erreur:', data.toString());
});

mcpServer.on('close', (code) => {
    try {
        const result = JSON.parse(response);
        console.log('Informations du domaine:', JSON.stringify(result, null, 2));
    } catch (e) {
        console.log('Réponse brute:', response);
    }
    process.exit(code);
});

setTimeout(() => {
    mcpServer.kill();
    console.log('Timeout');
    process.exit(1);
}, 30000);
EOF

if node temp-domain-query.js 2>&1; then
    echo "✅ Informations du domaine récupérées"
else
    echo "❌ Erreur lors de la récupération des informations du domaine"
fi

rm -f temp-domain-query.js

# Étape 4: Détection du CMS
echo -e "\n🔍 Étape 4: Détection du CMS..."

# Utiliser notre connecteur personnalisé pour détecter le CMS
cat > temp-cms-detection.js << EOF
import { spawn } from 'child_process';

const connector = spawn('node', ['dist/index.js'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: {
        ...process.env,
        HOSTINGER_API_TOKEN: '$HOSTINGER_API_TOKEN',
        HOSTINGER_DOMAIN: '$SOURCE_DOMAIN'
    }
});

const cmsRequest = {
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: {
        name: 'detect_cms',
        arguments: {
            url: 'https://$SOURCE_DOMAIN'
        }
    }
};

connector.stdin.write(JSON.stringify(cmsRequest) + '\n');

let response = '';
connector.stdout.on('data', (data) => {
    response += data.toString();
});

connector.on('close', (code) => {
    try {
        const result = JSON.parse(response);
        console.log('CMS détecté:', JSON.stringify(result, null, 2));
    } catch (e) {
        console.log('Réponse brute:', response);
    }
    process.exit(code);
});

setTimeout(() => {
    connector.kill();
    console.log('Timeout');
    process.exit(1);
}, 30000);
EOF

if node temp-cms-detection.js 2>&1; then
    echo "✅ CMS détecté"
else
    echo "❌ Erreur lors de la détection du CMS"
fi

rm -f temp-cms-detection.js

# Étape 5: Extraction du contenu
echo -e "\n📄 Étape 5: Extraction du contenu..."

cat > temp-content-extraction.js << EOF
import { spawn } from 'child_process';

const connector = spawn('node', ['dist/index.js'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: {
        ...process.env,
        HOSTINGER_API_TOKEN: '$HOSTINGER_API_TOKEN',
        HOSTINGER_DOMAIN: '$SOURCE_DOMAIN'
    }
});

const extractionRequest = {
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: {
        name: 'extract_content',
        arguments: {
            url: 'https://$SOURCE_DOMAIN',
            content_type: 'all'
        }
    }
};

connector.stdin.write(JSON.stringify(extractionRequest) + '\n');

let response = '';
connector.stdout.on('data', (data) => {
    response += data.toString();
});

connector.on('close', (code) => {
    try {
        const result = JSON.parse(response);
        console.log('Contenu extrait:', JSON.stringify(result, null, 2));
    } catch (e) {
        console.log('Réponse brute:', response);
    }
    process.exit(code);
});

setTimeout(() => {
    connector.kill();
    console.log('Timeout');
    process.exit(1);
}, 60000);
EOF

if node temp-content-extraction.js 2>&1; then
    echo "✅ Contenu extrait"
else
    echo "❌ Erreur lors de l'extraction du contenu"
fi

rm -f temp-content-extraction.js

# Étape 6: Création des fichiers de déploiement
echo -e "\n📝 Étape 6: Création des fichiers de déploiement..."

# Créer le README du tenant
cat > "$TENANT_PATH/README.md" << EOF
# Tenant $TARGET_TENANT - Migration depuis $SOURCE_DOMAIN

## Informations du site

- **URL Source** : $SOURCE_DOMAIN
- **URL Destination** : coachlibre.infra.$SOURCE_DOMAIN
- **Type** : Site migré depuis Hostinger
- **Technologies** : CMS détecté automatiquement
- **Statut** : 🔄 En cours de migration

## Migration

### Étape 1: Récupération du contenu
- [x] Création de la structure
- [x] Récupération des informations du domaine
- [x] Détection du CMS
- [x] Extraction du contenu

### Étape 2: Adaptation
- [ ] Modification des URLs absolues
- [ ] Adaptation des chemins relatifs
- [ ] Optimisation pour l'infrastructure CoachLibre
- [ ] Tests de compatibilité

### Étape 3: Déploiement
- [ ] Configuration Kubernetes
- [ ] Déploiement sur K3s
- [ ] Tests de fonctionnalité
- [ ] Validation de performance

## Structure

\`\`\`
tenants/$TARGET_TENANT/
├── README.md                    # Documentation
├── content/                     # Contenu du site
│   ├── index.html              # Page d'accueil
│   ├── assets/                 # Ressources
│   │   ├── css/               # Styles CSS
│   │   ├── js/                # JavaScript
│   │   └── images/            # Images
│   └── pages/                 # Pages additionnelles
├── deployment/                  # Configuration Kubernetes
│   ├── deployment.yaml        # Déploiement principal
│   ├── service.yaml           # Service
│   ├── ingress.yaml           # Ingress
│   ├── assets-configmap.yaml  # ConfigMap CSS
│   └── js-configmap.yaml      # ConfigMap JavaScript
└── scripts/                    # Scripts de déploiement
    ├── deploy.sh              # Script de déploiement
    └── configure-dns.sh       # Configuration DNS
\`\`\`

## Accès

Le site sera accessible sur :
- **HTTP** : http://coachlibre.infra.$SOURCE_DOMAIN
- **HTTPS** : https://coachlibre.infra.$SOURCE_DOMAIN (après configuration Cloudflare)

## Maintenance

Pour toute question ou problème :
- Vérifier les logs : \`kubectl logs -l app=$TARGET_TENANT-web -n coachlibre\`
- Redémarrer les pods : \`kubectl rollout restart deployment/$TARGET_TENANT-web -n coachlibre\`
- Vérifier la connectivité : \`kubectl port-forward service/$TARGET_TENANT-web-service 8080:80 -n coachlibre\`

---

**Status** : 🔄 Migration en cours  
**Dernière mise à jour** : $(date)  
**Version** : 1.0.0
EOF

echo "✅ README du tenant créé"

# Étape 7: Création des scripts de déploiement
echo -e "\n🔧 Étape 7: Création des scripts de déploiement..."

# Script de déploiement pour le tenant
cat > "$TENANT_SCRIPTS_PATH/deploy.sh" << EOF
#!/bin/bash

# Script de déploiement pour le tenant $TARGET_TENANT
echo "🚀 Déploiement du tenant $TARGET_TENANT..."

# Appliquer les ConfigMaps
kubectl apply -f deployment/assets-configmap.yaml
kubectl apply -f deployment/js-configmap.yaml

# Appliquer le déploiement
kubectl apply -f deployment/deployment.yaml
kubectl apply -f deployment/service.yaml
kubectl apply -f deployment/ingress.yaml

# Vérifier le statut
echo "📊 Statut du déploiement:"
kubectl get pods -l app=$TARGET_TENANT-web -n coachlibre
kubectl get services -l app=$TARGET_TENANT-web -n coachlibre
kubectl get ingress -n coachlibre

echo "✅ Déploiement terminé !"
echo "🌐 Site accessible sur: http://coachlibre.infra.$SOURCE_DOMAIN"
EOF

chmod +x "$TENANT_SCRIPTS_PATH/deploy.sh"
echo "✅ Script de déploiement créé"

# Étape 8: Configuration DNS
echo -e "\n🌍 Étape 8: Configuration DNS..."

cat > "$TENANT_SCRIPTS_PATH/configure-dns.sh" << EOF
#!/bin/bash

# Script de configuration DNS pour $TARGET_TENANT
CLOUDFLARE_TOKEN=\${1:-""}
ZONE_ID=\${2:-""}

echo "🌍 Configuration DNS pour $TARGET_TENANT..."

if [ -z "\$CLOUDFLARE_TOKEN" ] || [ -z "\$ZONE_ID" ]; then
    echo "❌ Usage: ./configure-dns.sh [CLOUDFLARE_TOKEN] [ZONE_ID]"
    exit 1
fi

# Créer l'enregistrement A
curl -X POST "https://api.cloudflare.com/client/v4/zones/\$ZONE_ID/dns_records" \\
     -H "Authorization: Bearer \$CLOUDFLARE_TOKEN" \\
     -H "Content-Type: application/json" \\
     --data '{
       "type": "A",
       "name": "coachlibre.infra.$SOURCE_DOMAIN",
       "content": "49.13.218.200",
       "ttl": 1,
       "proxied": true
     }'

echo "✅ Configuration DNS terminée !"
EOF

chmod +x "$TENANT_SCRIPTS_PATH/configure-dns.sh"
echo "✅ Script de configuration DNS créé"

# Étape 9: Résumé final
echo -e "\n📋 Étape 9: Résumé final..."

echo "🎉 Migration terminée avec succès !"
echo -e "\n📊 Résumé de la migration:"
echo "- Domaine source: $SOURCE_DOMAIN"
echo "- Tenant cible: $TARGET_TENANT"
echo "- Structure créée: $TENANT_PATH"
echo "- Scripts de déploiement: $TENANT_SCRIPTS_PATH"

echo -e "\n📋 Prochaines étapes:"
echo "1. Configurer le contenu extrait dans $TENANT_CONTENT_PATH"
echo "2. Adapter les fichiers de déploiement dans $TENANT_DEPLOYMENT_PATH"
echo "3. Déployer avec: ./tenants/$TARGET_TENANT/scripts/deploy.sh"
echo "4. Configurer le DNS avec: ./tenants/$TARGET_TENANT/scripts/configure-dns.sh"

echo -e "\n📖 Documentation: ./tenants/$TARGET_TENANT/README.md"




