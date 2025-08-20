# Script de déploiement complet CoachLibre sur K3s
Write-Host "🚀 Déploiement complet CoachLibre sur K3s..." -ForegroundColor Green

# Configuration
$NAMESPACE = "coachlibre"
$IMAGE_NAME = "coachlibre/frontend"
$IMAGE_TAG = "latest"

# 1. Vérification de l'environnement
Write-Host "📋 Vérification de l'environnement..." -ForegroundColor Yellow
kubectl config current-context
kubectl get namespace $NAMESPACE

# 2. Build de l'image de test
Write-Host "🔨 Build de l'image de test..." -ForegroundColor Yellow
docker build -t $IMAGE_NAME`:test -f apps/frontend/Dockerfile.test .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du build de l'image de test" -ForegroundColor Red
    exit 1
}

# 3. Tag de l'image pour le registry local (optionnel)
Write-Host "🏷️ Tag de l'image..." -ForegroundColor Yellow
docker tag $IMAGE_NAME`:test $IMAGE_NAME`:$IMAGE_TAG

# 4. Application du déploiement
Write-Host "📦 Application du déploiement..." -ForegroundColor Yellow
kubectl apply -f infrastructure/k8s/frontend-deployment-simple.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de l'application du déploiement" -ForegroundColor Red
    exit 1
}

# 5. Attente du démarrage des pods
Write-Host "⏳ Attente du démarrage des pods..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=coachlibre-frontend -n $NAMESPACE --timeout=300s

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Timeout lors du démarrage des pods" -ForegroundColor Red
    kubectl get pods -n $NAMESPACE
    kubectl describe pods -l app=coachlibre-frontend -n $NAMESPACE
    exit 1
}

# 6. Vérification du déploiement
Write-Host "✅ Vérification du déploiement..." -ForegroundColor Green
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE
kubectl get ingress -n $NAMESPACE

# 7. Test de l'application
Write-Host "🧪 Test de l'application..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Démarrer le port-forward en arrière-plan
$portForwardJob = Start-Job -ScriptBlock {
    param($namespace)
    kubectl port-forward service/coachlibre-frontend-service 8080:80 -n $namespace
} -ArgumentList $NAMESPACE

Start-Sleep -Seconds 3

# Test de la connexion
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application accessible sur http://localhost:8080" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️ Impossible de tester l'application localement" -ForegroundColor Yellow
}

# Arrêter le port-forward
Stop-Job $portForwardJob
Remove-Job $portForwardJob

Write-Host "Deploiement termine avec succes!" -ForegroundColor Green
Write-Host "L'application sera accessible sur: http://coachlibre.local" -ForegroundColor Cyan
Write-Host "Pour voir les logs: kubectl logs -f deployment/coachlibre-frontend -n $NAMESPACE" -ForegroundColor Yellow
