resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name              = var.bucket_domain
    origin_id                = "S3-${var.bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  ordered_cache_behavior {
    path_pattern           = "*.css"
    target_origin_id       = "S3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 86400
    default_ttl = 31536000
    max_ttl     = 31536000
  }

  ordered_cache_behavior {
    path_pattern           = "hashmap.json"
    target_origin_id       = "S3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  ordered_cache_behavior {
    path_pattern           = "*.js"
    target_origin_id       = "S3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 86400
    default_ttl = 31536000
    max_ttl     = 31536000
  }

  ordered_cache_behavior {
    path_pattern           = "*.woff*"
    target_origin_id       = "S3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = false

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 86400
    default_ttl = 31536000
    max_ttl     = 31536000
  }

  ordered_cache_behavior {
    path_pattern           = "*.png"
    target_origin_id       = "S3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = false

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 86400
    default_ttl = 2592000
    max_ttl     = 31536000
  }

  ordered_cache_behavior {
    path_pattern           = "*.jpg"
    target_origin_id       = "S3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = false

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 86400
    default_ttl = 2592000
    max_ttl     = 31536000
  }

  ordered_cache_behavior {
    path_pattern           = "*.svg"
    target_origin_id       = "S3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 86400
    default_ttl = 2592000
    max_ttl     = 31536000
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_id}"

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    dynamic "function_association" {
      for_each = var.req_func_list

      content {
        event_type   = "viewer-request"
        function_arn = function_association.value.function_arn
      }
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 86400
  }

  dynamic "custom_error_response" {
    for_each = local.error_responses_list

    content {
      error_caching_min_ttl = 30
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(
    var.shared_tags,
    {
      "TF" = "true",
    }
  )

  comment             = var.description
  aliases             = var.domain_aliases
  default_root_object = var.index_document
  price_class         = "PriceClass_All"
  enabled             = true
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${var.project}-security-headers"
  comment = "Security headers policy for VitePress documentation"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      override                   = true
      include_subdomains         = true
      preload                    = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      override     = true
      frame_option = "SAMEORIGIN"
    }

    referrer_policy {
      override        = true
      referrer_policy = "strict-origin-when-cross-origin"
    }

    xss_protection {
      override   = true
      mode_block = true
      protection = true
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "geolocation=(), microphone=(), camera=(), payment=(), usb=()"
      override = true
    }
  }
}