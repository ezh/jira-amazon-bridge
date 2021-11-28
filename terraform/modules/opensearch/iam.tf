
####################################################################################################
# Authenticated Role
####################################################################################################
resource "aws_iam_role" "cognito_authenticated" {
  name               = "${var.prefix}${var.name}-cognito-authenticated"
  assume_role_policy = data.aws_iam_policy_document.cognito_authenticated_policy_document.json

  tags = var.tags
}

data "aws_iam_policy_document" "cognito_authenticated_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.this.id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

resource "aws_iam_role_policy" "cognito_authenticated" {
  name = "${var.prefix}${var.name}-cognito-authenticated"
  role = aws_iam_role.cognito_authenticated.id

  policy = data.aws_iam_policy_document.cognito_authenticated.json
}

data "aws_iam_policy_document" "cognito_authenticated" {
  statement {
    effect = "Allow"
    actions = [
      "mobileanalytics:PutEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cognito-sync:*"
    ]
    resources = [
      "arn:aws:cognito-sync:${local.aws_region}:${local.aws_account_id}:identitypool/${aws_cognito_identity_pool.this.id}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cognito-identity:ListIdentityPools"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cognito-identity:*"
    ]
    resources = [
      "arn:aws:cognito-identity:${local.aws_region}:${local.aws_account_id}:identitypool/${aws_cognito_identity_pool.this.id}"
    ]
  }
}

####################################################################################################
# Unauthenticated Role
####################################################################################################
resource "aws_iam_role" "cognito_unauthenticated" {
  name               = "${var.prefix}${var.name}-cognito-unauthenticated"
  assume_role_policy = data.aws_iam_policy_document.cognito_unauthenticated_policy_document.json

  tags = var.tags
}

data "aws_iam_policy_document" "cognito_unauthenticated_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.this.id]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

resource "aws_iam_role_policy" "cognito_unauthenticated" {
  name   = "${var.prefix}${var.name}-cognito-unauthenticated"
  role   = aws_iam_role.cognito_unauthenticated.id
  policy = data.aws_iam_policy_document.cognito_unauthenticated.json
}

data "aws_iam_policy_document" "cognito_unauthenticated" {
  statement {
    effect = "Allow"
    actions = [
      "mobileanalytics:PutEvents"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cognito-sync:*"
    ]
    resources = [
      "arn:aws:cognito-sync:${local.aws_region}:${local.aws_account_id}:identitypool/${aws_cognito_identity_pool.this.id}"
    ]
  }
}

####################################################################################################
# Role enabling OpenSearch to access Cognito
####################################################################################################
resource "aws_iam_role" "cognito_for_opensearch" {
  name               = "${var.prefix}${var.name}-cognito-for-opensearch"
  assume_role_policy = data.aws_iam_policy_document.cognito_for_policy_document.json

  tags = var.tags
}

data "aws_iam_policy_document" "cognito_for_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cognito_for_opensearch" {
  role       = aws_iam_role.cognito_for_opensearch.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}
