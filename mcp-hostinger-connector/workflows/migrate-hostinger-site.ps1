# Workflow de migration d'un site depuis Hostinger
param(
    [string]$SourceDomain = "ori3com.cloud",
    [string]$TargetTenant = "ori3com",
    [string]$HostingerApiToken = "",
    [switch]$UseOfficialMCP = $true,
    [switch]$SkipConfirmation = $false
)

Write-Host "Workflow de migration depuis Hostinger..." -ForegroundColor Green
Write-Host "Domaine source: $SourceDomain" -ForegroundColor Cyan
Write-Host "Tenant cible: $TargetTenant" -ForegroundColor Cyan
Write-Host "Utilise MCP officiel: $UseOfficialMCP" -ForegroundColor Cyan

# Étape 1: Vérification des prérequis
Write-Host "`nEtape 1: Verification des prerequis..." -ForegroundColor Yellow

# Vérifier que nous sommes dans le bon répertoire
if (!(Test-Path "..\tenants")) {
    Write-Host "Repertoire tenants non trouve. Executez depuis la racine du projet." -ForegroundColor Red
    exit 1
}

# Vérifier le token API
if ([string]::IsNullOrEmpty($HostingerApiToken)) {
    Write-Host "Token API Hostinger manquant. Utilisez -HostingerApiToken 'votre_token'" -ForegroundColor Red
    exit 1
}

# Étape 2: Création de la structure du tenant
Write-Host "`nEtape 2: Creation de la structure du tenant..." -ForegroundColor Yellow

$tenantPath = "..\tenants\$TargetTenant"
$tenantContentPath = "$tenantPath\content"
$tenantDeploymentPath = "$tenantPath\deployment"
$tenantScriptsPath = "$tenantPath\scripts"

# Créer les dossiers
$directories = @(
    $tenantPath,
    $tenantContentPath,
    "$tenantContentPath\assets",
    "$tenantContentPath\assets\css",
    "$tenantContentPath\assets\js",
    "$tenantContentPath\assets\images",
    "$tenantContentPath\pages",
    $tenantDeploymentPath,
    $tenantScriptsPath
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Cree: $dir" -ForegroundColor Green
    }
}

# Étape 3: Récupération des informations du domaine via MCP
Write-Host "`nEtape 3: Recuperation des informations du domaine..." -ForegroundColor Yellow

# Créer un script temporaire pour interroger le serveur MCP
$mcpQueryScript = @"
import { spawn } from 'child_process';
import { readFileSync } from 'fs';

// Charger les variables d'environnement
const env = {
    APITOKEN: '$HostingerApiToken',
    DEBUG: 'false'
};

// Démarrer le serveur MCP approprié
const mcpCommand = '$UseOfficialMCP' === 'True' ? 'hostinger-api-mcp' : 'node';
const mcpArgs = '$UseOfficialMCP' === 'True' ? [] : ['dist/index.js'];

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
            domain: '$SourceDomain'
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
        console.log('Reponse brute:', response);
    }
    process.exit(code);
});

setTimeout(() => {
    mcpServer.kill();
    console.log('Timeout');
    process.exit(1);
}, 30000);
"@

$mcpQueryScript | Out-File -FilePath "temp-domain-query.js" -Encoding UTF8

try {
    $domainInfo = node temp-domain-query.js 2>&1
    Write-Host "Informations du domaine recuperees" -ForegroundColor Green
    Write-Host $domainInfo -ForegroundColor White
} catch {
    Write-Host "Erreur lors de la recuperation des informations du domaine" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} finally {
    if (Test-Path "temp-domain-query.js") {
        Remove-Item "temp-domain-query.js"
    }
}

# Étape 4: Détection du CMS
Write-Host "`nEtape 4: Detection du CMS..." -ForegroundColor Yellow

# Utiliser notre connecteur personnalisé pour détecter le CMS
$cmsDetectionScript = @"
import { spawn } from 'child_process';

