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
variable "vpc_selection_tags" {
  description = "Tag to be used to select existing VPC to be used to deploy AWS resources"
  type        = map(string)
}

variable "private_subnet_selection_tags" {
  description = "Tag to be used to select existing Private Subnets in the VPC to be used to deploy EC2 Instances"
  type        = map(string)
}

variable "private_nacl_selection_tags" {
  description = "Tag to be used to select existing NACL for Private Subnets in the VPC"
  type        = map(string)
}

variable "number_of_az" {
  description = "Number of AZs"
  type        = number
}

variable "eks_vpc_secondary_cidr_block" {
  type = string
}

variable "eks_vpc_secondary_cidr_subnet_blocks" {
}