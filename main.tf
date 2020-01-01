provider "aws" {}

### LOCALS ###
locals {
  create_log_group            = var.cloud_watch_logs_group_name == null
  cloud_watch_logs_group_name = local.create_log_group ? "/aws/cloudtrail/${format("%v", var.cloudtrail_name)}" : var.cloud_watch_logs_group_name
  cloud_watch_logs_group_arn  = local.create_log_group ? join("", aws_cloudwatch_log_group.this.*.arn) : data.aws_cloudwatch_log_group.this[0].arn

  create_log_group_role     = var.cloud_watch_logs_role_arn == null
  cloud_watch_logs_role_arn = local.create_log_group_role ? join("", aws_iam_role.this.*.arn) : var.cloud_watch_logs_role_arn

  kms_key_alias  = "terraform-cloudtrail-kms-key"
  create_kms_key = var.create_cloudtrail && var.kms_key_id == null
  kms_key_id     = local.create_kms_key ? module.kms.keys[local.kms_key_alias].arn : var.kms_key_id
  kms_key_policy = local.create_kms_key ? data.aws_iam_policy_document.kms_key_policy[0].json : ""

  keys = [
    {
      alias       = local.kms_key_alias,
      description = local.kms_key_alias,
      policy      = local.kms_key_policy
    }
  ]
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

module "kms" {
  source = "git::https://github.com/plus3it/terraform-aws-tardigrade-kms.git?ref=0.0.1"

  providers = {
    aws = aws
  }

  create_keys = local.create_kms_key
  keys        = local.keys
}


resource "aws_cloudtrail" "this" {
  count = var.create_cloudtrail ? 1 : 0

  name                       = var.cloudtrail_name
  s3_bucket_name             = var.cloudtrail_bucket
  enable_log_file_validation = true
  is_multi_region_trail      = true
  tags                       = var.tags
  kms_key_id                 = local.kms_key_id

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

data "aws_iam_policy_document" "kms_key_policy" {
  count = local.create_kms_key ? 1 : 0

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
        "arn:${data.aws_partition.current[0].partition}:cloudtrail:*:${data.aws_caller_identity.current[0].account_id}:trail/*"
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
        "arn:${data.aws_partition.current[0].partition}:cloudtrail:*:${data.aws_caller_identity.current[0].account_id}:trail/*"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"

      values = [
        "${data.aws_caller_identity.current[0].account_id}"
      ]
    }

    resources = ["*"]
  }
}
