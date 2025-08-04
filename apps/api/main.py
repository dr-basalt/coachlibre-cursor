from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
import os
from dotenv import load_dotenv

# Import des modules CrewAI
from agents.crew_manager import CrewManager
from agents.intent_manager import IntentManager
from agents.project_manager import ProjectManager
from agents.technical_lead import TechnicalLead
from agents.release_manager import ReleaseManager

load_dotenv()

app = FastAPI(
    title="CoachLibre API",
    description="API Multi-Agent pour la plateforme de coaching",
    version="1.0.0"
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # À configurer pour la production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modèles Pydantic
class UserIntent(BaseModel):
    intent: str
    context: Optional[dict] = None
    user_id: Optional[str] = None

class AgentResponse(BaseModel):
    agent_id: str
    response: str
    confidence: float
    next_agent: Optional[str] = None

class WorkflowResult(BaseModel):
    workflow_id: str
    status: str
    results: List[AgentResponse]
    final_output: str

# Initialisation des agents
crew_manager = CrewManager()
intent_manager = IntentManager()
project_manager = ProjectManager()
technical_lead = TechnicalLead()
release_manager = ReleaseManager()

@app.get("/")
async def root():
    return {"message": "CoachLibre API - Multi-Agent Platform"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "agents": ["intent", "project", "technical", "release"]}

@app.post("/workflow/process", response_model=WorkflowResult)
async def process_workflow(user_intent: UserIntent):
    """
    Traite une intention utilisateur à travers le workflow multi-agent
    """
    try:
        # 1. Gestionnaire d'intention
        intent_result = await intent_manager.process_intent(user_intent.intent, user_intent.context)
        
        # 2. Chef de projet fonctionnel
        project_result = await project_manager.analyze_requirements(intent_result)
        
        # 3. Chef de projet technique
        technical_result = await technical_lead.design_solution(project_result)
        
        # 4. Release Manager
        release_result = await release_manager.prepare_delivery(technical_result)
        
        # Compilation des résultats
        workflow_result = WorkflowResult(
            workflow_id=f"wf_{user_intent.user_id}_{int(hash(user_intent.intent))}",
            status="completed",
            results=[
                AgentResponse(
                    agent_id="intent_manager",
                    response=intent_result["analysis"],
                    confidence=intent_result["confidence"]
                ),
                AgentResponse(
                    agent_id="project_manager",
                    response=project_result["requirements"],
                    confidence=project_result["confidence"]
                ),
                AgentResponse(
                    agent_id="technical_lead",
                    response=technical_result["solution"],
                    confidence=technical_result["confidence"]
                ),
                AgentResponse(
                    agent_id="release_manager",
                    response=release_result["delivery_plan"],
                    confidence=release_result["confidence"]
                )
            ],
            final_output=release_result["final_output"]
        )
        
        return workflow_result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur dans le workflow: {str(e)}")

@app.get("/agents/{agent_id}/status")
async def get_agent_status(agent_id: str):
    """
    Récupère le statut d'un agent spécifique
    """
    agents = {
        "intent": intent_manager,
        "project": project_manager,
        "technical": technical_lead,
        "release": release_manager
    }
    
    if agent_id not in agents:
        raise HTTPException(status_code=404, detail="Agent non trouvé")
    
    return {"agent_id": agent_id, "status": "active", "last_activity": "2024-01-01T00:00:00Z"}

@app.post("/agents/{agent_id}/improve")
async def improve_agent_response(agent_id: str, feedback: dict):
    """
    Améliore la réponse d'un agent basé sur le feedback
    """
    # Logique d'amélioration des agents
    return {"message": f"Agent {agent_id} amélioré avec succès"}

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    ) 