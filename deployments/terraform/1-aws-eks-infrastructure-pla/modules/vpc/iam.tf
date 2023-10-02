# --- vpc/iam.tf ---

resource "aws_iam_role" "main" {
  name = "${var.network_name}-${var.cluster_name}-vpc-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name    = "${var.network_name}-${var.cluster_name}-vpc-role"
    Network = var.network_name
    Cluster = var.cluster_name
  }
}

resource "aws_iam_role_policy" "main" {
  name = "${var.network_name}-${var.cluster_name}-vpc-policy"
  role = aws_iam_role.main.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.main.arn}"
    }
  ]
}
EOF
}
