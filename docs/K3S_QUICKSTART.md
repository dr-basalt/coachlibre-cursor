# ⚡ Démarrage Rapide CoachLibre sur K3s

## 🎯 Installation Express (5 minutes)

### 1. Prérequis Vérifiés
```bash
# Vérifier l'accès au cluster
kubectl cluster-info
kubectl get nodes
```

### 2. Installation Automatisée
```bash
# Cloner le projet
git clone https://github.com/dr-basalt/coachlibre-cursor.git
cd coachlibre-cursor

# Rendre le script exécutable
chmod +x scripts/install-k3s.sh

# Lancer l'installation
./scripts/install-k3s.sh
```

Le script va automatiquement :
- ✅ Installer cert-manager
- ✅ Configurer Let's Encrypt
- ✅ Demander vos clés API
- ✅ Configurer vos domaines
- ✅ Build les images Docker
- ✅ Déployer CoachLibre
- ✅ Vérifier le déploiement

### 3. Accès aux Services
Une fois terminé, vos services seront accessibles :
- **Frontend** : `https://votre-domaine-frontend.com`
- **API** : `https://votre-domaine-api.com`

## 🔧 Installation Manuelle (Si nécessaire)

### Étape 1 : Dépendances
```bash
# Installer cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Configurer Let's Encrypt
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: votre-email@domaine.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
EOF
```

### Étape 2 : Configuration
```bash
cd infrastructure/k8s

# Configurer vos domaines
sed -i 's/app.coachlibre.com/votre-domaine-frontend.com/g' configmap.yaml
sed -i 's/api.coachlibre.com/votre-domaine-api.com/g' configmap.yaml
sed -i 's/app.coachlibre.com/votre-domaine-frontend.com/g' ingress.yaml
sed -i 's/api.coachlibre.com/votre-domaine-api.com/g' ingress.yaml

# Configurer vos secrets (remplacer les valeurs)
# Éditer secret.yaml avec vos clés API encodées en base64
```

### Étape 3 : Build et Déploiement
```bash
# Build des images
docker build -t coachlibre/api:latest ../../apps/api
docker build -t coachlibre/frontend:latest ../../apps/frontend

# Déploiement
kubectl apply -k .
```

## 🚨 Dépannage Rapide

### Problème : Pods en CrashLoopBackOff
```bash
# Vérifier les logs
kubectl logs -f deployment/api -n coachlibre
kubectl logs -f deployment/frontend -n coachlibre

# Vérifier les événements
kubectl get events -n coachlibre --sort-by='.lastTimestamp'
```

### Problème : Certificats SSL non générés
```bash
# Vérifier cert-manager
kubectl get pods -n cert-manager

# Vérifier les certificats
kubectl describe certificate coachlibre-tls -n coachlibre
```

### Problème : Images non trouvées
```bash
# Vérifier les images
kubectl describe pod -l app=api -n coachlibre

# Si registry privé, configurer imagePullSecrets
kubectl create secret docker-registry regcred \
  --docker-server=votre-registry.com \
  --docker-username=votre-username \
  --docker-password=votre-password \
  --namespace=coachlibre
```

## 📊 Commandes Utiles

```bash
# Statut général
kubectl get pods -n coachlibre
kubectl get services -n coachlibre
kubectl get ingress -n coachlibre

# Logs en temps réel
kubectl logs -f deployment/api -n coachlibre
kubectl logs -f deployment/frontend -n coachlibre

# Accéder à un pod
kubectl exec -it deployment/api -n coachlibre -- bash

# Redéployer un service
kubectl rollout restart deployment/api -n coachlibre

# Mise à l'échelle
kubectl scale deployment api --replicas=3 -n coachlibre
```

## 🔄 Mise à Jour

```bash
# Build des nouvelles images
docker build -t coachlibre/api:latest ./apps/api
docker build -t coachlibre/frontend:latest ./apps/frontend

# Redéploiement
kubectl rollout restart deployment/api -n coachlibre
kubectl rollout restart deployment/frontend -n coachlibre

# Vérifier le statut
kubectl rollout status deployment/api -n coachlibre
```

## 📞 Support

- **Documentation complète** : `/docs/K3S_INSTALLATION.md`
- **Logs détaillés** : `kubectl logs -f deployment/api -n coachlibre`
- **Événements** : `kubectl get events -n coachlibre --sort-by='.lastTimestamp'`

---

**✅ CoachLibre est maintenant opérationnel sur votre cluster K3s !** 