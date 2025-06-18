# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Assume Role Policy
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Policy Document
data "aws_iam_policy_document" "rds_and_secret_manager" {
  statement {
    actions = [
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "rds:DescribeDBInstances",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      "arn:aws:secretsmanager:eu-west-2:442042522885:secret:*",
      "arn:aws:rds:eu-west-2:442042522885:db:*",
      "arn:aws:elasticfilesystem:eu-west-2:442042522885:file-system/*",
      "arn:aws:elasticfilesystem:eu-west-2:442042522885:access-point/*"
    ]

    effect = "Allow"

  }
}

data "aws_caller_identity" "current" {}
