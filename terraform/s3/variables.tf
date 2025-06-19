variable "project" {
  description = "Project name"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Allows Terraform to delete the bucket when removing the resource"
  type        = bool
  default     = true
}

variable "index_document" {
  description = "Name of the index document for the S3 static web site"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Name of the error document for the S3 static web site"
  type        = string
  default     = "404.html"
}

variable "shared_tags" {
  description = "Tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "domain" {
  description = "Domain for CORS"
  type        = string
}