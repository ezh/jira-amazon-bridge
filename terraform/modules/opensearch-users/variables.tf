variable "tags" {
  type    = map(any)
  default = {}
}

variable "cognito_user_pool_id" {
  type        = string
  description = "ID of the user pool"
}

variable "user_mails" {
  type        = set(string)
  description = "List of the users"
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

variable "service_password" {
  type        = string
  description = "Service user app@nowhere password"
  sensitive   = true
  validation {
    condition = var.service_password == null || (
      can(regex("[!@#$%^&*()_:;,.]+", var.service_password)) &&
      can(regex("[0-9]+", var.service_password)) &&
      can(regex("[a-z]+", var.service_password)) &&
      can(regex("[A-Z]+", var.service_password)) &&
      length(var.service_password) > 8
    )
    error_message = "The password must contain at least 8 characters, comprising 1 digit, 1 upper-case character, 1 lower-case character and 1 special characters."
  }
}
