import { MCPTool } from './types';

export const MCP_TOOLS: MCPTool[] = [
  {
    name: 'listNamespaces',
    description: 'Liste tous les namespaces du cluster k3s',
    parameters: {
      type: 'object',
      properties: {},
      required: [],
    },
  },
  {
    name: 'listPods',
    description: 'Liste les pods dans un namespace spécifique ou tous les namespaces',
    parameters: {
      type: 'object',
      properties: {
        namespace: {
          type: 'string',
          description: 'Nom du namespace (optionnel, si non fourni liste tous les pods)',
        },
      },
      required: [],
    },
  },
  {
    name: 'listDeployments',
    description: 'Liste les déploiements dans un namespace spécifique ou tous les namespaces',
    parameters: {
      type: 'object',
      properties: {
        namespace: {
          type: 'string',
          description: 'Nom du namespace (optionnel, si non fourni liste tous les déploiements)',
        },
      },
      required: [],
    },
  },
  {
    name: 'listServices',
    description: 'Liste les services dans un namespace spécifique ou tous les namespaces',
    parameters: {
      type: 'object',
      properties: {
        namespace: {
          type: 'string',
          description: 'Nom du namespace (optionnel, si non fourni liste tous les services)',
        },
      },
      required: [],
    },
  },
  {
    name: 'listNodes',
    description: 'Liste tous les nœuds du cluster k3s',
    parameters: {
      type: 'object',
      properties: {},
      required: [],
    },
  },
  {
    name: 'describeResource',
    description: 'Décrit une ressource spécifique (pod, deployment, service, etc.)',
    parameters: {
      type: 'object',
      properties: {
        kind: {
          type: 'string',
          description: 'Type de ressource (Pod, Deployment, Service, etc.)',
        },
        name: {
          type: 'string',
          description: 'Nom de la ressource',
        },
        namespace: {
          type: 'string',
          description: 'Namespace de la ressource (optionnel pour les ressources cluster-wide)',
        },
      },
      required: ['kind', 'name'],
    },
  },
  {
    name: 'getPodLogs',
    description: 'Récupère les logs d\'un pod spécifique',
    parameters: {
      type: 'object',
      properties: {
        podName: {
          type: 'string',
          description: 'Nom du pod',
        },
        namespace: {
          type: 'string',
          description: 'Namespace du pod',
        },
        container: {
          type: 'string',
          description: 'Nom du container (optionnel, si non fourni utilise le container par défaut)',
        },
        tail: {
          type: 'number',
          description: 'Nombre de lignes à récupérer (défaut: 500)',
        },
      },
      required: ['podName', 'namespace'],
    },
  },
  {
    name: 'scaleDeployment',
    description: 'Met à l\'échelle un déploiement en changeant le nombre de réplicas',
    parameters: {
      type: 'object',
      properties: {
        deploymentName: {
          type: 'string',
          description: 'Nom du déploiement',
        },
        namespace: {
          type: 'string',
          description: 'Namespace du déploiement',
        },
        replicas: {
          type: 'number',
          description: 'Nombre de réplicas souhaité',
        },
      },
      required: ['deploymentName', 'namespace', 'replicas'],
    },
  },
  {
    name: 'applyYaml',
    description: 'Applique une configuration YAML au cluster',
    parameters: {
      type: 'object',
      properties: {
        yamlContent: {
          type: 'string',
          description: 'Contenu YAML à appliquer',
        },
        namespace: {
          type: 'string',
          description: 'Namespace cible (optionnel)',
        },
      },
      required: ['yamlContent'],
    },
  },
  {
    name: 'getClusterInfo',
    description: 'Récupère les informations générales du cluster k3s',
    parameters: {
      type: 'object',
      properties: {},
      required: [],
    },
  },
  {
    name: 'getContext',
    description: 'Récupère le contexte Kubernetes actuel',
    parameters: {
      type: 'object',
      properties: {},
      required: [],
    },
  },
  {
    name: 'restartDeployment',
    description: 'Redémarre un déploiement en forçant un rollout',
    parameters: {
      type: 'object',
      properties: {
        deploymentName: {
          type: 'string',
          description: 'Nom du déploiement',
        },
        namespace: {
          type: 'string',
          description: 'Namespace du déploiement',
        },
      },
      required: ['deploymentName', 'namespace'],
    },
  },
  {
    name: 'getEvents',
    description: 'Récupère les événements récents du cluster',
    parameters: {
      type: 'object',
      properties: {
        namespace: {
          type: 'string',
          description: 'Namespace pour filtrer les événements (optionnel)',
        },
        limit: {
          type: 'number',
          description: 'Nombre maximum d\'événements à récupérer (défaut: 100)',
        },
      },
      required: [],
    },
  },
  {
    name: 'portForward',
    description: 'Établit un port-forward vers un service ou un pod',
    parameters: {
      type: 'object',
      properties: {
        kind: {
          type: 'string',
          description: 'Type de ressource (Pod, Service)',
        },
        name: {
          type: 'string',
          description: 'Nom de la ressource',
        },
        namespace: {
          type: 'string',
          description: 'Namespace de la ressource',
        },
        localPort: {
          type: 'number',
          description: 'Port local',
        },
        remotePort: {
          type: 'number',
          description: 'Port distant',
        },
      },
      required: ['kind', 'name', 'namespace', 'localPort', 'remotePort'],
    },
  },
];

export function getToolByName(name: string): MCPTool | undefined {
  return MCP_TOOLS.find(tool => tool.name === name);
}

export function getAllTools(): MCPTool[] {
  return MCP_TOOLS;
}







