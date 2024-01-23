# ---  7-lwa-app-deployment-pla/s3_objects.tf ---

resource "aws_s3_object" "bdns_json" {
  depends_on = [
    local_file.bdns_json
  ]

  bucket        = module.s3_bucket.s3_bucket_id
  key           = local.bdns_json_filename
  source        = "${path.module}/bdns.json"
  etag          = md5(local_file.bdns_json.content)
  content_type  = "application/json"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "environment_js" {
  depends_on = [
    local_file.environment_js
  ]

  bucket        = module.s3_bucket.s3_bucket_id
  key           = local.environment_js_filename
  source        = "${path.module}/environment.js"
  etag          = md5(local_file.environment_js.content)
  content_type  = "application/javascript; charset=utf-8"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "html" {
  for_each = fileset("${path.module}/LWA", "**/*.html")

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "text/html; charset=utf-8"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "svg" {
  for_each = fileset("${path.module}/LWA", "**/*.svg")

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "image/svg+xml"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "css" {
  for_each = fileset("${path.module}/LWA", "**/*.css")

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "text/css"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "js" {
  for_each = local.s3_object_js

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "application/javascript; charset=utf-8"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "json" {
  for_each = local.s3_object_json

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "application/json"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "png" {
  for_each = fileset("${path.module}/LWA", "**/*.png")

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "image/png"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "jpg" {
  for_each = fileset("${path.module}/LWA", "**/*.jpg")

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "image/jpg"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "woff" {
  for_each = fileset("${path.module}/LWA", "**/*.woff")

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "font/woff"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "woff2" {
  for_each = fileset("${path.module}/LWA", "**/*.woff2")

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "font/woff2"
  cache_control = "public, max-age=15768000"
}

resource "aws_s3_object" "ttf" {
  for_each = fileset("${path.module}/LWA", "**/*.ttf")

  bucket        = module.s3_bucket.s3_bucket_id
  key           = each.value
  source        = "${path.module}/LWA/${each.value}"
  etag          = filemd5("${path.module}/LWA/${each.value}")
  content_type  = "application/octet-stream"
  cache_control = "public, max-age=15768000"
}
