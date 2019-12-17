provider "aws" {
  region = "us-east-1"
}

locals {
  partition = "aws"
}

data "aws_caller_identity" "current" {}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-cloudtrail-"
}

resource "aws_s3_bucket" "this" {
  bucket        = random_id.name.hex
  policy        = join("", data.template_file.this.*.rendered)
  force_destroy = true
}

resource "aws_kms_key" "this" {
  policy = join("", data.template_file.kms_policy.*.rendered)
}

data "template_file" "this" {
  template = file("${path.module}/../../templates/cloudtrail-bucket-policy.json")

  vars = {
    bucket    = random_id.name.hex
    partition = local.partition
  }
}

data "template_file" "kms_policy" {
  template = file("${path.module}/../../templates/cloudtrail-kms-key-policy.json")

  vars = {
    account_id = data.aws_caller_identity.current.account_id
  }
}

output "random_name" {
  value = random_id.name.hex
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "kms_key_id" {
  value = aws_kms_key.this.arn
}
