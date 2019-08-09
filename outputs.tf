# CloudTrail
output "cloudtrail_id" {
  description = "The name of the trail"
  value       = "${join("", aws_cloudtrail.this.*.id)}"
}

output "cloudtrail_home_region" {
  description = "The region in which the trail was created"
  value       = "${join("", aws_cloudtrail.this.*.home_region)}"
}

output "cloudtrail_arn" {
  description = "The Amazon Resource Name of the trail"
  value       = "${join("", aws_cloudtrail.this.*.arn)}"
}
