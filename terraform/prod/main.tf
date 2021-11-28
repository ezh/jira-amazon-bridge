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
  custom_messages_lambda         = module.lambda_cognito.lambda_cognito
  opensearch_data_instance_count = 1
  opensearch_data_instance_type  = "t3.medium.elasticsearch"
  subnet_ids                     = ["subnet-1ae93c67"]
  vpc_id                         = "vpc-7e087f15"
}

module "opensearch_users" {
  source = "../modules/opensearch-users"

  cognito_user_pool_id = module.opensearch.aws_cognito_user_pool.id
  name                 = "alexeydemo"
  service_password     = var.service_password
  user_mails           = ["alexey@naviteq.io"]
}

module "lambda_bridge" {
  source = "../modules/lambda_bridge"

  atlassian_host      = var.atlassian_host
  atlassian_password  = var.atlassian_password
  atlassian_user      = var.atlassian_user
  name                = "alexeydemo"
  nproc               = var.nproc
  opensearch_endpoint = module.opensearch.opensearch_endpoint
  schedule            = "cron(0 * * * ? *)"
}

module "lambda_cognito" {
  source = "../modules/lambda_cognito"

  name           = "alexeydemo"
  dashboard_link = "https://workload-alexeydemo.beseder.org/_dashboards/"
  tasks_link     = "https://workload-alexeydemo.beseder.org/_dashboards/goto/1a57b159d5658a911599c8f69ad7849c"
  time_link      = "https://workload-alexeydemo.beseder.org/_dashboards/goto/8a1dcd4d88d5ab9a9c195601f73937c6"
}
