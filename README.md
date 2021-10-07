# terraform-aws-tardigrade-cloudtrail

Creates an AWS Cloudtrail

## Testing

At the moment, testing is manual:

```
# Replace "xxx" with an actual AWS profile, then execute the integration tests.
AWS_PROFILE=xxx make terraform/pytest PYTEST_ARGS="-v --nomock"
```

<!-- BEGIN TFDOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.write_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_watch_logs_group_name"></a> [cloud\_watch\_logs\_group\_name](#input\_cloud\_watch\_logs\_group\_name) | (Optional) Name of preexisting log group to use; by default the module will create a log group | `string` | `null` | no |
| <a name="input_cloud_watch_logs_role_arn"></a> [cloud\_watch\_logs\_role\_arn](#input\_cloud\_watch\_logs\_role\_arn) | (Optional) Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group. | `string` | `null` | no |
| <a name="input_cloudtrail_bucket"></a> [cloudtrail\_bucket](#input\_cloudtrail\_bucket) | Name of S3 bucket to send CloudTrail logs; bucket must already exist | `string` | `null` | no |
| <a name="input_cloudtrail_name"></a> [cloudtrail\_name](#input\_cloudtrail\_name) | Name of the trail to create | `string` | `null` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Controls whether to create a kms key that Cloudtrail will use to encrypt the logs | `bool` | `true` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | Specifies whether log file integrity validation is enabled | `bool` | `true` | no |
| <a name="input_event_selectors"></a> [event\_selectors](#input\_event\_selectors) | List of maps specifying `read_write_type`, `include_management_events`, `type`, and `values`. See https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for more information regarding the map vales | `list(any)` | `[]` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Specifies whether the trail is publishing events from global services such as IAM to the log files | `bool` | `true` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | Specifies whether the trail is created in the current region or in all regions | `bool` | `true` | no |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | (Optional) The display name of the alias | `string` | `"terraform-cloudtrail-kms-key"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (Optional) ARN of the kms key used to encrypt the CloudTrail logs. | `string` | `null` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | (Optional) Specifies the number of days to retain log events in the log group. Only works if module creates the log group | `number` | `7` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the cloudtrail resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | The Amazon Resource Name of the trail |
| <a name="output_cloudtrail_home_region"></a> [cloudtrail\_home\_region](#output\_cloudtrail\_home\_region) | The region in which the trail was created |
| <a name="output_cloudtrail_id"></a> [cloudtrail\_id](#output\_cloudtrail\_id) | The name of the trail |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The KMS Key ARN used to encrypt the logs |
| <a name="output_log_group"></a> [log\_group](#output\_log\_group) | The CloudWatch log group object created when no previous log group is declared |

<!-- END TFDOCS -->
