variable "cloudtrail_name" {
  description = "Name of the trail to create"
  type        = string
  default     = null
}

variable "create_kms_key" {
  description = "Controls whether to create a kms key that Cloudtrail will use to encrypt the logs"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Specifies whether log file integrity validation is enabled"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Specifies whether to enable logging if it is configured"
  type        = bool
  default     = true
}

variable "include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Specifies whether the trail is created in the current region or in all regions"
  type        = bool
  default     = true
}

variable "kms_key_alias" {
  description = "(Optional) The display name of the alias"
  type        = string
  default     = "terraform-cloudtrail-kms-key"
}

variable "kms_key_id" {
  description = "(Optional) ARN of the kms key used to encrypt the CloudTrail logs."
  type        = string
  default     = null
}

variable "cloudtrail_bucket" {
  description = "Name of S3 bucket to send CloudTrail logs; bucket must already exist"
  type        = string
  default     = null
}

variable "use_cloud_watch_logs" {
  description = "Specifies whether to use a CloudWatch log group for this trail"
  type        = bool
  default     = true
}

variable "cloud_watch_logs_group_name" {
  description = "(Optional) Name of preexisting log group to use; by default the module will create a log group"
  type        = string
  default     = null
}

variable "cloud_watch_logs_role_arn" {
  description = "(Optional) Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group."
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "(Optional) Specifies the number of days to retain log events in the log group. Only works if module creates the log group"
  type        = number
  default     = 7
}

variable "event_selectors" {
  description = "List of maps specifying `read_write_type`, `include_management_events`, `type`, and `values`. See https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for more information regarding the map vales"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to the cloudtrail resource"
  type        = map(string)
  default     = {}
}
