locals {
  project     = "awsretry-docs"
  domain      = "awsretry.madpixels.io"
  description = "AWS-Retry docs portal"
  provisioner = "main"
  function    = "${path.root}/.tmpl/awsretry-docs.js"

  tags = {
    "Project"     = local.project,
    "Provisioner" = local.provisioner,
    "Github"      = "https://github.com/Mad-Pixels/awsretry-docs",
  }
}