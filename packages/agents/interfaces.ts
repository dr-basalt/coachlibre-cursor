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