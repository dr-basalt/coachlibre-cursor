#!/usr/bin/env node

import inquirer from 'inquirer';
import chalk from 'chalk';
import ora from 'ora';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

interface SetupConfig {
  projectName: string;
  frontendDomain: string;
  backendDomain: string;
  databaseUrl: string;
  openaiApiKey: string;
  stripeSecretKey: string;
  cloudflareApiToken: string;
  environment: 'development' | 'staging' | 'production';
}

async function main() {
  console.log(chalk.blue.bold('🚀 CoachLibre Setup Wizard'));
  console.log(chalk.gray('Configuration de votre plateforme de coaching multi-agent\n'));

  try {
    const config = await promptConfiguration();
    await validateConfiguration(config);
    await generateConfigurationFiles(config);
    await displayNextSteps(config);
    
    console.log(chalk.green.bold('\n✅ Configuration terminée avec succès !'));
  } catch (error) {
    console.error(chalk.red.bold('\n❌ Erreur lors de la configuration :'), error);
    process.exit(1);
  }
}

async function promptConfiguration(): Promise<SetupConfig> {
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'projectName',
      message: 'Nom du projet :',
      default: 'coachlibre',
      validate: (input: string) => {
        if (!input.trim()) return 'Le nom du projet est requis';
        if (!/^[a-z0-9-]+$/.test(input)) {
          return 'Le nom doit contenir uniquement des lettres minuscules, chiffres et tirets';
        }
        return true;
      }
    },
    {
      type: 'input',
      name: 'frontendDomain',
      message: 'Domaine frontend (ex: app.coachlibre.com) :',
      default: 'app.coachlibre.com',
      validate: (input: string) => {
        if (!input.trim()) return 'Le domaine frontend est requis';
        return true;
      }
    },
    {
      type: 'input',
      name: 'backendDomain',
      message: 'Domaine backend (ex: api.coachlibre.com) :',
      default: 'api.coachlibre.com',
      validate: (input: string) => {
        if (!input.trim()) return 'Le domaine backend est requis';
        return true;
      }
    },
    {
      type: 'input',
      name: 'databaseUrl',
      message: 'URL de la base de données PostgreSQL :',
      default: 'postgresql://user:password@localhost:5432/coachlibre',
      validate: (input: string) => {
        if (!input.trim()) return 'L\'URL de la base de données est requise';
        if (!input.startsWith('postgresql://')) {
          return 'L\'URL doit commencer par postgresql://';
        }
        return true;
      }
    },
    {
      type: 'password',
      name: 'openaiApiKey',
      message: 'Clé API OpenAI :',
      validate: (input: string) => {
        if (!input.trim()) return 'La clé API OpenAI est requise';
        if (!input.startsWith('sk-')) {
          return 'La clé API doit commencer par sk-';
        }
        return true;
      }
    },
    {
      type: 'password',
      name: 'stripeSecretKey',
      message: 'Clé secrète Stripe :',
      validate: (input: string) => {
        if (!input.trim()) return 'La clé secrète Stripe est requise';
        if (!input.startsWith('sk_')) {
          return 'La clé secrète doit commencer par sk_';
        }
        return true;
      }
    },
    {
      type: 'password',
      name: 'cloudflareApiToken',
      message: 'Token API Cloudflare :',
      validate: (input: string) => {
        if (!input.trim()) return 'Le token API Cloudflare est requis';
        return true;
      }
    },
    {
      type: 'list',
      name: 'environment',
      message: 'Environnement :',
      choices: [
        { name: 'Développement', value: 'development' },
        { name: 'Staging', value: 'staging' },
        { name: 'Production', value: 'production' }
      ],
      default: 'development'
    }
  ]);

  return answers as SetupConfig;
}

async function validateConfiguration(config: SetupConfig) {
  const spinner = ora('Validation de la configuration...').start();
  
  try {
    // Validation des domaines
    if (config.frontendDomain === config.backendDomain) {
      throw new Error('Les domaines frontend et backend doivent être différents');
    }

    // Validation de la base de données
    if (!config.databaseUrl.includes('@')) {
      throw new Error('URL de base de données invalide');
    }

    spinner.succeed('Configuration validée');
  } catch (error) {
    spinner.fail('Erreur de validation');
    throw error;
  }
}

async function generateConfigurationFiles(config: SetupConfig) {
  const spinner = ora('Génération des fichiers de configuration...').start();
  
  try {
    const rootDir = path.resolve(__dirname, '../../../');
    
    // Génération du fichier .env
    const envContent = generateEnvFile(config);
    await fs.writeFile(path.join(rootDir, '.env'), envContent);
    
    // Génération du fichier .env.example
    const envExampleContent = generateEnvExampleFile();
    await fs.writeFile(path.join(rootDir, '.env.example'), envExampleContent);
    
    // Génération de la configuration Kubernetes
    await generateK8sConfig(config, rootDir);
    
    // Génération de la configuration ArgoCD
    await generateArgoCDConfig(config, rootDir);
    
    spinner.succeed('Fichiers de configuration générés');
  } catch (error) {
    spinner.fail('Erreur lors de la génération');
    throw error;
  }
}

