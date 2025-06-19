variable "project" {
  description = "Project name"
  type        = string
}

variable "description" {
  description = "CloudFront description"
  type        = string
}

variable "bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "bucket_id" {
  description = "S3 bucket ID"
  type        = string
}

variable "bucket_domain" {
  description = "S3 bucket domain"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}

variable "domain_aliases" {
  description = "CloudFront domain aliases"
  type        = list(string)
  default     = []
}

variable "index_document" {
  description = "Name of the index document"
  type        = string
  default     = "index.html"
}

variable "error_responses" {
  description = "Error responses configuration"
  type = map(object({
    response_code      = number
    response_page_path = string
  }))
  default = {}
}

variable "shared_tags" {
  description = "Shared tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "req_func_list" {
  description = "List of viewer-request functions"
  type = list(object({
    function_arn = string
  }))
  default = []
}