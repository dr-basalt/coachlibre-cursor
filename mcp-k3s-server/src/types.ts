export interface K3sResource {
  apiVersion: string;
  kind: string;
  metadata: {
    name: string;
    namespace?: string;
    uid: string;
    creationTimestamp: string;
    labels?: Record<string, string>;
    annotations?: Record<string, string>;
  };
  spec?: any;
  status?: any;
}

export interface K3sPod extends K3sResource {
  kind: 'Pod';
  spec: {
    containers: Array<{
      name: string;
      image: string;
      ports?: Array<{
        containerPort: number;
        protocol: string;
      }>;
    }>;
    nodeName?: string;
  };
  status?: {
    phase: string;
    podIP?: string;
    hostIP?: string;
    containerStatuses?: Array<{
      name: string;
      ready: boolean;
      restartCount: number;
      state: any;
    }>;
  };
}

export interface K3sDeployment extends K3sResource {
  kind: 'Deployment';
  spec: {
    replicas: number;
    selector: {
      matchLabels: Record<string, string>;
    };
    template: {
      metadata: {
        labels: Record<string, string>;
      };
      spec: {
        containers: Array<{
          name: string;
          image: string;
        }>;
      };
    };
  };
  status?: {
    replicas: number;
    availableReplicas: number;
    readyReplicas: number;
    updatedReplicas: number;
  };
}

export interface K3sService extends K3sResource {
  kind: 'Service';
  spec: {
    type: string;
    ports: Array<{
      port: number;
      targetPort: number;
      protocol: string;
    }>;
    selector: Record<string, string>;
  };
  status?: {
    loadBalancer?: {
      ingress?: Array<{
        ip?: string;
        hostname?: string;
      }>;
    };
  };
}

export interface K3sNode extends K3sResource {
  kind: 'Node';
  spec: {
    unschedulable?: boolean;
  };
  status?: {
    conditions: Array<{
      type: string;
      status: string;
      lastHeartbeatTime: string;
      lastTransitionTime: string;
      reason?: string;
      message?: string;
    }>;
    addresses: Array<{
      type: string;
      address: string;
    }>;
    capacity: Record<string, string>;
    allocatable: Record<string, string>;
  };
}

export interface K3sNamespace extends K3sResource {
  kind: 'Namespace';
  status?: {
    phase: string;
  };
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  timestamp: string;
}

export interface SseEvent {
  event: string;
  data: string;
  id?: string;
  retry?: number;
}

export interface MCPTool {
  name: string;
  description: string;
  parameters: {
    type: string;
    properties: Record<string, any>;
    required: string[];
  };
}

export interface MCPToolCall {
  name: string;
  arguments: Record<string, any>;
}

export interface MCPToolResult {
  name: string;
  content: string;
  isError: boolean;
}

export interface K3sConfig {
  kubeconfig: string;
  context?: string;
  namespace?: string;
}

export interface ServerConfig {
  port: number;
  host: string;
  corsOrigin: string;
  rateLimitWindowMs: number;
  rateLimitMax: number;
  jwtSecret: string;
  enableAuth: boolean;
}






