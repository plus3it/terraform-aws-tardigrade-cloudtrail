data "aws_partition" "current" {}

data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

locals {
  test_id = data.terraform_remote_state.prereq.outputs.random_name
}

resource "aws_s3_bucket" "this" {
  bucket        = local.test_id
  force_destroy = true

  policy = templatefile(
    "${path.module}/../templates/cloudtrail-bucket-policy.json",
    {
      bucket    = local.test_id
      partition = data.aws_partition.current.partition
    }
  )
}

module "advanced_event_selector" {
  source = "../../"

  cloudtrail_name   = local.test_id
  cloudtrail_bucket = aws_s3_bucket.this.id
  kms_key_alias     = local.test_id

  advanced_event_selectors = [
    {
      name = "S3EventSelector"
      field_selectors = [
        {
          field  = "eventCategory"
          equals = ["Data"]
        },
        {
          field  = "resources.type"
          equals = ["AWS::S3::Object"]
        },
        {
          field       = "resources.ARN"
          starts_with = ["arn:aws:s3:::test"]
        }
      ]
    },
  ]
}
