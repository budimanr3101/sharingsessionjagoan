# # Tambahkan provider helm
# provider "helm" {
#   kubernetes {
#     host                   = module.eks-cluster.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks-cluster.cluster_certificate_authority_data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       args = [
#         "eks",
#         "get-token",
#         "--cluster-name",
#         module.eks-cluster.cluster_name
#       ]
#     }
#   }
# }

# # Install AWS Load Balancer Controller menggunakan Helm
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.14.1"

#   set {
#     name  = "clusterName"
#     value = module.eks-cluster.cluster_name
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.aws_load_balancer_controller.arn
#   }

#   depends_on = [module.eks-cluster]
# }

# ######################
# # Cluster Autoscaler #
# ######################
# # Install Cluster AutoScaller from Helm Chart
# resource "helm_release" "cluster_autoscaler" {
#   count      = var.enable_cluster_autoscaller ? 1 : 0

#   depends_on = [
#     aws_iam_role.cluster_autoscaler
#   ]
#   namespace  = "kube-system"
#   name       = "cluster-autoscaler"
#   chart      = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   version    = "9.46.6"

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = module.eks-cluster.cluster_name
#   }
#   set {
#     name  = "rbac.serviceAccount.create"
#     value = "true"
#   }

# set {
#   name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#   value = aws_iam_role.cluster_autoscaler[0].arn
# }


# set {
#   name  = "rbac.serviceAccount.name"
#   value = "cluster-autoscaler"
# }

#   set {
#     name  = "awsRegion"
#     value = data.aws_region.current.name
#   }

#   set {
#     name  = "extraArgs.expander"
#     value = "least-waste"
#   }

#   set {
#     name  = "extraArgs.skip-nodes-with-system-pods"
#     value = "false"
#   }

#   set {
#     name  = "extraArgs.aws-use-static-instance-list"
#     value = "true"
#   }

#   set {
#     name  = "replicaCount"
#     value = 3
#   }

#   set {
#     name  = "resources.limits.cpu"
#     value = "100m"
#   }

#   set {
#     name  = "resources.limits.memory"
#     value = "2Gi"
#   }

#   set {
#     name  = "resources.requests.cpu"
#     value = "100m"
#   }

#   set {
#     name  = "resources.requests.memory"
#     value = "500Mi"
#   }
# }

# ######################
# # EFS CSI Driver #
# ######################
# # Install EFS CSI DRIVER from Helm Chart

# # resource "helm_release" "aws_efs_csi_driver" {
# #   name       = "aws-efs-csi-driver"
# #   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
# #   chart      = "aws-efs-csi-driver"
# #   namespace  = "kube-system"
# #   version    = "3.1.9" # Sesuaikan dengan versi stable terbaru

# #   set {
# #     name  = "controller.serviceAccount.create"
# #     value = "true"
# #   }

# #   set {
# #     name  = "controller.serviceAccount.name"
# #     value = "efs-csi-controller-sa"
# #   }

# #   set {
# #     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
# #     value = aws_iam_role.efs_csi_driver.arn
# #   }

# #   depends_on = [module.eks-cluster]
# # }


# # ######################
# # # ADOT telemetry Driver #
# # ######################

# ######################
# # Secret Provider Class Driver #
# ######################
# # Install Secret Provider Class Driver from Helm Chart

# # resource "kubernetes_service_account" "secrets_store_csi_driver" {
# #   count = var.enable_secret_provider_class ? 1 : 0

# #   metadata {
# #     name      = "secrets-store-csi-driver-sa"
# #     namespace = "kube-system"
# #     annotations = {
# #       "eks.amazonaws.com/role-arn" = aws_iam_role.ssm_secrets_store_csi[0].arn
# #     }
# #   }
# # }

# # resource "helm_release" "csi_secrets_store" {
# #   count       = var.enable_secret_provider_class ? 1 : 0
# #   name        = "csi-secrets-store"
# #   repository  = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
# #   chart       = "secrets-store-csi-driver"
# #   namespace   = "kube-system"
# #   version     = "1.5.1"

# #   set {
# #     name  = "syncSecret.enabled"
# #     value = "true"
# #   }

# #   set {
# #     name  = "enableSecretRotation"
# #     value = "true"
# #   }

# #   set {
# #     name  = "linux.enabled"
# #     value = "true"
# #   }

# #   # Tetap biarkan Helm membuat SA
# #   set {
# #     name  = "rbac.serviceAccount.create"
# #     value = "true"
# #   }

# #   set {
# #     name  = "rbac.serviceAccount.name"
# #     value = "secrets-store-csi-driver-sa"
# #   }

# #   set {
# #     name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
# #     value = aws_iam_role.ssm_secrets_store_csi[0].arn
# #   }
# # }

# # resource "helm_release" "provider_aws" {
# #   count       = var.enable_secret_provider_class ? 1 : 0
# #   name        = "secrets-provider-aws"
# #   repository  = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
# #   chart       = "secrets-store-csi-driver-provider-aws"
# #   namespace   = "kube-system"
# #   version     = "1.0.1"
# # }



