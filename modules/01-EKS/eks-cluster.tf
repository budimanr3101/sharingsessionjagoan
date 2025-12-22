module "eks-cluster" {
  # checkov:skip=CKV_TF_1: ADD REASON
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31" # VERSI new

  cluster_name    = format("%s-%s-%s-eks", var.master_prefix, var.env_prefix, var.app_prefix)
  cluster_version = var.eks_cluster_spec.eks_cluster_version

  kms_key_administrators = var.kms_key_administrators
  create_kms_key         = var.create_kms_key 


  cluster_encryption_config = {
    provider_key_arn = var.create_kms_key ? null : var.cluster_encryption_config.provider_key_arn
    resources        = var.cluster_encryption_config.resources
  }
  # ===================================================================

  cluster_endpoint_public_access  = var.eks_cluster_spec.eks_enable_public_endpoint
  cluster_endpoint_private_access = var.eks_cluster_spec.eks_enable_private_endpoint
  enable_irsa                     = true

  cluster_addons = {
    vpc-cni = {
      most_recent      = true
      resolve_conflicts = "PRESERVE" # 
    }
    coredns = {
      most_recent      = true
      resolve_conflicts = "PRESERVE" # 
    }
    kube-proxy = {
      most_recent      = true
      resolve_conflicts = "PRESERVE" # 
    }
    aws-ebs-csi-driver = {
      most_recent      = true
      resolve_conflicts = "PRESERVE" # 
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids


  node_security_group_enable_recommended_rules = var.node_security_group_enable_recommended_rules
  cluster_security_group_additional_rules = var.cluster_security_group_additional
  node_security_group_additional_rules    = var.node_security_group_additional_rules

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2023_x86_64_STANDARD"
    capacity_type           = "ON_DEMAND"
    ebs_optimized           = true
    disable_api_termination = false
    enable_monitoring       = true

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = var.eks_cluster_spec.eks_node_ebs_size
          volume_type           = var.eks_cluster_spec.eks_node_ebs_type
          iops                  = var.eks_cluster_spec.eks_node_ebs_iops
          throughput            = var.eks_cluster_spec.eks_node_ebs_throughput
          encrypted             = true
          kms_key_id            = "arn:aws:kms:ap-southeast-3:381491966185:key/5cda741c-05c5-49ee-b394-03debf7a4439"
          delete_on_termination = true
        }
      }
    }

    iam_role_additional_policies = {
      AmazonEKSWorkerNodePolicy    = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      AmazonEKS_CNI_Policy         = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      CloudWatchAgentAdminPolicy   = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
      AWSLoadBalancerController    = aws_iam_policy.aws_load_balancer_controller.arn
      CmkCentralicedAccount        = aws_iam_policy.sharedCMK.arn
    }

    use_name_prefix            = true
    use_custom_launch_template = true
    ami_id                     = var.eks_cluster_spec.eks_node_ami_id
    enable_bootstrap_user_data = true
  }

  eks_managed_node_groups = var.eks_cluster_spec.eks_managed_node_groups

  # PENGGANTI aws-auth-configmap
  # Memberikan akses admin kepada IAM principal yang membuat cluster
  enable_cluster_creator_admin_permissions = false

  access_entries = {
    # Konversi dari aws_auth_roles
    infra_admin = {
      principal_arn = aws_iam_role.infra_role.arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  authentication_mode = "API_AND_CONFIG_MAP" 

  cluster_enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  cloudwatch_log_group_retention_in_days = var.eks_cluster_spec.cloudwatch_log_group_retention_in_days

  tags = var.tags
}