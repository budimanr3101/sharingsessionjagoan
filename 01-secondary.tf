module "cidr-secondary" {
  # checkov:skip=CKV_TF_2: ADD REASON
  # checkov:skip=CKV_TF_1: ADD REASON
  source = "./modules/02-cidr-secondary"
  # depends_on = [module.eks]

  # -------------------------------------------------------
  #  General Prefix and Tags
  # -------------------------------------------------------
  master_prefix = "dana"
  env_prefix    = var.environment_apps
  app_prefix    = var.application_name
  tags = {
    # "Environment" : "Prod"
    # "ApplicationName" : "NBDS"
    # "env" : "prod-nmbs"
  }


  # -------------------------------------------------------
  #  Module's Input Variables
  # -------------------------------------------------------

  # -------------------------------------------------------
  #  Tags for VPC/Subnets Selection tags & Number of AZs
  # -------------------------------------------------------
  number_of_az = 2

  vpc_selection_tags = {
    id = "vpc-0637841ad7277bf2d"
  }

  rt_association_subnet_selection_tags = {
    "SubnetType" : "Private"
  }

  rt_association_nacl_selection_tags = {
    "SubnetType" : "Private"
  }

  pod_subnet_selection_tags = {
    "SubnetType" : "EKSPod"
  }

  vpc_secondary_cidr_block         = "100.64.0.0/16"
  vpc_secondary_cidr_subnet_blocks = ["100.64.0.0/17", "100.64.128.0/17"] # Have Spare CIDR 100.64.192.0/18
  eks_cluster_name                 = "dana-jagoan-neon-eks"
}
