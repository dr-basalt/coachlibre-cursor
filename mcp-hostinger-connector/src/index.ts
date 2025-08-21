#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from '@modelcontextprotocol/sdk/types.js';
import axios from 'axios';
import * as cheerio from 'cheerio';
import puppeteer from 'puppeteer';
import dotenv from 'dotenv';

dotenv.config();

class HostingerConnector {
  private server: Server;
  private apiKey: string;
  private domain: string;

  constructor() {
    this.server = new Server(
      {
        name: 'hostinger-connector',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.apiKey = process.env.HOSTINGER_API_KEY || '';
    this.domain = process.env.HOSTINGER_DOMAIN || 'ori3com.cloud';

    this.setupToolHandlers();
  }

  private setupToolHandlers() {
    // Lister les outils disponibles
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'detect_cms',
            description: 'Détecte le type de CMS utilisé sur un site Hostinger',
            inputSchema: {
              type: 'object',
              properties: {
                url: {
                  type: 'string',
                  description: 'URL du site à analyser',
                },
              },
              required: ['url'],
            },
          },
          {
            name: 'extract_content',
            description: 'Extrait le contenu d\'un site CMS Hostinger',
            inputSchema: {
              type: 'object',
              properties: {
                url: {
                  type: 'string',
                  description: 'URL du site',
                },
                content_type: {
                  type: 'string',
                  enum: ['pages', 'posts', 'images', 'all'],
                  description: 'Type de contenu à extraire',
                },
              },
              required: ['url'],
            },
          },
          {
            name: 'wordpress_api_connect',
            description: 'Se connecte à l\'API WordPress d\'un site',
            inputSchema: {
              type: 'object',
              properties: {
                url: {
                  type: 'string',
                  description: 'URL du site WordPress',
                },
                endpoint: {
                  type: 'string',
                  description: 'Endpoint de l\'API (posts, pages, users, etc.)',
                },
              },
              required: ['url'],
            },
          },
          {
            name: 'hostinger_api_connect',
            description: 'Se connecte à l\'API Hostinger',
            inputSchema: {
              type: 'object',
              properties: {
                action: {
                  type: 'string',
                  enum: ['list_domains', 'get_domain_info', 'list_databases'],
                  description: 'Action à effectuer',
                },
              },
              required: ['action'],
            },
          },
          {
            name: 'crawl_site',
            description: 'Crawl complet d\'un site avec gestion des protections',
            inputSchema: {
              type: 'object',
              properties: {
                url: {
                  type: 'string',
                  description: 'URL du site',
                },
                depth: {
                  type: 'number',
                  description: 'Profondeur de crawling',
                  default: 2,
                },
                bypass_protection: {
                  type: 'boolean',
                  description: 'Contourner les protections',
                  default: true,
                },
              },
              required: ['url'],
            },
          },
        ] as Tool[],
      };
    });

    // Gérer les appels d'outils
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'detect_cms':
            return await this.detectCMS(args.url);
          case 'extract_content':
            return await this.extractContent(args.url, args.content_type);
          case 'wordpress_api_connect':
            return await this.wordpressAPIConnect(args.url, args.endpoint);
          case 'hostinger_api_connect':
            return await this.hostingerAPIConnect(args.action);
          case 'crawl_site':
            return await this.crawlSite(args.url, args.depth, args.bypass_protection);
          default:
            throw new Error(`Outil inconnu: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Erreur lors de l'exécution de l'outil ${name}: ${error}`,
            },
          ],
        };
      }
    });
  }

  private async detectCMS(url: string) {
    const headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    };

    try {
      const response = await axios.get(url, { headers, timeout: 10000 });
      const html = response.data;
      const $ = cheerio.load(html);

      const cmsIndicators = {
        wordpress: {
          patterns: [
            /wp-content/i,
            /wp-includes/i,
            /wp-admin/i,
            /wordpress/i,
            /wp-json/i,
          ],
          meta: 'generator',
        },
        joomla: {
          patterns: [/joomla/i, /joomla!/i],
          meta: 'generator',
        },
        drupal: {
          patterns: [/drupal/i],
          meta: 'generator',
        },
        magento: {
          patterns: [/magento/i],
          meta: 'generator',
        },
        shopify: {
          patterns: [/shopify/i],
          meta: 'generator',
        },
      };

      let detectedCMS = 'Unknown';
      let confidence = 0;

      for (const [cms, indicators] of Object.entries(cmsIndicators)) {
        let score = 0;

        // Vérifier les patterns dans le HTML
        for (const pattern of indicators.patterns) {
          if (pattern.test(html)) {
            score += 2;
          }
        }

        // Vérifier les meta tags
        const metaGenerator = $(`meta[name="${indicators.meta}"]`).attr('content');
        if (metaGenerator && indicators.patterns.some(p => p.test(metaGenerator))) {
          score += 3;
        }

        // Vérifier les chemins caractéristiques
        if (cms === 'wordpress') {
          if (await this.checkURL(`${url}/wp-admin`)) score += 2;
          if (await this.checkURL(`${url}/wp-json`)) score += 2;
        }

        if (score > confidence) {
          confidence = score;
          detectedCMS = cms;
        }
      }

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              cms: detectedCMS,
              confidence: confidence,
              url: url,
              analysis: {
                has_wp_admin: await this.checkURL(`${url}/wp-admin`),
                has_wp_json: await this.checkURL(`${url}/wp-json`),
                has_joomla_admin: await this.checkURL(`${url}/administrator`),
                has_drupal_admin: await this.checkURL(`${url}/admin`),
              },
            }, null, 2),
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Erreur lors de la détection du CMS: ${error}`,
          },
        ],
      };
    }
  }

  private async checkURL(url: string): Promise<boolean> {
    try {
      await axios.head(url, { timeout: 5000 });
      return true;
    } catch {
      return false;
    }
  }

  private async extractContent(url: string, contentType: string = 'all') {
    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });

    try {
      const page = await browser.newPage();
      
      // Contourner les protections
      await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
      await page.setExtraHTTPHeaders({
        'Accept-Language': 'fr-FR,fr;q=0.8,en-US;q=0.5,en;q=0.3',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
      });

      await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });

      const content = await page.evaluate((type) => {
        const extractData = () => {
          const data: any = {
            title: document.title,
            meta_description: document.querySelector('meta[name="description"]')?.getAttribute('content'),
            headings: Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6')).map(h => ({
              level: h.tagName.toLowerCase(),
              text: h.textContent?.trim(),
            })),
            links: Array.from(document.querySelectorAll('a[href]')).map(a => ({
              text: a.textContent?.trim(),
              href: a.getAttribute('href'),
            })),
            images: Array.from(document.querySelectorAll('img')).map(img => ({
              src: img.getAttribute('src'),
              alt: img.getAttribute('alt'),
            })),
            text_content: document.body.textContent?.trim(),
          };

          if (type === 'pages' || type === 'all') {
            data.pages = Array.from(document.querySelectorAll('nav a, .menu a, .navigation a')).map(a => ({
              text: a.textContent?.trim(),
              href: a.getAttribute('href'),
            }));
          }

          return data;
        };

        return extractData();
      }, contentType);

      await browser.close();

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify(content, null, 2),
          },
        ],
      };
    } catch (error) {
      await browser.close();
      return {
        content: [
          {
            type: 'text',
            text: `Erreur lors de l'extraction du contenu: ${error}`,
          },
        ],
      };
    }
  }

  private async wordpressAPIConnect(url: string, endpoint: string = 'posts') {
    const wpApiUrl = `${url}/wp-json/wp/v2/${endpoint}`;
    
    try {
      const response = await axios.get(wpApiUrl, {
        timeout: 10000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      });

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              endpoint: endpoint,
              url: wpApiUrl,
              data: response.data,
              total: response.headers['x-wp-total'],
              total_pages: response.headers['x-wp-totalpages'],
            }, null, 2),
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Erreur lors de la connexion à l'API WordPress: ${error}`,
          },
        ],
      };
    }
  }

  private async hostingerAPIConnect(action: string) {
    if (!this.apiKey) {
      return {
        content: [
          {
            type: 'text',
            text: 'Erreur: Clé API Hostinger non configurée',
          },
        ],
      };
    }

    const baseUrl = 'https://api.hostinger.com/v1';
    const headers = {
      'Authorization': `Bearer ${this.apiKey}`,
      'Content-Type': 'application/json',
    };

    try {
      let response;
      switch (action) {
        case 'list_domains':
          response = await axios.get(`${baseUrl}/domains`, { headers });
          break;
        case 'get_domain_info':
          response = await axios.get(`${baseUrl}/domains/${this.domain}`, { headers });
          break;
        case 'list_databases':
          response = await axios.get(`${baseUrl}/databases`, { headers });
          break;
        default:
          throw new Error(`Action non supportée: ${action}`);
      }

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify(response.data, null, 2),
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Erreur lors de la connexion à l'API Hostinger: ${error}`,
          },
        ],
      };
    }
  }

  private async crawlSite(url: string, depth: number = 2, bypassProtection: boolean = true) {
    const browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });

    try {
      const page = await browser.newPage();
      
      if (bypassProtection) {
        await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
        await page.setExtraHTTPHeaders({
          'Accept-Language': 'fr-FR,fr;q=0.8,en-US;q=0.5,en;q=0.3',
          'Accept-Encoding': 'gzip, deflate, br',
          'DNT': '1',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        });
      }

      const crawledData = await this.crawlRecursive(page, url, depth, new Set());

      await browser.close();

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify(crawledData, null, 2),
          },
        ],
      };
    } catch (error) {
      await browser.close();
      return {
        content: [
          {
            type: 'text',
            text: `Erreur lors du crawling: ${error}`,
          },
        ],
      };
    }
  }

  private async crawlRecursive(page: any, url: string, depth: number, visited: Set<string>) {
    if (depth === 0 || visited.has(url)) {
      return null;
    }

    visited.add(url);

    try {
      await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
      
      const pageData = await page.evaluate(() => {
        return {
          title: document.title,
          url: window.location.href,
          content: document.body.textContent?.trim(),
          links: Array.from(document.querySelectorAll('a[href]')).map(a => a.getAttribute('href')),
          images: Array.from(document.querySelectorAll('img')).map(img => ({
            src: img.getAttribute('src'),
            alt: img.getAttribute('alt'),
          })),
        };
      });

      const subPages = [];
      if (depth > 1) {
        for (const link of pageData.links.slice(0, 5)) { // Limiter à 5 liens par page
          if (link && link.startsWith('http') && link.includes(this.domain)) {
            const subPage = await this.crawlRecursive(page, link, depth - 1, visited);
            if (subPage) {
              subPages.push(subPage);
            }
          }
        }
      }

      return {
        ...pageData,
        subPages,
      };
    } catch (error) {
      console.error(`Erreur lors du crawling de ${url}:`, error);
      return null;
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Connecteur MCP Hostinger démarré');
  }
}

const connector = new HostingerConnector();
connector.run().catch(console.error);


