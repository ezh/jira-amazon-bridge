/*
 * # OpenSearch module
 *
 * creates
 * * OpenSearch
 * * Cognito
 * * Route53 CNAME
 * * Certificate
 */
 
 data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  aws_region         = data.aws_region.current.name
  aws_account_id     = data.aws_caller_identity.current.account_id
  identity_pool_name = replace("${var.prefix}${var.name}-opensearch", "-", "_")
}
