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

module "baseline" {
  source = "../../"

  create_kms_key    = false
  cloudtrail_name   = random_id.name.hex
  cloudtrail_bucket = aws_s3_bucket.this.id
}
