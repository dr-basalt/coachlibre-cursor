import { z } from 'zod';

// Schémas Zod pour validation
export const UserIntentSchema = z.object({
  intent: z.string().min(1, "L'intention ne peut pas être vide"),
  context: z.record(z.any()).optional(),
  user_id: z.string().optional(),
});

export const AgentResponseSchema = z.object({
  agent_id: z.string(),
  response: z.string(),
  confidence: z.number().min(0).max(1),
  next_agent: z.string().optional(),
});

export const WorkflowResultSchema = z.object({
  workflow_id: z.string(),
  status: z.enum(['pending', 'processing', 'completed', 'failed']),
  results: z.array(AgentResponseSchema),
  final_output: z.string(),
});

export const IntentAnalysisSchema = z.object({
  analysis: z.string(),
  confidence: z.number().min(0).max(1),
  category: z.enum(['coaching_request', 'formation_request', 'consultation_request', 'unknown']),
  priority: z.enum(['low', 'medium', 'high', 'urgent']),
  needs: z.array(z.string()),
  recommendations: z.array(z.string()),
});

export const RequirementsSchema = z.object({
  requirements: z.string(),
  confidence: z.number().min(0).max(1),
  objectives: z.array(z.string()),
  acceptance_criteria: z.array(z.string()),
  timeline: z.string(),
  resources: z.array(z.string()),
  risks: z.array(z.string()),
  success_metrics: z.array(z.string()),
});

export const TechnicalSolutionSchema = z.object({
  solution: z.string(),
  confidence: z.number().min(0).max(1),
  architecture: z.object({
    type: z.enum(['monolithique', 'microservices', 'serverless']),
    frontend: z.string(),
    backend: z.string(),
    database: z.string(),
    infrastructure: z.string().optional(),
  }),
  integrations: z.array(z.string()),
  security: z.array(z.string()),
  performance: z.record(z.string()),
  deployment: z.record(z.string()),
  effort_estimation: z.string(),
});

export const DeliveryPlanSchema = z.object({
  delivery_plan: z.string(),
  confidence: z.number().min(0).max(1),
  deployment_strategy: z.object({
    type: z.enum(['blue-green', 'canary', 'rolling', 'manual']),
    environments: z.array(z.string()),
    automation: z.string(),
  }),
  testing: z.record(z.string()),
  monitoring: z.record(z.string()),
  rollback: z.object({
    strategy: z.string(),
    triggers: z.array(z.string()),
    timeout: z.string(),
  }),
  documentation: z.array(z.string()),
  communication: z.record(z.any()),
  success_metrics: z.array(z.string()),
  timeline: z.string(),
});

// Types TypeScript
export type UserIntent = z.infer<typeof UserIntentSchema>;
export type AgentResponse = z.infer<typeof AgentResponseSchema>;
export type WorkflowResult = z.infer<typeof WorkflowResultSchema>;
export type IntentAnalysis = z.infer<typeof IntentAnalysisSchema>;
export type Requirements = z.infer<typeof RequirementsSchema>;
export type TechnicalSolution = z.infer<typeof TechnicalSolutionSchema>;
export type DeliveryPlan = z.infer<typeof DeliveryPlanSchema>;

// Types pour les agents
export interface Agent {
  id: string;
  name: string;
  role: string;
  status: 'active' | 'inactive' | 'error';
  last_activity: Date;
  performance_metrics: PerformanceMetrics;
}

export interface PerformanceMetrics {
  success_rate: number;
  average_response_time: number;
  error_rate: number;
  satisfaction_score: number;
}

export interface AgentConfig {
  model: string;
  temperature: number;
  max_tokens: number;
  system_prompt: string;
  tools: string[];
}

// Types pour les workflows
export interface WorkflowStep {
  id: string;
  agent_id: string;
  task: string;
  dependencies: string[];
  timeout: number;
  retry_count: number;
}

export interface Workflow {
  id: string;
  name: string;
  description: string;
  steps: WorkflowStep[];
  status: 'draft' | 'active' | 'paused' | 'completed';
  created_at: Date;
  updated_at: Date;
}

// Types pour les OKRs
export interface OKR {
  id: string;
  agent_id: string;
  objective: string;
  key_results: KeyResult[];
  target_date: Date;
  status: 'on_track' | 'at_risk' | 'behind' | 'completed';
}

export interface KeyResult {
  id: string;
  description: string;
  target_value: number;
  current_value: number;
  unit: string;
  weight: number;
} 