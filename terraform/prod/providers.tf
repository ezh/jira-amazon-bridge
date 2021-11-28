#Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 1.0"
}
