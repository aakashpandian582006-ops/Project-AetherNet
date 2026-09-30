# security/policy_validator.py
import json
import logging
from datetime import datetime, timezone
from engine_config import EngineConfig

logger = logging.getLogger("AetherNet.PolicyValidator")

class PolicyValidator:
    """Enforces zero-trust compliance validation on routing targets and IAM/VPC policies."""
    
    def __init__(self):
        self.standard = EngineConfig.COMPLIANCE_STANDARD

    def validate_route(self, destination_cidr: str) -> bool:
        """
        Validates CIDR block against Zero-Trust perimeter guidelines.
        Returns True if route complies with safety regulations.
        Returns False if an illegal bypass (0.0.0.0/0 or ::/0) is detected.
        """
        if destination_cidr in ["0.0.0.0/0", "::/0"]:
            logger.warning(
                json.dumps({
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "event": "POLICY_VIOLATION",
                    "compliance_standard": self.standard,
                    "destination_cidr": destination_cidr,
                    "message": f"Wildcard route {destination_cidr} violates {self.standard} zero-trust ingress/egress policy."
                })
            )
            return False
        return True

    def validate_iam_policy(self, policy_doc: dict) -> bool:
        """
        Checks IAM policy documents for overly permissive wildcard admin permissions (*).
        """
        statements = policy_doc.get("Statement", [])
        if isinstance(statements, dict):
            statements = [statements]

        for stmt in statements:
            if stmt.get("Effect") == "Allow":
                actions = stmt.get("Action", [])
                resources = stmt.get("Resource", [])
                if "*" in actions and "*" in resources:
                    logger.warning("Overly permissive wildcard (*) IAM policy statement detected!")
                    return False
        return True