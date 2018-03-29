provider "consul" {
  address    = "${var.consul_address}:8500"
  datacenter = "king"
}

data "aws_iam_account_alias" "current" {}

data "aws_region" "current" {
  current = true
}

data "aws_vpc" "king-vpc" {
  id = "${var.vpc_id}"
}

resource "consul_keys" "king-consul" {
  key {
    # king-swan/ap-northeast-1/test-vpc/vpc-923ksdn3
    path = "king-swan/${data.aws_region.current.name}/${data.aws_vpc.king-vpc.tags["Name"]}/${var.vpc_id}"

    value = <<EOF
{
  "cidr_block": "${data.aws_vpc.king-vpc.cidr_block}",
  "tunnel_ip": "${aws_vpn_connection.king-swan.tunnel1_address}",
  "psk": "${aws_vpn_connection.king-swan.tunnel1_preshared_key}"
}
EOF

    delete = true
  }
}
