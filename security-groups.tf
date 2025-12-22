# #############################
# module "sg_alb_ingress" {
#   source         = "../../../modules/security-group"
#   sg_name        = format("%s-%s-alb-ingress", var.environment_apps, var.application_name)
#   sg_description = "SG for ALB Ingress EKS Cluster"
#   vpc_id         = var.vpc_id

#   ingress_rules = [
#     {
#       protocol                  = "TCP"
#       port                      = "443"
#       source_security_group_ids = "sg-0c3cd44a5364c2d57"
#     },
#     {
#       protocol                  = "TCP"
#       port                      = "80"
#       source_security_group_ids = "sg-0c3cd44a5364c2d57"
#     },
#   ]
#   egress_rules = [
#     {
#       protocol         = "-1"
#       port             = 0
#       source_cidr_ipv4 = var.private_subnet_workload_cidr_a
#     },
#     {
#       protocol         = "-1"
#       port             = 0
#       source_cidr_ipv4 = var.private_subnet_workload_cidr_b
#     },
#     {
#       protocol         = "-1"
#       port             = 0
#       source_cidr_ipv4 = var.private_subnet_workload_cidr_c
#     },
#     {
#       protocol         = "-1"
#       port             = 0
#       source_cidr_ipv4 = var.private_subnet_eks_pod_secondary_cidr
#     },
#   ]
# }