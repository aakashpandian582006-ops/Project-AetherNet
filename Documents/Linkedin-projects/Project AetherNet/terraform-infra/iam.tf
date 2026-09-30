# AetherNet IAM Roles and Least-Privilege Remediation Policy Manifest

resource "aws_iam_role" "remediation_engine" {
  name = "aethernet-autonomic-remediator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
        }
      }
    ]
  })

  tags = {
    Name    = "aethernet-remediator-role"
    Project = "AetherNet"
    Author  = "Aakash Pandian"
  }
}

resource "aws_iam_policy" "remediation_policy" {
  name        = "aethernet-remediation-least-privilege-policy"
  description = "Allows BoundaryRemediator to inspect EC2 route tables, remediate drift, and write S3 compliance logs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcs",
          "ec2:DeleteRoute",
          "ec2:CreateRoute"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:HeadBucket",
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.compliance_bucket_name}",
          "arn:aws:s3:::${var.compliance_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "remediation_attach" {
  role       = aws_iam_role.remediation_engine.name
  policy_arn = aws_iam_policy.remediation_policy.arn
}
