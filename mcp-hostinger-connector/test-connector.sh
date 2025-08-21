#!/bin/bash

# Script de test du connecteur MCP Hostinger (Linux)
# Usage: ./test-connector.sh [URL] [ACTION]

URL=${1:-"https://ori3com.cloud"}
ACTION=${2:-"detect_cms"}

echo "🧪 Test du connecteur MCP Hostinger (Linux)..."
echo "URL: $URL"
echo "Action: $ACTION"

# Vérifier que le connecteur est compilé
if [ ! -f "dist/index.js" ]; then
    echo "❌ Connecteur non compilé. Exécutez 'npm run build' d'abord."
    exit 1
fi

# Vérifier le fichier .env
if [ ! -f ".env" ]; then
    echo "⚠️ Fichier .env manquant. Création d'un fichier temporaire..."
    
    cat > .env << EOF
HOSTINGER_API_KEY=test_key
HOSTINGER_DOMAIN=ori3com.cloud
EOF
fi

# Fonction pour tester une action spécifique
test_connector_action() {
    local action=$1
    local url=$2
    
    echo -e "\n🔍 Test de l'action: $action"
    
    # Créer un script de test temporaire
    cat > temp-test.js << EOF
import { spawn } from 'child_process';
import { readFileSync } from 'fs';

// Charger les variables d'environnement
const env = {};
const envContent = readFileSync('.env', 'utf8');
envContent.split('\n').forEach(line => {
    const [key, value] = line.split('=');
    if (key && value) {
        env[key.trim()] = value.trim();
    }
});

// Démarrer le connecteur
const connector = spawn('node', ['dist/index.js'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: { ...process.env, ...env }
});

// Envoyer une requête de test
const testRequest = {
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: {
        name: '$action',
        arguments: {
            url: '$url'
        }
    }
};

connector.stdin.write(JSON.stringify(testRequest) + '\n');

let response = '';
connector.stdout.on('data', (data) => {
    response += data.toString();
});

connector.stderr.on('data', (data) => {
    console.error('Erreur:', data.toString());
});

connector.on('close', (code) => {
    try {
        const result = JSON.parse(response);
        console.log('Résultat:', JSON.stringify(result, null, 2));
    } catch (e) {
        console.log('Réponse brute:', response);
    }
    process.exit(code);
});

// Timeout après 30 secondes
setTimeout(() => {
    connector.kill();
    console.log('Timeout - Le connecteur n\'a pas répondu');
    process.exit(1);
}, 30000);
EOF
    
    # Exécuter le test
    if node temp-test.js 2>&1; then
        echo "✅ Test réussi"
    else
        echo "❌ Test échoué"
    fi
    
    # Nettoyer
    rm -f temp-test.js
}

# Tests disponibles
declare -A available_tests=(
    ["detect_cms"]="Détection du CMS"
    ["extract_content"]="Extraction de contenu"
    ["wordpress_api_connect"]="Connexion API WordPress"
    ["crawl_site"]="Crawling du site"
)

# Exécuter le test demandé
if [[ -n "${available_tests[$ACTION]}" ]]; then
    test_connector_action "$ACTION" "$URL"
else
    echo "❌ Action non reconnue: $ACTION"
    echo "📋 Actions disponibles:"
    for key in "${!available_tests[@]}"; do
        echo "  - $key: ${available_tests[$key]}"
    done
fi

echo -e "\n✅ Test terminé !"


