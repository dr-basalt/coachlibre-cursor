# Script de déploiement simplifié pour Ori3Com
Write-Host "🚀 Déploiement du site Ori3Com..." -ForegroundColor Green

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

# Vérifier le statut
Write-Host "📊 Statut du déploiement:" -ForegroundColor Cyan
kubectl get pods -l app=ori3com-web -n coachlibre
kubectl get services -l app=ori3com-web -n coachlibre
kubectl get ingress -l app=ori3com-web -n coachlibre

Write-Host "🎉 Déploiement terminé !" -ForegroundColor Green
Write-Host "🌐 Site accessible sur: http://coachlibre.infra.ori3com.cloud" -ForegroundColor Cyan


