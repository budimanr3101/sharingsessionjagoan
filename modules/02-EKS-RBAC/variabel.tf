# modules/02-EKS-RBAC/variables.tf

variable "aws_account_id" {
  description = "ID Akun AWS untuk membangun ARN IAM Role secara dinamis."
  type        = string
}

# TAMBAHKAN VARIABEL INI
variable "cluster_name" {
  description = "Nama cluster EKS untuk membuat Access Entry."
  type        = string
}



variable "rbac_eks" {
  description = "Daftar definisi RBAC untuk membuat IAM Role, Role/ClusterRole, dan Binding."
  type = list(object({
    principal_name = string
    role_name      = string
    
    # --- TAMBAHAN BARU ---
    # Scope bisa "namespace" atau "cluster". Defaultnya "namespace".
    scope          = optional(string, "namespace") 

    # 'namespaces' sekarang opsional, hanya wajib jika scope adalah "namespace"
    namespaces     = optional(list(string), [])
    
    rules = list(object({
      api_groups = list(string)
      resources  = list(string)
      verbs      = list(string)
    }))
  }))
  default = []
}

variable "role_name_prefix" {
  description = "Prefix yang akan ditambahkan saat membangun nama IAM Role."
  type        = string
  default     = "eks-"
}

variable "role_name_suffix" {
  description = "Suffix yang akan ditambahkan saat membangun nama IAM Role."
  type        = string
  default     = "-access-role"
}

