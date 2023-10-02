# --- 0-common-pla/modules/ecr/main.tf ---

data "aws_caller_identity" "main" {}

module "ecr" {
  for_each = {
    repo1 = "epi-builder"
    repo2 = "epi-runner"
    repo3 = "ethadapter"
    repo4 = "quorum"
  }

  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6.0"

  repository_name = each.value
  repository_type = "private"

  create_registry_policy   = false
  create_repository_policy = false
  create_lifecycle_policy  = false

  repository_encryption_type = "AES256"

  repository_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : { "AWS" : "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root" },
        "Action" : [
          "ecr:*"
        ]
      }
    ]
  })
}
