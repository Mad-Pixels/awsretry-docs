output "id" {
  value     = aws_s3_bucket.this.id
  sensitive = true
}

output "arn" {
  value     = aws_s3_bucket.this.arn
  sensitive = true
}

output "name" {
  value     = "${var.project}-${var.bucket_name}"
  sensitive = true
}

output "domain" {
  value     = aws_s3_bucket.this.bucket_regional_domain_name
  sensitive = true
}