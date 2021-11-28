/*
Before creating the first OpenSearch cluster, ensure the service linked role exists.
If it doesn't, it can be created using following AWS CLI command:
$ aws iam create-service-linked-role --aws-service-name es.amazonaws.com
*/
resource "null_resource" "opensearch_service_linked_role" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-COMMAND
      aws iam create-service-linked-role --aws-service-name es.amazonaws.com
    COMMAND
    on_failure  = continue
  }
}

data "aws_iam_role" "opensearch_service_linked_role" {
  name = "AWSServiceRoleForAmazonOpenSearchService"

  depends_on = [
    null_resource.opensearch_service_linked_role
  ]
}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = "${var.prefix}${var.name}"
  elasticsearch_version = var.opensearch_version

  cluster_config {
    instance_count           = var.opensearch_data_instance_count
    instance_type            = var.opensearch_data_instance_type
    dedicated_master_enabled = var.opensearch_master_instance_count > 0
    dedicated_master_count   = var.opensearch_master_instance_count
    dedicated_master_type    = var.opensearch_master_instance_type
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.opensearch_data_instance_storage
  }

  encrypt_at_rest {
    enabled = var.opensearch_encrypt_at_rest
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    custom_endpoint                 = "${var.prefix}${var.name}.${data.aws_route53_zone.this.name}"
    custom_endpoint_certificate_arn = aws_acm_certificate.this.arn
    custom_endpoint_enabled         = true
    enforce_https                   = true
    tls_security_policy             = "Policy-Min-TLS-1-0-2019-07"
  }

  access_policies = data.aws_iam_policy_document.opensearch_access_policies.json

  cognito_options {
    enabled          = true
    user_pool_id     = aws_cognito_user_pool.this.id
    identity_pool_id = aws_cognito_identity_pool.this.id
    role_arn         = aws_iam_role.cognito_for_opensearch.arn
  }

  /*
  This is needed due to the issue with the AWS Terraform provider, as can be seen in the link below:
  https://github.com/hashicorp/terraform-provider-aws/issues/5557
  */
  /*
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-COMMAND
      sleep 10 # Give some time for the endpoint to become available
      aws cognito-idp update-user-pool-client \
        --user-pool-id ${aws_cognito_user_pool.this.id} \
        --client-id ${aws_cognito_user_pool_client.this.id} \
        --supported-identity-providers "COGNITO" \
        --callback-urls "https://${self.kibana_endpoint}app/kibana" \
        --logout-urls "https://${self.kibana_endpoint}app/kibana" \
        --allowed-o-auth-flows "code" \
        --allowed-o-auth-scopes "email" "openid" \
        --allowed-o-auth-flows-user-pool-client \
        --region ${local.aws_region}
    COMMAND
  }
  */

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_logs.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  tags = var.tags

  depends_on = [
    data.aws_iam_role.opensearch_service_linked_role,
    aws_acm_certificate_validation.this
  ]
}

data "aws_iam_policy_document" "opensearch_access_policies" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cognito_authenticated.arn]
    }
    actions = [
      "es:ESHttp*"
    ]
    resources = [
      "arn:aws:es:${local.aws_region}:${local.aws_account_id}:domain/${var.prefix}${var.name}/*"
    ]
  }
}

####################################################################################################
# Logs
####################################################################################################

resource "aws_cloudwatch_log_group" "opensearch_logs" {
  name = "opensearch/${var.prefix}${var.name}"
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_logs" {
  policy_name     = "${var.prefix}${var.name}-opensearch-logs"
  policy_document = data.aws_iam_policy_document.opensearch_logs.json
}

data "aws_iam_policy_document" "opensearch_logs" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream",
    ]
    resources = [
      "arn:aws:logs:*"
    ]
  }
}

####################################################################################################
# Certificate
####################################################################################################

resource "aws_acm_certificate" "this" {
  domain_name       = "${var.prefix}${var.name}.${data.aws_route53_zone.this.name}"
  validation_method = "DNS"
  subject_alternative_names = [
    "${var.prefix}${var.name}.${data.aws_route53_zone.this.name}"
  ]

  tags = var.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [subject_alternative_names]
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
