

# https://stackoverflow.com/questions/55128348/execute-terraform-apply-with-aws-assume-role

provider "aws" {
  region  = var.aws_region
  profile = var.profile_member_account
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"
}
