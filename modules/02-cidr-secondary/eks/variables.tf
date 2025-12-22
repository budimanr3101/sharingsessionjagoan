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

####################################################################################################
## VPC & Subnets Variable Definitions
####################################################################################################
variable "pod_subnet_selection_tags" {
  description = "Tag to be used to select existing Pod Subnets in the VPC to be used for the EKS Secondary VPC CIDRs configurations"
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

variable "eks_cluster_name" {
  type = string
}