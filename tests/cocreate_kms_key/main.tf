provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

resource "aws_kms_key" "this" {
  policy = join("", data.template_file.kms_policy.*.rendered)
}

data "template_file" "kms_policy" {
  template = file("${path.module}/../templates/cloudtrail-kms-key-policy.json")

  vars = {
    account_id = data.aws_caller_identity.current.account_id
  }
}

module "cocreate_kms_key" {
  source = "../../"

  providers = {
    aws = aws
  }

  create_kms_key    = true
  cloudtrail_name   = data.terraform_remote_state.prereq.outputs.random_name
  cloudtrail_bucket = data.terraform_remote_state.prereq.outputs.bucket_id
  kms_key_id        = aws_kms_key.this.id
}
