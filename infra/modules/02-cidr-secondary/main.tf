module "vpc" {
  source = "./vpc"

  # -------------------------------------------------------
  #  General Prefix and Tags
  # -------------------------------------------------------
  master_prefix = var.master_prefix
  env_prefix    = var.env_prefix
  app_prefix    = var.app_prefix
  tags          = var.tags

  # -------------------------------------------------------
  #  Module's Input Variables
  # -------------------------------------------------------

  # -------------------------------------------------------
  #  Tags for VPC/Subnets Selection tags & Number of AZs
  # -------------------------------------------------------
  number_of_az = var.number_of_az

  vpc_selection_tags = var.vpc_selection_tags

  private_subnet_selection_tags = var.rt_association_subnet_selection_tags

  private_nacl_selection_tags = var.rt_association_nacl_selection_tags

  eks_vpc_secondary_cidr_block = var.vpc_secondary_cidr_block
  eks_vpc_secondary_cidr_subnet_blocks = var.vpc_secondary_cidr_subnet_blocks
}

module "eks" {
  source = "./eks"

 # -------------------------------------------------------
  #  General Prefix and Tags
  # -------------------------------------------------------
  master_prefix = var.master_prefix
  env_prefix    = var.env_prefix
  app_prefix    = var.app_prefix
  tags          = var.tags

  # -------------------------------------------------------
  #  Module's Input Variables
  # -------------------------------------------------------

  # -------------------------------------------------------
  #  Tags for VPC/Subnets Selection tags & Number of AZs
  # -------------------------------------------------------
  number_of_az = var.number_of_az

  vpc_selection_tags = var.vpc_selection_tags

  pod_subnet_selection_tags = var.pod_subnet_selection_tags

  eks_cluster_name = var.eks_cluster_name
}
