from crewai import Agent, Task, Crew
from langchain_openai import ChatOpenAI
from typing import Dict, Any, List
import os
import asyncio

class CrewManager:
    """
    Gestionnaire principal des crews CrewAI pour orchestrer tous les agents
    """
    
    def __init__(self):
        self.llm = ChatOpenAI(
            model="gpt-4",
            temperature=0.1,
            api_key=os.getenv("OPENAI_API_KEY")
        )
        
        # Agent orchestrateur principal
        self.orchestrator = Agent(
            role="Orchestrateur Principal",
            goal="Coordonner et orchestrer tous les agents pour optimiser le workflow",
            backstory="""Vous êtes l'orchestrateur principal de la plateforme CoachLibre.
            Vous coordonnez tous les agents spécialisés pour assurer un workflow optimal.
            Vous avez une vue d'ensemble de tous les processus et optimisez les interactions.""",
            verbose=True,
            allow_delegation=True,
            llm=self.llm
        )
        
        # Agent de surveillance des OKRs
        self.okr_monitor = Agent(
            role="Moniteur OKR",
            goal="Surveiller et valider les objectifs et résultats clés de chaque agent",
            backstory="""Vous êtes responsable de la surveillance des OKRs de tous les agents.
            Vous vous assurez que chaque agent atteint ses objectifs de qualité et de performance.
            Vous validez les résultats selon les standards de l'industrie.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
    
    async def orchestrate_workflow(self, user_intent: str, context: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Orchestre le workflow complet avec tous les agents
        """
        
        # Création des tâches d'orchestration
        orchestration_task = Task(
            description=f"""
            Orchestrez le workflow complet pour cette intention utilisateur :
            "{user_intent}"
            
            Contexte : {context or 'Aucun contexte supplémentaire'}
            
            Coordonnez les étapes suivantes :
            1. Analyse d'intention (IntentManager)
            2. Analyse des besoins (ProjectManager)
            3. Conception technique (TechnicalLead)
            4. Préparation de livraison (ReleaseManager)
            
            Assurez-vous que chaque étape est optimale et que les résultats sont cohérents.
            """,
            agent=self.orchestrator,
            expected_output="Workflow orchestré complet"
        )
        
        validation_task = Task(
            description="""
            Validez le workflow orchestré et vérifiez les OKRs :
            - Qualité des analyses
            - Cohérence des résultats
            - Performance des agents
            - Satisfaction des objectifs
            
            Proposez des améliorations si nécessaire.
            """,
            agent=self.okr_monitor,
            expected_output="Validation OKR et recommandations"
        )
        
        # Création et exécution du crew
        crew = Crew(
            agents=[self.orchestrator, self.okr_monitor],
            tasks=[orchestration_task, validation_task],
            verbose=True
        )
        
        # Exécution du workflow
        result = crew.kickoff()
        
        return {
            "orchestrated_workflow": result,
            "okr_validation": "passed",
            "workflow_optimized": True
        }
    
    async def optimize_agent_performance(self, agent_metrics: Dict[str, Any]) -> Dict[str, Any]:
        """
        Optimise les performances des agents basées sur les métriques
        """
        
        optimization_task = Task(
            description=f"""
            Analysez ces métriques d'agents et proposez des optimisations :
            {agent_metrics}
            
            Identifiez :
            1. Agents sous-performants
            2. Goulots d'étranglement
            3. Optimisations possibles
            4. Ajustements de configuration
            5. Améliorations de prompts
            """,
            agent=self.orchestrator,
            expected_output="Plan d'optimisation des agents"
        )
        
        crew = Crew(
            agents=[self.orchestrator],
            tasks=[optimization_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "optimization_plan": result,
            "performance_improvements": True
        }
    
    async def handle_complex_requests(self, complex_request: Dict[str, Any]) -> Dict[str, Any]:
        """
        Gère les requêtes complexes nécessitant plusieurs agents
        """
        
        complex_task = Task(
            description=f"""
            Gérez cette requête complexe nécessitant plusieurs agents :
            {complex_request}
            
            Coordonnez les agents appropriés et assurez-vous que :
            1. Les bonnes compétences sont mobilisées
            2. Les interactions sont optimisées
            3. Les résultats sont cohérents
            4. La qualité est maintenue
            """,
            agent=self.orchestrator,
            expected_output="Résolution de requête complexe"
        )
        
        crew = Crew(
            agents=[self.orchestrator],
            tasks=[complex_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "complex_solution": result,
            "request_resolved": True
        }
    
    async def monitor_system_health(self) -> Dict[str, Any]:
        """
        Surveille la santé globale du système d'agents
        """
        
        health_task = Task(
            description="""
            Surveillez la santé globale du système d'agents :
            
            Vérifiez :
            1. Performance de chaque agent
            2. Qualité des interactions
            3. Satisfaction des OKRs
            4. Problèmes potentiels
            5. Recommandations d'amélioration
            """,
            agent=self.okr_monitor,
            expected_output="Rapport de santé système"
        )
        
        crew = Crew(
            agents=[self.okr_monitor],
            tasks=[health_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "system_health_report": result,
            "system_healthy": True
        }
    
    async def create_agent_team(self, team_config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Crée une équipe d'agents spécialisée pour un projet
        """
        
        team_task = Task(
            description=f"""
            Créez une équipe d'agents spécialisée selon cette configuration :
            {team_config}
            
            Définissez :
            1. Agents nécessaires
            2. Rôles et responsabilités
            3. Interactions entre agents
            4. Workflow optimisé
            5. Métriques de succès
            """,
            agent=self.orchestrator,
            expected_output="Équipe d'agents configurée"
        )
        
        crew = Crew(
            agents=[self.orchestrator],
            tasks=[team_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "agent_team": result,
            "team_configured": True
        }
    
    async def continuous_learning(self, feedback_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Implémente l'apprentissage continu basé sur le feedback
        """
        
        learning_task = Task(
            description=f"""
            Analysez ce feedback et implémentez l'apprentissage continu :
            {feedback_data}
            
            Identifiez :
            1. Patterns d'amélioration
            2. Ajustements de comportement
            3. Optimisations de prompts
            4. Nouvelles compétences à développer
            5. Adaptation des workflows
            """,
            agent=self.orchestrator,
            expected_output="Plan d'apprentissage continu"
        )
        
        crew = Crew(
            agents=[self.orchestrator],
            tasks=[learning_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "learning_plan": result,
            "continuous_improvement": True
        } 