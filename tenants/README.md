# Arborescence des Tenants - CoachLibre

## 🏗️ Structure des Sites Multi-Tenants

Cette arborescence permet de gérer plusieurs sites web (tenants) de manière organisée et modulaire.

```
tenants/
├── README.md                    # Documentation
├── ori3com/                     # Site www.ori3com.cloud
│   ├── README.md               # Documentation spécifique
│   ├── content/                # Contenu du site
│   │   ├── index.html         # Page d'accueil
│   │   ├── assets/            # Ressources (CSS, JS, images)
│   │   └── pages/             # Pages additionnelles
│   ├── deployment/             # Configuration Kubernetes
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   └── scripts/                # Scripts de déploiement
├── coachlibre/                 # Site principal CoachLibre
│   ├── README.md
│   ├── content/
│   ├── deployment/
│   └── scripts/
└── templates/                  # Templates réutilisables
    ├── nginx/
    ├── kubernetes/
    └── scripts/
```

## 🚀 Déploiement

### Site Ori3Com
- **URL Source** : www.ori3com.cloud
- **URL Destination** : coachlibre.infra.ori3com.cloud
- **Namespace** : coachlibre
- **Service** : ori3com-web

### Site CoachLibre
- **URL** : coachlibre.infra.ori3com.cloud (version actuelle)
- **Namespace** : coachlibre
- **Service** : coachlibre-web

## 📋 Workflow de Migration

1. **Récupération** : Extraction du contenu du site source
2. **Adaptation** : Modification des URLs et références
3. **Déploiement** : Mise en place sur l'infrastructure CoachLibre
4. **Validation** : Tests et vérifications
5. **Migration DNS** : Redirection du trafic

## 🔧 Commandes Utiles

```bash
# Déployer un tenant
kubectl apply -f tenants/{tenant}/deployment/

# Vérifier le statut
kubectl get pods -n coachlibre -l app={tenant}

# Accéder aux logs
kubectl logs -n coachlibre deployment/{tenant}-deployment
```

## 📝 Notes

- Chaque tenant a sa propre configuration Kubernetes
- Les assets sont optimisés pour l'infrastructure CoachLibre
- Support multi-environnements (dev, staging, prod)
- Monitoring et logs centralisés

