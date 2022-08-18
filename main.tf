### LOCALS ###
locals {
  # cloudwatch log group integration
  use_existing_log_group = var.use_existing_log_group
  create_log_group       = var.use_existing_log_group ? false : var.create_log_group

  cloud_watch_logs_group_name = var.use_existing_log_group ? var.cloud_watch_logs_group_name : var.create_log_group ? var.cloud_watch_logs_group_name == null ? "/aws/cloudtrail/${format("%v", var.cloudtrail_name)}" : var.cloud_watch_logs_group_name : null

  cloud_watch_logs_group_arn = var.use_existing_log_group ? "${data.aws_cloudwatch_log_group.this[0].arn}:*" : var.create_log_group ? "${aws_cloudwatch_log_group.this[0].arn}:*" : null

  create_log_group_role = var.use_existing_log_group ? var.cloud_watch_logs_role_arn == null : var.create_log_group

  cloud_watch_logs_role_arn = var.use_existing_log_group ? var.cloud_watch_logs_role_arn == null ? aws_iam_role.this[0].arn : var.cloud_watch_logs_role_arn : var.create_log_group ? var.cloud_watch_logs_role_arn == null ? aws_iam_role.this[0].arn : var.cloud_watch_logs_role_arn : null

  # kms integration
  kms_key_id     = var.create_kms_key ? module.kms[0].keys[var.kms_key_alias].arn : var.kms_key_id
  kms_key_policy = var.create_kms_key ? data.aws_iam_policy_document.kms_key_policy[0].json : ""

  keys = [
    {
      alias               = var.kms_key_alias,
      description         = var.kms_key_alias,
      policy              = local.kms_key_policy,
      enable_key_rotation = true
    }
  ]
}

### RESOURCES ###
# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  count = local.create_log_group ? 1 : 0

  name              = local.cloud_watch_logs_group_name
  retention_in_days = var.retention_in_days
}

# Create IAM Policy
resource "aws_iam_policy" "this" {
  count = local.create_log_group_role ? 1 : 0

  name   = var.cloudtrail_name
  policy = data.aws_iam_policy_document.write_logs[0].json
}

# Create IAM Role
resource "aws_iam_role" "this" {
  count = local.create_log_group_role ? 1 : 0

  name               = var.cloudtrail_name
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = var.tags
}

# Attach Policy to IAM Role
resource "aws_iam_policy_attachment" "this" {
  count = local.create_log_group_role ? 1 : 0

  name       = var.cloudtrail_name
  roles      = [aws_iam_role.this[0].name]
  policy_arn = aws_iam_policy.this[0].arn
}

module "kms" {
  source = "git::https://github.com/plus3it/terraform-aws-tardigrade-kms.git?ref=2.0.0"
  count  = var.create_kms_key ? 1 : 0

  keys = local.keys
}

resource "aws_cloudtrail" "this" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = var.cloudtrail_bucket
  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging                = var.enable_logging
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  tags                          = var.tags
  kms_key_id                    = local.kms_key_id

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
data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_cloudwatch_log_group" "this" {
  count = local.use_existing_log_group ? 1 : 0

  name = var.cloud_watch_logs_group_name
}

data "aws_iam_policy_document" "assume_role" {
  count = local.create_log_group_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "write_logs" {
  count = local.create_log_group_role ? 1 : 0

  statement {
    sid = "WriteCloudWatchLogs"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloud_watch_logs_group_name}:log-stream:*"
    ]
  }
}

data "aws_iam_policy_document" "kms_key_policy" {
  count = var.create_kms_key ? 1 : 0

  statement {
    sid     = "Enable IAM User Permissions"
    actions = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]
  }

  statement {
    sid     = "Allow CloudTrail to encrypt logs"
    actions = ["kms:GenerateDataKey*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"

      values = [
        "arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
      ]
    }

    resources = ["*"]
  }

  statement {
    sid     = "Allow CloudTrail to describe key"
    actions = ["kms:DescribeKey"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid = "Allow principals in the account to decrypt log files"
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"

      values = [
        "arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    resources = ["*"]
  }
}
