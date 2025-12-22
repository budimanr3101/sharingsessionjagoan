module "eks" {
  # checkov:skip=CKV_TF_1: ADD REASON
  # checkov:skip=CKV_TF_2: ADD REASON
  source = "./modules/01-EKS"

  master_prefix = var.app_master_prefix
  env_prefix    = var.environment_apps
  app_prefix    = var.application_name

  kms_cmk_prefix = var.kms_cmk_arn
  vpc_selection_tags = {
    "App" : var.application_name,
    "Environment" : var.environment_apps,
    "Name" : var.eks.resource
  }

  private_subnet_selection_tags = {
    "Subnet" : "Private"
  }

  public_subnet_selection_tags = {
    "Subnet" : "Public"
  }

  number_of_az = var.eks.number_of_az


  ### Add-On Cluster AutoScaller ###
  enable_cluster_autoscaller = false

  ## ADOT Telemetry Add-ons to Cloudwatch Metrics ##
  enable_adot_role   = false ## Default Monitoring node & Cluster Only
  enable_pod_metrics = false

  # enable_secret_provider_class = false 
  # ssm_parameters               = null

  kms_key_administrators = []

  create_kms_key = var.eks.create_kms_key

  cluster_encryption_config = {
    "resources" : [
      "secrets"
    ],
    "provider_key_arn" : var.kms_cmk_arn
  }

  eks_cluster_spec = {
    eks_cluster_version                    = var.eks.cluster_version
    eks_enable_public_endpoint             = var.eks.public_endpoint #Prod Should "false"
    eks_enable_private_endpoint            = var.eks.private_endpoint
    cloudwatch_log_group_retention_in_days = var.eks.log_group_retention_days
    cluster_addons = {
      coredns = {
        preserve          = true
        resolve_conflicts = "PRESERVE"
        most_recent       = true
        configuration_value = {
          tolerations = [
            {
              key      = "CriticalAddonsOnly"
              operator = "Exists"
            },
            {
              key    = "node-role.kubernetes.io/master"
              effect = "Noschedule"
            }
          ]
        }
      }
      kube-proxy = {
        preserve          = true
        resolve_conflicts = "PRESERVE"
        most_recent       = true
        configuration_value = {
          tolerations = [
            {
              key      = "CriticalAddonsOnly"
              operator = "Exists"
            },
            {
              key    = "node-role.kubernetes.io/master"
              effect = "Noschedule"
            }
          ]
        }
      }
      vpc-cni = {
        preserve          = true
        resolve_conflicts = "PRESERVE"
        most_recent       = true
        configuration_value = {
          tolerations = [
            {
              key      = "CriticalAddonsOnly"
              operator = "Exists"
            },
            {
              key    = "node-role.kubernetes.io/master"
              effect = "Noschedule"
            }
          ],
          env = {
            ENABLE_POD_ENI                     = "true"
            AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
            POD_SECURITY_GROUP_ENFORCING_MODE  = "standard"
            ENABLE_PREFIX_DELEGATION           = "true"
          }
        }
      }
      aws-ebs-csi-driver = {
        preserve          = true
        resolve_conflicts = "PRESERVE"
        most_recent       = true
        configuration_value = {
          tolerations = [
            {
              key      = "CriticalAddonsOnly"
              operator = "Exists"
            },
            {
              key    = "node-role.kubernetes.io/master"
              effect = "Noschedule"
            }
          ]
        }
      }
    },
    ### default type used for all EKS Managed Group , and the encrypting doesnt enable for default###
    eks_node_ami_id         = var.eks.node_ami_id
    eks_node_ebs_size       = var.eks.node_ebs_size
    eks_node_ebs_type       = var.eks.node_ebs_type
    eks_node_ebs_iops       = var.eks.node_ebs_iops       #set this value if using gp3 or io1
    eks_node_ebs_throughput = var.eks.node_ebs_throughput #set this value if using gp3 or io1

    #-----------------------------------------------------------------

    eks_managed_node_groups = {
      labs-nodegroup = {
        name = format("%s-%s-node", var.environment_apps, var.application_name)
        ami_type = "AL2023_ARM_64_STANDARD" # ARM BASE
        # ami_type = "AL2023_x86_64_STANDARD" #AMD BASE
        instance_types = [var.eks.instance_type]
        capacity_type  = var.eks.capacity_type 

        min_size     = var.eks.min_size
        max_size     = var.eks.max_size
        desired_size = var.eks.desired_size

        cloudinit_pre_nodeadm = [{
          content_type = "application/node.eks.aws"
          content      = <<-EOT
          ---
          apiVersion: node.eks.aws/v1alpha1
          kind: NodeConfig
          spec:
            kubelet:
              config:
                maxPods: 110
          EOT
        }]

        labels = {
          env = "${var.environment_apps}-${var.application_name}"
        }

        taints = [
          # {
          #   key    = "Env"
          #   value  = "Dev"
          #   effect = "NO_SCHEDULE"
          # }
        ]
      }
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = [var.private_subnet_id_a, var.private_subnet_id_b]

  node_security_group_enable_recommended_rules = false


  cluster_security_group_additional = {

    vpc_access = {
      protocol    = "TCP"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      description = "Allow Kubernetes API Access from VPC"
      cidr_blocks = ["10.0.0.0/16"]
    }
  }

  node_security_group_additional_rules = {
    ingress_secondary_cidr = {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      description = "Allow Kubernetes API Access from VPC Secondary IP"
      cidr_blocks = ["${var.private_subnet_eks_pod_secondary_cidr}"]
    },
    ingress_nodes_ephemeral = {
      description = "Node to node ingress on ephemeral ports"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    ingress_cluster_4443_webhook = {
      description                   = "Cluster API to node 4443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 4443
      to_port                       = 4443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_6443_webhook = {
      description                   = "Cluster API to node 6443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 6443
      to_port                       = 6443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_8443_webhook = {
      description                   = "Cluster API to node 8443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_9443_webhook = {
      description                   = "Cluster API to node 9443/tcp webhook"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    },
    # node_to_elasticache_redis = {
    #   protocol    = "TCP"
    #   from_port   = 16379
    #   to_port     = 16379
    #   type        = "egress"
    #   description = "Allow Kubernetes Service Access Elasticache Redis from VPC Secondary IP"
    #   cidr_blocks = ["${var.vpc_cidr}"]
    # },
    #ALL-Outbound
    egress_all = {
      description      = "Allow all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  }
  
  authentication_mode = "API_AND_CONFIG_MAP" #


  tags = {}
}
