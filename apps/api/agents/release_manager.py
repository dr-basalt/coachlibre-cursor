from crewai import Agent, Task, Crew
from langchain_openai import ChatOpenAI
from typing import Dict, Any
import os

class ReleaseManager:
    """
    Agent responsable de la préparation et du déploiement des livrables
    """
    
    def __init__(self):
        self.llm = ChatOpenAI(
            model="gpt-4",
            temperature=0.2,
            api_key=os.getenv("OPENAI_API_KEY")
        )
        
        # Agent principal de gestion des releases
        self.release_coordinator = Agent(
            role="Coordinateur de Release",
            goal="Préparer et coordonner les déploiements de manière sécurisée et fiable",
            backstory="""Vous êtes un release manager expérimenté spécialisé dans les déploiements continus.
            Vous avez une expertise en DevOps, CI/CD et gestion des environnements.
            Vous vous assurez que les livrables sont de qualité et déployés en toute sécurité.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
        
        # Agent superviseur de qualité
        self.quality_supervisor = Agent(
            role="Superviseur de Qualité",
            goal="Valider la qualité des livrables avant déploiement",
            backstory="""Vous êtes un expert en assurance qualité qui valide les livrables.
            Vous vous assurez que les standards de qualité sont respectés.
            Vous avez une expertise en tests automatisés et en validation de déploiement.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
    
    async def prepare_delivery(self, technical_solution: Dict[str, Any]) -> Dict[str, Any]:
        """
        Prépare le plan de livraison basé sur la solution technique
        """
        
        # Création des tâches
        delivery_task = Task(
            description=f"""
            Préparez un plan de livraison basé sur cette solution technique :
            {technical_solution}
            
            Votre plan doit inclure :
            1. Stratégie de déploiement (blue-green, canary, rolling)
            2. Environnements (dev, staging, production)
            3. Pipeline CI/CD détaillé
            4. Tests automatisés (unit, integration, e2e)
            5. Monitoring et alerting
            6. Rollback strategy
            7. Documentation utilisateur
            8. Formation et support
            9. Métriques de succès
            10. Plan de communication
            
            Adaptez votre plan au contexte de la plateforme CoachLibre.
            """,
            agent=self.release_coordinator,
            expected_output="Plan de livraison détaillé"
        )
        
        validation_task = Task(
            description="""
            Validez le plan de livraison fourni et proposez des améliorations.
            Vérifiez que :
            - La stratégie de déploiement est appropriée
            - Les tests sont complets
            - Le monitoring est suffisant
            - Le rollback est possible
            - La documentation est complète
            - Le plan de communication est clair
            
            Retournez le plan validé ou amélioré.
            """,
            agent=self.quality_supervisor,
            expected_output="Plan de livraison validé ou amélioré"
        )
        
        # Création et exécution du crew
        crew = Crew(
            agents=[self.release_coordinator, self.quality_supervisor],
            tasks=[delivery_task, validation_task],
            verbose=True
        )
        
        # Exécution du workflow
        result = crew.kickoff()
        
        # Traitement du résultat
        try:
            # Simulation d'un résultat structuré
            delivery_result = {
                "delivery_plan": result,
                "confidence": 0.90,
                "deployment_strategy": {
                    "type": "blue-green",
                    "environments": ["dev", "staging", "production"],
                    "automation": "GitHub Actions + ArgoCD"
                },
                "testing": {
                    "unit_tests": "Jest + Pytest",
                    "integration_tests": "Postman + Newman",
                    "e2e_tests": "Playwright",
                    "performance_tests": "k6",
                    "security_tests": "OWASP ZAP"
                },
                "monitoring": {
                    "metrics": "Prometheus + Grafana",
                    "logging": "ELK Stack",
                    "alerting": "PagerDuty",
                    "tracing": "Jaeger"
                },
                "rollback": {
                    "strategy": "automatic",
                    "triggers": ["error_rate > 5%", "response_time > 2s"],
                    "timeout": "5 minutes"
                },
                "documentation": [
                    "Guide utilisateur",
                    "Documentation API",
                    "Guide de déploiement",
                    "Runbook opérationnel"
                ],
                "communication": {
                    "stakeholders": ["équipe_dev", "coachs", "clients"],
                    "channels": ["email", "slack", "dashboard"],
                    "frequency": "real-time"
                },
                "success_metrics": [
                    "uptime > 99.9%",
                    "response_time < 500ms",
                    "error_rate < 1%",
                    "user_satisfaction > 4.5/5"
                ],
                "timeline": "2-3 semaines"
            }
            
            return delivery_result
            
        except Exception as e:
            # Fallback en cas d'erreur
            return {
                "delivery_plan": f"Plan de livraison basé sur : {technical_solution.get('solution', 'N/A')}",
                "confidence": 0.6,
                "deployment_strategy": {"type": "manual"},
                "testing": {"basic": "tests manuels"},
                "monitoring": {"basic": "logs"},
                "rollback": {"strategy": "manual"},
                "documentation": ["Guide basique"],
                "communication": {"basic": "email"},
                "success_metrics": ["fonctionnel"],
                "timeline": "À définir"
            }
    
    async def execute_deployment(self, deployment_config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Exécute le déploiement selon la configuration
        """
        deployment_task = Task(
            description=f"""
            Exécutez le déploiement selon cette configuration :
            {deployment_config}
            
            Suivez ces étapes :
            1. Validation pré-déploiement
            2. Déploiement en staging
            3. Tests de validation
            4. Déploiement en production
            5. Monitoring post-déploiement
            6. Validation finale
            """,
            agent=self.release_coordinator,
            expected_output="Rapport de déploiement"
        )
        
        crew = Crew(
            agents=[self.release_coordinator],
            tasks=[deployment_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "deployment_report": result,
            "deployment_successful": True
        }
    
    async def monitor_deployment(self, deployment_id: str) -> Dict[str, Any]:
        """
        Surveille le déploiement en cours
        """
        monitoring_task = Task(
            description=f"""
            Surveillez le déploiement {deployment_id} et identifiez :
            1. Métriques de performance
            2. Erreurs et alertes
            3. Comportement utilisateur
            4. Problèmes potentiels
            5. Actions correctives nécessaires
            """,
            agent=self.quality_supervisor,
            expected_output="Rapport de surveillance"
        )
        
        crew = Crew(
            agents=[self.quality_supervisor],
            tasks=[monitoring_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "monitoring_report": result,
            "deployment_healthy": True
        }
    
    async def create_release_notes(self, release_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Crée les notes de release
        """
        notes_task = Task(
            description=f"""
            Créez des notes de release basées sur ces données :
            {release_data}
            
            Les notes doivent inclure :
            1. Résumé des changements
            2. Nouvelles fonctionnalités
            3. Corrections de bugs
            4. Améliorations de performance
            5. Instructions de mise à jour
            6. Problèmes connus
            7. Support et contact
            """,
            agent=self.release_coordinator,
            expected_output="Notes de release complètes"
        )
        
        crew = Crew(
            agents=[self.release_coordinator],
            tasks=[notes_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "release_notes": result,
            "notes_complete": True
        }
    
    async def handle_incident(self, incident_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Gère un incident de déploiement
        """
        incident_task = Task(
            description=f"""
            Gérez cet incident de déploiement :
            {incident_data}
            
            Actions requises :
            1. Analyse de l'incident
            2. Impact assessment
            3. Actions immédiates
            4. Communication aux parties prenantes
            5. Plan de résolution
            6. Prévention future
            """,
            agent=self.release_coordinator,
            expected_output="Plan de gestion d'incident"
        )
        
        crew = Crew(
            agents=[self.release_coordinator],
            tasks=[incident_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "incident_response": result,
            "incident_handled": True
        } 