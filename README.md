# 🚀 CoachLibre - Plateforme SaaS Multi-Agent pour Coaching

## 🎯 Vision
CoachLibre est une plateforme SaaS révolutionnaire qui utilise l'IA multi-agent pour automatiser et optimiser le processus de coaching. Chaque interaction utilisateur est traitée par un workflow d'agents spécialisés, du gestionnaire d'intention au release manager.

## 🏗️ Architecture Multi-Tenant Agentique

### Stack Core Validée
- **Backend Core**: CrewAI (orchestration agents) + PayloadCMS (admin/config) + FastAPI (API gateway)
- **Base de données**: PostgreSQL + Qdrant (vector search)
- **Workflow Layer**: Flowise (conversational AI) + n8n (automation workflows)
- **Site Builder**: Astro + TinaCMS (édition inline) + React Islands
- **Infrastructure**: Kubernetes + Crossplane + Backstage + ArgoCD

### 🔄 Workflow Multi-Agent
```
Utilisateur → Gestionnaire d'Intention → Chef Projet Fonctionnel → Chef Projet Technique → Lead Développeur → Release Manager
```

Chaque métier dispose de sous-agents en boucle d'amélioration jusqu'à atteindre les OKRs définis.

## 📁 Structure du Monorepo

```
coachlibre/
├── apps/
│   ├── frontend/          # Astro + TinaCMS (Site Builder)
│   ├── frontoffice/       # Interface client (Astro)
│   ├── backoffice/        # Interface admin (PayloadCMS)
│   └── api/              # FastAPI + CrewAI
├── packages/
│   ├── shared/           # Types et utilitaires partagés
│   ├── ui/              # Composants React réutilisables
│   └── agents/          # Définitions des agents CrewAI
├── infrastructure/
│   ├── k8s/             # Manifests Kubernetes
│   ├── crossplane/      # Infrastructure as Code
│   └── argocd/          # GitOps deployment
└── tools/
    ├── setup-wizard/    # Wizard de configuration
    └── dev-tools/       # Outils de développement
```

## 🚀 Fonctionnalités Clés

### 🎥 Système de Visio
- **LiveKit** + HLS/WHIP pour WebRTC → HLS
- Support multi-bitrate et CDN
- Transition automatique pour le one-to-many

### 📅 Gestion des RDV
- Système composable type Cal.com
- Connecteurs OAuth (Google/Apple/Outlook)
- Scalabilité horizontale

### 🧠 Assistant IA
- RAG réflexif sur MongoDB
- Pre-diagnostic et recommandations
- Aide au choix d'accompagnement

### 🛒 Tunnel de Vente
- Éditeur de funnels drag & drop
- Templates Airtable/Baserow
- Gestion des modèles de commercialisation

### 💳 Paiements & CRM
- Intégration Stripe
- Connecteurs HubSpot, ActiveCampaign
- Gestion bancaire (Qonto/Shine)

## 🛠️ Technologies

### Frontend
- **Astro** (SSR/SSG + Hydration)
- **TinaCMS** (édition inline)
- **React Islands** (composants interactifs)
- **TailwindCSS** (styling)

### Backend
- **FastAPI** (API Gateway)
- **PayloadCMS** (Headless CMS)
- **CrewAI** (orchestration agents)
- **PostgreSQL** + **Qdrant** (vector DB)

### Workflow & IA
- **Flowise** (conversational AI)
- **n8n** (automation)
- **Ollama** (LLM local)
- **Mistral** (LLM cloud)

### Infrastructure
- **Kubernetes** (orchestration)
- **Crossplane** (IaC)
- **Backstage** (developer portal)
- **ArgoCD** (GitOps)
- **Cloudflare** (CDN/DNS)

## 🚀 Quick Start

```bash
# Installation
npm install

# Démarrage en mode développement
npm run dev

# Build pour production
npm run build

# Déploiement
npm run deploy
```

## 📋 Roadmap

- [ ] Setup initial du monorepo
- [ ] Configuration CrewAI + agents
- [ ] Interface Astro + TinaCMS
- [ ] Intégration LiveKit
- [ ] Système de RDV
- [ ] Assistant IA RAG
- [ ] Tunnel de vente
- [ ] Infrastructure Kubernetes
- [ ] CI/CD GitOps

## 🤝 Contribution

Ce projet suit les standards de développement modernes avec une architecture évolutive et modulaire. 