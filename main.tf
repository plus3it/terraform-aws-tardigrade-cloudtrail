provider "aws" {
}

data "aws_partition" "current" {
}

resource "aws_cloudtrail" "this" {
  count = var.create_cloudtrail ? 1 : 0

  name                       = var.cloudtrail_name
  s3_bucket_name             = var.cloudtrail_bucket
  enable_log_file_validation = true
  is_multi_region_trail      = true
  tags                       = var.tags

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:${data.aws_partition.current.partition}:lambda"]
    }
  }
}
