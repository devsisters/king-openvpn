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
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = "aws.seoul"
  }

  name = "king-custom-vpc"

  cidr = "172.30.0.0/16"

  azs             = ["ap-northeast-2a"]
  public_subnets  = ["172.30.0.0/17"]
  private_subnets = ["172.30.128.0/17"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "custom_singapore_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = "aws.singapore"
  }

  name = "king-custom-vpc"

  cidr = "172.31.0.0/16"

  azs             = ["ap-southeast-1a"]
  public_subnets  = ["172.31.0.0/17"]
  private_subnets = ["172.31.128.0/17"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
