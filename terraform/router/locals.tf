locals {
  versions_config = jsondecode(file("${path.module}/../../versions.json"))

  locale_mapping = {
    for locale in local.versions_config.locales :
    locale.code => locale.countries
  }
}