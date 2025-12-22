# output "subnet" {
#   value = data.aws_route_table.private_route_tables[*].id #data.aws_subnets.private_subnets.ids[0] 
# }

output "route-table" {
  value = local.lc_name_list #data.aws_route_table.private_route_tables[*]
}


output "subnet" {
  value = data.aws_subnets.private_subnets
}