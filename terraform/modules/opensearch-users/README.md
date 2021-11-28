<!-- BEGIN_TF_DOCS -->
# OpenSearch users module

creates OpenSearch users with CloudFormation helper

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.service_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_cloudformation_stack.users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#input\_cognito\_user\_pool\_id) | ID of the user pool | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the deployment | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | AWS resources name common prefix | `string` | `"workload-"` | no |
| <a name="input_service_password"></a> [service\_password](#input\_service\_password) | Service user app@nowhere password | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | `{}` | no |
| <a name="input_user_mails"></a> [user\_mails](#input\_user\_mails) | List of the users | `set(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->