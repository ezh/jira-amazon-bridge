/*
 * # Atlassian JIRA -> Amazon OpenSearch bridge
 *
 * naviteq sandbox environment
 */

terraform {
  backend "s3" {
    bucket = "naviteq-sandbox-tfstate"
    key    = "workload-alexeydemo/terraform.tfstate"
    region = "eu-west-2"
  }
}

module "opensearch" {
  source = "../modules/opensearch"

  hosted_zone_id                 = "Z05919571D0GJVTX3HNPQ"
  name                           = "alexeydemo"
  opensearch_data_instance_count = 1
  opensearch_data_instance_type  = "t3.medium.elasticsearch"
  subnet_ids                     = ["subnet-1ae93c67"]
  vpc_id                         = "vpc-7e087f15"
}

module "opensearch-users" {
  source = "../modules/opensearch-users"

  cognito_user_pool_id = module.opensearch.aws_cognito_user_pool.id
  name                 = "alexeydemo"
  service_password     = var.service_password
  user_mails           = ["alexey@naviteq.io"]
}

module "opensearch-connector" {
  source = "../modules/connector"

  atlassian_host      = var.atlassian_host
  atlassian_password  = var.atlassian_password
  atlassian_user      = var.atlassian_user
  name                = "alexeydemo"
  nproc               = var.nproc
  opensearch_endpoint = module.opensearch.opensearch_endpoint
  schedule            = "cron(0 * * * ? *)"
}
