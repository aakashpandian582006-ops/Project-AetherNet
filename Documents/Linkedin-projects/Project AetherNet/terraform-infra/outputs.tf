output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the provisioned AetherNet Core VPC."
}

output "private_route_table_id" {
  value       = aws_route_table.private_rt.id
  description = "Target private route table ID subject to autonomic remediation."
}

output "public_route_table_id" {
  value       = aws_route_table.public_rt.id
  description = "Public route table ID bound to Internet Gateway."
}

output "compliance_bucket_name" {
  value       = var.compliance_bucket_name
  description = "S3 compliance ledger bucket name."
}

output "remediation_role_arn" {
  value       = aws_iam_role.remediation_engine.arn
  description = "IAM Role ARN associated with the remediation engine."
}
