# 🚀 Guide de Démarrage Rapide - CoachLibre

## Prérequis

- **Node.js** 18+ et **pnpm** 8+
- **Python** 3.11+
- **Docker** et **Docker Compose**
- **Git**

## Installation

### 1. Cloner le projet
```bash
git clone https://github.com/your-org/coachlibre.git
cd coachlibre
```

### 2. Configuration initiale
```bash
# Lancer le wizard de configuration
pnpm setup
```

Le wizard vous demandera :
- Nom du projet
- Domaines frontend/backend
- URL de base de données PostgreSQL
- Clé API OpenAI
- Clé secrète Stripe
- Token API Cloudflare
- Environnement (dev/staging/prod)

### 3. Installation des dépendances
```bash
# Installation globale
pnpm install

# Build des packages partagés
pnpm run build
```

### 4. Démarrage avec Docker Compose
```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier les services
docker-compose ps
```

## Services Disponibles

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Site Builder Astro |
| API | http://localhost:8000 | API FastAPI |
| n8n | http://localhost:5678 | Workflows automatisés |
| Flowise | http://localhost:3002 | IA conversationnelle |
| Grafana | http://localhost:3001 | Monitoring (admin/admin) |
| Prometheus | http://localhost:9090 | Métriques |
| PostgreSQL | localhost:5432 | Base de données |
| Qdrant | http://localhost:6333 | Base vectorielle |
| Redis | localhost:6379 | Cache |

## Développement

### Structure du projet
```
coachlibre/
├── apps/
│   ├── frontend/          # Astro + TinaCMS
│   ├── frontoffice/       # Interface client
│   ├── backoffice/        # Interface admin
│   └── api/              # FastAPI + CrewAI
├── packages/
│   ├── shared/           # Types et utilitaires
│   ├── ui/              # Composants React
│   └── agents/          # Définitions agents
├── infrastructure/
│   ├── k8s/             # Kubernetes
│   ├── crossplane/      # Infrastructure as Code
│   └── argocd/          # GitOps
└── tools/
    ├── setup-wizard/    # Configuration
    └── dev-tools/       # Outils dev
```

### Commandes utiles

```bash
# Démarrage en mode développement
pnpm dev

# Build pour production
pnpm build

# Tests
pnpm test

# Linting
pnpm lint

# Déploiement
pnpm deploy
```

### Développement des agents

Les agents CrewAI sont dans `apps/api/agents/` :

```python
# Exemple d'utilisation d'un agent
from agents.intent_manager import IntentManager

intent_manager = IntentManager()
result = await intent_manager.process_intent("Je veux un coaching en leadership")
```

### Développement frontend

Le frontend utilise Astro avec TinaCMS :

```bash
cd apps/frontend

# Mode développement
pnpm dev

# Mode TinaCMS
pnpm tina:dev
```

## Configuration

### Variables d'environnement

Créer un fichier `.env` basé sur `.env.example` :

```env
# Base de données
DATABASE_URL=postgresql://user:password@localhost:5432/coachlibre

# OpenAI
OPENAI_API_KEY=sk-your_key_here

# Stripe
STRIPE_SECRET_KEY=sk_test_your_key_here

# Domaines
FRONTEND_DOMAIN=app.coachlibre.com
BACKEND_DOMAIN=api.coachlibre.com
```

### Configuration des agents

Les agents peuvent être configurés via l'API :

```bash
# Vérifier le statut des agents
curl http://localhost:8000/agents/intent/status

# Améliorer un agent
curl -X POST http://localhost:8000/agents/intent/improve \
  -H "Content-Type: application/json" \
  -d '{"feedback": "Améliorer l'analyse des intentions"}'
```

## Tests

### Tests API
```bash
cd apps/api
pytest
```

### Tests Frontend
```bash
cd apps/frontend
pnpm test
```

### Tests E2E
```bash
# Avec Playwright
pnpm test:e2e
```

## Déploiement

### Développement local
```bash
# Avec Docker Compose
docker-compose up -d

# Ou en mode développement
pnpm dev
```

### Staging
```bash
# Build et déploiement
pnpm build
pnpm deploy:staging
```

### Production
```bash
# Déploiement GitOps avec ArgoCD
git push origin main
# ArgoCD déploie automatiquement
```

## Monitoring

### Métriques
- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3001 (admin/admin)

### Logs
```bash
# Logs des services
docker-compose logs -f api
docker-compose logs -f frontend
```

### Santé des agents
```bash
# Vérifier la santé du système
curl http://localhost:8000/health
```

## Dépannage

### Problèmes courants

1. **Port déjà utilisé**
   ```bash
   # Vérifier les ports utilisés
   netstat -tulpn | grep :8000
   
   # Arrêter le processus
   kill -9 <PID>
   ```

2. **Base de données non accessible**
   ```bash
   # Vérifier PostgreSQL
   docker-compose logs postgres
   
   # Redémarrer
   docker-compose restart postgres
   ```

3. **Agents non fonctionnels**
   ```bash
   # Vérifier les logs
   docker-compose logs api
   
   # Vérifier la clé OpenAI
   echo $OPENAI_API_KEY
   ```

### Support

- **Documentation** : `/docs/`
- **Issues** : GitHub Issues
- **Discord** : [Lien Discord]

## Prochaines étapes

1. **Personnalisation** : Configurer vos agents
2. **Intégrations** : Connecter vos services
3. **Déploiement** : Mettre en production
4. **Monitoring** : Configurer les alertes
5. **Scaling** : Optimiser les performances 