# --- csi-external-snapshotter/main.tf ---

resource "helm_release" "main" {
  name      = "csi-external-snapshotter"
  namespace = "kube-system"

  chart = "${path.module}/files/charts/csi-external-snapshotter"

  values = [<<EOF
image: "${var.image_version}"

EOF
  ]
}
