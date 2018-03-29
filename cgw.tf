# https://registry.terraform.io/modules/terraform-aws-modules/vpn-gateway/aws/1.0.3
# TODO: 이런거 쓸까?

provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

resource "aws_customer_gateway" "king-seoul" {
  provider   = "aws.seoul"
  bgp_asn    = 65000
  ip_address = "${aws_instance.king-swan.public_ip}"
  type       = "ipsec.1"

  tags {
    Name = "king-vpn"
  }
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

resource "aws_customer_gateway" "king-singapore" {
  provider   = "aws.singapore"
  bgp_asn    = 65000
  ip_address = "${aws_instance.king-swan.public_ip}"
  type       = "ipsec.1"

  tags {
    Name = "king-vpn"
  }
}
