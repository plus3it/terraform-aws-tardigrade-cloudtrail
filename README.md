# terraform-aws-tardigrade-cloudtrail

Creates an AWS Cloudtrail

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cloudtrail\_bucket | Name of S3 bucket to send CloudTrail logs; bucket must already exist | string | `"null"` | no |
| cloudtrail\_name | Name of the trail to create | string | `"null"` | no |
| create\_cloudtrail | Controls whether to create the CloudTrail | bool | `"true"` | no |
| tags | A map of tags to add to the cloudtrail resource | map(string) | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail\_arn | The Amazon Resource Name of the trail |
| cloudtrail\_home\_region | The region in which the trail was created |
| cloudtrail\_id | The name of the trail |

