output "king_vpn_private_ip" {
  value = "${aws_instance.king_vpn.private_ip}"
}

output "aws_public_route_table_id" {
  value = "${module.king_vpc.aws_public_route_table_id}"
}

output "aws_private_route_table_id" {
  value = "${module.king_vpc.aws_private_route_table_id}"
}

output "king_vpc_id" {
  value = "${module.king_vpc.vpc_id}"
}
