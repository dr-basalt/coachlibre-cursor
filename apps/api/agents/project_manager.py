from crewai import Agent, Task, Crew
from langchain_openai import ChatOpenAI
from typing import Dict, Any
import os

class ProjectManager:
    """
    Agent responsable de l'analyse des besoins et de la planification fonctionnelle
    """
    
    def __init__(self):
        self.llm = ChatOpenAI(
            model="gpt-4",
            temperature=0.2,
            api_key=os.getenv("OPENAI_API_KEY")
        )
        
        # Agent principal d'analyse des besoins
        self.requirements_analyzer = Agent(
            role="Analyste des Besoins Fonctionnels",
            goal="Analyser les besoins utilisateur et définir les spécifications fonctionnelles",
            backstory="""Vous êtes un chef de projet fonctionnel expérimenté spécialisé dans l'analyse des besoins.
            Vous avez une expertise dans la transformation des intentions utilisateur en spécifications claires et mesurables.
            Vous travaillez dans le domaine du coaching et de l'accompagnement personnalisé.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
        
        # Agent superviseur pour validation
        self.requirements_supervisor = Agent(
            role="Superviseur des Spécifications",
            goal="Valider et optimiser les spécifications fonctionnelles",
            backstory="""Vous êtes un superviseur senior qui valide les spécifications fonctionnelles.
            Vous vous assurez que les besoins sont bien compris, mesurables et réalisables.
            Vous avez une expertise en méthodologies agiles et en gestion de projet.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
    
    async def analyze_requirements(self, intent_analysis: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analyse les besoins basés sur l'analyse d'intention
        """
        
        # Création des tâches
        requirements_task = Task(
            description=f"""
            Analysez les besoins fonctionnels basés sur cette analyse d'intention :
            {intent_analysis}
            
            Développez des spécifications fonctionnelles détaillées incluant :
            1. Objectifs SMART (Spécifiques, Mesurables, Atteignables, Réalistes, Temporels)
            2. Besoins fonctionnels détaillés
            3. Critères d'acceptation
            4. Contraintes et risques identifiés
            5. Planning préliminaire
            6. Ressources nécessaires
            7. Métriques de succès
            
            Adaptez votre analyse au contexte du coaching et de l'accompagnement personnalisé.
            """,
            agent=self.requirements_analyzer,
            expected_output="Spécifications fonctionnelles détaillées"
        )
        
        validation_task = Task(
            description="""
            Validez les spécifications fonctionnelles fournies et proposez des améliorations.
            Vérifiez que :
            - Les objectifs sont SMART
            - Les besoins sont clairs et mesurables
            - Les critères d'acceptation sont définis
            - Le planning est réaliste
            - Les risques sont identifiés et mitigés
            
            Retournez les spécifications validées ou améliorées.
            """,
            agent=self.requirements_supervisor,
            expected_output="Spécifications validées ou améliorées"
        )
        
        # Création et exécution du crew
        crew = Crew(
            agents=[self.requirements_analyzer, self.requirements_supervisor],
            tasks=[requirements_task, validation_task],
            verbose=True
        )
        
        # Exécution du workflow
        result = crew.kickoff()
        
        # Traitement du résultat
        try:
            # Simulation d'un résultat structuré
            requirements_result = {
                "requirements": result,
                "confidence": 0.88,
                "objectives": [
                    "Définir un plan d'accompagnement personnalisé",
                    "Établir des objectifs mesurables",
                    "Créer un suivi régulier"
                ],
                "acceptance_criteria": [
                    "Plan d'accompagnement validé par le client",
                    "Objectifs SMART définis",
                    "Calendrier de suivi établi"
                ],
                "timeline": "4-6 semaines",
                "resources": ["coach_certifié", "outils_suivi", "plateforme_communication"],
                "risks": ["disponibilité_client", "objectifs_irréalistes"],
                "success_metrics": ["atteinte_objectifs", "satisfaction_client", "progression_mesurable"]
            }
            
            return requirements_result
            
        except Exception as e:
            # Fallback en cas d'erreur
            return {
                "requirements": f"Analyse des besoins basée sur : {intent_analysis.get('analysis', 'N/A')}",
                "confidence": 0.6,
                "objectives": ["Accompagnement personnalisé"],
                "acceptance_criteria": ["Client satisfait"],
                "timeline": "À définir",
                "resources": ["coach"],
                "risks": ["Non spécifiés"],
                "success_metrics": ["Satisfaction client"]
            }
    
    async def create_project_plan(self, requirements: Dict[str, Any]) -> Dict[str, Any]:
        """
        Crée un plan de projet détaillé basé sur les spécifications
        """
        planning_task = Task(
            description=f"""
            Créez un plan de projet détaillé basé sur ces spécifications :
            {requirements}
            
            Le plan doit inclure :
            1. Phases du projet avec jalons
            2. Répartition des tâches
            3. Estimation des efforts
            4. Gestion des risques
            5. Communication et reporting
            6. Qualité et validation
            """,
            agent=self.requirements_analyzer,
            expected_output="Plan de projet détaillé"
        )
        
        crew = Crew(
            agents=[self.requirements_analyzer],
            tasks=[planning_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "project_plan": result,
            "planning_complete": True
        }
    
    async def monitor_progress(self, project_id: str, current_status: Dict[str, Any]) -> Dict[str, Any]:
        """
        Surveille le progrès du projet et propose des ajustements
        """
        monitoring_task = Task(
            description=f"""
            Analysez le progrès du projet {project_id} :
            {current_status}
            
            Identifiez :
            1. Écarts par rapport au planning
            2. Risques émergents
            3. Actions correctives nécessaires
            4. Ajustements du plan
            """,
            agent=self.requirements_supervisor,
            expected_output="Rapport de surveillance et recommandations"
        )
        
        crew = Crew(
            agents=[self.requirements_supervisor],
            tasks=[monitoring_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "monitoring_report": result,
            "adjustments_needed": True
        } 