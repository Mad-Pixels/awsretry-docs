data "aws_iam_policy_document" "cloudfront_s3_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${var.bucket_arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project}-oac"
  description                       = "OAC for ${var.bucket_domain}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  policy = data.aws_iam_policy_document.cloudfront_s3_policy.json
  bucket = var.bucket_id
}