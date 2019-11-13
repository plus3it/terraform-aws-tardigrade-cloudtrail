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
