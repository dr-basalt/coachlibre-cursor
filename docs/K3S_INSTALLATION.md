# 🚀 Guide d'Installation CoachLibre sur K3s

## 📋 Compatibilité

✅ **CoachLibre est 100% compatible avec K3s** ! Le projet est conçu pour fonctionner sur Kubernetes et K3s est une distribution légère de Kubernetes parfaite pour ce type de déploiement.

## 🎯 Prérequis

### Cluster K3s
- **K3s** : Version 1.24+ (recommandé 1.28+)
- **Rancher** : Interface de gestion (optionnel mais recommandé)
- **Ressources minimales** :
  - **CPU** : 4 cœurs
  - **RAM** : 8 GB
  - **Stockage** : 50 GB SSD
  - **Réseau** : Accès internet pour les images Docker

### Outils requis
- **kubectl** : Client Kubernetes
- **helm** : Gestionnaire de packages Kubernetes
- **git** : Pour cloner le projet

## 🚀 Installation Étape par Étape

### 1. Préparation du Cluster

```bash
# Vérifier l'accès au cluster
kubectl cluster-info

# Vérifier les nodes
kubectl get nodes

# Vérifier les namespaces
kubectl get namespaces
```

### 2. Installation des Dépendances

#### Helm Charts requis :
```bash
# Ajouter les repos Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Installer cert-manager (pour les certificats SSL)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Attendre que cert-manager soit prêt
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s
```

#### Cluster Issuer pour Let's Encrypt :
```bash
# Créer le ClusterIssuer pour Let's Encrypt
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

### 3. Clonage et Configuration du Projet

```bash
# Cloner le projet
git clone https://github.com/dr-basalt/coachlibre-cursor.git
cd coachlibre-cursor

# Aller dans le répertoire infrastructure
cd infrastructure/k8s
```

### 4. Configuration des Secrets

**⚠️ IMPORTANT** : Vous devez configurer vos propres clés API avant le déploiement.

```bash
# Créer un fichier temporaire pour encoder vos secrets
cat > encode-secrets.sh << 'EOF'
#!/bin/bash

echo "Configuration des secrets CoachLibre"
echo "===================================="

# Demander les clés API
read -p "Clé API OpenAI: " OPENAI_KEY
read -p "Clé API Mistral: " MISTRAL_KEY
read -p "Clé secrète Stripe: " STRIPE_KEY
read -p "Secret JWT (générer une chaîne aléatoire): " JWT_SECRET
read -p "Clé de chiffrement (générer une chaîne aléatoire): " ENCRYPTION_KEY

# Encoder en base64
OPENAI_B64=$(echo -n "$OPENAI_KEY" | base64)
MISTRAL_B64=$(echo -n "$MISTRAL_KEY" | base64)
STRIPE_B64=$(echo -n "$STRIPE_KEY" | base64)
JWT_B64=$(echo -n "$JWT_SECRET" | base64)
ENCRYPTION_B64=$(echo -n "$ENCRYPTION_KEY" | base64)

# Mettre à jour le fichier secret.yaml
cat > secret.yaml << SECRET_EOF
apiVersion: v1
kind: Secret
metadata:
  name: coachlibre-secrets
  namespace: coachlibre
type: Opaque
data:
  OPENAI_API_KEY: "$OPENAI_B64"
  MISTRAL_API_KEY: "$MISTRAL_B64"
  STRIPE_SECRET_KEY: "$STRIPE_B64"
  JWT_SECRET: "$JWT_B64"
  ENCRYPTION_KEY: "$ENCRYPTION_B64"
SECRET_EOF

echo "✅ Fichier secret.yaml mis à jour"
echo "⚠️  N'oubliez pas de supprimer ce script après utilisation"
EOF

chmod +x encode-secrets.sh
./encode-secrets.sh
```

### 5. Configuration des Domaines

Éditer le fichier `configmap.yaml` pour vos domaines :

```bash
# Éditer les domaines dans configmap.yaml
sed -i 's/app.coachlibre.com/votre-domaine-frontend.com/g' configmap.yaml
sed -i 's/api.coachlibre.com/votre-domaine-api.com/g' configmap.yaml

# Éditer l'ingress pour vos domaines
sed -i 's/app.coachlibre.com/votre-domaine-frontend.com/g' ingress.yaml
sed -i 's/api.coachlibre.com/votre-domaine-api.com/g' ingress.yaml
```

### 6. Build et Push des Images Docker

```bash
# Retourner à la racine du projet
cd ../../

# Build des images
docker build -t coachlibre/api:latest ./apps/api
docker build -t coachlibre/frontend:latest ./apps/frontend

# Si vous avez un registry privé, tagger et pousser
# docker tag coachlibre/api:latest votre-registry.com/coachlibre/api:latest
# docker tag coachlibre/frontend:latest votre-registry.com/coachlibre/frontend:latest
# docker push votre-registry.com/coachlibre/api:latest
# docker push votre-registry.com/coachlibre/frontend:latest

