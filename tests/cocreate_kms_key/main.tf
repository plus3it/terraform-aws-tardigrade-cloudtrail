data "aws_caller_identity" "current" {}

data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

locals {
  test_id = data.terraform_remote_state.prereq.outputs.random_name
}

resource "aws_kms_key" "this" {
  policy = templatefile(
    "${path.module}/../templates/cloudtrail-kms-key-policy.json",
    {
      account_id = data.aws_caller_identity.current.account_id
    }
  )
}

module "cocreate_kms_key" {
  source = "../../"

  create_kms_key    = false
  cloudtrail_name   = local.test_id
  cloudtrail_bucket = data.terraform_remote_state.prereq.outputs.bucket_id
  kms_key_id        = aws_kms_key.this.arn
}
