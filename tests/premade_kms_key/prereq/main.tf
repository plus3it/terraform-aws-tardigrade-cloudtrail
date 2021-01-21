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
  force_destroy = true

  policy = templatefile(
    "${path.module}/../../templates/cloudtrail-bucket-policy.json",
    {
      bucket    = random_id.name.hex
      partition = local.partition
    }
  )
}

resource "aws_kms_key" "this" {
  policy = templatefile(
    "${path.module}/../../templates/cloudtrail-kms-key-policy.json",
    {
      account_id = data.aws_caller_identity.current.account_id
    }
  )
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
