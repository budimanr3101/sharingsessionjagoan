output "subnet" {
  value = module.vpc.subnet
}

output "route-table" {
  value = module.vpc.route-table
}

output "eks-cluster-endpoint" {
  value = module.eks.eks-cluster-endpoint
}

output "eks-cluster-auth-cluster-token" {
    value = module.eks.eks-cluster-auth-cluster-token
}

output "cluster-certificate-authority" {
  value = module.eks.cluster-certificate-authority
}