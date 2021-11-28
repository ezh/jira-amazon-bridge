####################################################################################################
# Cognito User Pool
####################################################################################################
resource "aws_cognito_user_pool" "this" {
  name = "${var.prefix}${var.name}-opensearch"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.prefix}${var.name}-opensearch-${local.aws_account_id}-${local.aws_region}"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.prefix}${var.name}-opensearch"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = true

  refresh_token_validity               = 30
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "phone", "profile"]
  callback_urls                        = ["https://${var.prefix}${var.name}.${data.aws_route53_zone.this.name}/_dashboards/app/home"]
  logout_urls                          = ["https://${var.prefix}${var.name}.${data.aws_route53_zone.this.name}/_dashboards/app/home"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]

  access_token_validity = 60
  id_token_validity     = 60
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  /*
  supported_identity_providers = ["COGNITO"]

  callback_urls = [
    "https://${data.aws_elasticsearch_domain.aos.kibana_endpoint}app/kibana"
  ]

  logout_urls = [
    "https://${data.aws_elasticsearch_domain.aos.kibana_endpoint}app/kibana"
  ]

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid"]
  allowed_oauth_flows_user_pool_client = true
  */

  /*
  The changes to these properties are ignored because they're set through AWS CLI.
  This is needed due to the issue with the AWS Terraform provider, as can be seen in the link below:
  https://github.com/hashicorp/terraform-provider-aws/issues/5557
  */
  lifecycle {
    ignore_changes = [
      supported_identity_providers,
      callback_urls,
      logout_urls,
      allowed_oauth_flows,
      allowed_oauth_scopes,
      allowed_oauth_flows_user_pool_client
    ]
  }
}

resource "null_resource" "set_cognito_identity_providers" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = <<-COMMAND
      app_clients=(`aws cognito-idp list-user-pool-clients --user-pool-id ${aws_cognito_user_pool.this.id} | jq -r '.UserPoolClients[].ClientId'`)

      providers=''
      for app_client_id in $${app_clients[@]}; do
        providers+=" ProviderName=\"cognito-idp.${local.aws_region}.amazonaws.com/${aws_cognito_user_pool.this.id}\",ClientId=\"$app_client_id\""
      done

      aws cognito-identity update-identity-pool \
        --identity-pool-id "${aws_cognito_identity_pool.this.id}" \
        --identity-pool-name "${local.identity_pool_name}" \
        --no-allow-unauthenticated-identities \
        --cognito-identity-providers $providers
    COMMAND
  }

  depends_on = [
    aws_elasticsearch_domain.this,
    aws_cognito_user_pool_client.this,
    aws_cognito_identity_pool.this
  ]
}

####################################################################################################
# Cognito Identity Pool
####################################################################################################
resource "aws_cognito_identity_pool" "this" {
  identity_pool_name               = local.identity_pool_name
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.this.id
    provider_name = aws_cognito_user_pool.this.endpoint
  }

  tags = var.tags

  # ES Service will create a Cognito provider and Client secret when auth is enabled
  # AWS ES Adds an additional ID Provider when auth is enabled. Ignore or TF will destroy it
  lifecycle {
    ignore_changes = [
      cognito_identity_providers
    ]
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "this" {
  identity_pool_id = aws_cognito_identity_pool.this.id
  roles = {
    "authenticated"   = aws_iam_role.cognito_authenticated.arn
    "unauthenticated" = aws_iam_role.cognito_unauthenticated.arn
  }
}
