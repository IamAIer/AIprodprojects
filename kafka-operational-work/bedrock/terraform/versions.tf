terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.62"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  name = "kafka-operational-bot-${var.environment}"
  tags = {
    Project     = "kafka-operational-assistant"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}
