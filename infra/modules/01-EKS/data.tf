# -------------------------------------------------------
# AWS General Information
# -------------------------------------------------------

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

# -------------------------------------------------------
# VPC - Subnets
# -------------------------------------------------------
data "aws_vpc" "selected" {
  id = "vpc-0637841ad7277bf2d"
  # tags = var.vpc_selection_tags
  # filter {
  #   name   = "isDefault"
  #   values = [false]
  # }
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# data "aws_subnet_ids" "public_subnets" {
#   tags   = var.public_subnet_selection_tags
#   vpc_id = data.aws_vpc.selected.id
#   filter {
#     name   = "availability-zone"
#     values = local.lc_name_list
#   }
# }

data "aws_subnets" "public_subnets" {
  filter {
    name   = "availability-zone"
    values = local.lc_name_list
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = var.public_subnet_selection_tags
}

# data "aws_subnet_ids" "protected_subnets" {
#   tags   = var.protected_subnet_selection_tags
#   vpc_id = data.aws_vpc.selected.id
#   filter {
#     name   = "availability-zone"
#     values = local.lc_name_list
#   }
# }

# data "aws_subnets" "protected_subnets" {
#   filter {
#     name   = "availability-zone"
#     values = local.lc_name_list
#   }
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.selected.id]
#   }
#   tags = var.protected_subnet_selection_tags
# }


# data "aws_subnet_ids" "private_subnets" {
#   tags   = var.private_subnet_selection_tags
#   vpc_id = data.aws_vpc.selected.id
#   filter {
#     name   = "availability-zone"
#     values = local.lc_name_list
#   }

#   # filter {
#   #   name = "tag:Name"
#   #   values = ["Prod-Web-A", "Prod-Web-B"]
#   # }
# }

data "aws_subnets" "private_subnets" {
  filter {
    name   = "availability-zone"
    values = local.lc_name_list
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  tags = var.private_subnet_selection_tags
}


data "aws_subnet" "private_subnet" {
  for_each = toset(data.aws_subnets.private_subnets.ids)
  id       = each.value
}


#TODO: Enable these if NACL wants to be managed in TF
data "aws_network_acls" "public_nacl" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Purpose = "public"
  }
}

data "aws_network_acls" "private_nacl" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Purpose = "web"
  }
}

data "aws_network_acls" "protected_nacl" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    Purpose = "protected"
  }
}

# data "aws_ssm_parameter" "ssm_parameters_store" {
#   for_each = toset(var.ssm_parameters)

#   name = each.value
# }

### EKS DATA
# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

# # Konfigurasi provider Kubernetes di sini, BUKAN di dalam modul
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

# -------------------------------------------------------
# KMS CMK from LZ
# -------------------------------------------------------
#TODO: Uncomment these KMS-CMK in the real accounts
# data "aws_kms_key" "kms_cmk_sns" {
#   key_id = format("alias/%s", var.kms_cmk_prefix)
# }

# data "aws_kms_key" "kms_cmk_s3" {
#   key_id = format("alias/%s", var.kms_cmk_prefix)
# }

# data "aws_kms_key" "kms_cmk_rds" {
#   key_id = format("alias/%s", var.kms_cmk_prefix)
# }

# data "aws_kms_key" "kms_cmk_ebs" {
#   key_id = format("alias/%s", var.kms_cmk_prefix)
# }

# data "aws_kms_key" "kms_cmk_backup" {
#   key_id = format("alias/%s", var.kms_cmk_prefix)
# }

# data "aws_kms_key" "kms_cmk_app" {
#   key_id = format("alias/%s", var.kms_cmk_prefix)
# }

# # -------------------------------------------------------
# # Parameter Store
# # -------------------------------------------------------
# data "aws_ssm_parameter" "redis_auth_token" {
#   for_each = { for parameter in var.elasticache_redis_clusters : parameter.auth_token_parameter_store_name => parameter }
#   name = each.value.auth_token_parameter_store_name
# }

# # -------------------------------------------------------
# # AMIs
# # -------------------------------------------------------
#TODO: Uncomment these AMI in the real accounts
# data "aws_ami" "amazon_linux_hardened" {
#   most_recent = true

#   owners = ["self"]

