# Script de configuration de l'accès externe CoachLibre
Write-Host "🌐 Configuration de l'accès externe CoachLibre..." -ForegroundColor Green

# Configuration
$NAMESPACE = "coachlibre"
$DOMAIN = "coachlibre.infra.ori3com.cloud"
$HETZNER_LB_NAME = "coachlibre-lb"
$HETZNER_LB_TYPE = "lb11"  # Load balancer type
$HETZNER_LOCATION = "fsn1"  # Frankfurt

# 1. Vérification de l'état actuel
Write-Host "📋 Vérification de l'état actuel..." -ForegroundColor Yellow
kubectl get pods -n $NAMESPACE
kubectl get ingress -n $NAMESPACE

# 2. Mise à jour de l'ingress avec le bon domaine
Write-Host "🔧 Mise à jour de l'ingress..." -ForegroundColor Yellow

# Créer un nouveau manifest d'ingress avec le domaine
$ingressYaml = @"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: coachlibre-frontend-ingress
  namespace: $NAMESPACE
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "30"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - $DOMAIN
    secretName: coachlibre-frontend-tls
  rules:
  - host: $DOMAIN
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: coachlibre-frontend-service
            port:
              number: 80
"@

# Sauvegarder le manifest
$ingressYaml | Out-File -FilePath "infrastructure/k8s/frontend-ingress-external.yaml" -Encoding UTF8

# Appliquer le nouveau manifest
kubectl apply -f infrastructure/k8s/frontend-ingress-external.yaml

# 3. Instructions pour Hetzner Cloud
Write-Host "☁️ Configuration Hetzner Cloud requise:" -ForegroundColor Cyan
Write-Host "1. Créer un Load Balancer dans Hetzner Cloud Console" -ForegroundColor Yellow
Write-Host "2. Type: $HETZNER_LB_TYPE" -ForegroundColor Yellow
Write-Host "3. Location: $HETZNER_LOCATION" -ForegroundColor Yellow
Write-Host "4. Nom: $HETZNER_LB_NAME" -ForegroundColor Yellow
Write-Host "5. Ajouter les 3 nœuds K3s comme targets:" -ForegroundColor Yellow
Write-Host "   - 49.13.218.200 (master)" -ForegroundColor Yellow
Write-Host "   - 91.99.152.96 (slave1)" -ForegroundColor Yellow
Write-Host "   - 159.69.244.226 (slave2)" -ForegroundColor Yellow
Write-Host "6. Configurer le service HTTP sur le port 80" -ForegroundColor Yellow
Write-Host "7. Configurer le service HTTPS sur le port 443" -ForegroundColor Yellow

# 4. Instructions pour Cloudflare
Write-Host "☁️ Configuration Cloudflare requise:" -ForegroundColor Cyan
Write-Host "1. Aller sur https://dash.cloudflare.com" -ForegroundColor Yellow
Write-Host "2. Sélectionner le domaine: ori3com.cloud" -ForegroundColor Yellow
Write-Host "3. Aller dans DNS > Records" -ForegroundColor Yellow
Write-Host "4. Ajouter un enregistrement CNAME:" -ForegroundColor Yellow
Write-Host "   - Nom: coachlibre.infra" -ForegroundColor Yellow
Write-Host "   - Cible: [IP_DU_LOAD_BALANCER_HETZNER]" -ForegroundColor Yellow
Write-Host "   - Proxy: Activé (nuage orange)" -ForegroundColor Yellow
Write-Host "5. Configurer SSL/TLS > Overview > Full (strict)" -ForegroundColor Yellow

# 5. Vérification de l'ingress
Write-Host "✅ Vérification de l'ingress..." -ForegroundColor Green
kubectl get ingress -n $NAMESPACE

Write-Host "🎉 Configuration terminée!" -ForegroundColor Green
Write-Host "📝 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Configurer le Load Balancer Hetzner" -ForegroundColor Yellow
Write-Host "2. Configurer le domaine Cloudflare" -ForegroundColor Yellow
Write-Host "3. Tester l'accès sur https://$DOMAIN" -ForegroundColor Yellow
