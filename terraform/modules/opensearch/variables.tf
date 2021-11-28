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

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "opensearch_version" {
  type    = string
  default = "OpenSearch_1.0"
}

variable "opensearch_data_instance_count" {
  type    = number
  default = 0
}

variable "opensearch_data_instance_type" {
  type    = string
  default = "t3.small.elasticsearch"
}

variable "opensearch_data_instance_storage" {
  type    = number
  default = 10
}

variable "opensearch_master_instance_count" {
  type    = number
  default = 0
}

variable "opensearch_master_instance_type" {
  type    = string
  default = "t3.small.elasticsearch"
}

variable "opensearch_encrypt_at_rest" {
  type        = bool
  default     = true
  description = "Default is 'true'. Can be disabled for unsupported instance types."
}

variable "hosted_zone_id" {
  type        = string
  description = "OpenSearch DNS hosted zone id"

}
