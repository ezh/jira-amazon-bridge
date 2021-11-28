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

variable "service_password" {
  type        = string
  description = "Service user app@nowhere password"
  sensitive = true
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
