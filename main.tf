### LOCALS ###
locals {
  # cloudwatch log group integration
  create_log_group            = var.use_cloud_watch_logs ? var.cloud_watch_logs_group_name == null : false
  cloud_watch_logs_group_name = local.create_log_group ? "/aws/cloudtrail/${format("%v", var.cloudtrail_name)}" : var.cloud_watch_logs_group_name
  cloud_watch_logs_group_arn  = var.use_cloud_watch_logs ? local.create_log_group ? "${aws_cloudwatch_log_group.this[0].arn}:*" : "${data.aws_cloudwatch_log_group.this[0].arn}:*" : null

  create_log_group_role     = var.use_cloud_watch_logs ? var.cloud_watch_logs_role_arn == null : false
  cloud_watch_logs_role_arn = local.create_log_group_role ? aws_iam_role.this[0].arn : var.cloud_watch_logs_role_arn

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
  s3_key_prefix                 = var.s3_key_prefix
  enable_log_file_validation    = var.enable_log_file_validation
  enable_logging                = var.enable_logging
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  tags                          = var.tags
  kms_key_id                    = local.kms_key_id

  cloud_watch_logs_group_arn = var.use_cloud_watch_logs ? local.cloud_watch_logs_group_arn : null
  cloud_watch_logs_role_arn  = var.use_cloud_watch_logs ? local.cloud_watch_logs_role_arn : null

  dynamic "event_selector" {
    for_each = var.event_selectors
    content {
      read_write_type           = try(event_selector.value.read_write_type, "All")
      include_management_events = try(event_selector.value.include_management_events, "true")

      dynamic "data_resource" {
        for_each = try(event_selector.value.data_resources, [])
        content {
          type   = try(data_resource.value.type, null)
          values = try(data_resource.value.values, [])
        }
      }
    }
  }

  dynamic "advanced_event_selector" {
    for_each = var.advanced_event_selectors
    content {
      name = try(advanced_event_selector.value.name, null) //optional

      dynamic "field_selector" {
        for_each = try(advanced_event_selector.value.field_selectors, [])
        content {
          field           = try(field_selector.value.field, null)           //required
          equals          = try(field_selector.value.equals, null)          //optional
          not_equals      = try(field_selector.value.not_equals, null)      //optional
          starts_with     = try(field_selector.value.starts_with, null)     //optional
          not_starts_with = try(field_selector.value.not_starts_with, null) //optional
          ends_with       = try(field_selector.value.ends_with, null)       //optional
          not_ends_with   = try(field_selector.value.not_ends_with, null)   //optional
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
  count = var.use_cloud_watch_logs && !local.create_log_group ? 1 : 0

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
