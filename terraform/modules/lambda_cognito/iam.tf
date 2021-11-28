resource "aws_iam_role" "this" {
  name = "${var.prefix}${var.name}-lambda-cognito-role"
  path = "/${var.prefix}${var.name}/"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowLambdaAssumingRole"
        Effect : "Allow"
        Action : "sts:AssumeRole",
        Principal : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "this" {
  name = "${var.prefix}${var.name}-lambda-cognito-role"
  path = "/${var.prefix}${var.name}/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ])
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
