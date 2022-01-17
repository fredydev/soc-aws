

# https://stackoverflow.com/questions/55128348/execute-terraform-apply-with-aws-assume-role

provider "aws" {
  version = "2.42.0"
  region  = var.aws_region
  profile = var.profile_member_account
}
