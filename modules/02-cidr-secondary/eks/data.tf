// -----------------------------------------------------------------------------------------------//
// ------------------------------------   TF DATA   ----------------------------------------------//
// -----------------------------------------------------------------------------------------------//
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

# -------------------------------------------------------
# VPC - Subnets
# -------------------------------------------------------
data "aws_vpc" "selected" {
  id = "vpc-0637841ad7277bf2d"
  # tags = var.vpc_selection_tags
  # filter {
  #   name   = "isDefault"
  #   values = [false]
  # }
}

data "aws_subnets" "pod_subnets" {
  tags   = var.pod_subnet_selection_tags
  filter {
    name   = "availability-zone"
    values = local.lc_name_list
  }
}

data "aws_subnet" "pod_subnets" {
  for_each = toset(data.aws_subnets.pod_subnets.ids)
  id       = each.value
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name

  lifecycle {
    postcondition {
      condition     = self.status == "ACTIVE"
      error_message = "EKS cluster ${var.eks_cluster_name} is not active yet"
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_node_groups" "nodegroup_list" {
  cluster_name = var.eks_cluster_name
}

data "aws_eks_node_group" "nodegroup" {
  for_each = data.aws_eks_node_groups.nodegroup_list.names
  cluster_name    = var.eks_cluster_name
  node_group_name = each.value
}
