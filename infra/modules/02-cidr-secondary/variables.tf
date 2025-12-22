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

variable "vpc_selection_tags" {
  description = "Tag to be used to select existing VPC to be used to deploy AWS resources"
  type        = map(string)
}

####################################################################################################
## VPC & EKS Variable Definitions
##############################################################

variable "number_of_az" {
}

variable "rt_association_subnet_selection_tags" {
}

variable "rt_association_nacl_selection_tags" {
}

variable "pod_subnet_selection_tags" {
}

variable "vpc_secondary_cidr_block" {}
variable "vpc_secondary_cidr_subnet_blocks" {}
variable "eks_cluster_name" {}