### Account Config ###
app_master_prefix = "dana"
environment_apps  = "jagoan"
application_name  = "neon"
project_prefix    = "labtool"
region            = "ap-southeast-3"

####### PVC Detail #########
vpc_id   = "vpc-0637841ad7277bf2d"
vpc_cidr = "10.0.0.0/16"

#### SUBNET CIDR #########
## Public Subnet CIDR ##
public_subnet_cidr_a = "10.0.0.0/20"
public_subnet_cidr_b = "10.0.16.0/20"

## Private Subnet CIDR ##
private_subnet_cidr_a = "10.0.128.0/20"
private_subnet_cidr_b = "10.0.144.0/20"

private_subnet_eks_pod_secondary_cidr = "100.64.0.0/16"

## Protected Subnet CIDR ##

####### SUBNET ID ##########
## Public Subnet ID ##
public_subnet_id_a = "subnet-0b073b12186f056d0"
public_subnet_id_b = "subnet-0109f587a0c486b14"
## Private Subnet ID ##
private_subnet_id_a = "subnet-0dea9fc596a50e27c"
private_subnet_id_b = "subnet-0f702b4e89fb5f74a"

kms_cmk_arn = "arn:aws:kms:ap-southeast-3:381491966185:key/5cda741c-05c5-49ee-b394-03debf7a4439"


### EKS Config #####
eks = {
  resource                 = "eks"
  number_of_az             = 2
  cluster_version          = "1.33"
  public_endpoint          = true #after create change this false
  private_endpoint         = true
  log_group_retention_days = 3
  ami_type                 = "AL2023_ARM_64_STANDARD" ## AL 2023 ARM
  node_ami_id              = ""                       
  node_ebs_size            = 20
  node_ebs_type       = "gp3"
  node_ebs_iops       = 3000
  node_ebs_throughput = 125
  instance_type       = "t4g.medium"
  capacity_type       = "ON_DEMAND"
  min_size            = 1
  max_size            = 1
  desired_size        = 1
  create_kms_key      = false
  kms_key_id          = "arn:aws:kms:ap-southeast-3:381491966185:key/5cda741c-05c5-49ee-b394-03debf7a4439"
}