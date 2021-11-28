<!-- BEGIN_TF_DOCS -->
# Atlassian JIRA -> Amazon OpenSearch bridge

creates
* lambda function
* trigger

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [null_resource.pip_install](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [archive_file.python](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atlassian_host"></a> [atlassian\_host](#input\_atlassian\_host) | Atlassian JIRA URL | `string` | n/a | yes |
| <a name="input_atlassian_password"></a> [atlassian\_password](#input\_atlassian\_password) | Atlassian JIRA password | `string` | n/a | yes |
| <a name="input_atlassian_user"></a> [atlassian\_user](#input\_atlassian\_user) | Atlassian JIRA user | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the deployment | `string` | n/a | yes |
| <a name="input_nproc"></a> [nproc](#input\_nproc) | number of parallel routines in lambda | `number` | n/a | yes |
| <a name="input_opensearch_endpoint"></a> [opensearch\_endpoint](#input\_opensearch\_endpoint) | OpenSearch endpoint | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | AWS resources name common prefix | `string` | `"workload-"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | n/a | `string` | `"Lambda EventBridge cron expressions"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
