output "eks-cluster-endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "eks-cluster-auth-cluster-token" {
    value = data.aws_eks_cluster_auth.cluster.token
}

output "cluster-certificate-authority" {
  value = data.aws_eks_cluster.cluster.certificate_authority.0.data
}