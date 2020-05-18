# terraform-aws-tardigrade-cloudtrail

Creates an AWS Cloudtrail


<!-- BEGIN TFDOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_watch\_logs\_group\_name | (Optional) Name of preexisting log group to use; by default the module will create a log group | `string` | `null` | no |
| cloud\_watch\_logs\_role\_arn | (Optional) Specifies the role for the CloudWatch Logs endpoint to assume to write to a user’s log group. | `string` | `null` | no |
| cloudtrail\_bucket | Name of S3 bucket to send CloudTrail logs; bucket must already exist | `string` | `null` | no |
| cloudtrail\_name | Name of the trail to create | `string` | `null` | no |
| create\_cloudtrail | Controls whether to create the CloudTrail | `bool` | `true` | no |
| create\_kms\_key | Controls whether to create a kms key that Cloudtrail will use to encrypt the logs | `bool` | `true` | no |
| event\_selectors | List of maps specifying `read_write_type`, `include_management_events`, `type`, and `values`. See https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for more information regarding the map vales | `list` | `[]` | no |
| kms\_key\_alias | (Optional) The display name of the alias | `string` | `"terraform-cloudtrail-kms-key"` | no |
| kms\_key\_id | (Optional) ARN of the kms key used to encrypt the CloudTrail logs. | `string` | `null` | no |
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
