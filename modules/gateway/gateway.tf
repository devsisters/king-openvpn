resource "aws_vpn_gateway" "king-swan" {
  tags {
    Name = "king-swan-vpn-gateway"
  }
}

resource "aws_vpn_gateway_attachment" "king-swan" {
  vpc_id         = "${var.vpc_id}"
  vpn_gateway_id = "${aws_vpn_gateway.king-swan.id}"
}

resource "aws_vpn_connection" "king-swan" {
  vpn_gateway_id = "${aws_vpn_gateway.king-swan.id}"

  customer_gateway_id = "${var.customer_gateway_id}"
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_vpn_connection_route" "king-swan" {
  vpn_connection_id      = "${aws_vpn_connection.king-swan.id}"
  destination_cidr_block = "${local.king_vpc_cidr_block}"
}
