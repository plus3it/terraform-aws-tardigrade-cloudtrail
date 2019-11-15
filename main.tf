provider "aws" {
}

data "aws_partition" "current" {
}

resource "aws_cloudtrail" "this" {
  count = var.create_cloudtrail ? 1 : 0

  name                       = var.cloudtrail_name
  s3_bucket_name             = var.cloudtrail_bucket
  enable_log_file_validation = true
  is_multi_region_trail      = true
  tags                       = var.tags

  dynamic "event_selector" {
    iterator = event_selectors
    for_each = var.event_selectors
    content {
      read_write_type           = lookup(event_selectors.value, "read_write_type", "All")
      include_management_events = lookup(event_selectors.value, "include_management_events", "true")

      dynamic "data_resource" {
        iterator = data_resources
        for_each = lookup(event_selectors.value, "data_resources", [])
        content {
          type   = lookup(data_resources.value, "type", null)
          values = lookup(data_resources.value, "values", [])
        }
      }
    }
  }
}
