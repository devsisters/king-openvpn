provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

data "terraform_remote_state" "king_vpn" {
  backend = "s3"

  config {
    bucket = "${var.king_vpn_remote_state_s3_bucket_name}"
    key    = "king-vpn/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

resource "aws_customer_gateway" "king_seoul" {
  provider   = "aws.seoul"
  bgp_asn    = 65000
  ip_address = "${data.terraform_remote_state.king_vpn.king_swan_public_ip}"
  type       = "ipsec.1"

  tags {
    Name = "king-vpn"
  }
}

resource "aws_customer_gateway" "king_singapore" {
  provider   = "aws.singapore"
  bgp_asn    = 65000
  ip_address = "${data.terraform_remote_state.king_vpn.king_swan_public_ip}"
  type       = "ipsec.1"

  tags {
    Name = "king-vpn"
  }
}

module "custom_seoul_vpc" {
  source = "git@github.com:devsisters/king-openvpn.git?ref=master//modules/vpc"

  name       = "king-custom-vpc"
  aws_region = "ap-northeast-2"
  az_main    = "a"
  az_sub     = "c"
  cidr_block = "172.30.0.0/16"
}

module "custom_singapore_vpc" {
  source = "git@github.com:devsisters/king-openvpn.git?ref=master//modules/vpc"

  name       = "king-custom-vpc"
  aws_region = "ap-southeast-1"
  az_main    = "a"
  az_sub     = "c"
  cidr_block = "172.31.0.0/16"
}