# Mettre à jour les manifests avec votre registry si nécessaire
# sed -i 's/coachlibre\/api:latest/votre-registry.com\/coachlibre\/api:latest/g' infrastructure/k8s/api.yaml
# sed -i 's/coachlibre\/frontend:latest/votre-registry.com\/coachlibre\/frontend:latest/g' infrastructure/k8s/frontend.yaml
```

### 7. Déploiement

```bash
# Aller dans le répertoire k8s
cd infrastructure/k8s

# Appliquer tous les manifests
kubectl apply -k .

# Ou appliquer individuellement
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f postgresql.yaml
kubectl apply -f redis.yaml
kubectl apply -f qdrant.yaml
kubectl apply -f api.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml
```

### 8. Vérification du Déploiement

```bash
# Vérifier les pods
kubectl get pods -n coachlibre

# Vérifier les services
kubectl get services -n coachlibre

# Vérifier l'ingress
kubectl get ingress -n coachlibre

# Vérifier les certificats
kubectl get certificates -n coachlibre

# Logs des pods
kubectl logs -f deployment/api -n coachlibre
kubectl logs -f deployment/frontend -n coachlibre
```

## 🔧 Configuration Post-Déploiement

### 1. Base de Données

```bash
# Attendre que PostgreSQL soit prêt
kubectl wait --for=condition=ready pod -l app=postgresql -n coachlibre --timeout=300s

# Exécuter les migrations (si nécessaire)
kubectl exec -it deployment/api -n coachlibre -- python -m alembic upgrade head
```

### 2. Initialisation des Agents

```bash
# Vérifier que l'API répond
kubectl exec -it deployment/api -n coachlibre -- curl http://localhost:8000/health

# Initialiser les agents (si nécessaire)
kubectl exec -it deployment/api -n coachlibre -- python -c "
from agents.intent_manager import IntentManager
from agents.crew_manager import CrewManager
# Initialisation des agents
"
```

### 3. Monitoring

```bash
# Installer Prometheus et Grafana
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Accéder à Grafana
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
# URL: http://localhost:3000
# Login: admin
# Mot de passe: prom-operator
```

## 🌐 Accès aux Services

Une fois déployé, vos services seront accessibles via :

- **Frontend** : `https://votre-domaine-frontend.com`
- **API** : `https://votre-domaine-api.com`
- **Grafana** : `http://votre-cluster:3000` (port-forward)

## 🔍 Dépannage

### Problèmes courants :

1. **Pods en CrashLoopBackOff**
   ```bash
   # Vérifier les logs
   kubectl logs -f deployment/api -n coachlibre
   
   # Vérifier les événements
   kubectl get events -n coachlibre --sort-by='.lastTimestamp'
   ```

2. **Certificats SSL non générés**
   ```bash
   # Vérifier cert-manager
   kubectl get pods -n cert-manager
   
   # Vérifier les certificats
   kubectl describe certificate coachlibre-tls -n coachlibre
   ```

3. **Base de données non accessible**
   ```bash
   # Vérifier PostgreSQL
   kubectl logs -f deployment/postgresql -n coachlibre
   
   # Tester la connexion
   kubectl exec -it deployment/api -n coachlibre -- python -c "
   import psycopg2
   conn = psycopg2.connect('postgresql://coachlibre:coachlibre123@postgresql:5432/coachlibre')
   print('Connexion OK')
   "
   ```

4. **Images non trouvées**
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

## 📊 Monitoring et Maintenance

### Commandes utiles :

```bash
# État général du cluster
kubectl get nodes
kubectl top nodes
kubectl top pods -n coachlibre

# Sauvegarde de la base de données
kubectl exec -it deployment/postgresql -n coachlibre -- \
  pg_dump -U coachlibre coachlibre > backup.sql

# Redéploiement d'un service
kubectl rollout restart deployment/api -n coachlibre

# Mise à l'échelle
kubectl scale deployment api --replicas=3 -n coachlibre
```

### Alertes recommandées :

- **CPU** > 80% pendant 5 minutes
- **Mémoire** > 85% pendant 5 minutes
- **Pods** en état non Ready
- **Certificats** expirant dans 30 jours

## 🔄 Mise à Jour

```bash
# Mettre à jour les images
docker build -t coachlibre/api:latest ./apps/api
docker build -t coachlibre/frontend:latest ./apps/frontend

# Redéployer
kubectl rollout restart deployment/api -n coachlibre
kubectl rollout restart deployment/frontend -n coachlibre

# Vérifier le statut
kubectl rollout status deployment/api -n coachlibre
```

## 🎯 Prochaines Étapes

1. **Configurer les sauvegardes automatiques**
2. **Mettre en place le monitoring avancé**
3. **Configurer les alertes**
4. **Optimiser les performances**
5. **Mettre en place la haute disponibilité**

---

**✅ CoachLibre est maintenant déployé sur votre cluster K3s !**

Pour toute question ou problème, consultez les logs et les événements Kubernetes, ou contactez l'équipe de support. 