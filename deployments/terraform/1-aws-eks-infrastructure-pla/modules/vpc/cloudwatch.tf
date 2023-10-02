# --- vpc/cloudwatch.tf ---

resource "aws_cloudwatch_log_group" "main" {
  #checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year

  name = "/aws/vpc/${var.network_name}-${var.cluster_name}/vpc"

  retention_in_days = 30

  kms_key_id = aws_kms_key.main.arn

  tags = {
    Name    = "/aws/vpc/${var.network_name}-${var.cluster_name}/vpc"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}
