terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "infrabucket-iacgitops-eu-west-2"
    key            = "tfstate-wordpress-prod"
    region         = "eu-west-2"
    dynamodb_table = "tfstate-dynamo-lock"
    encrypt        = true
  }
}
