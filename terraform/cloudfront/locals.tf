locals {
  error_responses_list = [
    for error_code, response in var.error_responses : {
      error_code         = error_code
      response_code      = response.response_code
      response_page_path = response.response_page_path
    }
  ]
}