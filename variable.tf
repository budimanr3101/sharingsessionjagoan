variable "environment_apps" {
  description = "The application SDLC Environment."
  validation {
    condition = contains(
      ["prod","jagoan"], var.environment_apps
    )
    error_message = "SDLC environment that you put is not in the list."
  }
}


variable "eks" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}


variable "rbac_list" {
  description = "Definisi RBAC yang sederhana untuk tim."
  type        = any # Gunakan 'any' agar lebih fleksibel
  default     = []
}

variable "region" {
  description = "AWS Region"
}

variable "application_name" {
  description = "Application name"
}

############################# VPC & Subnet ################################
variable "vpc_id" {
  description = "The VPC Id"
}

variable "vpc_cidr" {
  description = "The VPC CIDR"
}

##### Subnet CIDR ########
# Public Subnet CIDR
variable "public_subnet_cidr_a" {
  description = "Public Subnet CIDR 1"
}

variable "public_subnet_cidr_b" {
  description = "Public Subnet CIDR 2"
}

# Private Subnet CIDR
variable "private_subnet_cidr_a" {
  description = "Private Subnet CIDR 1"
}

variable "private_subnet_cidr_b" {
  description = "Private Subnet CIDR 2"
}

variable "private_subnet_eks_pod_secondary_cidr" {

}

##### Subnet IDs ########
# Public Subnet IDs
variable "public_subnet_id_a" {
  description = "Public Subnet ID 1"
}

variable "public_subnet_id_b" {
  description = "Public Subnet ID 2"
}

# variable "public_subnet_id_c" {
#   description = "Public Subnet ID 2"
# }

# Private Subnet IDs
variable "private_subnet_id_a" {
  description = "Private Subnet ID 1"
}

variable "private_subnet_id_b" {
  description = "Private Subnet ID 2"
}

# variable "private_subnet_eks_pod_id_a" {

# }

# variable "private_subnet_eks_pod_id_b" {

# }


variable "app_master_prefix" {

}

variable "project_prefix" {
  type = string
}


# variable "ami_id" {

# }

variable "kms_cmk_arn" {

}