provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  region = "ap-northeast-1"
  alias  = "tokyo"
}

data "terraform_remote_state" "king_vpn" {
  backend = "s3"

  config {
    bucket = "${var.king_vpn_remote_state_s3_bucket_name}"
    key    = "king-vpn/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "aws_region" "current" {}

data "aws_vpc" "target_vpc" {
  id = "${var.vpc_id}"
}

locals {
  king_vpc_cidr_block = "172.29.0.0/16"
}
