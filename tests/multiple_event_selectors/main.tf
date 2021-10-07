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

module "multiple_event_selectors" {
  source = "../../"

  cloudtrail_name   = local.test_id
  cloudtrail_bucket = aws_s3_bucket.this.id
  kms_key_alias     = local.test_id

  event_selectors = [
    {
      "read_write_type"           = "All"
      "include_management_events" = true
      "data_resources" = [
        {
          "type"   = "AWS::Lambda::Function"
          "values" = ["arn:${data.aws_partition.current.partition}:lambda"]
        },
        {
          type   = "AWS::S3::Object"
          values = ["arn:aws:s3:::"]
        }
      ]
    },
    {
      "read_write_type"           = "WriteOnly"
      "include_management_events" = false
      "data_resources" = [
        {
          type   = "AWS::S3::Object"
          values = ["${aws_s3_bucket.this.arn}/"]
        }
      ]
    }
  ]
}
