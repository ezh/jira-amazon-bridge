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

variable "dashboard_link" {
  type        = string
  description = "HREF to dashboard"
}

variable "tasks_link" {
  type        = string
  description = "HREF to tasks report"
}

variable "time_link" {
  type        = string
  description = "HREF to time tracking report"
}
