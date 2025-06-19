module "router" {
  source = "./router"

  name    = "${local.project}-router"
  comment = local.description
}

module "s3" {
  source = "./s3"

  project = local.project
  domain  = local.domain

  bucket_name = var.bucket_name
  shared_tags = local.tags
}

module "cf" {
  source = "./cloudfront"

  bucket_id     = module.s3.id
  bucket_arn    = module.s3.arn
  bucket_domain = module.s3.domain

  project        = local.project
  description    = local.description
  domain_aliases = [local.domain]

  acm_certificate_arn = var.acm_crt

  req_func_list = [
    {
      function_arn = module.router.function_arn
    }
  ]

  error_responses = {
    403 = {
      response_code      = 404
      response_page_path = "/404.html"
    },
    404 = {
      response_code      = 404
      response_page_path = "/404.html"
    }
  }

  shared_tags = local.tags
  depends_on  = [module.s3]
}