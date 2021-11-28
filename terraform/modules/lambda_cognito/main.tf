
locals {
  function_name        = "${var.prefix}${var.name}-cognito"
  cloudwatch_log_group = "/aws/lambda/${local.function_name}"
  python_source        = "${path.root}/../../python/cognito"
  python_destination   = "${path.root}/.terraform/lambda_cognito/"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = local.python_destination
  output_path = "${path.root}/.terraform/lambda_cognito.zip"

  depends_on = [
    null_resource.pip_install
  ]
}

data "archive_file" "python" {
  type        = "zip"
  source_dir  = "${path.root}/../../python/cognito"
  output_path = "${path.root}/.terraform/python_cognito.zip"
}

resource "aws_lambda_function" "this" {
  function_name = local.function_name
  handler       = "main.lambda_handler"
  role          = aws_iam_role.this.arn

  publish          = true
  runtime          = "python3.9"
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout          = 600

  layers = []

  environment {
    variables = {
      APP_NAME       = "${var.prefix}${var.name}"
      DASHBOARD_LINK = var.dashboard_link
      TIME_LINK      = var.time_link
      TASKS_LINK     = var.tasks_link
    }
  }

  tags = var.tags

  depends_on = [
    null_resource.pip_install
  ]
}

resource "null_resource" "pip_install" {
  triggers = {
    src_hash   = sha256(file("${local.python_source}/requirements.txt"))
    python_sha = data.archive_file.python.output_sha
  }

  provisioner "local-exec" {
    command = join("", [
      "mkdir -p \"${local.python_destination}\";",
      "cp \"${local.python_source}\"/* -t \"${local.python_destination}\";",
      "python3 -mpip install --upgrade -r \"${local.python_source}/requirements.txt\" -t \"${local.python_destination}\";"
    ])
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = local.cloudwatch_log_group

  tags = var.tags
}
