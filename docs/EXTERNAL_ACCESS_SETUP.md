# 🌐 Configuration de l'Accès Externe CoachLibre

Ce guide explique comment configurer l'accès externe à l'application CoachLibre via Hetzner Cloud et Cloudflare.

## 📋 Prérequis

- Cluster K3s opérationnel
- Compte Hetzner Cloud avec API token
- Compte Cloudflare avec API token
- Domaine `ori3com.cloud` configuré sur Cloudflare

## 🚀 Configuration Rapide

### 1. Configuration des Variables d'Environnement

```powershell
# Token API Hetzner Cloud
$env:HETZNER_API_TOKEN = "votre_token_hetzner"

# Token API Cloudflare
$env:CLOUDFLARE_API_TOKEN = "votre_token_cloudflare"
$env:CLOUDFLARE_ZONE_ID = "votre_zone_id_cloudflare"
```

### 2. Configuration Automatique

```powershell
# 1. Configurer le Load Balancer Hetzner
.\scripts\configure-hetzner-lb.ps1

# 2. Configurer Cloudflare (après avoir l'IP du LB)
.\scripts\configure-cloudflare.ps1

# 3. Tester l'accès
.\scripts\test-external-access.ps1
```

## 🔧 Configuration Manuelle

### Configuration Hetzner Cloud

1. **Créer un Load Balancer**
   - Type: `lb11`
   - Location: `fsn1` (Frankfurt)
   - Nom: `coachlibre-lb`

2. **Ajouter les nœuds K3s comme targets**
   - `49.13.218.200` (master)
   - `91.99.152.96` (slave1)
   - `159.69.244.226` (slave2)

3. **Configurer les services**
   - HTTP sur le port 80
   - HTTPS sur le port 443

### Configuration Cloudflare

1. **Ajouter un enregistrement DNS**
   - Type: `A`
   - Nom: `coachlibre.infra`
   - Cible: `[IP_DU_LOAD_BALANCER_HETZNER]`
   - Proxy: Activé (nuage orange)

2. **Configurer SSL/TLS**
   - Mode: `Full (strict)`
   - Always Use HTTPS: Activé

## 📊 Vérification

### Test de l'Application

```powershell
# Vérifier l'état du cluster
kubectl get pods -n coachlibre
kubectl get ingress -n coachlibre

# Tester l'accès
curl https://coachlibre.infra.ori3com.cloud
```

### Surveillance des Logs

```powershell
# Logs en temps réel
kubectl logs -f -n coachlibre -l app=coachlibre-frontend

# Logs de l'ingress
kubectl logs -f -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

## 🔒 Sécurité

### Certificats SSL

- Certificats automatiques via Let's Encrypt
- Renouvellement automatique
- Mode Full (strict) sur Cloudflare

### Règles de Sécurité

- Always Use HTTPS activé
- Headers de sécurité configurés
- CORS configuré pour l'API

## 🛠️ Dépannage

### Problèmes Courants

1. **DNS non résolu**
   - Vérifier la configuration Cloudflare
   - Attendre la propagation DNS (5-10 minutes)

2. **Certificat SSL invalide**
   - Vérifier cert-manager
   - Vérifier la configuration Let's Encrypt

3. **Load Balancer inaccessible**
   - Vérifier les règles de firewall
   - Vérifier la configuration des targets

### Commandes de Diagnostic

```powershell
# Vérifier l'état des certificats
kubectl get certificates -n coachlibre

# Vérifier les événements
kubectl get events -n coachlibre --sort-by=.lastTimestamp

# Tester la connectivité
Test-NetConnection -ComputerName coachlibre.infra.ori3com.cloud -Port 443
```

## 📝 URLs Finales

- **Application**: https://coachlibre.infra.ori3com.cloud
- **API** (future): https://api.coachlibre.infra.ori3com.cloud
- **Documentation**: https://docs.coachlibre.infra.ori3com.cloud

## 🔄 Maintenance

### Mise à Jour

```powershell
# Redéployer l'application
.\scripts\deploy-complete.ps1

# Mettre à jour les certificats
kubectl delete certificate coachlibre-frontend-tls -n coachlibre
```

### Sauvegarde

```powershell
# Sauvegarder la configuration
kubectl get all -n coachlibre -o yaml > backup/coachlibre-$(Get-Date -Format 'yyyyMMdd-HHmmss').yaml
```

## 📞 Support

En cas de problème :
1. Vérifier les logs avec les commandes ci-dessus
2. Consulter la documentation Kubernetes
3. Vérifier la configuration des services cloud
