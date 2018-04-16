resource "aws_route" "king-swan" {
  route_table_id         = "${var.aws_public_route_table_id}"
  destination_cidr_block = "${local.king_vpc_cidr_block}"
  gateway_id             = "${aws_vpn_gateway.king-swan.id}"
}

resource "aws_route" "king-vpc" {
  route_table_id         = "${data.terraform_remote_state.king_vpn.aws_public_route_table_id}"
  destination_cidr_block = "${var.vpc_cidr_block}"
  network_interface_id   = "${data.terraform_remote_state.king_vpn.network_interface_id}"
}
