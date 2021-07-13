data "aws_partition" "current" {
}

locals {
  partition = "aws"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-cloudtrail-"
}

resource "aws_s3_bucket" "this" {
  bucket        = random_id.name.hex
  force_destroy = true

  policy = templatefile(
    "${path.module}/../templates/cloudtrail-bucket-policy.json",
    {
      bucket    = random_id.name.hex
      partition = local.partition
    }
  )
}

module "multiple_event_selectors" {
  source = "../../"

  cloudtrail_name   = random_id.name.hex
  cloudtrail_bucket = aws_s3_bucket.this.id

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
