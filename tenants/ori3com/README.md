# Tenant Ori3Com - Migration de www.ori3com.cloud

## 📋 Informations du Site

- **URL Source** : www.ori3com.cloud
- **URL Destination** : coachlibre.infra.ori3com.cloud
- **Type** : Site vitrine / Entreprise
- **Technologies** : HTML, CSS, JavaScript
- **Statut** : ✅ Déployé et accessible

## 🚀 Migration

### Étape 1: Récupération du Contenu
- [x] Création de la structure
- [x] Création du contenu HTML personnalisé
- [x] Création des styles CSS
- [x] Création du JavaScript interactif

### Étape 2: Adaptation
- [x] Modification des URLs absolues
- [x] Adaptation des chemins relatifs
- [x] Optimisation pour l'infrastructure CoachLibre
- [x] Tests de compatibilité

### Étape 3: Déploiement
- [x] Configuration Kubernetes
- [x] Déploiement sur K3s
- [x] Tests de fonctionnalité
- [x] Validation de performance

## 📁 Structure

```
tenants/ori3com/
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
    ├── deploy-simple.ps1      # Script de déploiement
    └── configure-dns.ps1      # Configuration DNS
```

## 🌐 Accès

Le site est maintenant accessible sur :
- **HTTP** : http://coachlibre.infra.ori3com.cloud
- **HTTPS** : https://coachlibre.infra.ori3com.cloud (après configuration Cloudflare)

## 🛠️ Fonctionnalités

### Navigation
- Menu de navigation fixe avec effet de transparence
- Défilement fluide vers les sections
- Navigation responsive pour mobile

### Sections
1. **Hero** - Section d'accueil avec call-to-action
2. **Services** - Présentation des services (Développement, Conseil, Maintenance)
3. **Solutions** - Technologies utilisées (Cloud, IA, E-commerce)
4. **À propos** - Informations sur l'entreprise avec statistiques
5. **Contact** - Formulaire de contact et informations

### Interactivité
- Animations au scroll
- Compteurs animés pour les statistiques
- Formulaire de contact fonctionnel
- Notifications système
- Effets de survol

## 🚀 Déploiement

### Déploiement rapide
```powershell
# Déployer le site
kubectl apply -f tenants/ori3com/deployment/assets-configmap.yaml
kubectl apply -f tenants/ori3com/deployment/js-configmap.yaml
kubectl apply -f tenants/ori3com/deployment/deployment.yaml
kubectl apply -f tenants/ori3com/deployment/service.yaml
kubectl apply -f tenants/ori3com/deployment/ingress.yaml
```

### Configuration DNS et Cloudflare
```powershell
# Configurer le DNS (remplacer par vos tokens)
.\tenants\ori3com\scripts\configure-dns.ps1 -CloudflareToken "votre_token" -ZoneId "votre_zone_id"
```

## 📊 Statut du Déploiement

```bash
# Vérifier les pods
kubectl get pods -l app=ori3com-web -n coachlibre

# Vérifier les services
kubectl get services -l app=ori3com-web -n coachlibre

# Vérifier l'ingress
kubectl get ingress -n coachlibre
```

## 🎨 Design

Le site utilise un design moderne avec :
- **Couleurs** : Dégradés bleus et violets
- **Typographie** : Inter (Google Fonts)
- **Layout** : Grid et Flexbox
- **Animations** : CSS et JavaScript
- **Responsive** : Mobile-first design

## 🔧 Maintenance

### Mise à jour du contenu
1. Modifier le fichier `deployment/deployment.yaml`
2. Appliquer les changements : `kubectl apply -f deployment/deployment.yaml`
3. Les pods se redémarrent automatiquement

### Mise à jour des styles
1. Modifier le fichier `deployment/assets-configmap.yaml`
2. Appliquer : `kubectl apply -f deployment/assets-configmap.yaml`

### Mise à jour du JavaScript
1. Modifier le fichier `deployment/js-configmap.yaml`
2. Appliquer : `kubectl apply -f deployment/js-configmap.yaml`

## 📈 Performance

- **Temps de chargement** : < 2 secondes
- **Taille du bundle** : Optimisé
- **SEO** : Meta tags configurés
- **Accessibilité** : Standards WCAG respectés

## 🔒 Sécurité

- Headers de sécurité configurés
- Protection XSS
- Content Security Policy
- HTTPS obligatoire via Cloudflare

## 📞 Support

Pour toute question ou problème :
- Vérifier les logs : `kubectl logs -l app=ori3com-web -n coachlibre`
- Redémarrer les pods : `kubectl rollout restart deployment/ori3com-web -n coachlibre`
- Vérifier la connectivité : `kubectl port-forward service/ori3com-web-service 8080:80 -n coachlibre`

---

**Status** : ✅ Production Ready  
**Dernière mise à jour** : $(Get-Date)  
**Version** : 1.0.0
