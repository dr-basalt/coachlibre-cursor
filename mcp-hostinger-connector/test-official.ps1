# Script de test du serveur MCP officiel Hostinger
param(
    [string]$Url = "https://ori3com.cloud",
    [string]$Action = "list_domains"
)

Write-Host "Test du serveur MCP officiel Hostinger..." -ForegroundColor Green
Write-Host "URL: $Url" -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Cyan

# Vérifier que le serveur MCP officiel est installé
try {
    $mcpVersion = hostinger-api-mcp --version 2>&1
    Write-Host "Serveur MCP officiel: $mcpVersion" -ForegroundColor Green
} catch {
    Write-Host "Serveur MCP officiel non installe. Executez: npm install -g hostinger-api-mcp" -ForegroundColor Red
    exit 1
}

# Vérifier le fichier .env
if (!(Test-Path ".env")) {
    Write-Host "Fichier .env manquant. Création d'un fichier temporaire..." -ForegroundColor Yellow
    
    $tempEnv = @"
HOSTINGER_API_TOKEN=test_token
HOSTINGER_DOMAIN=ori3com.cloud
DEBUG=false
APITOKEN=test_token
"@
    $tempEnv | Out-File -FilePath ".env" -Encoding UTF8
}

# Fonction pour tester une action spécifique avec le serveur officiel
function Test-OfficialMCPServer {
    param([string]$Action, [string]$Url)
    
    Write-Host "`nTest de l'action officielle: $Action" -ForegroundColor Yellow
    
    # Créer un script de test temporaire pour le serveur officiel
    $testScript = @"
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
switch('$Action') {
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
                    domain: '$Url'
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
"@

    $testScript | Out-File -FilePath "temp-official-test.js" -Encoding UTF8
    
    try {
        $result = node temp-official-test.js 2>&1
        Write-Host "Test reussi" -ForegroundColor Green
        Write-Host "Resultat:" -ForegroundColor Cyan
        Write-Host $result -ForegroundColor White
    } catch {
        Write-Host "Test echoue" -ForegroundColor Red
        Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        # Nettoyer
        if (Test-Path "temp-official-test.js") {
            Remove-Item "temp-official-test.js"
        }
    }
}

# Tests disponibles pour le serveur officiel
$availableOfficialTests = @{
    "list_domains" = "Liste des domaines"
    "get_domain_info" = "Informations sur le domaine"
    "list_databases" = "Liste des bases de données"
    "list_tools" = "Liste des outils disponibles"
}

# Exécuter le test demandé
if ($availableOfficialTests.ContainsKey($Action)) {
    Test-OfficialMCPServer -Action $Action -Url $Url
} else {
    Write-Host "Action non reconnue: $Action" -ForegroundColor Red
    Write-Host "Actions disponibles:" -ForegroundColor Cyan
    foreach ($test in $availableOfficialTests.GetEnumerator()) {
        Write-Host "  - $($test.Key): $($test.Value)" -ForegroundColor White
    }
}

Write-Host "`nTest termine !" -ForegroundColor Green




