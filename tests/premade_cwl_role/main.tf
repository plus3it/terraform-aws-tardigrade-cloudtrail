data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

locals {
  partition = "aws"
  test_id   = data.terraform_remote_state.prereq.outputs.random_name
}

resource "aws_s3_bucket" "this" {
  bucket        = local.test_id
  force_destroy = true

  policy = templatefile(
    "${path.module}/../templates/cloudtrail-bucket-policy.json",
    {
      bucket    = local.test_id
      partition = local.partition
    }
  )
}

module "premade_cwl_role" {
  source = "../../"

  cloudtrail_name             = local.test_id
  cloudtrail_bucket           = aws_s3_bucket.this.id
  cloud_watch_logs_group_name = data.terraform_remote_state.prereq.outputs.cwl_group_name
  cloud_watch_logs_role_arn   = data.terraform_remote_state.prereq.outputs.cwl_role_arn
  kms_key_alias               = local.test_id
}
