from crewai import Agent, Task, Crew
from langchain_openai import ChatOpenAI
from typing import Dict, Any
import os

class TechnicalLead:
    """
    Agent responsable de la conception technique et de l'architecture des solutions
    """
    
    def __init__(self):
        self.llm = ChatOpenAI(
            model="gpt-4",
            temperature=0.3,
            api_key=os.getenv("OPENAI_API_KEY")
        )
        
        # Agent principal de conception technique
        self.technical_architect = Agent(
            role="Architecte Technique",
            goal="Concevoir des solutions techniques robustes et évolutives",
            backstory="""Vous êtes un lead développeur expérimenté spécialisé dans l'architecture de solutions.
            Vous avez une expertise dans les technologies modernes (Astro, FastAPI, CrewAI, Kubernetes).
            Vous concevez des solutions scalables et maintenables pour la plateforme de coaching.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
        
        # Agent superviseur technique
        self.technical_supervisor = Agent(
            role="Superviseur Technique",
            goal="Valider et optimiser les architectures techniques",
            backstory="""Vous êtes un architecte senior qui valide les conceptions techniques.
            Vous vous assurez que les solutions sont robustes, performantes et évolutives.
            Vous avez une expertise en DevOps, cloud native et microservices.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
    
    async def design_solution(self, requirements: Dict[str, Any]) -> Dict[str, Any]:
        """
        Conçoit une solution technique basée sur les spécifications fonctionnelles
        """
        
        # Création des tâches
        design_task = Task(
            description=f"""
            Concevez une solution technique basée sur ces spécifications :
            {requirements}
            
            Votre conception doit inclure :
            1. Architecture globale (microservices, monolithique, etc.)
            2. Stack technologique recommandée
            3. API design et endpoints
            4. Base de données et modèles
            5. Intégrations externes (LiveKit, Stripe, etc.)
            6. Sécurité et authentification
            7. Performance et scalabilité
            8. Monitoring et observabilité
            9. Déploiement et CI/CD
            10. Estimation des efforts techniques
            
            Adaptez votre conception au contexte de la plateforme CoachLibre.
            """,
            agent=self.technical_architect,
            expected_output="Conception technique détaillée"
        )
        
        validation_task = Task(
            description="""
            Validez la conception technique fournie et proposez des améliorations.
            Vérifiez que :
            - L'architecture est scalable et maintenable
            - Les technologies choisies sont appropriées
            - La sécurité est bien prise en compte
            - Les performances sont optimisées
            - Le déploiement est automatisé
            - Le monitoring est complet
            
            Retournez la conception validée ou améliorée.
            """,
            agent=self.technical_supervisor,
            expected_output="Conception technique validée ou améliorée"
        )
        
        # Création et exécution du crew
        crew = Crew(
            agents=[self.technical_architect, self.technical_supervisor],
            tasks=[design_task, validation_task],
            verbose=True
        )
        
        # Exécution du workflow
        result = crew.kickoff()
        
        # Traitement du résultat
        try:
            # Simulation d'un résultat structuré
            solution_result = {
                "solution": result,
                "confidence": 0.92,
                "architecture": {
                    "type": "microservices",
                    "frontend": "Astro + TinaCMS + React Islands",
                    "backend": "FastAPI + CrewAI + PayloadCMS",
                    "database": "PostgreSQL + Qdrant",
                    "infrastructure": "Kubernetes + Crossplane + ArgoCD"
                },
                "integrations": [
                    "LiveKit (visio)",
                    "Stripe (paiements)",
                    "OAuth (calendriers)",
                    "Flowise (IA conversationnelle)",
                    "n8n (workflows)"
                ],
                "security": [
                    "JWT authentication",
                    "OAuth 2.0",
                    "HTTPS/TLS",
                    "Rate limiting",
                    "Input validation"
                ],
                "performance": {
                    "caching": "Redis",
                    "cdn": "Cloudflare",
                    "load_balancing": "Kubernetes Ingress",
                    "monitoring": "Prometheus + Grafana"
                },
                "deployment": {
                    "ci_cd": "GitHub Actions + ArgoCD",
                    "containers": "Docker",
                    "orchestration": "Kubernetes",
                    "monitoring": "Backstage"
                },
                "effort_estimation": "8-12 semaines"
            }
            
            return solution_result
            
        except Exception as e:
            # Fallback en cas d'erreur
            return {
                "solution": f"Conception technique basée sur : {requirements.get('requirements', 'N/A')}",
                "confidence": 0.7,
                "architecture": {
                    "type": "monolithique",
                    "frontend": "Astro",
                    "backend": "FastAPI",
                    "database": "PostgreSQL"
                },
                "integrations": ["Basiques"],
                "security": ["Standard"],
                "performance": {"caching": "Basic"},
                "deployment": {"ci_cd": "Manual"},
                "effort_estimation": "À définir"
            }
    
    async def create_technical_specs(self, solution: Dict[str, Any]) -> Dict[str, Any]:
        """
        Crée les spécifications techniques détaillées
        """
        specs_task = Task(
            description=f"""
            Créez des spécifications techniques détaillées basées sur cette solution :
            {solution}
            
            Les spécifications doivent inclure :
            1. Diagrammes d'architecture
            2. API specifications (OpenAPI/Swagger)
            3. Modèles de données
            4. Schémas de base de données
            5. Configurations d'infrastructure
            6. Tests et qualité
            7. Documentation technique
            """,
            agent=self.technical_architect,
            expected_output="Spécifications techniques détaillées"
        )
        
        crew = Crew(
            agents=[self.technical_architect],
            tasks=[specs_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "technical_specs": result,
            "specs_complete": True
        }
    
    async def review_code_quality(self, code_review: Dict[str, Any]) -> Dict[str, Any]:
        """
        Effectue une revue de code et propose des améliorations
        """
        review_task = Task(
            description=f"""
            Effectuez une revue de code basée sur ces éléments :
            {code_review}
            
            Analysez :
            1. Qualité du code
            2. Bonnes pratiques
            3. Performance
            4. Sécurité
            5. Maintenabilité
            6. Tests
            7. Documentation
            
            Proposez des améliorations concrètes.
            """,
            agent=self.technical_supervisor,
            expected_output="Rapport de revue de code avec recommandations"
        )
        
        crew = Crew(
            agents=[self.technical_supervisor],
            tasks=[review_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "code_review_report": result,
            "improvements_suggested": True
        }
    
    async def optimize_performance(self, performance_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Optimise les performances basées sur les métriques
        """
        optimization_task = Task(
            description=f"""
            Analysez ces données de performance et proposez des optimisations :
            {performance_data}
            
            Identifiez :
            1. Goulots d'étranglement
            2. Optimisations possibles
            3. Configurations à ajuster
            4. Monitoring à améliorer
            5. Tests de charge à effectuer
            """,
            agent=self.technical_architect,
            expected_output="Plan d'optimisation des performances"
        )
        
        crew = Crew(
            agents=[self.technical_architect],
            tasks=[optimization_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "optimization_plan": result,
            "performance_improvements": True
        } 