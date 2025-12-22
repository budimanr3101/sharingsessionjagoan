# CIDR Secondary Association
resource "aws_vpc_ipv4_cidr_block_association" "vpc_secondary_cidr" {
  vpc_id     = data.aws_vpc.selected.id
  cidr_block = var.eks_vpc_secondary_cidr_block
}

# Subnet for CIDR Secondary
resource "aws_subnet" "vpc_secondary_cidr_subnets" {
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.vpc_secondary_cidr
  ]
  count = var.number_of_az
  vpc_id     = data.aws_vpc.selected.id
  availability_zone = local.lc_name_list[count.index]
  cidr_block = var.eks_vpc_secondary_cidr_subnet_blocks[count.index]

  tags = {
    Name = format("%s-%s-%s-subnet-%s", var.env_prefix, var.app_prefix, "eks-pod", local.suffix_az[count.index])
    SubnetType = "EKSPod"
  }
}

resource "aws_route_table_association" "pod_subnet_rt_attach" {
  depends_on = [ aws_subnet.vpc_secondary_cidr_subnets ]
  count = var.number_of_az
  subnet_id      = aws_subnet.vpc_secondary_cidr_subnets[count.index].id
  route_table_id = data.aws_route_table.private_route_tables[count.index].id 
}

resource "aws_network_acl_association" "pod_subnet_nacl_assoc" {
  depends_on = [ aws_subnet.vpc_secondary_cidr_subnets ]
  count = var.number_of_az
  subnet_id      = aws_subnet.vpc_secondary_cidr_subnets[count.index].id
  network_acl_id = data.aws_network_acls.private_nacl.ids[0]
}
