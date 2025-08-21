import { spawn, SpawnOptions } from 'child_process';
import { K3sConfig, K3sResource, ApiResponse } from './types';

export class K3sClient {
  private config: K3sConfig;

  constructor(config: K3sConfig) {
    this.config = config;
  }

  private async executeKubectl(args: string[]): Promise<string> {
    return new Promise((resolve, reject) => {
      const options: SpawnOptions = {
        env: {
          ...process.env,
          KUBECONFIG: this.config.kubeconfig,
        },
        cwd: process.cwd(),
      };

      if (this.config.context) {
        args.unshift('--context', this.config.context);
      }

      const kubectl = spawn('kubectl', args, options);
      let stdout = '';
      let stderr = '';

      kubectl.stdout.on('data', (data) => {
        stdout += data.toString();
      });

      kubectl.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      kubectl.on('close', (code) => {
        if (code === 0) {
          resolve(stdout);
        } else {
          reject(new Error(`kubectl failed with code ${code}: ${stderr}`));
        }
      });

      kubectl.on('error', (error) => {
        reject(new Error(`Failed to execute kubectl: ${error.message}`));
      });
    });
  }

  async getNamespaces(): Promise<ApiResponse<K3sResource[]>> {
    try {
      const output = await this.executeKubectl(['get', 'namespaces', '-o', 'json']);
      const data = JSON.parse(output);
      return {
        success: true,
        data: data.items,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async getPods(namespace?: string): Promise<ApiResponse<K3sResource[]>> {
    try {
      const args = ['get', 'pods', '-o', 'json'];
      if (namespace) {
        args.splice(2, 0, '-n', namespace);
      } else {
        args.splice(2, 0, '-A');
      }

      const output = await this.executeKubectl(args);
      const data = JSON.parse(output);
      return {
        success: true,
        data: data.items,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async getDeployments(namespace?: string): Promise<ApiResponse<K3sResource[]>> {
    try {
      const args = ['get', 'deployments', '-o', 'json'];
      if (namespace) {
        args.splice(2, 0, '-n', namespace);
      } else {
        args.splice(2, 0, '-A');
      }

      const output = await this.executeKubectl(args);
      const data = JSON.parse(output);
      return {
        success: true,
        data: data.items,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async getServices(namespace?: string): Promise<ApiResponse<K3sResource[]>> {
    try {
      const args = ['get', 'services', '-o', 'json'];
      if (namespace) {
        args.splice(2, 0, '-n', namespace);
      } else {
        args.splice(2, 0, '-A');
      }

      const output = await this.executeKubectl(args);
      const data = JSON.parse(output);
      return {
        success: true,
        data: data.items,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async getNodes(): Promise<ApiResponse<K3sResource[]>> {
    try {
      const output = await this.executeKubectl(['get', 'nodes', '-o', 'json']);
      const data = JSON.parse(output);
      return {
        success: true,
        data: data.items,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async describeResource(kind: string, name: string, namespace?: string): Promise<ApiResponse<string>> {
    try {
      const args = ['describe', kind, name];
      if (namespace) {
        args.splice(2, 0, '-n', namespace);
      }

      const output = await this.executeKubectl(args);
      return {
        success: true,
        data: output,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async getPodLogs(podName: string, namespace: string, container?: string, tail: number = 500): Promise<ApiResponse<string>> {
    try {
      const args = ['logs', podName, '-n', namespace, '--tail', tail.toString()];
      if (container) {
        args.splice(2, 0, '-c', container);
      }

      const output = await this.executeKubectl(args);
      return {
        success: true,
        data: output,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async scaleDeployment(deploymentName: string, namespace: string, replicas: number): Promise<ApiResponse<string>> {
    try {
      const output = await this.executeKubectl([
        'scale', 'deployment', deploymentName,
        '--replicas', replicas.toString(),
        '-n', namespace
      ]);
      return {
        success: true,
        data: output,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async applyYaml(yamlContent: string, namespace?: string): Promise<ApiResponse<string>> {
    try {
      const args = ['apply', '-f', '-'];
      if (namespace) {
        args.splice(2, 0, '-n', namespace);
      }

      return new Promise((resolve, reject) => {
        const options: SpawnOptions = {
          env: {
            ...process.env,
            KUBECONFIG: this.config.kubeconfig,
          },
          cwd: process.cwd(),
          stdio: ['pipe', 'pipe', 'pipe'],
        };

        if (this.config.context) {
          args.unshift('--context', this.config.context);
        }

        const kubectl = spawn('kubectl', args, options);
        let stdout = '';
        let stderr = '';

        kubectl.stdout.on('data', (data) => {
          stdout += data.toString();
        });

        kubectl.stderr.on('data', (data) => {
          stderr += data.toString();
        });

        kubectl.on('close', (code) => {
          if (code === 0) {
            resolve({
              success: true,
              data: stdout,
              timestamp: new Date().toISOString(),
            });
          } else {
            resolve({
              success: false,
              error: `kubectl failed with code ${code}: ${stderr}`,
              timestamp: new Date().toISOString(),
            });
          }
        });

        kubectl.on('error', (error) => {
          resolve({
            success: false,
            error: `Failed to execute kubectl: ${error.message}`,
            timestamp: new Date().toISOString(),
          });
        });

        kubectl.stdin.write(yamlContent);
        kubectl.stdin.end();
      });
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async getClusterInfo(): Promise<ApiResponse<string>> {
    try {
      const output = await this.executeKubectl(['cluster-info']);
      return {
        success: true,
        data: output,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }

  async getContext(): Promise<ApiResponse<string>> {
    try {
      const output = await this.executeKubectl(['config', 'current-context']);
      return {
        success: true,
        data: output.trim(),
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString(),
      };
    }
  }
}








