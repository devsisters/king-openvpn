output "king_vpn_private_ip" {
  value = "${aws_instance.king_vpn.private_ip}"
}

output "aws_public_route_table_id" {
  value = "${module.king_vpc.aws_public_route_table_id}"
}
