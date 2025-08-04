"""
Module des agents CrewAI pour la plateforme CoachLibre
"""

from .crew_manager import CrewManager
from .intent_manager import IntentManager
from .project_manager import ProjectManager
from .technical_lead import TechnicalLead
from .release_manager import ReleaseManager

__all__ = [
    "CrewManager",
    "IntentManager", 
    "ProjectManager",
    "TechnicalLead",
    "ReleaseManager"
] 