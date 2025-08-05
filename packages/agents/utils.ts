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