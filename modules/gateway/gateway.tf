resource "aws_vpn_gateway" "king_swan" {
  tags {
    Name = "king-swan-vpn-gateway"
  }
}

resource "aws_vpn_gateway_attachment" "king_swan" {
  vpc_id         = "${var.vpc_id}"
  vpn_gateway_id = "${aws_vpn_gateway.king_swan.id}"
}

resource "aws_vpn_connection" "king_swan" {
  vpn_gateway_id = "${aws_vpn_gateway.king_swan.id}"

  customer_gateway_id = "${var.customer_gateway_id}"
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_vpn_connection_route" "king_swan" {
  vpn_connection_id      = "${aws_vpn_connection.king_swan.id}"
  destination_cidr_block = "${local.king_vpc_cidr_block}"
}
