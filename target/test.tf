provider "aws" {
  region = "ap-northeast-2"
}

data "terraform_remote_state" "king_vpn" {
  backend = "s3"

  config {
    bucket = "${var.king_vpn_remote_state_s3_bucket_name}"
    key    = "king-vpn/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# Ubuntu Server 16.04 LTS (HVM)
data "aws_ami" "ubuntu_xenial" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_customer_gateway" "king_seoul" {
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

resource "aws_instance" "king_seoul" {
  ami           = "${data.aws_ami.ubuntu_xenial.id}"
  instance_type = "t2.micro"
  key_name      = "${var.seoul_public_key_name}"

  vpc_security_group_ids = [
    "${module.king_gateway.sg_id}",
  ]

  subnet_id = "${module.custom_seoul_vpc.public_common_subnet_id}"

  tags {
    Name = "king-seoul"
  }
}
