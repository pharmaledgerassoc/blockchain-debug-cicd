clusterName: ${cluster_name}

replicaCount: 2

image:
  repository: public.ecr.aws/eks/aws-load-balancer-controller
  tag: ${image_version}

serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}

ingressClassConfig:
  default: true

ingressClassParams:
  create: true
  name: alb
  spec:
    scheme: internet-facing
    ipAddressType: ipv4
    loadBalancerAttributes:
      - key: deletion_protection.enabled
        value: "false"

      - key: routing.http2.enabled
        value: "true"

      - key: routing.http.drop_invalid_header_fields.enabled
        value: "true"

defaultSSLPolicy: ELBSecurityPolicy-FS-1-2-Res-2019-08

region: ${region_name}

vpcId: ${vpc_id}

clusterSecretsPermissions:
  allowAllSecrets: true

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
