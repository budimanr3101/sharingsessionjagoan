variable "master_prefix" {
  description = "Master Prefix for all AWS Resources"
  type        = string
}

variable "env_prefix" {
  description = "Environment Prefix for all AWS Resources"
  type        = string
}

variable "app_prefix" {
  description = "Application Prefix for all AWS Resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

# variable "access_entries" {
#   description = "Access Entries"
# }

####################################################################################################
## VPC & Subnets Variable Definitions
####################################################################################################

# variable "protected_subnet_selection_tags" {
#   description = "Tag to be used to select existing Protected Subnets in the VPC to be used to deploy EC2 Instances"
#   type        = map(string)
# }

variable "private_subnet_selection_tags" {
  description = "Tag to be used to select existing Private Subnets in the VPC to be used to deploy EC2 Instances"
  type        = map(string)
}

variable "public_subnet_selection_tags" {
  description = "Tag to be used to select existing Public Subnets in the VPC to be used to deploy EC2 Instances"
  type        = map(string)
}

variable "vpc_selection_tags" {
  description = "Tag to be used to select existing VPC to be used to deploy AWS resources"
  type        = map(string)
}

variable "number_of_az" {
  description = "Number of AZs"
  type        = number
}

####################################################################################################
## CIDRs Variable Definitions
####################################################################################################

# variable "cicd_tools_cidr" {
#   description = "Prefix list of CICD Tools IP Addresses"
# }

# variable "on_prem_cidr" {
#   description = "List of Onpremise CIDRs for EFS access"
#   type        = list(string)
#   default     = [""]
# }

####################################################################################################
## KMS Variable Definitions
####################################################################################################

variable "kms_cmk_prefix" {
  description = "The prefix of KMS-CMK Name"
  type        = string
}

####################################################################################################
## EC2 Instance Variable Definitions
####################################################################################################

# variable "ec2_keypair_name" {
#   description = "The Name of EC2 Keypair"
#   type        = string
# }

# variable "ec2_bastion_spec" {
#   description = "Specifications of Bastion EC2 Instance"
# }

####################################################################################################
## Elasticache Redis Variable Definitions
####################################################################################################

# variable "elasticache_redis_clusters" {
#   description = "List of Elasticache Redis instances to be provisioned"
# }

####################################################################################################
## EKS Cluster Variable Definitions
####################################################################################################

variable "eks_cluster_spec" {
  description = "The specifications for the EKS Cluster"
}

variable "kms_key_administrators" {
  description = "A list of IAM ARNs for key administrators. If no value is provided, the current caller identity is used to ensure at least one key admin is available"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster security group will be provisioned"
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If control_plane_subnet_ids is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  #default = aws_subnet.private_subnet.id
}

variable "control_plane_subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  default     = []
}

# variable "cluster_addons" {
#   description = "List of EKS cluster addons to install"
#   type = map(object({
#     most_recent                 = optional(bool, true)
#     resolve_conficts_on_update = optional(string, "PRESERVE")
#     configuration_values       = optional(string)
#     service_account_role_arn   = optional(string)
#   }))
#   default = {
#     vpc-cni = {
#       most_recent                 = true
#       resolve_conficts_on_update = "PRESERVE"
#     }
#     coredns = {
#       most_recent                 = true
#       resolve_conficts_on_update = "PRESERVE"
#     }
#     kube-proxy = {
#       most_recent                 = true
#       resolve_conficts_on_update = "PRESERVE"
#     }
#     aws-ebs-csi-driver = {
#       most_recent                 = true
#       resolve_conficts_on_update = "PRESERVE"
#     }
#   }
# }

variable "node_security_group_enable_recommended_rules" {
  type        = bool
  description = "List of additional security group rules to add to the node security group created. Set source_cluster_security_group = true inside rules to set the cluster_security_group as source"
}

variable "cluster_security_group_additional" {
  type        = any
  description = "List of additional security group rules to add to the cluster security group created. Set source_node_security_group = true inside rules to set the node_security_group as source"
}

variable "node_security_group_additional_rules" {
  type        = any
  description = "List of additional security group rules to add to the node security group created. Set source_cluster_security_group = true inside rules to set the cluster_security_group as source"
}

variable "authentication_mode" {
  type        = string
  description = "The authentication mode for the cluster."
  # Default value (optional)
  default = "API_AND_CONFIG_MAP"
  # Validation block
  validation {
    condition     = var.authentication_mode == "CONFIG_MAP" || var.authentication_mode == "API" || var.authentication_mode == "API_AND_CONFIG_MAP"
    error_message = "access_type must be one of 'CONFIG_MAP', 'API', or 'API_AND_CONFIG_MAP'."
  }
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

# variable "jenkins_iam_user_name" {
#   type = string
#   description = "jenkins IAM user name"
#   default = "jenkins"
# }

# variable "itoc_grafana_user_name" {
#   type = string
#   description = "ITOC Grafana IAM user name"
#   default = "itoc_grafana"
# }

# variable "terraform_executor_role_name" {
#   type        = string
#   description = "name for terraform executor role, this role will be assume by jenkins worker from devops account"
#   default     = "TerraformExecutor"
# }

# variable "gl_runner_role_name" {
#   type        = string
#   description = "name for Gitlab runner role, this role will be assume by jenkins worker from devops account"
#   # default     = "TerraformExecutor"
# }

# variable "lz_admin_role_name" {
#   type        = string
#   description = "LZ admin role name"
#   # default     = "AWSReservedSSO_LZ-Administrator"
# }

# variable "nbp_on_prem_cidrs" {
#   type        = list(string)
#   description = "list of application onpremise CIDRs"
# }

# variable "k8s_namespaces_create" {
#   description = "List of namespaces to create via Terraform."
#   type        = list(string)
#   default     = []
# }

# variable "k8s_namespaces_rbac" {
#   description = "List of namespaces to apply RBAC (apps-view role)."
#   type        = list(string)
#   default     = []
# }

# variable "enable_rbac" {
#   description = "Enable or disable creation of RBAC and IAM resources"
#   type        = bool
#   default     = true
# }


variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-3"
}

variable "create_kms_key" {
  type = bool
}

variable "cluster_encryption_config" {

}
# variable "kms_key_id" {
#   type = string
# }

variable "enable_cluster_autoscaller" {
  description = "Enable or disable Cluster Autoscaler installation"
  type        = bool
  default     = false
}



variable "enable_adot_role" {
  description = "Enable or disable the installation of AWS Distro for OpenTelemetry Collector"
  type        = bool
  default     = false
}


variable "enable_pod_metrics" {
  description = "Enable ADOT Collector to collect pod-level metrics"
  type        = bool
  default     = true 
}

# variable "iam_permissions_boundary_arn" {
#   description = "IAM permissions boundary ARN"
#   type        = string
#   default     = "" # Kosongkan jika tidak digunakan
# }

# variable "ssm_parameters" {
#   description = "List of SSM parameter names"
#   type        = list(string)
#   default     = []
# }

# variable "enable_secret_provider_class" {
#   description = "Enable SecretProviderClass and CSI driver"
#   type        = bool
#   default     = false
# }



