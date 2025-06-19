output "function_arn" {
  description = "ARN of the CloudFront function"
  value       = aws_cloudfront_function.this.arn
}

output "etag" {
  description = "ETag of the CloudFront function"
  value       = aws_cloudfront_function.this.etag
}