#   filter {
#     name   = "name"
#     values = ["hardened-ami"]
#   }
# }


# -------------------------------------------------------
# EC2 User Data Scripts
# -------------------------------------------------------

data "template_file" "bastion_userdata" {
  template = file("${path.module}/userdata-scripts/bastion-userdata.sh")
  # vars = {
  #   "app_env_prefix" = var.env_prefix
  # }
}

# data "aws_iam_role" "terraformexecutor" {
#   name = var.terraform_executor_role_name
# }

# data "aws_iam_role" "gl_runner_role" {
#   name = var.gl_runner_role_name
# }

# data "aws_iam_role" "lz_admin_role" {
#   name = var.lz_admin_role_name
# }

# main.tf

# 1. Definisikan data source cloudinit_config untuk membuat user data MIME multipart
# data "cloudinit_config" "eks_al2023_userdata" {
#   gzip          = false
#   base64_encode = true # EKS Managed Node Groups memerlukan user_data dalam format base64

#   # Bagian pertama: Konfigurasi Node EKS (NodeConfig)
#   part {
#     content_type = "application/node.eks.aws"
#     content = templatefile("${path.module}/userdata-scripts/node_config.yaml.tftpl", {
#       cluster_name             = module.eks-cluster.cluster_name
#       api_server_endpoint      = module.eks-cluster.cluster_endpoint
#       certificate_authority    = module.eks-cluster.cluster_certificate_authority_data
#       # Anda bisa menambahkan variabel lain di sini jika diperlukan
#       max_pods = 110 
#     })
#   }

#   # Bagian kedua: Skrip shell untuk instalasi CloudWatch Agent
#   # part {
#   #   content_type = "text/x-shellscript"
#   #   content = <<-EOT
#   #     #!/bin/bash
#   #     set -ex
      
#   #     echo "EKS Node Bootstrap with NodeConfig complete on AL2023!"

#   #     # Install CloudWatch Agent (AL2023 pakai dnf)
#   #     dnf install -y amazon-cloudwatch-agent

#   #     mkdir -p /opt/aws/amazon-cloudwatch-agent/bin

#   #     cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
#   #     {
#   #       "agent": {
#   #         "metrics_collection_interval": 60,
#   #         "run_as_user": "root"
#   #       },
#   #       "metrics": {
#   #         "namespace": "EKS/Node",
#   #         "append_dimensions": {
#   #           "InstanceId": "$${aws:InstanceId}",
#   #           "ImageId": "$${aws:ImageId}",
#   #           "InstanceType": "$${aws:InstanceType}",
#   #           "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
#   #         },
#   #         "metrics_collected": {
#   #           "cpu": {
#   #             "measurement": [
#   #               "cpu_usage_idle",
#   #               "cpu_usage_iowait",
#   #               "cpu_usage_user",
#   #               "cpu_usage_system"
#   #             ],
#   #             "metrics_collection_interval": 60,
#   #             "totalcpu": true
#   #           },
#   #           "mem": {
#   #             "measurement": [
#   #               "mem_used_percent"
#   #             ],
#   #             "metrics_collection_interval": 60
#   #           },
#   #           "disk": {
#   #             "measurement": [
#   #               "disk_used_percent"
#   #             ],
#   #             "metrics_collection_interval": 60,
#   #             "resources": [
#   #               "*"
#   #             ]
#   #           }
#   #         }
#   #       }
#   #     }
#   #     EOF

#   #     # Start CloudWatch Agent
#   #     /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#   #       -a fetch-config \
#   #       -m ec2 \
#   #       -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
#   #       -s
#   #   EOT
#   # }
# }

# Buat file template untuk NodeConfig
# Simpan ini sebagai: userdata/node_config.yaml.tftpl
# ---
# apiVersion: node.eks.aws/v1alpha1
# kind: NodeConfig
# spec:
#   cluster:
#     name: ${cluster_name}
#     apiServerEndpoint: ${api_server_endpoint}
#     certificateAuthority: ${certificate_authority}
#   kubelet:
#     config:
#       maxPods: ${max_pods}
#     # flags: # Contoh jika Anda perlu menambahkan flag lain
#     # - "--node-labels=project=my-project"
