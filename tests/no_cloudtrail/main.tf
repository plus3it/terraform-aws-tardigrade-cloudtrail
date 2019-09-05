provider "aws" {
  region = "us-east-1"
}

module "no_cloudtrail" {
  source = "../../"

  providers = {
    aws = aws
  }

  create_cloudtrail = false
}