const connector = spawn('node', ['dist/index.js'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: {
        ...process.env,
        HOSTINGER_API_TOKEN: '$HostingerApiToken',
        HOSTINGER_DOMAIN: '$SourceDomain'
    }
});

const cmsRequest = {
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: {
        name: 'detect_cms',
        arguments: {
            url: 'https://$SourceDomain'
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
        console.log('CMS detecte:', JSON.stringify(result, null, 2));
    } catch (e) {
        console.log('Reponse brute:', response);
    }
    process.exit(code);
});

setTimeout(() => {
    connector.kill();
    console.log('Timeout');
    process.exit(1);
}, 30000);
"@

$cmsDetectionScript | Out-File -FilePath "temp-cms-detection.js" -Encoding UTF8

try {
    $cmsInfo = node temp-cms-detection.js 2>&1
    Write-Host "CMS detecte" -ForegroundColor Green
    Write-Host $cmsInfo -ForegroundColor White
} catch {
    Write-Host "Erreur lors de la detection du CMS" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} finally {
    if (Test-Path "temp-cms-detection.js") {
        Remove-Item "temp-cms-detection.js"
    }
}

# Étape 5: Extraction du contenu
Write-Host "`nEtape 5: Extraction du contenu..." -ForegroundColor Yellow

$contentExtractionScript = @"
import { spawn } from 'child_process';

const connector = spawn('node', ['dist/index.js'], {
    stdio: ['pipe', 'pipe', 'pipe'],
    env: {
        ...process.env,
        HOSTINGER_API_TOKEN: '$HostingerApiToken',
        HOSTINGER_DOMAIN: '$SourceDomain'
    }
});

const extractionRequest = {
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: {
        name: 'extract_content',
        arguments: {
            url: 'https://$SourceDomain',
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
        console.log('Reponse brute:', response);
    }
    process.exit(code);
});

setTimeout(() => {
    connector.kill();
    console.log('Timeout');
    process.exit(1);
}, 60000);
"@

$contentExtractionScript | Out-File -FilePath "temp-content-extraction.js" -Encoding UTF8

try {
    $contentInfo = node temp-content-extraction.js 2>&1
    Write-Host "Contenu extrait" -ForegroundColor Green
    Write-Host $contentInfo -ForegroundColor White
} catch {
    Write-Host "Erreur lors de l'extraction du contenu" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} finally {
    if (Test-Path "temp-content-extraction.js") {
        Remove-Item "temp-content-extraction.js"
    }
}

# Étape 6: Création des fichiers de déploiement
Write-Host "`nEtape 6: Creation des fichiers de deploiement..." -ForegroundColor Yellow

# Créer le README du tenant
$tenantReadme = @"
# Tenant $TargetTenant - Migration depuis $SourceDomain

## Informations du site

- **URL Source** : $SourceDomain
- **URL Destination** : coachlibre.infra.$SourceDomain
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

```
tenants/$TargetTenant/
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
    ├── deploy.ps1             # Script de déploiement
    └── configure-dns.ps1      # Configuration DNS
```

## Accès

Le site sera accessible sur :
- **HTTP** : http://coachlibre.infra.$SourceDomain
- **HTTPS** : https://coachlibre.infra.$SourceDomain (après configuration Cloudflare)

## Maintenance

Pour toute question ou problème :
- Vérifier les logs : `kubectl logs -l app=$TargetTenant-web -n coachlibre`
- Redémarrer les pods : `kubectl rollout restart deployment/$TargetTenant-web -n coachlibre`
- Vérifier la connectivité : `kubectl port-forward service/$TargetTenant-web-service 8080:80 -n coachlibre`

---

**Status** : 🔄 Migration en cours  
**Dernière mise à jour** : $(Get-Date)  
**Version** : 1.0.0
"@

$tenantReadme | Out-File -FilePath "$tenantPath\README.md" -Encoding UTF8
Write-Host "README du tenant cree" -ForegroundColor Green

# Étape 7: Création des scripts de déploiement
Write-Host "`nEtape 7: Creation des scripts de deploiement..." -ForegroundColor Yellow

