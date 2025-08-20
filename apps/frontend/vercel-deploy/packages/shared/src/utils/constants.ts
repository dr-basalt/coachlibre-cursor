// Configuration des agents
export const AGENT_CONFIG = {
  DEFAULT_MODEL: 'gpt-4',
  DEFAULT_TEMPERATURE: 0.1,
  MAX_TOKENS: 4000,
  TIMEOUT: 30000, // 30 secondes
} as const;

// Types d'agents
export const AGENT_TYPES = {
  INTENT_MANAGER: 'intent_manager',
  PROJECT_MANAGER: 'project_manager',
  TECHNICAL_LEAD: 'technical_lead',
  RELEASE_MANAGER: 'release_manager',
  CREW_MANAGER: 'crew_manager',
} as const;

// Statuts des workflows
export const WORKFLOW_STATUS = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  COMPLETED: 'completed',
  FAILED: 'failed',
} as const;

// Catégories d'intention
export const INTENT_CATEGORIES = {
  COACHING_REQUEST: 'coaching_request',
  FORMATION_REQUEST: 'formation_request',
  CONSULTATION_REQUEST: 'consultation_request',
  UNKNOWN: 'unknown',
} as const;

// Priorités
export const PRIORITIES = {
  LOW: 'low',
  MEDIUM: 'medium',
  HIGH: 'high',
  URGENT: 'urgent',
} as const;

// Types d'architecture
export const ARCHITECTURE_TYPES = {
  MONOLITHIC: 'monolithique',
  MICROSERVICES: 'microservices',
  SERVERLESS: 'serverless',
} as const;

// Stratégies de déploiement
export const DEPLOYMENT_STRATEGIES = {
  BLUE_GREEN: 'blue-green',
  CANARY: 'canary',
  ROLLING: 'rolling',
  MANUAL: 'manual',
} as const;

// Endpoints API
export const API_ENDPOINTS = {
  WORKFLOW: '/workflow/process',
  AGENT_STATUS: '/agents/{agent_id}/status',
  AGENT_IMPROVE: '/agents/{agent_id}/improve',
  HEALTH: '/health',
} as const;

// Codes d'erreur
export const ERROR_CODES = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  AGENT_ERROR: 'AGENT_ERROR',
  WORKFLOW_ERROR: 'WORKFLOW_ERROR',
  TIMEOUT_ERROR: 'TIMEOUT_ERROR',
  NETWORK_ERROR: 'NETWORK_ERROR',
} as const;

// Messages d'erreur
export const ERROR_MESSAGES = {
  INVALID_INTENT: "L'intention fournie n'est pas valide",
  AGENT_NOT_FOUND: "L'agent demandé n'a pas été trouvé",
  WORKFLOW_FAILED: "Le workflow a échoué",
  TIMEOUT: "La requête a expiré",
  NETWORK_ERROR: "Erreur de réseau",
} as const;

// Configuration des métriques
export const METRICS_CONFIG = {
  CONFIDENCE_THRESHOLD: 0.7,
  SUCCESS_RATE_THRESHOLD: 0.8,
  RESPONSE_TIME_THRESHOLD: 5000, // 5 secondes
  ERROR_RATE_THRESHOLD: 0.05, // 5%
} as const;

// Configuration des OKRs
export const OKR_CONFIG = {
  TARGET_CONFIDENCE: 0.9,
  TARGET_SUCCESS_RATE: 0.95,
  TARGET_RESPONSE_TIME: 2000, // 2 secondes
  TARGET_ERROR_RATE: 0.01, // 1%
} as const; 