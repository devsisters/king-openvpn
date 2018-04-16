data "terraform_remote_state" "king-vpn" {
  backend = "s3"

  config {
    bucket = "${var.king}"
    key    = "king-vpn/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
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

resource "aws_customer_gateway" "king-singapore" {
  provider   = "aws.singapore"
  bgp_asn    = 65000
  ip_address = "${aws_instance.king-swan.public_ip}"
  type       = "ipsec.1"

  tags {
    Name = "king-vpn"
  }
}

module "custom-seoul-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = "aws.seoul"
  }

  name = "king-custom-vpc"

  cidr = "172.16.0.0/16"

  azs            = ["ap-northeast-2a"]
  public_subnets = ["172.16.0.0/18"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "custom-singapore-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = "aws.singapore"
  }

  name = "king-custom-vpc"

  cidr = "172.16.0.0/16"

  azs            = ["ap-southeast-1a"]
  public_subnets = ["172.16.0.0/18"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
