# Script de déploiement pour Ori3Com
Write-Host "🚀 Déploiement du site Ori3Com..." -ForegroundColor Green

# Vérifier que kubectl est disponible
try {
    $kubectlVersion = kubectl version --client --short
    Write-Host "✅ kubectl disponible: $kubectlVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl non disponible. Veuillez l'installer." -ForegroundColor Red
    exit 1
}

# Vérifier la connexion au cluster
try {
    kubectl cluster-info
    Write-Host "✅ Connexion au cluster établie" -ForegroundColor Green
} catch {
    Write-Host "❌ Impossible de se connecter au cluster Kubernetes" -ForegroundColor Red
    exit 1
}

# Déployer les ConfigMaps
Write-Host "📦 Déploiement des ConfigMaps..." -ForegroundColor Yellow
kubectl apply -f tenants/ori3com/deployment/assets-configmap.yaml
kubectl apply -f tenants/ori3com/deployment/js-configmap.yaml

# Déployer le déploiement principal
Write-Host "🏗️ Déploiement de l'application..." -ForegroundColor Yellow
kubectl apply -f tenants/ori3com/deployment/deployment.yaml

# Déployer le service
Write-Host "🔗 Déploiement du service..." -ForegroundColor Yellow
kubectl apply -f tenants/ori3com/deployment/service.yaml

# Déployer l'ingress
Write-Host "🌐 Déploiement de l'ingress..." -ForegroundColor Yellow
kubectl apply -f tenants/ori3com/deployment/ingress.yaml

# Attendre que les pods soient prêts
Write-Host "⏳ Attente du démarrage des pods..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=ori3com-web -n coachlibre --timeout=300s

# Vérifier le statut
Write-Host "📊 Statut du déploiement:" -ForegroundColor Cyan
kubectl get pods -l app=ori3com-web -n coachlibre
kubectl get services -l app=ori3com-web -n coachlibre
kubectl get ingress -l app=ori3com-web -n coachlibre

Write-Host "🎉 Déploiement terminé !" -ForegroundColor Green
Write-Host "🌐 Site accessible sur: http://coachlibre.infra.ori3com.cloud" -ForegroundColor Cyan


