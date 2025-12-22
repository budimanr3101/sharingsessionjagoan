locals {
  adjusted_number_of_az = var.number_of_az <= length(data.aws_availability_zones.available.names) ? var.number_of_az : length(data.aws_availability_zones.available.names)
  lc_name_list          = slice(data.aws_availability_zones.available.names, 0, local.adjusted_number_of_az)
  general_prefix        = format("%s-%s-%s", var.master_prefix, var.env_prefix, var.app_prefix)
  # cluster_name = format("%s-%s-%s-eks", var.master_prefix, var.env_prefix, var.app_prefix)

  rds_kms_key = "arn:aws:kms:ap-southeast-3:733406324963:key/5036d2e0-c803-4277-b9fe-2aaa811ab08f"
  ec2_kms_key = "arn:aws:kms:ap-southeast-3:537124962690:key/94ee7551-3c36-424d-9b7c-78483b951386"
}