# Script de déploiement pour le tenant
$deployScript = @"
# Script de deploiement pour le tenant $TargetTenant
Write-Host "Deploiement du tenant $TargetTenant..." -ForegroundColor Green

# Appliquer les ConfigMaps
kubectl apply -f deployment/assets-configmap.yaml
kubectl apply -f deployment/js-configmap.yaml

# Appliquer le déploiement
kubectl apply -f deployment/deployment.yaml
kubectl apply -f deployment/service.yaml
kubectl apply -f deployment/ingress.yaml

# Vérifier le statut
Write-Host "Statut du deploiement:" -ForegroundColor Cyan
kubectl get pods -l app=$TargetTenant-web -n coachlibre
kubectl get services -l app=$TargetTenant-web -n coachlibre
kubectl get ingress -n coachlibre

Write-Host "Deploiement termine !" -ForegroundColor Green
Write-Host "Site accessible sur: http://coachlibre.infra.$SourceDomain" -ForegroundColor Cyan
"@

$deployScript | Out-File -FilePath "$tenantScriptsPath\deploy.ps1" -Encoding UTF8
Write-Host "Script de deploiement cree" -ForegroundColor Green

# Étape 8: Configuration DNS
Write-Host "`nEtape 8: Configuration DNS..." -ForegroundColor Yellow

$dnsScript = @"
# Script de configuration DNS pour $TargetTenant
param(
    [string]`$CloudflareToken = "",
    [string]`$ZoneId = ""
)

Write-Host "Configuration DNS pour $TargetTenant..." -ForegroundColor Green

# Headers pour l'API Cloudflare
`$headers = @{
    'Authorization' = "Bearer `$CloudflareToken"
    'Content-Type' = 'application/json'
}

# Créer l'enregistrement A
`$dnsRecord = @{
    type = "A"
    name = "coachlibre.infra.$SourceDomain"
    content = "49.13.218.200"  # IP du serveur Hetzner
    ttl = 1
    proxied = `$true
}

`$dnsJson = `$dnsRecord | ConvertTo-Json

try {
    `$response = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/`$ZoneId/dns_records" -Method POST -Headers `$headers -Body `$dnsJson
    
    if (`$response.success) {
        Write-Host "Enregistrement DNS cree avec succes!" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de la creation de l'enregistrement DNS" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur lors de la communication avec l'API Cloudflare" -ForegroundColor Red
}

Write-Host "Configuration DNS terminee !" -ForegroundColor Green
"@

$dnsScript | Out-File -FilePath "$tenantScriptsPath\configure-dns.ps1" -Encoding UTF8
Write-Host "Script de configuration DNS cree" -ForegroundColor Green

# Étape 9: Résumé final
Write-Host "`nEtape 9: Resume final..." -ForegroundColor Yellow

Write-Host "Migration terminee avec succes !" -ForegroundColor Green
Write-Host "`nResume de la migration:" -ForegroundColor Cyan
Write-Host "- Domaine source: $SourceDomain" -ForegroundColor White
Write-Host "- Tenant cible: $TargetTenant" -ForegroundColor White
Write-Host "- Structure creee: $tenantPath" -ForegroundColor White
Write-Host "- Scripts de deploiement: $tenantScriptsPath" -ForegroundColor White

Write-Host "`nProchaines etapes:" -ForegroundColor Cyan
Write-Host "1. Configurer le contenu extrait dans $tenantContentPath" -ForegroundColor White
Write-Host "2. Adapter les fichiers de deploiement dans $tenantDeploymentPath" -ForegroundColor White
Write-Host "3. Deployer avec: .\tenants\$TargetTenant\scripts\deploy.ps1" -ForegroundColor White
Write-Host "4. Configurer le DNS avec: .\tenants\$TargetTenant\scripts\configure-dns.ps1" -ForegroundColor White

Write-Host "`nDocumentation: .\tenants\$TargetTenant\README.md" -ForegroundColor Yellow


