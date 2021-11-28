/*
 * # OpenSearch users module
 *
 * creates OpenSearch users with CloudFormation helper
 */
 
 resource "aws_cloudformation_stack" "users" {
  for_each = var.user_mails

  name = "${var.prefix}${var.name}-user-${replace(lower(each.key), "/[^a-z]+/", "")}"

  template_body = templatefile("${path.module}/cf_template.json", {
    user_mail    = lower(each.key)
    user_name    = replace(lower(each.key), "/[^a-z]+/", "")
    user_pool_id = var.cognito_user_pool_id
  })

  on_failure = "DELETE"

  tags = var.tags
}

resource "aws_cloudformation_stack" "service_user" {
  name = "${var.prefix}${var.name}-user-${var.prefix}${var.name}"

  template_body = templatefile("${path.module}/cf_template_silent.json", {
    user_mail    = "${var.prefix}${var.name}@nowhere"
    user_name    = "${var.prefix}${var.name}@nowhere"
    user_pool_id = var.cognito_user_pool_id
  })

  on_failure = "DELETE"

  tags = var.tags

  provisioner "local-exec" {
    command = join(" ",
      ["aws cognito-idp admin-set-user-password",
        "--user-pool-id ${var.cognito_user_pool_id} --permanent",
      "--username '${var.prefix}${var.name}@nowhere' --password ${var.service_password}"]
    )
  }
}
