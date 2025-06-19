provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.6.1"
}