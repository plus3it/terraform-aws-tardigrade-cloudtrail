resource "random_id" "name" {
  byte_length = 6
  prefix      = "terraform-cwl-"
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name = "Tardigrade/Cloudtrail/${random_id.name.hex}"
}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "write_logs" {
  statement {
    sid = "WriteCloudWatchLogs"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.this.id}:log-stream:*"
    ]
  }
}

output "cwl_group_name" {
  value = aws_cloudwatch_log_group.this.id
}
