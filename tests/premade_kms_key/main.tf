data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

module "premade_kms_key" {
  source = "../../"

  create_kms_key = false

  cloudtrail_name   = data.terraform_remote_state.prereq.outputs.random_name
  cloudtrail_bucket = data.terraform_remote_state.prereq.outputs.bucket_id
  kms_key_id        = data.terraform_remote_state.prereq.outputs.kms_key_id
}
