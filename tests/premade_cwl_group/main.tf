provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

locals {
  partition = "aws"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-cloudtrail-"
}

resource "aws_s3_bucket" "this" {
  bucket        = random_id.name.hex
  policy        = join("", data.template_file.this.*.rendered)
  force_destroy = true
}

data "template_file" "this" {
  template = file("${path.module}/../templates/cloudtrail-bucket-policy.json")

  vars = {
    bucket    = random_id.name.hex
    partition = local.partition
  }
}

module "premade_cwl_group" {
  source = "../../"

  providers = {
    aws = aws
  }

  cloudtrail_name             = random_id.name.hex
  cloudtrail_bucket           = aws_s3_bucket.this.id
  cloud_watch_logs_group_name = data.terraform_remote_state.prereq.outputs.cwl_group_name
}
