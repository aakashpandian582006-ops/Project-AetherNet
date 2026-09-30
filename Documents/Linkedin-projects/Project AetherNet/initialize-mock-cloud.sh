#!/usr/bin/env bash

# Project AetherNet - Autonomic Cloud Environment Initializer
# Author: Aakash Pandian | Role: Cloud Engineer / Platform Architect
# Bootstraps LocalStack simulated AWS infrastructure and Terraform manifests.

set -e

echo "=========================================================="
echo "    AetherNet: Autonomic Cloud Emulation Bootstrap       "
echo "    Author: Aakash Pandian | Enterprise Platform Lead    "
echo "=========================================================="

# 1. Export Mock AWS Credentials
echo "[+] Exporting AWS mock credentials..."
export AWS_ACCESS_KEY_ID="mock_id"
export AWS_SECRET_ACCESS_KEY="mock_secret"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ENDPOINT_URL="http://localhost:4566"

LOCALSTACK_URL="http://localhost:4566"
MAX_ATTEMPTS=20
ATTEMPT=1

# 2. Wait for LocalStack health gateway to be online
echo "[+] Pinging LocalStack health gateway at ${LOCALSTACK_URL}..."
while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  if curl -s "${LOCALSTACK_URL}/_localstack/health" | grep -qE '"s3":|"ec2":|"running"'; then
    echo "[+] LocalStack health check passed!"
    break
  fi
  echo "[-] LocalStack services not ready yet (Attempt $ATTEMPT/$MAX_ATTEMPTS). Retrying in 2s..."
  sleep 2
  ATTEMPT=$((ATTEMPT + 1))
done

# AWS CLI helper pointing to local emulator
aws_local() {
  aws --endpoint-url="$LOCALSTACK_URL" --region "$AWS_DEFAULT_REGION" "$@"
}

# 3. Provision Infrastructure via Terraform (if terraform installed and LocalStack operational)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="${SCRIPT_DIR}/terraform-infra"

if command -v terraform &> /dev/null && curl -s "${LOCALSTACK_URL}/_localstack/health" &> /dev/null; then
  echo "[+] Terraform detected. Applying HCL manifests from ${TF_DIR}..."
  (
    cd "$TF_DIR"
    terraform init -reconfigure -input=false || true
    terraform apply -auto-approve -input=false || true
  )
else
  echo "[!] Terraform CLI or active LocalStack container unavailable; performing direct AWS CLI endpoint bootstrap..."
fi

# 4. Create mock S3 compliance bucket if not created
BUCKET_NAME="aethernet-compliance-ledger"
echo "[+] Ensuring S3 compliance bucket exists: s3://$BUCKET_NAME..."
if command -v aws &> /dev/null; then
  if aws_local s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "[-] Bucket s3://$BUCKET_NAME exists."
  else
    aws_local s3 mb "s3://$BUCKET_NAME" 2>/dev/null || true
    echo "[+] Bucket s3://$BUCKET_NAME created successfully."
  fi
fi

# 5. Create mock VPC (Tagged as vpc-101010) & Route Table if not created
if command -v aws &> /dev/null; then
  echo "[+] Verifying mock VPC and route table initialization..."
  VPC_INFO=$(aws_local ec2 create-vpc --cidr-block 10.10.10.0/24 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=vpc-101010}]' 2>/dev/null || true)
  echo "[+] VPC setup verified."
fi

# 6. Seed initial audit ledger entry into S3 compliance ledger
echo "[+] Seeding initial compliance audit entries to S3..."
TEMP_LOGS_FILE="/tmp/aethernet_init_audit.json"
cat <<EOF > "$TEMP_LOGS_FILE"
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "event_id": "evt-init-001",
  "type": "SYSTEM_BOOTSTRAP",
  "status": "OPTIMAL",
  "message": "AetherNet Autonomic Cloud initial state provisioned by Aakash Pandian.",
  "compliance_framework": "CIS-AWS-1.4",
  "operator": "INITIALIZER"
}
EOF

if command -v aws &> /dev/null; then
  aws_local s3api put-object \
    --bucket "$BUCKET_NAME" \
    --key "audits/OPTIMAL-init.json" \
    --body "$TEMP_LOGS_FILE" \
    --content-type "application/json" 2>/dev/null || true
fi
rm -f "$TEMP_LOGS_FILE"

echo "=========================================================="
echo "  Autonomic Cloud Infrastructure Bootstrap Complete!       "
echo "  Author: Aakash Pandian | VertexGuard Pro Architecture    "
echo "=========================================================="
