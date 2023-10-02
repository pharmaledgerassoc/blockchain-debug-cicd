# --- 6-epi-app-deployment-pla/epi.tf ---

data "http" "apihub_json_template" {
  url = local.https_url_apihub_json_template
}
data "template_file" "apihub_json" {
  template = data.http.apihub_json_template.response_body
  vars = {
    oauth_jwks_endpoint    = var.oauth_jwks_endpoint
    issuer                 = var.issuer
    authorization_endpoint = var.authorization_endpoint
    token_endpoint         = var.token_endpoint
    client_id              = var.client_id
    dns_name               = var.dns_name
    client_secret          = var.client_secret
    logout_url             = var.logout_url
    dns_name               = var.dns_name
    enable_oauth           = true
    server_authentication  = true
  }
}

data "aws_route53_zone" "epi" {
  name         = join("", [regex("^[^\\.]+\\.(.+)", var.dns_name)[0], "."])
  private_zone = false
}
resource "aws_acm_certificate" "epi" {
  domain_name       = var.dns_name
  validation_method = "DNS"

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}"
    Network = var.network_name
    Cluster = var.cluster_name
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "epi_acm_verification" {
  for_each = {
    for dvo in aws_acm_certificate.epi.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]

  zone_id = data.aws_route53_zone.epi.zone_id
  ttl     = 60

  allow_overwrite = true
}
resource "aws_acm_certificate_validation" "epi_acm_certificate_validation_waiter" {
  certificate_arn         = aws_acm_certificate.epi.arn
  validation_record_fqdns = [for record in aws_route53_record.epi_acm_verification : record.fqdn]
}

resource "aws_secretsmanager_secret" "epi" {
  #checkov:skip=CKV2_AWS_57:Ensure Secrets Manager secrets should have automatic rotation enabled

  name_prefix = "${var.network_name}-${var.cluster_name}-epi"
  kms_key_id  = aws_kms_key.epi.arn
}
resource "aws_secretsmanager_secret_version" "epi" {
  secret_id = aws_secretsmanager_secret.epi.id
  secret_string = jsonencode({

    envJson = <<EOF
    {
      "PSK_TMP_WORKING_DIR": "tmp",
      "PSK_CONFIG_LOCATION": "../apihub-root/external-volume/config",
      "DEV": false,
      "VAULT_DOMAIN": "${var.vault_domain}",
      "BUILD_SECRET_KEY": "${var.build_secret_key}",
      "BDNS_ROOT_HOSTS": "http://127.0.0.1:8080",
      "OPENDSU_ENABLE_DEBUG": true,
      "SSO_SECRETS_ENCRYPTION_KEY": "${var.sso_secrets_encryption_key}"
    }
    EOF

    apihubJson = data.template_file.apihub_json.rendered
  })
}
resource "aws_secretsmanager_secret_policy" "epi" {
  secret_arn = aws_secretsmanager_secret.epi.arn
  policy     = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "${aws_iam_role.epi.arn}"
      },
      "Action" : ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
      "Resource" : "*"
    }
  ]
}
EOF
}

resource "helm_release" "epi" {
  depends_on = [
    helm_release.ethadapter,
    aws_acm_certificate_validation.epi_acm_certificate_validation_waiter
  ]

  name = "epi"

  repository = local.https_url_helm_charts_repository
  chart      = "epi"
  version    = var.epi_helm_chart_version

  replace = true
  wait    = true
  timeout = 300

  values = [
    data.local_file.epi_info_yaml.content,
    data.local_file.epi_service_yaml.content,
    data.local_file.epi_secretsmanager_yaml.content,

    templatefile("${path.module}/templates/epi-ingress.yaml.tftpl", {
      dns_name           = var.dns_name,
      certificate_arn    = aws_acm_certificate.epi.arn,
      load_balancer_name = "${var.network_name}-${var.cluster_name}-epi"
  })]
}

data "aws_lb" "epi" {
  depends_on = [
    helm_release.epi
  ]

  name = "${var.network_name}-${var.cluster_name}-epi"
}

resource "aws_route53_record" "epi" {
  name = var.dns_name
  type = "A"

  zone_id = data.aws_route53_zone.epi.zone_id

  alias {
    name    = data.aws_lb.epi.dns_name
    zone_id = data.aws_lb.epi.zone_id

    evaluate_target_health = true
  }

  allow_overwrite = true
}
