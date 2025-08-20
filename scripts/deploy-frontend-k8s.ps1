# Script de déploiement du frontend sur K3s
Write-Host "🚀 Déploiement du frontend CoachLibre sur K3s..." -ForegroundColor Green

# Configuration
$IMAGE_NAME = "coachlibre/frontend"
$IMAGE_TAG = "latest"
$NAMESPACE = "coachlibre"

# Vérifier que kubectl est configuré
Write-Host "📋 Vérification de la configuration kubectl..." -ForegroundColor Yellow
kubectl config current-context

# Vérifier que le namespace existe
Write-Host "📁 Vérification du namespace $NAMESPACE..." -ForegroundColor Yellow
kubectl get namespace $NAMESPACE

# Build de l'image Docker
Write-Host "🔨 Build de l'image Docker..." -ForegroundColor Yellow
docker build -t $IMAGE_NAME`:$IMAGE_TAG -f apps/frontend/Dockerfile .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du build Docker" -ForegroundColor Red
    exit 1
}

# Tag et push de l'image (optionnel - pour un registry distant)
# docker tag $IMAGE_NAME`:$IMAGE_TAG your-registry.com/$IMAGE_NAME`:$IMAGE_TAG
# docker push your-registry.com/$IMAGE_NAME`:$IMAGE_TAG

# Application des manifests Kubernetes
Write-Host "📦 Application des manifests Kubernetes..." -ForegroundColor Yellow
kubectl apply -f infrastructure/k8s/frontend-deployment.yaml

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de l'application des manifests" -ForegroundColor Red
    exit 1
}

# Attendre que les pods soient prêts
Write-Host "⏳ Attente du démarrage des pods..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=coachlibre-frontend -n $NAMESPACE --timeout=300s

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Timeout lors du démarrage des pods" -ForegroundColor Red
    kubectl get pods -n $NAMESPACE
    kubectl describe pods -l app=coachlibre-frontend -n $NAMESPACE
    exit 1
}

# Vérification du déploiement
Write-Host "✅ Vérification du déploiement..." -ForegroundColor Green
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE
kubectl get ingress -n $NAMESPACE

Write-Host "🎉 Déploiement terminé avec succès!" -ForegroundColor Green
Write-Host "🌐 L'application sera accessible sur: https://coachlibre.local" -ForegroundColor Cyan
