import os
import boto3
from botocore.config import Config

class EngineConfig:
    """Enterprise Autonomic Cloud Engine Configuration."""
    AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
    AWS_ENDPOINT_URL = os.getenv("AWS_ENDPOINT_URL", "http://localhost:4566")
    LOCALSTACK_URL = os.getenv("LOCALSTACK_URL", "http://localhost:4566")
    USE_REAL_AWS = os.getenv("USE_REAL_AWS", "false").lower() == "true"
    
    COMPLIANCE_STANDARD = os.getenv("COMPLIANCE_STANDARD", "CIS-AWS-1.4")
    DEFAULT_COMPLIANCE = "CIS-AWS-1.4"
    COMPLIANCE_BUCKET = os.getenv("COMPLIANCE_BUCKET", "aethernet-compliance-ledger")
    
    # Target Route Table IDs for remediation
    DEFAULT_ROUTE_TABLE_ID = os.getenv("DEFAULT_ROUTE_TABLE_ID", "rtb-9e353773")
    
    # Canonical baseline routes allowed per route table:
    CANONICAL_BASELINE_ROUTES = {
        "local": "10.10.10.0/24"
    }

    # Boto3 client resilience configuration with short timeouts for sub-200ms processing
    BOTO_CONFIG = Config(
        retries={'max_attempts': 3, 'mode': 'standard'},
        connect_timeout=1.5,
        read_timeout=1.5
    )

def get_boto3_client(service_name: str, endpoint_url: str = None, region_name: str = None):
    """Factory function for resilient boto3 clients supporting LocalStack and AWS."""
    endpoint = endpoint_url or (None if EngineConfig.USE_REAL_AWS else EngineConfig.AWS_ENDPOINT_URL)
    region = region_name or EngineConfig.AWS_REGION
    
    kwargs = {
        "region_name": region,
        "config": EngineConfig.BOTO_CONFIG
    }
    if endpoint:
        kwargs["endpoint_url"] = endpoint
        kwargs["aws_access_key_id"] = "mock_key"
        kwargs["aws_secret_access_key"] = "mock_secret"
        
    return boto3.client(service_name, **kwargs)

def get_ec2_client(endpoint_url: str = None, region_name: str = None):
    return get_boto3_client("ec2", endpoint_url, region_name)

def get_s3_client(endpoint_url: str = None, region_name: str = None):
    return get_boto3_client("s3", endpoint_url, region_name)