# CloudTrail
output "cloudtrail_id" {
  description = "The name of the trail"
  value       = join("", aws_cloudtrail.this.*.id)
}

output "cloudtrail_home_region" {
  description = "The region in which the trail was created"
  value       = join("", aws_cloudtrail.this.*.home_region)
}

output "cloudtrail_arn" {
  description = "The Amazon Resource Name of the trail"
  value       = join("", aws_cloudtrail.this.*.arn)
}

output "log_group" {
  description = "The CloudWatch log group object created when no previous log group is declared"
  value       = length(aws_cloudwatch_log_group.this) > 0 ? aws_cloudwatch_log_group.this[0] : null
}

output "kms_key_id" {
  description = "The KMS Key ARN used to encrypt the logs"
  value       = length(aws_cloudtrail.this) > 0 ? aws_cloudtrail.this[0].kms_key_id : null
}
