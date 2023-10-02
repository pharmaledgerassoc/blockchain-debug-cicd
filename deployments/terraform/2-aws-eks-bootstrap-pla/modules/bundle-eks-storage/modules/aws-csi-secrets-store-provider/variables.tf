# --- aws-csi-secrets-store-provider/variables.tf ---

# https://artifacthub.io/packages/helm/aws/csi-secrets-store-provider-aws
variable "helm_chart_version" {
  type = string
}

variable "image_version" {
  type = string
}
