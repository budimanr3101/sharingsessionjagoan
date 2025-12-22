// -----------------------------------------------------------------------------------------------//
// ------------------------------------   TF DATA   ----------------------------------------------//
// -----------------------------------------------------------------------------------------------//

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

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

data "aws_subnets" "private_subnets" {
  tags   = var.private_subnet_selection_tags
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_route_table" "private_route_tables" {
    count = length(data.aws_subnets.private_subnets.ids)
    subnet_id       = data.aws_subnets.private_subnets.ids[count.index]
}

data "aws_network_acls" "private_nacl" {
  vpc_id = data.aws_vpc.selected.id
  tags = var.private_nacl_selection_tags
}