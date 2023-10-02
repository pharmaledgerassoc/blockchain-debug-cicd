# --- aws-loadbalancer-controller/locals.tf ---

locals {
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.main.account_id}:oidc-provider/${trim(var.oidc_provider_url, "https://")}"
}
