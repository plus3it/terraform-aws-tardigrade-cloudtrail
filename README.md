# terraform-aws-tardigrade-cloudtrail

Creates an AWS Cloudtrail


<!-- BEGIN TFDOCS -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| cloud\_watch\_logs\_group\_name | (Optional) Name of preexisting log group to use; by default the module will create a log group | `string` | n/a | yes |
| cloud\_watch\_logs\_role\_arn | (Optional) Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group. | `string` | n/a | yes |
| cloudtrail\_bucket | Name of S3 bucket to send CloudTrail logs; bucket must already exist | `string` | n/a | yes |
| cloudtrail\_name | Name of the trail to create | `string` | n/a | yes |
| kms\_key\_id | (Optional) ARN of the kms key used to encrypt the CloudTrail logs. If no ARN is provided, the module will create a KMS key to encrypt with | `string` | n/a | yes |
| create\_cloudtrail | Controls whether to create the CloudTrail | `bool` | `true` | no |
| event\_selectors | List of maps specifying `read_write_type`, `include_management_events`, `type`, and `values`. See https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for more information regarding the map vales | `list` | `[]` | no |
| kms\_key\_alias | (Optional) The display name of the alias | `string` | `"terraform-cloudtrail-kms-key"` | no |
| retention\_in\_days | (Optional) Specifies the number of days to retain log events in the log group. Only works if module creates the log group | `number` | `7` | no |
| tags | A map of tags to add to the cloudtrail resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail\_arn | The Amazon Resource Name of the trail |
| cloudtrail\_home\_region | The region in which the trail was created |
| cloudtrail\_id | The name of the trail |
| kms\_key\_id | The KMS Key ARN used to encrypt the logs |
| log\_group | The CloudWatch log group object created when no previous log group is declared |

<!-- END TFDOCS -->
