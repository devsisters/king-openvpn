provider "aws" {
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

module "custom_singapore_vpc" {
  source = "git@github.com:devsisters/king-openvpn.git?ref=modules//modules/vpc"

  name       = "king-custom-vpc"
  aws_region = "ap-southeast-1"
  az_main    = "a"
  az_sub     = "c"
  cidr_block = "172.30.0.0/16"
}

module "vpc_peering" {
  source = "git@github.com:devsisters/king-openvpn.git?ref=modules//modules/peering"

  local_vpc_id                 = "${module.custom_singapore_vpc.vpc_id}"
  local_region                 = "ap-southeast-1"
  local_public_route_table_id  = "${module.custom_singapore_vpc.aws_public_route_table_id}"
  local_private_route_table_id = "${module.custom_singapore_vpc.aws_private_route_table_id}"

  remote_vpc_id                 = "${data.terraform_remote_state.king_vpn.king_vpc_id}"
  remote_region                 = "ap-northeast-1"
  remote_public_route_table_id  = "${data.terraform_remote_state.king_vpn.aws_public_route_table_id}"
  remote_private_route_table_id = "${data.terraform_remote_state.king_vpn.aws_private_route_table_id}"
}

resource "aws_instance" "king_singapore" {
  ami           = "${data.aws_ami.ubuntu_xenial.id}"
  instance_type = "t2.micro"
  key_name      = "${var.singapore_public_key_name}"

  vpc_security_group_ids = ["${aws_security_group.king_singapore.id}"]

  subnet_id = "${module.custom_singapore_vpc.public_common_subnet_id}"

  tags {
    Name = "king-singapore"
  }
}

resource "aws_security_group" "king_singapore" {
  name   = "king-singapore"
  vpc_id = "${module.custom_singapore_vpc.vpc_id}"

  # SSH
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${data.terraform_remote_state.king_vpn.king_vpn_private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
