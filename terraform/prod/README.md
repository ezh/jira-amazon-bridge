<!-- BEGIN_TF_DOCS -->
# Atlassian JIRA -> Amazon OpenSearch bridge

naviteq sandbox environment

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_opensearch"></a> [opensearch](#module\_opensearch) | ../modules/opensearch | n/a |
| <a name="module_opensearch-connector"></a> [opensearch-connector](#module\_opensearch-connector) | ../modules/connector | n/a |
| <a name="module_opensearch-users"></a> [opensearch-users](#module\_opensearch-users) | ../modules/opensearch-users | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atlassian_host"></a> [atlassian\_host](#input\_atlassian\_host) | Atlassian JIRA URL | `string` | n/a | yes |
| <a name="input_atlassian_password"></a> [atlassian\_password](#input\_atlassian\_password) | Atlassian JIRA password | `string` | n/a | yes |
| <a name="input_atlassian_user"></a> [atlassian\_user](#input\_atlassian\_user) | Atlassian JIRA user | `string` | n/a | yes |
| <a name="input_nproc"></a> [nproc](#input\_nproc) | number of parallel routines in lambda | `number` | n/a | yes |
| <a name="input_service_password"></a> [service\_password](#input\_service\_password) | Service user app@nowhere password | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
