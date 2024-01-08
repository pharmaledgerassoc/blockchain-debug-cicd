# --- 7-lwa-app-deployment-pla/locals.tf ---

locals {
  https_url_environment_js_template = "https://raw.githubusercontent.com/${var.lwa_repo}/${var.lwa_branch}/environment.js.template"

  fqdn = var.hostname == "" ? var.dns_domain : join(".", [var.hostname, var.dns_domain])

  bdns_url = "https://${local.fqdn}/bdns.json"

  csp_frame_src               = "https://pharmaledger.org/"
  csp_frame_src_unsafe_hashes = "'sha256-a9WQFev6CZ0GH38JvCWXzczSwvi7wMTbmCWdWaLncC8='"

  csp_script_src_unsafe_hashes = "'sha256-XkPjGMp0z+c11Qt/zG8pIkC1TIiA9lf9XEXevRQbMTU='"

  csp_connect_src = local.bdns_json_url_specified ? "${var.bdns_json_url} https://${local.fqdn} ${join(" ", [for url in distinct(regexall("https://[^\"/]+", data.http.bdns_json[0].response_body)) : url])}" : "https://${local.fqdn} ${join(" ", [for url in distinct(regexall("https://[^\"/]+", file(local.bdns_json_local_path))) : url])}"

  s3_object_js   = setsubtract(fileset("${path.module}/LWA", "**/*.js"), ["environment.js"])
  s3_object_json = setsubtract(fileset("${path.module}/LWA", "**/*.json"), ["bdns.json"])

  bdns_json_url_specified = var.bdns_json_url == "" ? false : true
  bdns_json_local_path    = "../networks/${var.network_name}/bdns.json"
}
