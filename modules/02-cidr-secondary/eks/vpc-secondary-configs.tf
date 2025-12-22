# module "aws_node_config_for_secondary_cidr" {
#   # source = "magnolia-sre/kubectl-cmd/kubernetes"
#   source = "./kubectl-cmd" #this is the modified version of magnolia-sre/kubectl-cmd/kubernetes module
#   app          = format("%s-%s", var.env_prefix, var.app_prefix)
#   cluster-name = var.eks_cluster_name
#   credentials = {
#     token: {
#       endpoint : data.aws_eks_cluster.cluster.endpoint
#       token : data.aws_eks_cluster_auth.cluster.token
#       ca-certificate : data.aws_eks_cluster.cluster.certificate_authority.0.data
#     }
#   }

#   cmds = [
#     "kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true",
#     # "kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone",
#     "kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone",
#     "kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true"
#   ]

#   destroy-cmds = [
#     "kubectl unset env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true",
#     # "kubectl unset env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone",
#     "kubectl unset env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone",
#     "kubectl unset set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true"
#   ]
# }

# resource "kubernetes_manifest" "eni_configs" {
#   for_each = data.aws_subnet.pod_subnets
#   manifest = yamldecode(templatefile("${path.module}/manifest/eni-config-template.yml", {az_name=each.value.availability_zone, subnet_id=each.value.id}))
# }

# resource "null_resource" "refresh_nodegroup_asg" {
#   depends_on = [
#     module.aws_node_config_for_secondary_cidr,
#     kubernetes_manifest.eni_configs
#   ]
#   for_each = data.aws_eks_node_group.nodegroup
#   provisioner "local-exec" {
#     command = format("aws autoscaling start-instance-refresh --preferences MinHealthyPercentage=0,InstanceWarmup=0,SkipMatching=false --auto-scaling-group-name %s --region ap-southeast-3 ", each.value.resources[0].autoscaling_groups[0].name)
#   }
# }

######
module "aws_node_config_for_secondary_cidr" {
  # source = "magnolia-sre/kubectl-cmd/kubernetes"
  source = "./kubectl-cmd" #this is the modified version of magnolia-sre/kubectl-cmd/kubernetes module
  app          = format("%s-%s", var.env_prefix, var.app_prefix)
  cluster-name = var.eks_cluster_name
  credentials = {
    token: {
      endpoint : data.aws_eks_cluster.cluster.endpoint
      token : data.aws_eks_cluster_auth.cluster.token
      ca-certificate : data.aws_eks_cluster.cluster.certificate_authority.0.data
    }
  }

  cmds = [
    "kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true",
    "kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone",
    "kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true"
  ]

  destroy-cmds = [
    "kubectl unset env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true",
    "kubectl unset env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone",
    "kubectl unset set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true"
  ]
}

resource "kubernetes_manifest" "eni_configs" {
  for_each = data.aws_subnet.pod_subnets
  manifest = yamldecode(templatefile("${path.module}/manifest/eni-config-template.yml", {az_name=each.value.availability_zone, subnet_id=each.value.id}))
}

resource "null_resource" "refresh_nodegroup_asg" {
  depends_on = [
    module.aws_node_config_for_secondary_cidr,
    kubernetes_manifest.eni_configs
  ]
  for_each = data.aws_eks_node_group.nodegroup
  provisioner "local-exec" {
    command = format("aws autoscaling start-instance-refresh --preferences MinHealthyPercentage=0,InstanceWarmup=0,SkipMatching=false --auto-scaling-group-name %s", each.value.resources[0].autoscaling_groups[0].name)
  }
}