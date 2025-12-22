# modules/01-EKS/outputs.tf

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks-cluster.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's API server."
  value       = module.eks-cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with the cluster."
  value       = module.eks-cluster.cluster_certificate_authority_data
  sensitive   = true
}

# Anda juga bisa menambahkan output lain yang mungkin berguna nanti
output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks-cluster.cluster_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL of the OIDC provider for the cluster."
  value       = module.eks-cluster.cluster_oidc_issuer_url
}