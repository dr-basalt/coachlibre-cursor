#!/bin/bash

# Script de test du serveur MCP officiel Hostinger (Linux)
# Usage: ./test-official.sh [URL] [ACTION]

URL=${1:-"https://ori3com.cloud"}
ACTION=${2:-"list_domains"}

echo "🧪 Test du serveur MCP officiel Hostinger (Linux)..."
echo "URL: $URL"
echo "Action: $ACTION"

# Vérifier que le serveur MCP officiel est installé
if ! command -v hostinger-api-mcp &> /dev/null; then
    echo "❌ Serveur MCP officiel non installé. Exécutez: sudo npm install -g hostinger-api-mcp"
    exit 1
fi

MCP_VERSION=$(hostinger-api-mcp --version 2>&1)
echo "✅ Serveur MCP officiel: $MCP_VERSION"

# Vérifier le fichier .env
if [ ! -f ".env" ]; then
    echo "⚠️ Fichier .env manquant. Création d'un fichier temporaire..."
    
    cat > .env << EOF
HOSTINGER_API_TOKEN=test_token
HOSTINGER_DOMAIN=ori3com.cloud
DEBUG=false
APITOKEN=test_token
EOF
fi

# Fonction pour tester une action spécifique avec le serveur officiel
test_official_mcp_server() {
    local action=$1
    local url=$2
    
    echo -e "\n🔍 Test de l'action officielle: $action"
    
    # Créer un script de test temporaire pour le serveur officiel
    cat > temp-official-test.js << EOF
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

// Démarrer le serveur MCP officiel
const mcpServer = spawn('hostinger-api-mcp', [], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: { ...process.env, ...env }
});

// Envoyer une requête de test selon l'action
let testRequest;
switch('$action') {
    case 'list_domains':
        testRequest = {
            jsonrpc: '2.0',
            id: 1,
            method: 'tools/call',
            params: {
                name: 'list_domains',
                arguments: {}
            }
        };
        break;
    case 'get_domain_info':
        testRequest = {
            jsonrpc: '2.0',
            id: 1,
            method: 'tools/call',
            params: {
                name: 'get_domain_info',
                arguments: {
                    domain: '$url'
                }
            }
        };
        break;
    case 'list_databases':
        testRequest = {
            jsonrpc: '2.0',
            id: 1,
            method: 'tools/call',
            params: {
                name: 'list_databases',
                arguments: {}
            }
        };
        break;
    default:
        testRequest = {
            jsonrpc: '2.0',
            id: 1,
            method: 'tools/list',
            params: {}
        };
}

mcpServer.stdin.write(JSON.stringify(testRequest) + '\n');

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
        console.log('Résultat:', JSON.stringify(result, null, 2));
    } catch (e) {
        console.log('Réponse brute:', response);
    }
    process.exit(code);
});

// Timeout après 30 secondes
setTimeout(() => {
    mcpServer.kill();
    console.log('Timeout - Le serveur MCP officiel n\'a pas répondu');
    process.exit(1);
}, 30000);
EOF
    
    # Exécuter le test
    if node temp-official-test.js 2>&1; then
        echo "✅ Test réussi"
    else
        echo "❌ Test échoué"
    fi
    
    # Nettoyer
    rm -f temp-official-test.js
}

# Tests disponibles pour le serveur officiel
declare -A available_official_tests=(
    ["list_domains"]="Liste des domaines"
    ["get_domain_info"]="Informations sur le domaine"
    ["list_databases"]="Liste des bases de données"
    ["list_tools"]="Liste des outils disponibles"
)

# Exécuter le test demandé
if [[ -n "${available_official_tests[$ACTION]}" ]]; then
    test_official_mcp_server "$ACTION" "$URL"
else
    echo "❌ Action non reconnue: $ACTION"
    echo "📋 Actions disponibles:"
    for key in "${!available_official_tests[@]}"; do
        echo "  - $key: ${available_official_tests[$key]}"
    done
fi

echo -e "\n✅ Test terminé !"




