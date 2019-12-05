variable "create_cloudtrail" {
  description = "Controls whether to create the CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_name" {
  description = "Name of the trail to create"
  type        = string
  default     = null
}

variable "cloudtrail_bucket" {
  description = "Name of S3 bucket to send CloudTrail logs; bucket must already exist"
  type        = string
  default     = null
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
  type        = list
  default     = []
}

variable "tags" {
  description = "A map of tags to add to the cloudtrail resource"
  type        = map(string)
  default     = {}
}
