# --- snapscheduler/main.tf ---

resource "kubernetes_namespace" "main" {
  metadata {
    name = "snapscheduler"
  }
}

resource "helm_release" "main" {
  depends_on = [
    kubernetes_namespace.main
  ]

  name      = "snapscheduler"
  namespace = "snapscheduler"

  repository = "https://backube.github.io/helm-charts"
  chart      = "snapscheduler"
  version    = var.helm_chart_version

  values = [<<EOF
replicaCount: 2

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 10m
    memory: 128Mi

securityContext:
  privileged: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 65534
  runAsGroup: 65534

podSecurityContext:
  runAsUser: 65534
  runAsGroup: 65534
  fsGroup: 65534
  seccompProfile:
    type: RuntimeDefault
EOF
  ]
}