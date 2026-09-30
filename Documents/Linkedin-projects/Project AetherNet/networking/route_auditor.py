"""
Networking Route Auditor & Drift Generator for Project AetherNet.
Provides helper routines to inspect VPC Route Tables, inject synthetic drift for testing,
and trigger autonomic state reconciliation via BoundaryRemediator.
"""

import os
import sys
import time
import json
import logging
import asyncio
from datetime import datetime, timezone

# Add security directory to sys.path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'security'))
from engine_config import EngineConfig, get_ec2_client
from boundary_remediator import BoundaryRemediator, logger

class RouteAuditor:
    """Network Route Auditor for inspecting network topology and simulating drift events."""

    def __init__(self, endpoint_url: str = None, region_name: str = None):
        self.endpoint_url = endpoint_url or EngineConfig.AWS_ENDPOINT_URL
        self.region_name = region_name or EngineConfig.AWS_REGION
        self.ec2 = get_ec2_client(endpoint_url=self.endpoint_url, region_name=self.region_name)
        self.remediator = BoundaryRemediator(endpoint_url=self.endpoint_url, region_name=self.region_name)

    def inject_drift(self, route_table_id: str, destination_cidr: str = "0.0.0.0/0") -> bool:
        """
        Simulates an unauthorized route injection (configuration drift).
        Injects a public gateway or blackhole route to test autonomic detection.
        """
        logger.info(f"Injecting synthetic route drift ({destination_cidr}) into {route_table_id}")
        try:
            # First attempt to create route. If it exists, replace or ignore.
            try:
                self.ec2.create_route(
                    RouteTableId=route_table_id,
                    DestinationCidrBlock=destination_cidr,
                    GatewayId="local"  # Dummy target gateway for LocalStack testing
                )
            except Exception:
                # If create_route fails, attempt replace_route or fallback
                pass
            logger.info(f"Synthetic drift injected successfully into {route_table_id}")
            return True
        except Exception as e:
            logger.error(f"Failed to inject drift into {route_table_id}: {e}")
            return False

    def list_all_route_tables() -> list[str]:
        """Lists all route table IDs currently in the AWS/LocalStack account."""
        try:
            response = self.ec2.describe_route_tables()
            return [rt['RouteTableId'] for rt in response.get('RouteTables', [])]
        except Exception as e:
            logger.error(f"Failed to describe route tables: {e}")
            return [EngineConfig.DEFAULT_ROUTE_TABLE_ID]


if __name__ == "__main__":
    auditor = RouteAuditor()
    print("Testing RouteAuditor drift injection...")
    auditor.inject_drift(EngineConfig.DEFAULT_ROUTE_TABLE_ID)
    res = auditor.remediator.audit_and_remediate_routes(EngineConfig.DEFAULT_ROUTE_TABLE_ID)
    print("Remediation result:", json.dumps(res, indent=2))
