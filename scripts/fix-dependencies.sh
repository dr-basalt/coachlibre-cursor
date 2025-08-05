#!/bin/bash

# 🔧 Script de correction des dépendances CoachLibre
# Auteur: CoachLibre Team
# Version: 1.0.0

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour vérifier et corriger les packages manquants
fix_missing_packages() {
    print_status "Vérification des packages manquants..."
    
    # Vérifier si le package agents existe
    if [ ! -f "packages/agents/package.json" ]; then
        print_warning "Package @coachlibre/agents manquant, création..."
        
        # Créer le répertoire si nécessaire
        mkdir -p packages/agents
        
        # Créer package.json
        cat > packages/agents/package.json << 'EOF'
{
  "name": "@coachlibre/agents",
  "version": "1.0.0",
  "description": "Définitions des agents CrewAI",
  "main": "index.ts",
  "types": "index.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "jest",
    "lint": "eslint . --ext .ts"
  },
  "dependencies": {
    "@coachlibre/shared": "workspace:*"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0"
  }
}
EOF
        
        # Créer les fichiers TypeScript
        cat > packages/agents/index.ts << 'EOF'
// Export des types et interfaces pour les agents
export * from './types';
export * from './interfaces';
export * from './utils';
EOF
        
        cat > packages/agents/types.ts << 'EOF'
// Types pour les agents CrewAI
export interface AgentConfig {
  name: string;
  role: string;
  goal: string;
  backstory?: string;
  verbose?: boolean;
  allow_delegation?: boolean;
  tools?: string[];
}

export interface AgentResponse {
  success: boolean;
  data?: any;
  error?: string;
  agent_name: string;
  timestamp: string;
}

export interface AgentTask {
  id: string;
  description: string;
  agent: string;
  status: 'pending' | 'running' | 'completed' | 'failed';
  result?: any;
  created_at: string;
  completed_at?: string;
}

export interface CrewConfig {
  agents: AgentConfig[];
  tasks: string[];
  verbose?: boolean;
  memory?: boolean;
  cache?: boolean;
  max_rpm?: number;
  share_crew?: boolean;
}
EOF
        
        cat > packages/agents/interfaces.ts << 'EOF'
// Interfaces pour les agents CrewAI
export interface IAgent {
  name: string;
  role: string;
  goal: string;
  execute(task: string): Promise<any>;
  getStatus(): string;
}

export interface ICrewManager {
  agents: IAgent[];
  addAgent(agent: IAgent): void;
  removeAgent(agentName: string): void;
  executeTask(task: string, agentName?: string): Promise<any>;
  getAgentStatus(agentName: string): string;
}

export interface IIntentManager {
  analyzeIntent(userInput: string): Promise<string>;
  classifyIntent(intent: string): string;
  routeToAgent(intent: string): string;
}

export interface IProjectManager {
  createProject(requirements: string): Promise<string>;
  updateProject(projectId: string, updates: any): Promise<void>;
  getProjectStatus(projectId: string): Promise<string>;
}

export interface ITechnicalLead {
  reviewCode(code: string): Promise<string>;
  suggestImprovements(code: string): Promise<string[]>;
  estimateEffort(requirements: string): Promise<number>;
}

export interface IReleaseManager {
  prepareRelease(projectId: string): Promise<string>;
  validateRelease(releaseId: string): Promise<boolean>;
  deployRelease(releaseId: string): Promise<void>;
}
EOF
        
        cat > packages/agents/utils.ts << 'EOF'
// Utilitaires pour les agents CrewAI
import { AgentConfig, AgentResponse, AgentTask } from './types';

export function createAgentResponse(
  agentName: string,
  success: boolean,
  data?: any,
  error?: string
): AgentResponse {
  return {
    success,
    data,
    error,
    agent_name: agentName,
    timestamp: new Date().toISOString()
  };
}

export function createAgentTask(
  description: string,
  agent: string
): AgentTask {
  return {
    id: generateTaskId(),
    description,
    agent,
    status: 'pending',
    created_at: new Date().toISOString()
  };
}

export function generateTaskId(): string {
  return `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

export function validateAgentConfig(config: AgentConfig): boolean {
  return !!(config.name && config.role && config.goal);
}

export function formatAgentOutput(output: any): string {
  if (typeof output === 'string') {
    return output;
  }
  if (typeof output === 'object') {
    return JSON.stringify(output, null, 2);
  }
  return String(output);
}

export function calculateAgentPerformance(
  tasks: AgentTask[],
  agentName: string
): { completed: number; failed: number; success_rate: number } {
  const agentTasks = tasks.filter(task => task.agent === agentName);
  const completed = agentTasks.filter(task => task.status === 'completed').length;
  const failed = agentTasks.filter(task => task.status === 'failed').length;
  const total = agentTasks.length;
  
  return {
    completed,
    failed,
    success_rate: total > 0 ? (completed / total) * 100 : 0
  };
}
EOF
        
        cat > packages/agents/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./",
    "declaration": true,
    "declarationMap": true
  },
  "include": [
    "**/*.ts"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ]
}
EOF
        
        print_success "Package @coachlibre/agents créé"
    else
        print_success "Package @coachlibre/agents existe déjà"
    fi
}

# Fonction pour nettoyer et réinstaller
clean_and_install() {
    print_status "Nettoyage des caches et réinstallation..."
    
    # Nettoyer les caches pnpm
    pnpm store prune
    
    # Supprimer node_modules et lock files
    rm -rf node_modules
    rm -rf apps/*/node_modules
    rm -rf packages/*/node_modules
    rm -rf tools/*/node_modules
    rm -f pnpm-lock.yaml
    
    # Réinstaller
    print_status "Installation des dépendances..."
    pnpm install
    
    print_success "Installation terminée"
}

# Fonction pour vérifier l'installation
verify_installation() {
    print_status "Vérification de l'installation..."
    
    # Vérifier que tous les packages sont installés
    if pnpm list --depth=0 | grep -q "ERR_PNPM_WORKSPACE_PKG_NOT_FOUND"; then
        print_error "Il y a encore des erreurs de dépendances"
        return 1
    fi
    
    print_success "Installation vérifiée avec succès"
    return 0
}

# Fonction principale
main() {
    echo "🔧 Correction des dépendances CoachLibre"
    echo "========================================"
    echo ""
    
    # Vérifier qu'on est dans le bon répertoire
    if [ ! -f "pnpm-workspace.yaml" ]; then
        print_error "Ce script doit être exécuté depuis la racine du projet CoachLibre"
        exit 1
    fi
    
    # Corriger les packages manquants
    fix_missing_packages
    
    # Nettoyer et réinstaller
    clean_and_install
    
    # Vérifier l'installation
    if verify_installation; then
        echo ""
        print_success "🎉 Toutes les dépendances sont maintenant correctement installées !"
        echo ""
        echo "Vous pouvez maintenant :"
        echo "- Lancer le développement : pnpm dev"
        echo "- Build le projet : pnpm build"
        echo "- Déployer sur K3s : ./scripts/install-k3s.sh"
        echo ""
    else
        print_error "❌ Il y a encore des problèmes avec les dépendances"
        exit 1
    fi
}

# Exécuter le script principal
main "$@" 