function generateEnvFile(config: SetupConfig): string {
  return `# Configuration CoachLibre
NODE_ENV=${config.environment}

# Base de données
DATABASE_URL=${config.databaseUrl}

# OpenAI
OPENAI_API_KEY=${config.openaiApiKey}

# Stripe
STRIPE_SECRET_KEY=${config.stripeSecretKey}
STRIPE_PUBLISHABLE_KEY=pk_test_...

# Cloudflare
CLOUDFLARE_API_TOKEN=${config.cloudflareApiToken}

# Domaines
FRONTEND_DOMAIN=${config.frontendDomain}
BACKEND_DOMAIN=${config.backendDomain}

# TinaCMS
TINA_CLIENT_ID=your_tina_client_id
TINA_TOKEN=your_tina_token

# LiveKit
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret

# Qdrant
QDRANT_URL=http://localhost:6333

# Monitoring
PROMETHEUS_URL=http://localhost:9090
GRAFANA_URL=http://localhost:3000
`;
}

function generateEnvExampleFile(): string {
  return `# Configuration CoachLibre - Exemple
NODE_ENV=development

# Base de données
DATABASE_URL=postgresql://user:password@localhost:5432/coachlibre

# OpenAI
OPENAI_API_KEY=sk-your_openai_api_key

# Stripe
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key

# Cloudflare
CLOUDFLARE_API_TOKEN=your_cloudflare_api_token

# Domaines
FRONTEND_DOMAIN=app.coachlibre.com
BACKEND_DOMAIN=api.coachlibre.com

# TinaCMS
TINA_CLIENT_ID=your_tina_client_id
TINA_TOKEN=your_tina_token

# LiveKit
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret

# Qdrant
QDRANT_URL=http://localhost:6333

# Monitoring
PROMETHEUS_URL=http://localhost:9090
GRAFANA_URL=http://localhost:3000
`;
}

async function generateK8sConfig(config: SetupConfig, rootDir: string) {
  const k8sDir = path.join(rootDir, 'infrastructure/k8s');
  await fs.ensureDir(k8sDir);
  
  const namespaceYaml = `apiVersion: v1
kind: Namespace
metadata:
  name: coachlibre
  labels:
    name: coachlibre
`;
  
  await fs.writeFile(path.join(k8sDir, 'namespace.yaml'), namespaceYaml);
  
  const configMapYaml = `apiVersion: v1
kind: ConfigMap
metadata:
  name: coachlibre-config
  namespace: coachlibre
data:
  FRONTEND_DOMAIN: "${config.frontendDomain}"
  BACKEND_DOMAIN: "${config.backendDomain}"
  NODE_ENV: "${config.environment}"
`;
  
  await fs.writeFile(path.join(k8sDir, 'configmap.yaml'), configMapYaml);
}

async function generateArgoCDConfig(config: SetupConfig, rootDir: string) {
  const argocdDir = path.join(rootDir, 'infrastructure/argocd');
  await fs.ensureDir(argocdDir);
  
  const applicationYaml = `apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: coachlibre
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/coachlibre
    targetRevision: main
    path: infrastructure/k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: coachlibre
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
`;
  
  await fs.writeFile(path.join(argocdDir, 'application.yaml'), applicationYaml);
}

async function displayNextSteps(config: SetupConfig) {
  console.log(chalk.blue.bold('\n📋 Prochaines étapes :'));
  console.log(chalk.gray('\n1. Installation des dépendances :'));
  console.log(chalk.white('   pnpm install'));
  
  console.log(chalk.gray('\n2. Configuration des domaines DNS :'));
  console.log(chalk.white(`   - ${config.frontendDomain} → Votre serveur`));
  console.log(chalk.white(`   - ${config.backendDomain} → Votre serveur`));
  
  console.log(chalk.gray('\n3. Démarrage en mode développement :'));
  console.log(chalk.white('   pnpm dev'));
  
  console.log(chalk.gray('\n4. Déploiement en production :'));
  console.log(chalk.white('   pnpm deploy'));
  
  console.log(chalk.gray('\n📚 Documentation :'));
  console.log(chalk.white('   https://github.com/your-org/coachlibre/docs'));
  
  console.log(chalk.gray('\n🆘 Support :'));
  console.log(chalk.white('   https://github.com/your-org/coachlibre/issues'));
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(console.error);
} 