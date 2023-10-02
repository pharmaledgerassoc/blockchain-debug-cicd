# --- 2-aws-eks-bootstrap-pla/modules/aws-for-fluent-bit/locals.tf ---

locals {
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.main.account_id}:oidc-provider/${trim(var.oidc_provider_url, "https://")}"
}
