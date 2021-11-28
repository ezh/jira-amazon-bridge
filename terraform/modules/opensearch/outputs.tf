output "aws_cognito_user_pool" {
  value = aws_cognito_user_pool.this
}

output "opensearch_endpoint" {
  value = aws_elasticsearch_domain.this.endpoint
}
