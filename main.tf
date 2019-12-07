provider "aws" {}

### LOCALS ###
locals {
  create_log_group            = var.cloud_watch_logs_group_name == null
  cloud_watch_logs_group_name = local.create_log_group ? "/aws/cloudtrail/${format("%v", var.cloudtrail_name)}" : var.cloud_watch_logs_group_name
  cloud_watch_logs_group_arn  = local.create_log_group ? join("", aws_cloudwatch_log_group.this.*.arn) : data.aws_cloudwatch_log_group.this[0].arn

  create_log_group_role     = var.cloud_watch_logs_role_arn == null
  cloud_watch_logs_role_arn = local.create_log_group_role ? join("", aws_iam_role.this.*.arn) : var.cloud_watch_logs_role_arn
}

### RESOURCES ###
# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudtrail && local.create_log_group ? 1 : 0

  name              = local.cloud_watch_logs_group_name
  retention_in_days = var.retention_in_days
}

# Create IAM Policy
resource "aws_iam_policy" "this" {
  count = var.create_cloudtrail && local.create_log_group_role ? 1 : 0

  name   = var.cloudtrail_name
  policy = data.aws_iam_policy_document.write_logs[0].json
}

# Create IAM Role
resource "aws_iam_role" "this" {
  count = var.create_cloudtrail && local.create_log_group_role ? 1 : 0

  name               = var.cloudtrail_name
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = var.tags
}

# Attach Policy to IAM Role
resource "aws_iam_policy_attachment" "this" {
  count = var.create_cloudtrail && local.create_log_group_role ? 1 : 0

  name       = var.cloudtrail_name
  roles      = [aws_iam_role.this[0].name]
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_cloudtrail" "this" {
  count = var.create_cloudtrail ? 1 : 0

  name                       = var.cloudtrail_name
  s3_bucket_name             = var.cloudtrail_bucket
  enable_log_file_validation = true
  is_multi_region_trail      = true
  tags                       = var.tags

  cloud_watch_logs_group_arn = local.cloud_watch_logs_group_arn
  cloud_watch_logs_role_arn  = local.cloud_watch_logs_role_arn

  dynamic "event_selector" {
    iterator = event_selectors
    for_each = var.event_selectors
    content {
      read_write_type           = lookup(event_selectors.value, "read_write_type", "All")
      include_management_events = lookup(event_selectors.value, "include_management_events", "true")

      dynamic "data_resource" {
        iterator = data_resources
        for_each = lookup(event_selectors.value, "data_resources", [])
        content {
          type   = lookup(data_resources.value, "type", null)
          values = lookup(data_resources.value, "values", [])
        }
      }
    }
  }
}

### DATA SOURCES ###
data "aws_partition" "current" {
  count = var.create_cloudtrail ? 1 : 0
}

data "aws_region" "current" {
  count = var.create_cloudtrail ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = var.create_cloudtrail ? 1 : 0
}

data "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudtrail && ! local.create_log_group ? 1 : 0

  name = var.cloud_watch_logs_group_name
}

data "aws_iam_policy_document" "assume_role" {
  count = var.create_cloudtrail && local.create_log_group_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "write_logs" {
  count = var.create_cloudtrail && local.create_log_group_role ? 1 : 0

  statement {
    sid = "WriteCloudWatchLogs"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:${data.aws_partition.current[0].partition}:logs:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:log-group:${local.cloud_watch_logs_group_name}:log-stream:*"
    ]
  }
}
