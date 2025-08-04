from crewai import Agent, Task, Crew
from langchain_openai import ChatOpenAI
from typing import Dict, Any
import os

class IntentManager:
    """
    Agent responsable de l'analyse et de la compréhension des intentions utilisateur
    """
    
    def __init__(self):
        self.llm = ChatOpenAI(
            model="gpt-4",
            temperature=0.1,
            api_key=os.getenv("OPENAI_API_KEY")
        )
        
        # Agent principal d'analyse d'intention
        self.intent_analyzer = Agent(
            role="Analyste d'Intention",
            goal="Analyser et comprendre les intentions des utilisateurs pour les diriger vers les bons services",
            backstory="""Vous êtes un expert en analyse comportementale et en compréhension des besoins utilisateur.
            Vous avez une expertise particulière dans le domaine du coaching et de l'accompagnement personnalisé.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
        
        # Agent superviseur pour amélioration
        self.intent_supervisor = Agent(
            role="Superviseur d'Intention",
            goal="Valider et améliorer les analyses d'intention pour assurer la qualité",
            backstory="""Vous êtes un superviseur expérimenté qui valide les analyses d'intention.
            Vous vous assurez que les besoins utilisateur sont correctement identifiés et priorisés.""",
            verbose=True,
            allow_delegation=False,
            llm=self.llm
        )
    
    async def process_intent(self, intent: str, context: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Traite une intention utilisateur et retourne une analyse structurée
        """
        
        # Création des tâches
        analysis_task = Task(
            description=f"""
            Analysez l'intention suivante de l'utilisateur :
            "{intent}"
            
            Contexte fourni : {context or 'Aucun contexte supplémentaire'}
            
            Votre analyse doit inclure :
            1. Catégorisation de l'intention (coaching, formation, consultation, etc.)
            2. Niveau d'urgence et de priorité
            3. Besoins identifiés
            4. Recommandations d'actions
            5. Score de confiance (0-1)
            
            Retournez votre analyse au format JSON structuré.
            """,
            agent=self.intent_analyzer,
            expected_output="Analyse JSON structurée de l'intention utilisateur"
        )
        
        validation_task = Task(
            description="""
            Validez l'analyse d'intention fournie et proposez des améliorations si nécessaire.
            Assurez-vous que :
            - La catégorisation est appropriée
            - Les besoins sont bien identifiés
            - Les recommandations sont pertinentes
            - Le score de confiance est justifié
            
            Retournez l'analyse validée ou améliorée.
            """,
            agent=self.intent_supervisor,
            expected_output="Analyse validée ou améliorée"
        )
        
        # Création et exécution du crew
        crew = Crew(
            agents=[self.intent_analyzer, self.intent_supervisor],
            tasks=[analysis_task, validation_task],
            verbose=True
        )
        
        # Exécution du workflow
        result = crew.kickoff()
        
        # Traitement du résultat
        try:
            # Simulation d'un résultat structuré (à adapter selon le vrai output de CrewAI)
            analysis_result = {
                "analysis": result,
                "confidence": 0.85,
                "category": "coaching_request",
                "priority": "medium",
                "needs": ["accompagnement_personnalise", "objectifs_clairs"],
                "recommendations": ["séance_découverte", "évaluation_besoins"]
            }
            
            return analysis_result
            
        except Exception as e:
            # Fallback en cas d'erreur
            return {
                "analysis": f"Analyse d'intention : {intent}",
                "confidence": 0.5,
                "category": "unknown",
                "priority": "low",
                "needs": [],
                "recommendations": ["contact_humain"]
            }
    
    async def improve_analysis(self, feedback: Dict[str, Any]) -> Dict[str, Any]:
        """
        Améliore l'analyse basée sur le feedback reçu
        """
        improvement_task = Task(
            description=f"""
            Améliorez votre analyse précédente basée sur ce feedback :
            {feedback}
            
            Identifiez les points d'amélioration et proposez une version optimisée.
            """,
            agent=self.intent_analyzer,
            expected_output="Analyse améliorée"
        )
        
        crew = Crew(
            agents=[self.intent_analyzer],
            tasks=[improvement_task],
            verbose=True
        )
        
        result = crew.kickoff()
        
        return {
            "improved_analysis": result,
            "improvement_applied": True
        } 