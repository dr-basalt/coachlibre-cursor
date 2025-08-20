import { 
  UserIntentSchema, 
  AgentResponseSchema, 
  WorkflowResultSchema,
  IntentAnalysisSchema,
  RequirementsSchema,
  TechnicalSolutionSchema,
  DeliveryPlanSchema,
  type UserIntent,
  type AgentResponse,
  type WorkflowResult
} from '../types/agent';

/**
 * Valide une intention utilisateur
 */
export function validateUserIntent(data: unknown): UserIntent {
  return UserIntentSchema.parse(data);
}

/**
 * Valide une réponse d'agent
 */
export function validateAgentResponse(data: unknown): AgentResponse {
  return AgentResponseSchema.parse(data);
}

/**
 * Valide un résultat de workflow
 */
export function validateWorkflowResult(data: unknown): WorkflowResult {
  return WorkflowResultSchema.parse(data);
}

/**
 * Valide une analyse d'intention
 */
export function validateIntentAnalysis(data: unknown) {
  return IntentAnalysisSchema.parse(data);
}

/**
 * Valide des spécifications de besoins
 */
export function validateRequirements(data: unknown) {
  return RequirementsSchema.parse(data);
}

/**
 * Valide une solution technique
 */
export function validateTechnicalSolution(data: unknown) {
  return TechnicalSolutionSchema.parse(data);
}

/**
 * Valide un plan de livraison
 */
export function validateDeliveryPlan(data: unknown) {
  return DeliveryPlanSchema.parse(data);
}

/**
 * Valide de manière sécurisée (retourne null si invalide)
 */
export function safeValidate<T>(schema: any, data: unknown): T | null {
  try {
    return schema.parse(data);
  } catch (error) {
    console.error('Validation error:', error);
    return null;
  }
}

/**
 * Valide un objet avec des erreurs détaillées
 */
export function validateWithErrors<T>(schema: any, data: unknown): { success: true; data: T } | { success: false; errors: string[] } {
  try {
    const result = schema.parse(data);
    return { success: true, data: result };
  } catch (error: any) {
    if (error.errors) {
      const errors = error.errors.map((err: any) => `${err.path.join('.')}: ${err.message}`);
      return { success: false, errors };
    }
    return { success: false, errors: [error.message] };
  }
} 