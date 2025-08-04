# 🏗️ Architecture CoachLibre

## Vue d'ensemble

CoachLibre est une plateforme SaaS multi-agent qui utilise l'IA pour automatiser et optimiser le processus de coaching. L'architecture est conçue pour être scalable, modulaire et évolutive.

## Architecture Globale

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Frontoffice   │    │   Backoffice    │
│   (Astro)       │    │   (Astro)       │    │ (PayloadCMS)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   API Gateway   │
                    │   (FastAPI)     │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │  Multi-Agent    │
                    │   Workflow      │
                    │   (CrewAI)      │
                    └─────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │     Qdrant      │    │     Redis       │
│   (Primary DB)  │    │   (Vector DB)   │    │    (Cache)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Composants Principaux

### 1. Frontend (Site Builder)
- **Technologie**: Astro + TinaCMS + React Islands
- **Rôle**: Interface d'édition inline pour les sites de coaching
- **Fonctionnalités**:
  - Édition WYSIWYG
  - Templates drag & drop
  - Intégration IA pour la génération de contenu
  - Preview en temps réel

### 2. Frontoffice (Interface Client)
- **Technologie**: Astro + React
- **Rôle**: Interface utilisateur pour les clients
- **Fonctionnalités**:
  - Assistant IA RAG
  - Système de prise de RDV
  - Visio intégrée (LiveKit)
  - Espaces de formation

### 3. Backoffice (Interface Admin)
- **Technologie**: PayloadCMS
- **Rôle**: Administration et gestion de la plateforme
- **Fonctionnalités**:
  - Gestion des utilisateurs
  - Configuration des agents
  - Monitoring et analytics
  - Gestion des paiements

### 4. API Gateway
- **Technologie**: FastAPI
- **Rôle**: Point d'entrée unique pour toutes les APIs
- **Fonctionnalités**:
  - Authentification et autorisation
  - Rate limiting
  - Validation des données
  - Routing vers les services

### 5. Workflow Multi-Agent
- **Technologie**: CrewAI
- **Rôle**: Orchestration des agents spécialisés
- **Agents**:
  - **IntentManager**: Analyse des intentions utilisateur
  - **ProjectManager**: Gestion des besoins fonctionnels
  - **TechnicalLead**: Conception technique
  - **ReleaseManager**: Préparation des livrables

## Workflow Multi-Agent

```
Utilisateur → IntentManager → ProjectManager → TechnicalLead → ReleaseManager
     │              │              │              │              │
     └──────────────┴──────────────┴──────────────┴──────────────┘
                                    │
                              OKR Monitor
```

### Boucle d'Amélioration
Chaque agent dispose de sous-agents en boucle d'amélioration :
1. **Sous-agent 1** : Traitement initial
2. **Sous-agent 2** : Supervision et amélioration
3. **Retour au sous-agent 1** : Amélioration itérative
4. **Validation OKR** : Contrôle qualité

## Base de Données

### PostgreSQL (Base principale)
- **Rôle**: Données transactionnelles
- **Tables principales**:
  - Users, Coaches, Clients
  - Appointments, Sessions
  - Payments, Subscriptions
  - Workflows, AgentResults

### Qdrant (Base vectorielle)
- **Rôle**: Recherche sémantique et RAG
- **Collections**:
  - Coaching content
  - User interactions
  - Agent knowledge base
  - Training materials

### Redis (Cache)
- **Rôle**: Cache et sessions
- **Utilisation**:
  - Cache des réponses d'agents
  - Sessions utilisateur
  - Rate limiting
  - Job queues

## Intégrations Externes

### Paiements
- **Stripe**: Paiements et abonnements
- **Connecteurs bancaires**: Qonto, Shine

### Communication
- **LiveKit**: Visioconférence WebRTC → HLS
- **OAuth**: Google, Apple, Outlook (calendriers)

### IA et Workflows
- **Flowise**: IA conversationnelle
- **n8n**: Automatisation des workflows
- **Ollama**: LLM local
- **Mistral**: LLM cloud

### Marketing et CRM
- **HubSpot**: CRM
- **ActiveCampaign**: Email marketing
- **Airtable/Baserow**: Templates et données

## Infrastructure

### Kubernetes
- **Orchestration**: Gestion des conteneurs
- **Scaling**: Auto-scaling horizontal
- **Load Balancing**: Distribution de charge
- **Service Mesh**: Communication inter-services

### Crossplane
- **Infrastructure as Code**: Définition déclarative
- **Multi-cloud**: Support AWS, GCP, Azure
- **GitOps**: Synchronisation automatique

### ArgoCD
- **Déploiement GitOps**: Synchronisation avec Git
- **Rollback automatique**: En cas de problème
- **Monitoring**: État des déploiements

### Backstage
- **Developer Portal**: Interface développeur
- **Service Catalog**: Catalogue des services
- **Documentation**: Documentation technique

## Sécurité

### Authentification
- **JWT**: Tokens d'authentification
- **OAuth 2.0**: Authentification tierce
- **MFA**: Authentification multi-facteurs

### Autorisation
- **RBAC**: Contrôle d'accès basé sur les rôles
- **Tenant isolation**: Isolation multi-tenant
- **API Gateway**: Validation des permissions

### Chiffrement
- **HTTPS/TLS**: Chiffrement en transit
- **Encryption at rest**: Chiffrement au repos
- **Secrets management**: Gestion des secrets

## Monitoring et Observabilité

### Métriques
- **Prometheus**: Collecte de métriques
- **Grafana**: Visualisation et alerting
- **Custom metrics**: Métriques métier

### Logs
- **ELK Stack**: Centralisation des logs
- **Structured logging**: Logs structurés
- **Log aggregation**: Agrégation des logs

### Tracing
- **Jaeger**: Traçage distribué
- **OpenTelemetry**: Standard de traçage
- **Performance monitoring**: Monitoring des performances

## Performance

### Optimisations
- **CDN**: Cloudflare pour le contenu statique
- **Caching**: Redis pour les données fréquentes
- **Database optimization**: Index et requêtes optimisées
- **Image optimization**: Compression des images

### Scalabilité
- **Horizontal scaling**: Réplication des services
- **Vertical scaling**: Ressources adaptatives
- **Load balancing**: Distribution intelligente
- **Database sharding**: Partitionnement des données

## Déploiement

### Environnements
- **Development**: Développement local
- **Staging**: Tests et validation
- **Production**: Environnement de production

### Stratégies
- **Blue-Green**: Déploiement sans interruption
- **Canary**: Déploiement progressif
- **Rolling**: Mise à jour progressive

### CI/CD
- **GitHub Actions**: Automatisation
- **ArgoCD**: Déploiement GitOps
- **Testing**: Tests automatisés
- **Security scanning**: Analyse de sécurité

## Évolutivité

### Modularité
- **Microservices**: Services indépendants
- **API-first**: APIs bien définies
- **Plugin architecture**: Architecture extensible

### Extensibilité
- **Custom agents**: Agents personnalisables
- **Workflow builder**: Création de workflows
- **Template system**: Système de templates

### Maintenance
- **Automated updates**: Mises à jour automatiques
- **Health checks**: Vérifications de santé
- **Backup strategy**: Stratégie de sauvegarde 