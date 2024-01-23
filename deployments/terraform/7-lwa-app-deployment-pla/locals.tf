# --- 7-lwa-app-deployment-pla/locals.tf ---

locals {
  timestamp = var.timestamp == "" ? formatdate("YYYYMMDDhhmmss", timestamp()) : var.timestamp

  https_url_environment_js_template = "https://raw.githubusercontent.com/pharmaledgerassoc/LWA/main/environment.js.template"

  fqdn = var.hostname == "" ? var.dns_domain : join(".", [var.hostname, var.dns_domain])

  bdns_url = "https://${local.fqdn}/${local.bdns_json_filename}"

  csp_frame_src               = "https://pharmaledger.org/"
  csp_frame_src_unsafe_hashes = "'sha256-a9WQFev6CZ0GH38JvCWXzczSwvi7wMTbmCWdWaLncC8='"

  csp_script_src_unsafe_hashes = "'sha256-XkPjGMp0z+c11Qt/zG8pIkC1TIiA9lf9XEXevRQbMTU='"

  csp_connect_src = local.bdns_json_url_specified ? "https://${local.fqdn} ${join(" ", [for url in distinct(regexall("https://[^\"/]+", data.http.bdns_json[0].response_body)) : url])}" : "https://${local.fqdn} ${join(" ", [for url in distinct(regexall("https://[^\"/]+", file(local.bdns_json_local_path))) : url])}"

  bdns_json_filename      = "bdns-${local.timestamp}_v${var.app_build_version}.json"
  environment_js_filename = "environment-${local.timestamp}_v${var.app_build_version}.js"

  s3_object_js   = setsubtract(fileset("${path.module}/LWA", "**/*.js"), [local.environment_js_filename, "environment.js", "local_environment.js"])
  s3_object_json = setsubtract(fileset("${path.module}/LWA", "**/*.json"), ["bdns.json", "package.json", "octopus.json", "lib/zxing-wrapper/package.json"])

  bdns_json_url_specified = var.bdns_json_url == "" ? false : true
  bdns_json_local_path    = "../networks/${var.network_name}/bdns.json"

  cloudfront_default_root_object = one(fileset("${path.module}/LWA", "index-*.html"))

  custom_error_response_4xx = flatten([
    for error_code in [400, 403, 404, 405, 414, 416] : [
      {
        error_code            = error_code
        error_caching_min_ttl = 10

        response_code      = error_code
        response_page_path = "/4xx-errors/index.html"
      }
    ]
  ])
}
