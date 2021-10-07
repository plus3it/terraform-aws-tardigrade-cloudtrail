resource "random_id" "name" {
  byte_length = 6
  prefix      = "terraform-cwl-"
}

resource "random_id" "tardigrade" {
  byte_length = 6
  prefix      = "tardigrade-cloudtrail-"
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name = "Tardigrade/Cloudtrail/${random_id.name.hex}"
}

# Create IAM Policy
resource "aws_iam_policy" "this" {
  name   = random_id.name.hex
  policy = data.aws_iam_policy_document.write_logs.json
}

# Create IAM Role
resource "aws_iam_role" "this" {
  name               = random_id.name.hex
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach Policy to IAM Role
resource "aws_iam_policy_attachment" "this" {
  name       = random_id.name.hex
  roles      = [aws_iam_role.this.name]
  policy_arn = aws_iam_policy.this.arn
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

output "random_name" {
  value = random_id.tardigrade.hex
}

output "cwl_group_name" {
  value = aws_cloudwatch_log_group.this.id
}

output "cwl_role_arn" {
  value = aws_iam_role.this.arn
}
