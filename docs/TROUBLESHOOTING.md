# 🔧 Guide de Dépannage CoachLibre

## 🚨 Problèmes Courants et Solutions

### 1. Erreur de Dépendances Workspace

**Problème :**
```bash
ERR_PNPM_WORKSPACE_PKG_NOT_FOUND  In apps/api: "@coachlibre/agents@workspace:*" is in the dependencies but no package named "@coachlibre/agents" is present in the workspace
```

**Solution :**
```bash
# Exécuter le script de correction automatique
chmod +x scripts/fix-dependencies.sh
./scripts/fix-dependencies.sh
```

**Ou manuellement :**
```bash
# Nettoyer les caches
pnpm store prune
rm -rf node_modules
rm -f pnpm-lock.yaml

# Réinstaller
pnpm install
```

### 2. Erreur de Build Docker

**Problème :**
```bash
ERROR: failed to solve: process "/bin/sh -c pnpm install" did not return a zero code
```

**Solution :**
```bash
# Vérifier que pnpm est installé dans le Dockerfile
# Ajouter dans le Dockerfile :
RUN npm install -g pnpm

# Ou utiliser une image avec pnpm préinstallé
FROM node:18-alpine
RUN npm install -g pnpm
```

### 3. Erreur de Port Déjà Utilisé

**Problème :**
```bash
Error: listen EADDRINUSE: address already in use :::8000
```

**Solution :**
```bash
# Vérifier les ports utilisés
netstat -tulpn | grep :8000

# Arrêter le processus
kill -9 <PID>

# Ou changer le port dans la configuration
```

### 4. Erreur de Base de Données

**Problème :**
```bash
psycopg2.OperationalError: could not connect to server
```

**Solution :**
```bash
# Vérifier que PostgreSQL est démarré
docker-compose ps postgres

# Redémarrer PostgreSQL
docker-compose restart postgres

# Vérifier les logs
docker-compose logs postgres
```

### 5. Erreur de Certificats SSL

**Problème :**
```bash
cert-manager: cert-manager/controller "msg"="failed to obtain certificate"
```

**Solution :**
```bash
# Vérifier cert-manager
kubectl get pods -n cert-manager

# Vérifier les certificats
kubectl get certificates -n coachlibre

# Vérifier les événements
kubectl get events -n coachlibre --sort-by='.lastTimestamp'
```

### 6. Erreur d'Images Docker Non Trouvées

**Problème :**
```bash
Failed to pull image "coachlibre/api:latest": rpc error: code = Unknown desc = failed to pull and unpack image
```

**Solution :**
```bash
# Build les images localement
docker build -t coachlibre/api:latest ./apps/api
docker build -t coachlibre/frontend:latest ./apps/frontend

# Ou utiliser un registry privé
docker tag coachlibre/api:latest votre-registry.com/coachlibre/api:latest
docker push votre-registry.com/coachlibre/api:latest
```

### 7. Erreur de Mémoire Insuffisante

**Problème :**
```bash
JavaScript heap out of memory
```

**Solution :**
```bash
# Augmenter la mémoire Node.js
export NODE_OPTIONS="--max-old-space-size=4096"

# Ou dans package.json
"scripts": {
  "build": "NODE_OPTIONS='--max-old-space-size=4096' pnpm run build"
}
```

### 8. Erreur de Permissions

**Problème :**
```bash
EACCES: permission denied
```

**Solution :**
```bash
# Corriger les permissions
sudo chown -R $USER:$USER .
chmod +x scripts/*.sh

# Ou utiliser sudo si nécessaire
sudo pnpm install
```

### 9. Erreur de Version Node.js

**Problème :**
```bash
Unsupported engine for package
```

**Solution :**
```bash
# Vérifier la version Node.js
node --version

# Installer la bonne version (18+ recommandé)
# Avec nvm :
nvm install 18
nvm use 18

# Ou avec votre gestionnaire de paquets
```

### 10. Erreur de Dépendances Python

**Problème :**
```bash
ModuleNotFoundError: No module named 'crewai'
```

**Solution :**
```bash
# Installer les dépendances Python
cd apps/api
pip install -r requirements.txt

# Ou avec Docker
docker build -t coachlibre/api:latest .
```

## 🔍 Commandes de Diagnostic

### Vérification Générale
```bash
# Vérifier l'état du projet
pnpm list --depth=0
pnpm run build

# Vérifier les services Docker
docker-compose ps
docker-compose logs

# Vérifier Kubernetes
kubectl get pods -n coachlibre
kubectl get events -n coachlibre --sort-by='.lastTimestamp'
```

### Logs Détaillés
```bash
# Logs API
kubectl logs -f deployment/api -n coachlibre
docker-compose logs -f api

# Logs Frontend
kubectl logs -f deployment/frontend -n coachlibre
docker-compose logs -f frontend

# Logs Base de données
kubectl logs -f deployment/postgresql -n coachlibre
docker-compose logs -f postgres
```

### Tests de Connectivité
```bash
# Test API
curl http://localhost:8000/health
kubectl exec -it deployment/api -n coachlibre -- curl http://localhost:8000/health

# Test Base de données
kubectl exec -it deployment/postgresql -n coachlibre -- psql -U coachlibre -d coachlibre -c "SELECT 1;"

# Test Redis
kubectl exec -it deployment/redis -n coachlibre -- redis-cli ping
```

## 🛠️ Scripts de Récupération

### Script de Réparation Complète
```bash
#!/bin/bash
# Script de réparation complète

echo "🔧 Réparation complète CoachLibre"

# 1. Nettoyer
rm -rf node_modules
rm -f pnpm-lock.yaml
docker-compose down -v

# 2. Réinstaller
pnpm install
pnpm run build

# 3. Redémarrer
docker-compose up -d

# 4. Vérifier
docker-compose ps
curl http://localhost:8000/health
```

### Script de Sauvegarde
```bash
#!/bin/bash
# Script de sauvegarde

echo "💾 Sauvegarde CoachLibre"

# Sauvegarder la base de données
docker-compose exec postgres pg_dump -U coachlibre coachlibre > backup_$(date +%Y%m%d_%H%M%S).sql

# Sauvegarder les configurations
tar -czf config_backup_$(date +%Y%m%d_%H%M%S).tar.gz infrastructure/k8s/ docs/

echo "✅ Sauvegarde terminée"
```

## 📞 Support

### Informations à Fournir
Quand vous demandez de l'aide, fournissez :

1. **Version du système :**
   ```bash
   node --version
   pnpm --version
   docker --version
   kubectl version
   ```

2. **Logs d'erreur complets :**
   ```bash
   pnpm install 2>&1 | tee install.log
   ```

3. **État du système :**
   ```bash
   df -h
   free -h
   docker system df
   ```

4. **Configuration :**
   - Contenu de `package.json`
   - Contenu de `docker-compose.yml`
   - Variables d'environnement (sans les secrets)

### Ressources Utiles
- **Documentation** : `/docs/`
- **Issues GitHub** : [Lien vers les issues]
- **Discord** : [Lien Discord]
- **Email** : support@coachlibre.com

---

**💡 Conseil :** En cas de doute, commencez toujours par exécuter `./scripts/fix-dependencies.sh` qui corrige automatiquement la plupart des problèmes courants. 