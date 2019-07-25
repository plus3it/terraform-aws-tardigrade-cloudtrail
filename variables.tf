variable "create_cloudtrail" {
  description = "Controls whether to create the CloudTrail"
  default     = true
}

variable "cloudtrail_name" {
  description = "Name of the trail to create"
  type        = "string"
  default     = ""
}

variable "cloudtrail_bucket" {
  description = "Name of S3 bucket to send CloudTrail logs; bucket must already exist"
  type        = "string"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to the cloudtrail resource"
  type        = "map"
  default     = {}
}
