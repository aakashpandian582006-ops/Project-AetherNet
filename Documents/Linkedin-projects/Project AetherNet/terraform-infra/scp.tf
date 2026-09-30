# Service Control Policy (SCP) Simulation for Zero-Trust Perimeter Boundary

resource "aws_organizations_policy" "deny_unauthorized_public_routes" {
  name        = "AetherNet-DenyPublicEgressRouteCreation"
  description = "Service Control Policy preventing manual or automated creation of 0.0.0.0/0 route egress rules in private VPC partitions."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyPublicRouteInPrivatePartitions"
        Effect = "Deny"
        Action = [
          "ec2:CreateRoute"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:CidrBlock" = "0.0.0.0/0"
          }
        }
      }
    ]
  })

  tags = {
    Project   = "AetherNet"
    Author    = "Aakash Pandian"
    RuleType  = "ServiceControlPolicy"
  }
}
