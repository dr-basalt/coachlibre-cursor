# Script de test du connecteur MCP Hostinger
param(
    [string]$Url = "https://ori3com.cloud",
    [string]$Action = "detect_cms"
)

Write-Host "🧪 Test du connecteur MCP Hostinger..." -ForegroundColor Green
Write-Host "URL: $Url" -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Cyan

# Vérifier que le connecteur est compilé
if (!(Test-Path "dist/index.js")) {
    Write-Host "❌ Connecteur non compilé. Exécutez 'npm run build' d'abord." -ForegroundColor Red
    exit 1
}

# Vérifier le fichier .env
if (!(Test-Path ".env")) {
    Write-Host "⚠️ Fichier .env manquant. Création d'un fichier temporaire..." -ForegroundColor Yellow
    
    $tempEnv = @"
HOSTINGER_API_KEY=test_key
HOSTINGER_DOMAIN=ori3com.cloud
"@
    $tempEnv | Out-File -FilePath ".env" -Encoding UTF8
}

# Fonction pour tester une action spécifique
function Test-ConnectorAction {
    param([string]$Action, [string]$Url)
    
    Write-Host "`n🔍 Test de l'action: $Action" -ForegroundColor Yellow
    
    # Créer un script de test temporaire
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
        name: '$Action',
        arguments: {
            url: '$Url'
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
"@

    $testScript | Out-File -FilePath "temp-test.js" -Encoding UTF8
    
    try {
        $result = node temp-test.js 2>&1
        Write-Host "✅ Test réussi" -ForegroundColor Green
        Write-Host "📋 Résultat:" -ForegroundColor Cyan
        Write-Host $result -ForegroundColor White
    } catch {
        Write-Host "❌ Test échoué" -ForegroundColor Red
        Write-Host "📋 Erreur: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        # Nettoyer
        if (Test-Path "temp-test.js") {
            Remove-Item "temp-test.js"
        }
    }
}

# Tests disponibles
$availableTests = @{
    "detect_cms" = "Détection du CMS"
    "extract_content" = "Extraction de contenu"
    "wordpress_api_connect" = "Connexion API WordPress"
    "crawl_site" = "Crawling du site"
}

# Exécuter le test demandé
if ($availableTests.ContainsKey($Action)) {
    Test-ConnectorAction -Action $Action -Url $Url
} else {
    Write-Host "❌ Action non reconnue: $Action" -ForegroundColor Red
    Write-Host "📋 Actions disponibles:" -ForegroundColor Cyan
    foreach ($test in $availableTests.GetEnumerator()) {
        Write-Host "  - $($test.Key): $($test.Value)" -ForegroundColor White
    }
}

Write-Host "`n🎉 Test terminé !" -ForegroundColor Green
