resource "aws_route" "target_vpc" {
  route_table_id         = "${var.aws_public_route_table_id}"
  destination_cidr_block = "${local.king_vpc_cidr_block}"
  gateway_id             = "${aws_vpn_gateway.king_swan.id}"
}

resource "aws_route" "king_vpc" {
  provider               = "aws.tokyo"
  route_table_id         = "${data.terraform_remote_state.king_vpn.aws_public_route_table_id}"
  destination_cidr_block = "${data.aws_vpc.target_vpc.cidr_block}"
  network_interface_id   = "${data.terraform_remote_state.king_vpn.king_swan_network_interface_id}"
}
