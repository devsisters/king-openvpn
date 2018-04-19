provider "consul" {
  address    = "${var.consul_address}:8500"
  datacenter = "king"
}

resource "consul_keys" "king_consul" {
  key {
    # king-swan/ap-northeast-1/test-vpc/vpc-923ksdn3
    path = "king-swan/${data.aws_region.current.name}/${data.aws_vpc.target_vpc.tags["Name"]}/${var.vpc_id}"

    value = <<EOF
{
  "cidr_block": "${data.aws_vpc.target_vpc.cidr_block}",
  "tunnel_ip": "${aws_vpn_connection.king_swan.tunnel1_address}",
  "psk": "${aws_vpn_connection.king_swan.tunnel1_preshared_key}"
}
EOF

    delete = true
  }
}
