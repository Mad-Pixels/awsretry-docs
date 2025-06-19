variable "acm_crt" {
  description = "ACM certificate arn for cloudfront domain"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "bucket_name" {
  description = "Site bucket name"
  type        = string
}