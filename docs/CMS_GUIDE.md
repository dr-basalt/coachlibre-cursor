# Guide d'Utilisation du CMS - CoachLibre

## 🎯 Vue d'ensemble

CoachLibre utilise **TinaCMS** comme système de gestion de contenu, intégré avec **Astro** pour créer une expérience d'édition moderne et intuitive.

## 🚀 Accès au CMS

### Option 1: Interface Web (Page d'accueil)
1. Allez sur http://coachlibre.infra.ori3com.cloud
2. Cliquez sur **"Accéder au CMS"** ou **"Gérer les Pages"**
3. Connectez-vous avec vos identifiants TinaCMS

### Option 2: Développement Local
```bash
# Dans le répertoire du projet
cd apps/frontend

# Installer les dépendances
pnpm install

# Démarrer l'application avec TinaCMS
pnpm run tina:dev
```

L'interface sera disponible sur :
- **Site** : http://localhost:4321
- **CMS** : http://localhost:4321/admin

## 📝 Collections Disponibles

### 📄 Pages
Gérez les pages statiques du site :
- **Page d'accueil** : Contenu principal du site
- **À propos** : Informations sur CoachLibre
- **Services** : Description des services offerts
- **Contact** : Informations de contact

**Champs disponibles :**
- `title` : Titre de la page (obligatoire)
- `description` : Description meta
- `body` : Contenu principal (rich text)

### 📝 Articles
Créez et publiez des articles :
- **Articles de blog** : Contenu informatif
- **Actualités** : Nouvelles et mises à jour
- **Tutoriels** : Guides et instructions
- **Ressources** : Documents et liens utiles

**Champs disponibles :**
- `title` : Titre de l'article (obligatoire)
- `description` : Description meta
- `date` : Date de publication
- `body` : Contenu principal (rich text)

## 🛠️ Fonctionnalités du CMS

### ✏️ Éditeur Rich Text
- **Formatage** : Gras, italique, souligné
- **Titres** : H1, H2, H3, H4, H5, H6
- **Listes** : À puces et numérotées
- **Liens** : URLs internes et externes
- **Images** : Upload et insertion
- **Code** : Blocs de code avec coloration syntaxique

### 🖼️ Gestion des Médias
- **Upload** : Glisser-déposer d'images
- **Organisation** : Dossier `uploads/`
- **Optimisation** : Redimensionnement automatique
- **Alt text** : Accessibilité

### 🔄 Workflow de Publication
1. **Création** : Nouveau contenu
2. **Édition** : Modification du contenu
3. **Prévisualisation** : Aperçu avant publication
4. **Sauvegarde** : Enregistrement des modifications
5. **Publication** : Mise en ligne

## 🎨 Personnalisation

### Configuration TinaCMS
Le fichier `apps/frontend/tina/config.ts` contient :
- **Collections** : Structure des contenus
- **Champs** : Types de données
- **Validation** : Règles de saisie
- **Interface** : Personnalisation de l'UI

### Thèmes et Styles
- **TailwindCSS** : Classes utilitaires
- **Composants React** : Interface personnalisée
- **Responsive** : Adaptation mobile/desktop

## 🔧 Commandes Utiles

### Développement
```bash
# Démarrer en mode développement
pnpm run dev

# Démarrer avec TinaCMS
pnpm run tina:dev

# Builder l'application
pnpm run build

# Builder avec TinaCMS
pnpm run tina:build
```

### Scripts Automatisés
```bash
# Script PowerShell pour démarrer le CMS
./scripts/start-astro-cms-dev.ps1
```

## 🔒 Sécurité et Authentification

### Configuration des Tokens
```bash
# Variables d'environnement requises
TINA_CLIENT_ID=your_client_id
TINA_TOKEN=your_token
```

### Permissions
- **Lecture** : Consultation du contenu
- **Écriture** : Modification du contenu
- **Admin** : Gestion complète

## 📊 Statistiques et Analytics

### Métriques Disponibles
- **Pages vues** : Trafic du site
- **Contenu édité** : Modifications fréquentes
- **Performance** : Temps de chargement
- **SEO** : Optimisation des moteurs de recherche

## 🚨 Dépannage

### Problèmes Courants

#### CMS inaccessible
```bash
# Vérifier que l'application est démarrée
kubectl get pods -n coachlibre

# Vérifier les logs
kubectl logs -n coachlibre deployment/coachlibre-frontend-astro-cms
```

#### Erreurs de build
```bash
# Nettoyer les caches
pnpm clean

# Réinstaller les dépendances
pnpm install

# Rebuilder
pnpm run build
```

#### Problèmes de connexion
- Vérifier les tokens TinaCMS
- Contrôler la connectivité réseau
- Vérifier les permissions

### Support
- **Documentation** : Ce guide
- **Logs** : Console du navigateur
- **Kubernetes** : `kubectl logs`
- **TinaCMS** : Documentation officielle

## 🔄 Intégration Continue

### Workflow Git
1. **Édition** : Via TinaCMS
2. **Commit** : Sauvegarde automatique
3. **Push** : Synchronisation avec Git
4. **Build** : Génération automatique
5. **Déploiement** : Mise en production

### Environnements
- **Développement** : Local (localhost:4321)
- **Staging** : Pré-production
- **Production** : coachlibre.infra.ori3com.cloud

## 📚 Ressources Additionnelles

### Documentation
- [TinaCMS Documentation](https://tina.io/docs/)
- [Astro Documentation](https://docs.astro.build/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)

### Communauté
- [TinaCMS Discord](https://discord.gg/tinacms)
- [Astro Discord](https://discord.gg/astro)
- [GitHub Issues](https://github.com/dr-basalt/coachlibre-cursor/issues)

---

**CoachLibre CMS** - Interface moderne pour la gestion de contenu
