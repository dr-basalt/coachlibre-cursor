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