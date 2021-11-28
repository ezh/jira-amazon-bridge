/*
 * # Atlassian JIRA -> Amazon OpenSearch bridge
 *
 * creates
 * * lambda function
 * * trigger
 */
 
 data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.root}/.terraform/app/"
  output_path = "${path.root}/.terraform/lambda_function.zip"

  depends_on = [
    null_resource.pip_install
  ]
}

data "archive_file" "python" {
  type        = "zip"
  source_dir  = "${path.root}/../../python"
  output_path = "${path.root}/.terraform/python.zip"
}

locals {
  aws_region           = data.aws_region.current.name
  aws_account_id       = data.aws_caller_identity.current.account_id
  function_name        = "${var.prefix}${var.name}-connector"
  cloudwatch_log_group = "/aws/lambda/${local.function_name}"
}

resource "aws_lambda_function" "this" {
  function_name = local.function_name
  handler       = "main.lambda_handler"
  role          = aws_iam_role.this.arn

  publish          = true
  runtime          = "python3.9"
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      OPENSEARCH_URL     = var.opensearch_endpoint
      OPENSEARCH_REGION  = data.aws_region.current.name
      ATLASSIAN_HOST     = var.atlassian_host
      ATLASSIAN_USER     = var.atlassian_user
      ATLASSIAN_PASSWORD = var.atlassian_password
      NPROC              = var.nproc
    }
  }

  depends_on = [
    null_resource.pip_install
  ]
}

resource "null_resource" "pip_install" {
  triggers = {
    src_hash   = sha256(file("${path.root}/../../requirements.txt"))
    python_sha = data.archive_file.python.output_sha
  }

  provisioner "local-exec" {
    command = join("", [
      "mkdir -p ${path.root}/.terraform/app/;",
      "cp ${path.root}/../../python/connector/*.py -t ${path.root}/.terraform/app/;",
      "python3 -mpip install --upgrade -r ${path.root}/../../requirements.txt -t ${path.root}/.terraform/app/;"
    ])
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = local.cloudwatch_log_group
}
