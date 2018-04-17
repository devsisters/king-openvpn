provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket  = "<<< YOUR REMOTE STATE S3 BUCKET NAME >>>"
    key     = "king-vpn/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = "true"
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
