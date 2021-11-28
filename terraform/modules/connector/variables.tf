variable "tags" {
  type    = map(any)
  default = {}
}

variable "name" {
  type        = string
  description = "Name of the deployment"
}

variable "prefix" {
  type        = string
  description = "AWS resources name common prefix"
  default     = "workload-"
}

variable "opensearch_endpoint" {
  type        = string
  description = "OpenSearch endpoint"
}

variable "atlassian_host" {
  type        = string
  description = "Atlassian JIRA URL"
}

variable "atlassian_user" {
  type        = string
  description = "Atlassian JIRA user"
}

variable "atlassian_password" {
  type        = string
  description = "Atlassian JIRA password"
  sensitive   = true
}

variable "nproc" {
  type        = number
  description = "number of parallel routines in lambda"
}

variable "schedule" {
  type    = string
  default = "Lambda EventBridge cron expressions"
}
