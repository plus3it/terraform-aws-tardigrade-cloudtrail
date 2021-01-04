provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

module "premade_kms_key" {
  source = "../../"

  providers = {
    aws = aws
  }

  cloudtrail_name   = data.terraform_remote_state.prereq.outputs.random_name
  cloudtrail_bucket = data.terraform_remote_state.prereq.outputs.bucket_id
  kms_key_id        = data.terraform_remote_state.prereq.outputs.kms_key_id
}
